# Opportunity

## Purpose

Represents an open demand item raised by a client. An opportunity captures the need for
a specific skill or role, the required headcount, a target start date, and its current
fulfilment status. It is the demand side of the replenishment model and drives the
supply-demand matching workflow.

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field               | Type              | Nullable | Description                                                             |
| ------------------- | ----------------- | -------- | ----------------------------------------------------------------------- |
| `title`             | String            | No       | Short descriptive title for the opportunity. E.g. "Q3 Java Engineers".  |
| `client_id`         | UUID → clients.id | No       | The client this opportunity belongs to.                                 |
| `role_needed`       | String            | No       | The role or skill profile being sought. E.g. "Senior Java Developer".   |
| `quantity`          | Integer           | No       | Number of positions to fill. Must be ≥ 1.                               |
| `target_start_date` | Date              | Yes      | Desired start date for the placement. Optional at creation.             |
| `status`            | Enum              | No       | Current fulfilment state (see Status Values below). Defaults to `open`. |

## Status Values

| Value         | Meaning                                             |
| ------------- | --------------------------------------------------- |
| `open`        | Demand raised; no matching or staffing started yet. |
| `in_progress` | Matching or staffing activity is actively underway. |
| `closed`      | Demand fulfilled; all positions placed.             |
| `cancelled`   | Demand withdrawn by the client before fulfilment.   |

## Rules

- `client_id` MUST reference an existing, active client. Linking to an inactive client MUST
  produce a validation error.
- `quantity` MUST be a positive integer (≥ 1).
- `status` follows a forward-only progression in normal flow:
  `open` → `in_progress` → `closed` or `cancelled`. Reverting to an earlier status is not
  permitted without Super Admin override.
- `title` and `role_needed` MUST NOT be empty strings.
- Only authenticated users with appropriate permissions (Account Manager or Super Admin) may
  create or update opportunities.
- Closing or cancelling an opportunity does not delete it — the record is retained for
  reporting and audit.

## Relationships

- `client_id` → [Client](/domain/client-management/entities/client.md)
- Will be referenced by future Staffing / Assignment entities.
