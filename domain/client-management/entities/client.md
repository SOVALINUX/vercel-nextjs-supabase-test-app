# Client

## Purpose

Represents a business organisation being managed within the replenishment system. A client is
the central grouping entity — opportunities are raised against clients, and named users from the
system are assigned as the client's commercial contacts.

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field                | Type            | Nullable | Description                                                   |
| -------------------- | --------------- | -------- | ------------------------------------------------------------- |
| `name`               | String          | No       | Legal or trading name of the client organisation.             |
| `link`               | String (URL)    | Yes      | Website or CRM link. Must be a valid URL if provided.         |
| `sales_executive_id` | UUID → users.id | Yes      | The user acting as sales executive for this client. Optional. |
| `account_manager_id` | UUID → users.id | No       | The user responsible for day-to-day account management.       |

## Join Table — `client_representatives`

Stores the list of account representatives assigned to a client. One client may have multiple
representatives.

| Field       | Type              | Nullable | Description                        |
| ----------- | ----------------- | -------- | ---------------------------------- |
| `client_id` | UUID → clients.id | No       | The client this entry belongs to.  |
| `user_id`   | UUID → users.id   | No       | The user acting as representative. |

The pair `(client_id, user_id)` MUST be unique — the same user cannot be listed twice on the
same client.

## Rules

- `account_manager_id` is mandatory; every client must have a named account manager.
- `sales_executive_id` is optional at creation; it may be assigned or updated later.
- A client MUST have at least zero account representatives (empty list is valid).
- `link` must pass URL format validation if provided; the system does not verify the URL resolves.
- Contacts (`sales_executive_id`, `account_manager_id`, representative `user_id`) MUST
  reference active users. Referencing a deactivated user MUST produce a validation error.

## Relationships

- `sales_executive_id` → [User](/domain/core/entities/user.md) (nullable)
- `account_manager_id` → [User](/domain/core/entities/user.md)
- `client_representatives.user_id` → [User](/domain/core/entities/user.md)
- Referenced by [Opportunity](/domain/staffing/entities/opportunity.md) via `client_id`.
