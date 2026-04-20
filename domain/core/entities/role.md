# Role

## Purpose

Defines a named permission profile. A role aggregates a set of permissions that determine which
resources a user may access and what operations they may perform. Users are assigned one or more
roles (via the `user_roles` bridge table); their effective permissions are the union of all
permissions from all assigned roles.

Roles are seeded by migration at deployment; no UI for creating custom roles is required in this
iteration.

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field         | Type            | Nullable | Description                                                |
| ------------- | --------------- | -------- | ---------------------------------------------------------- |
| `name`        | String (unique) | No       | Machine-readable identifier. E.g. `super_admin`.           |
| `description` | String          | Yes      | Human-readable explanation of the role's permission scope. |

## Bridge Table — `role_permissions`

A role may be assigned multiple permissions (URN-based, see
[Permission Model](/domain/core/permission-model.md)).

| Field           | Type                  | Nullable | Description                                     |
| --------------- | --------------------- | -------- | ----------------------------------------------- |
| `role_id`       | UUID → roles.id       | No       | The role being granted the permission.          |
| `permission_id` | UUID → permissions.id | No       | The permission (URN) being granted to the role. |

The pair `(role_id, permission_id)` MUST be unique.

## Seeded Values

| name              | description                                                                    |
| ----------------- | ------------------------------------------------------------------------------ |
| `super_admin`     | Full access to all entities including user and role management.                |
| `account_manager` | Access to clients, employees, and opportunities. Cannot manage users or roles. |

## Rules

- Role `name` MUST be unique.
- Roles are managed by Super Admins only; no self-service role creation or deletion in v1.
- Deleting a role that is assigned to one or more active users MUST be prevented.
- A role with no permissions is valid (zero-permission role).

## Relationships

- Referenced by [User](/domain/core/entities/user.md) via `user_roles` bridge table.
- `role_permissions.permission_id` → [Permission Model](/domain/core/permission-model.md)
- Referenced by [Group](/domain/core/entities/group.md) via `group_permissions` bridge table.
