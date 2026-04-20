# Role

## Purpose

Defines a named permission profile. Every user is assigned exactly one role that determines
which entities they may create, read, update, or deactivate. Roles are seeded by migration at
deployment; no UI for creating custom roles is required in this iteration.

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field         | Type            | Nullable | Description                                                |
| ------------- | --------------- | -------- | ---------------------------------------------------------- |
| `name`        | String (unique) | No       | Machine-readable identifier. E.g. `super_admin`.           |
| `description` | String          | Yes      | Human-readable explanation of the role's permission scope. |

## Seeded Values

| name              | description                                                                    |
| ----------------- | ------------------------------------------------------------------------------ |
| `super_admin`     | Full access to all entities including user and role management.                |
| `account_manager` | Access to clients, employees, and opportunities. Cannot manage users or roles. |

## Rules

- Role `name` MUST be unique.
- Roles are managed by Super Admins only; no self-service role creation or deletion in v1.
- Deleting a role that is assigned to one or more active users MUST be prevented.

## Relationships

- Referenced by [User](/domain/user/user.md) via `role_id`.
