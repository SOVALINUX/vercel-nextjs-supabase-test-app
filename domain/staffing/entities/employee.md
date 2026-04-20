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

| Field                | Type                | Nullable | Description                                                                                |
| -------------------- | ------------------- | -------- | ------------------------------------------------------------------------------------------ |
| `first_name`         | String              | No       | Employee's given name.                                                                     |
| `last_name`          | String              | No       | Employee's family name.                                                                    |
| `email`              | String (unique)     | No       | Work email address. Must be unique across all employees.                                   |
| `job_title`          | String              | Yes      | Current job title or position. E.g. "Senior Consultant".                                   |
| `department`         | String              | Yes      | Organisational department. E.g. "Engineering", "Delivery".                                 |
| `is_active`          | Boolean             | No       | Employment status. `true` = active staff, `false` = departed/inactive. Defaults to `true`. |
| `work_start_date`    | Date                | Yes      | The date the employee started working. Optional at creation.                               |
| `work_end_date`      | Date                | Yes      | The date the employee's employment ended. Null for active employees.                       |
| `manager_id`         | UUID → employees.id | Yes      | The direct line manager of this employee. Self-referential FK. Nullable (no manager set).  |
| `employment_type`    | Enum                | No       | Contract basis: `employee` \| `contractor` \| `trainee`. Defaults to `employee`.           |
| `job_function_track` | String              | Yes      | The job function track name. E.g. "Software Engineering", "Delivery Management".           |
| `job_function_name`  | String              | Yes      | The specific role name within the track. E.g. "Backend Engineer".                          |
| `job_function_level` | String              | Yes      | The level within the track. E.g. "Level 3", "A3", "Senior".                                |

## Employment Type Values

| Value        | Description                                       |
| ------------ | ------------------------------------------------- |
| `employee`   | Permanent or fixed-term employed staff member.    |
| `contractor` | External contractor engaged for a defined period. |
| `trainee`    | Trainee or apprentice on a structured programme.  |

## Rules

- Employee `email` MUST be unique. Duplicate emails MUST produce a clear error.
- Deactivation (`is_active = false`) is a soft delete. Records are retained for audit and
  historical matching purposes.
- `work_end_date` MUST NOT be earlier than `work_start_date` if both are provided.
- `manager_id` MUST reference an existing employee; self-referential cycles MUST be prevented.
- Only authenticated users with appropriate permissions (Account Manager or Super Admin) may
  create or update employee records.
- `job_title` and `department` are optional at creation and may be updated at any time.
- `job_function_track`, `job_function_name`, and `job_function_level` are optional and may be
  updated independently.

## Relationships

- `manager_id` → [Employee](/domain/staffing/entities/employee.md) (self-referential, nullable)
- Will be referenced by future Staffing / Assignment entities.
