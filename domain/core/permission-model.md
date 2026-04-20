# Permission Model

## Purpose

Defines the resource-based permission system used by the Replenishment Management System.
Permissions are expressed as URNs (Unique Resource Names) modelled after AWS ARN conventions.

---

## Entity Overview

The following entities together form the permission system. Full field and rule definitions
live in the `entities/` folder:

| Entity         | File                                   | Role in permission system                                     |
| -------------- | -------------------------------------- | ------------------------------------------------------------- |
| **User**       | [entities/user.md](entities/user.md)   | Principal. Accumulates roles and group memberships.           |
| **Role**       | [entities/role.md](entities/role.md)   | Named permission profile. Assigned to users via `user_roles`. |
| **Group**      | [entities/group.md](entities/group.md) | User collection. Can hold permissions and nest other groups.  |
| **Permission** | _(defined below)_                      | A single URN grant or deny assigned to a role or group.       |

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

## Permission Evaluation Order

1. Collect all permissions from the user's roles (via `role_permissions`).
2. Collect all permissions from the user's directly assigned groups (via `group_permissions`).
3. Recursively collect permissions from all ancestor groups.
4. Union all allow URNs.
5. Apply deny URNs (`!`-prefixed) from any source — these override all matching allows.
6. If no permission matches the requested resource+verb, access is **denied by default**.
