# User

## Purpose

Represents an authenticated identity in the system. A user can log in, perform operations
according to their assigned role, and appear as a named contact on client records (as sales
executive, account manager, or account representative).

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field       | Type            | Nullable | Description                                                        |
| ----------- | --------------- | -------- | ------------------------------------------------------------------ |
| `name`      | String          | No       | Full display name of the user.                                     |
| `email`     | String (unique) | No       | Login email address. Must be unique across all users.              |
| `role_id`   | UUID → roles.id | No       | The role assigned to this user. Exactly one role per user.         |
| `is_active` | Boolean         | No       | Whether the user can authenticate. Defaults to `true` on creation. |

## Rules

- Email MUST be unique. Attempting to create or update a user with a duplicate email MUST
  produce a clear error.
- Every user MUST have exactly one role at all times. A user without a role MUST NOT be
  able to access any protected resource.
- Deactivation (`is_active = false`) is a soft delete. The record is retained for audit
  purposes. A deactivated user MUST NOT be able to authenticate.
- Only a Super Admin may create, update role assignment, or deactivate a user.

## Relationships

- `role_id` → [Role](/domain/core/entities/role.md)
- Referenced by [Client](/domain/client-management/entities/client.md) as `sales_executive_id`, `account_manager_id`,
  and in the `client_representatives` join (all optional or role-dependent).
