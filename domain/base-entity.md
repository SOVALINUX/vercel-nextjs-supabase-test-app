# Base Entity

## Purpose

Every persistent record in the system extends this base. It provides a uniform audit trail and
primary key contract across all domain entities.

## Fields

| Field        | Type                | Nullable | Description                                                      |
| ------------ | ------------------- | -------- | ---------------------------------------------------------------- |
| `id`         | UUID                | No       | Primary key. Auto-generated on insert.                           |
| `created_by` | UUID → users.id     | No       | The user who created this record. Set on insert, never changed.  |
| `created_at` | Timestamp (with tz) | No       | UTC timestamp of creation. Set on insert, never changed.         |
| `updated_by` | UUID → users.id     | Yes      | The user who performed the last update. Null until first update. |
| `updated_at` | Timestamp (with tz) | Yes      | UTC timestamp of the last update. Null until first update.       |

## Rules

- `id`, `created_by`, and `created_at` are set automatically by the system on record creation.
  They MUST NOT be supplied or overridden by the caller.
- `updated_by` and `updated_at` are set automatically by the system on every update operation.
  They MUST NOT be supplied or overridden by the caller.
- All domain entity tables inherit these fields verbatim — no aliases or renamed columns.
