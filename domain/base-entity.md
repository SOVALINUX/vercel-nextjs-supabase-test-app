# Base Entity

## Purpose

Every persistent record in the system extends this base. It provides a uniform audit trail and
primary key contract across all domain entities.

## Fields

| Field         | Type                | Nullable | Description                                                                                                       |
| ------------- | ------------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| `id`          | UUID                | No       | Primary key. Auto-generated on insert.                                                                            |
| `_created_by` | UUID → users.id     | No       | The user who created this record. Set on insert, never changed.                                                   |
| `_created_at` | Timestamp (with tz) | No       | UTC timestamp of creation. Set on insert, never changed.                                                          |
| `_updated_by` | UUID → users.id     | Yes      | The user who performed the last update. Null until first update.                                                  |
| `_updated_at` | Timestamp (with tz) | Yes      | UTC timestamp of the last update. Null until first update.                                                        |
| `_deleted`    | Boolean             | No       | Soft-delete flag. `true` = logically deleted. Defaults to `false`. Active queries MUST filter `_deleted = false`. |

## Rules

- `id`, `_created_by`, and `_created_at` are set automatically by the system on record creation.
  They MUST NOT be supplied or overridden by the caller.
- `_updated_by` and `_updated_at` are set automatically by the system on every update operation.
  They MUST NOT be supplied or overridden by the caller.
- `_deleted` is set to `false` on creation. Hard deletes are not permitted; set `_deleted = true`
  to logically remove a record.
- All domain entity tables inherit these fields verbatim — no aliases or renamed columns.
- System fields (all `_`-prefixed) are reserved for the platform layer and MUST NOT be used as
  regular application fields.
