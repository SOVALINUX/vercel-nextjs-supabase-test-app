# Employee

## Purpose

Represents an internal staff member available for staffing assignments and supply-demand
matching. An employee is the supply side of the replenishment model — their skills, availability,
and status are matched against open opportunities.

An employee is distinct from a user: an employee may or may not have a corresponding user account
in the system.

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field        | Type            | Nullable | Description                                                                                |
| ------------ | --------------- | -------- | ------------------------------------------------------------------------------------------ |
| `first_name` | String          | No       | Employee's given name.                                                                     |
| `last_name`  | String          | No       | Employee's family name.                                                                    |
| `email`      | String (unique) | No       | Work email address. Must be unique across all employees.                                   |
| `job_title`  | String          | Yes      | Current job title or position. E.g. "Senior Consultant".                                   |
| `department` | String          | Yes      | Organisational department. E.g. "Engineering", "Delivery".                                 |
| `is_active`  | Boolean         | No       | Employment status. `true` = active staff, `false` = departed/inactive. Defaults to `true`. |

## Rules

- Employee `email` MUST be unique. Duplicate emails MUST produce a clear error.
- Deactivation (`is_active = false`) is a soft delete. Records are retained for audit and
  historical matching purposes.
- Only authenticated users with appropriate permissions (Account Manager or Super Admin) may
  create or update employee records.
- `job_title` and `department` are optional at creation and may be updated at any time.

## Relationships

- No direct foreign keys to other entities in this iteration.
- Will be referenced by future Staffing / Assignment entities.
