# Permission Model

## Purpose

Defines the resource-based permission system used by the Replenishment Management System.
Permissions are expressed as URNs (Unique Resource Names) modelled after AWS ARN conventions.
This document specifies the URN format, the `Permission` entity, and the `Group` entity used
for permission aggregation and external-directory synchronisation.

---

## URN Format

```
urn:<tenant>:<resource-type>:<resource-name>:<resource-path>:<verb>
```

### Segments

| Segment         | Type   | Description                                                                                                                               |
| --------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `tenant`        | String | Always `main` in this iteration (single-tenant).                                                                                          |
| `resource-type` | Enum   | `data` \| `url` \| `feature`                                                                                                              |
| `resource-name` | String | For `data`: table name (e.g. `employee`, `opportunity`). For `url`: route prefix. For `feature`: feature flag name.                       |
| `resource-path` | String | For `data`: field name or `*` for the whole record. For `url`: sub-path or `*`. For `feature`: sub-feature or `*`.                        |
| `verb`          | String | For `data`: `READ`, `WRITE`, `DELETE`, or custom string. For `url`/`feature`: HTTP method or action name. Wildcard `*` matches all verbs. |

### Wildcards

Any segment may be replaced with `*` to match all values in that position.

**Examples**:

| URN                              | Meaning                                      |
| -------------------------------- | -------------------------------------------- |
| `urn:main:data:employee:*:READ`  | Read any field on the employee table.        |
| `urn:main:data:employee:email:*` | Any verb on the employee email field.        |
| `urn:main:data:*:*:READ`         | Read access to all data resources.           |
| `urn:main:url:/api/admin/*:*`    | All HTTP methods on the /api/admin/ subtree. |
| `urn:main:feature:reporting:*:*` | All actions within the reporting feature.    |

### Deny Prefix

A URN prefixed with `!` is a **deny** permission and overrides any matching allow. Denies from
any source (role or group) take precedence over allows.

**Example**: `!urn:main:data:role:*:DELETE` — deny deletion of role records regardless of other
permissions.

---

## Permission Entity

### Extends

[Base Entity](/domain/base-entity.md)

### Fields

| Field         | Type            | Nullable | Description                                                       |
| ------------- | --------------- | -------- | ----------------------------------------------------------------- |
| `urn`         | String (unique) | No       | The full URN string (with optional `!` deny prefix).              |
| `description` | String          | Yes      | Human-readable explanation of what this permission grants/denies. |

### Rules

- `urn` MUST be unique across all permissions.
- URN format MUST conform to `urn:<tenant>:<resource-type>:<resource-name>:<resource-path>:<verb>`.
- A deny URN (prefixed `!`) takes precedence over any matching allow URN across all evaluated
  roles and groups.
- Permissions are immutable records — changing a URN requires creating a new permission and
  retiring the old one.

---

## Group Entity

### Purpose

Groups aggregate users and can be assigned permissions directly. Groups support nesting (a group
can contain other groups) and can be synchronised from an external directory (e.g. Active
Directory / LDAP) or managed manually.

### Extends

[Base Entity](/domain/base-entity.md)

### Fields

| Field         | Type            | Nullable | Description                                                                                                  |
| ------------- | --------------- | -------- | ------------------------------------------------------------------------------------------------------------ |
| `name`        | String (unique) | No       | Display name of the group. E.g. `engineering-leads`.                                                         |
| `description` | String          | Yes      | Human-readable explanation of the group's membership and purpose.                                            |
| `source`      | Enum            | No       | How membership is managed: `manual` \| `active_directory` \| `ldap` \| `scim`.                               |
| `sync_config` | JSON            | Yes      | Provider-specific synchronisation settings (e.g. AD group DN, SCIM filter). Required when `source ≠ manual`. |
| `is_active`   | Boolean         | No       | Whether the group is active. Defaults to `true`.                                                             |

### Bridge Table — `group_users`

| Field      | Type             | Nullable | Description                        |
| ---------- | ---------------- | -------- | ---------------------------------- |
| `group_id` | UUID → groups.id | No       | The group receiving the member.    |
| `user_id`  | UUID → users.id  | No       | The user being added to the group. |

The pair `(group_id, user_id)` MUST be unique.

### Bridge Table — `group_subgroups`

Groups can nest arbitrarily. Permissions from child groups are inherited by parent groups'
members (additive, bottom-up).

| Field             | Type             | Nullable | Description           |
| ----------------- | ---------------- | -------- | --------------------- |
| `parent_group_id` | UUID → groups.id | No       | The containing group. |
| `child_group_id`  | UUID → groups.id | No       | The nested group.     |

Circular group nesting MUST be prevented at write time.

### Bridge Table — `group_permissions`

| Field           | Type                  | Nullable | Description                                      |
| --------------- | --------------------- | -------- | ------------------------------------------------ |
| `group_id`      | UUID → groups.id      | No       | The group being granted the permission.          |
| `permission_id` | UUID → permissions.id | No       | The permission (URN) being granted to the group. |

### Rules

- Group membership is evaluated at request time; cached evaluation is acceptable with a
  short TTL.
- A user's effective permissions are the union of permissions from all directly assigned roles,
  all directly assigned groups, and all ancestor groups (recursively), with deny URNs applied last.
- External-directory groups (`source ≠ manual`) MUST NOT be edited via UI membership controls;
  only `sync_config` may be updated.
- Deleting a group that has active members MUST be prevented unless force-deleted by Super Admin.

---

## Permission Evaluation Order

1. Collect all permissions from user's roles (via `role_permissions`).
2. Collect all permissions from user's directly assigned groups (via `group_permissions`).
3. Recursively collect permissions from all ancestor groups.
4. Allow URNs are unioned.
5. Deny URNs (`!`-prefixed) from any source override all matching allows.
6. If no permission matches the requested resource+verb, access is **denied by default**.
