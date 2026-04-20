# Group

## Purpose

Groups aggregate users and can be assigned permissions directly. Groups support nesting (a group
can contain other groups) and can be synchronised from an external directory (e.g. Active
Directory / LDAP) or managed manually.

A user's effective permissions are the union of permissions from all directly assigned roles,
all directly assigned groups, and all ancestor groups (recursively), with deny URNs applied last.
See [Permission Model](/domain/core/permission-model.md) for the full evaluation rules.

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field         | Type            | Nullable | Description                                                                                                  |
| ------------- | --------------- | -------- | ------------------------------------------------------------------------------------------------------------ |
| `name`        | String (unique) | No       | Display name of the group. E.g. `engineering-leads`.                                                         |
| `description` | String          | Yes      | Human-readable explanation of the group's membership and purpose.                                            |
| `source`      | Enum            | No       | How membership is managed: `manual` \| `active_directory` \| `ldap` \| `scim`.                               |
| `sync_config` | JSON            | Yes      | Provider-specific synchronisation settings (e.g. AD group DN, SCIM filter). Required when `source ≠ manual`. |
| `is_active`   | Boolean         | No       | Whether the group is active. Defaults to `true`.                                                             |

## Bridge Table — `group_users`

| Field      | Type             | Nullable | Description                        |
| ---------- | ---------------- | -------- | ---------------------------------- |
| `group_id` | UUID → groups.id | No       | The group receiving the member.    |
| `user_id`  | UUID → users.id  | No       | The user being added to the group. |

The pair `(group_id, user_id)` MUST be unique.

## Bridge Table — `group_subgroups`

Groups can nest arbitrarily. Permissions from child groups are inherited by parent groups'
members (additive, bottom-up).

| Field             | Type             | Nullable | Description           |
| ----------------- | ---------------- | -------- | --------------------- |
| `parent_group_id` | UUID → groups.id | No       | The containing group. |
| `child_group_id`  | UUID → groups.id | No       | The nested group.     |

Circular group nesting MUST be prevented at write time.

## Bridge Table — `group_permissions`

| Field           | Type                  | Nullable | Description                                      |
| --------------- | --------------------- | -------- | ------------------------------------------------ |
| `group_id`      | UUID → groups.id      | No       | The group being granted the permission.          |
| `permission_id` | UUID → permissions.id | No       | The permission (URN) being granted to the group. |

## Rules

- `name` MUST be unique across all groups.
- External-directory groups (`source ≠ manual`) MUST NOT have membership edited via UI; only
  `sync_config` may be updated.
- Circular nesting MUST be prevented at write time.
- Group membership is evaluated at request time; cached evaluation is acceptable with a short TTL.
- Deleting a group that has active members MUST be prevented unless force-deleted by Super Admin.
- A group with no permissions or members is valid.

## Relationships

- `group_users.user_id` → [User](/domain/core/entities/user.md)
- `group_subgroups` → [Group](/domain/core/entities/group.md) (self-referential)
- `group_permissions.permission_id` → [Permission Model](/domain/core/permission-model.md)
