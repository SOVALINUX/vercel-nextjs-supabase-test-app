# User

## Purpose

Represents an authenticated identity in the system. A user can log in, perform operations
according to their assigned roles, and appear as a named contact on client records (as sales
executive, account manager, or account representative).

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field       | Type            | Nullable | Description                                                        |
| ----------- | --------------- | -------- | ------------------------------------------------------------------ |
| `name`      | String          | No       | Full display name of the user.                                     |
| `email`     | String (unique) | No       | Login email address. Must be unique across all users.              |
| `is_active` | Boolean         | No       | Whether the user can authenticate. Defaults to `true` on creation. |

## Bridge Table — `user_roles`

A user may be assigned multiple roles. Roles are accumulated — the user has all permissions
granted by any of their assigned roles.

| Field     | Type            | Nullable | Description                     |
| --------- | --------------- | -------- | ------------------------------- |
| `user_id` | UUID → users.id | No       | The user being assigned a role. |
| `role_id` | UUID → roles.id | No       | The role being assigned.        |

The pair `(user_id, role_id)` MUST be unique — the same role cannot be assigned to a user twice.

## Rules

- Email MUST be unique. Attempting to create or update a user with a duplicate email MUST
  produce a clear error.
- Every user MUST have at least one role. A user with no roles MUST NOT be able to access any
  protected resource.
- Deactivation (`is_active = false`) is a soft delete. The record is retained for audit
  purposes. A deactivated user MUST NOT be able to authenticate.
- Only a Super Admin may create, update role assignments, or deactivate a user.

## Relationships

- `user_roles.role_id` → [Role](/domain/core/entities/role.md)
- Referenced by [Client](/domain/client-management/entities/client.md) as `sales_executive_id`,
  `account_manager_id`, and in the `client_representatives` join (all optional or role-dependent).
