# Comment

## Purpose

Represents a user-authored note attached to any entity in the system (e.g. project, client,
opportunity). Comments provide a lightweight audit and communication layer — capturing who said
what, when, and on which record — without requiring a separate per-entity comment table.

## Extends

[Base Entity](/domain/base-entity.md)

## Fields

| Field         | Type            | Nullable | Description                                                                  |
| ------------- | --------------- | -------- | ---------------------------------------------------------------------------- |
| `body`        | String          | No       | The comment text. MUST NOT be empty.                                         |
| `author_id`   | UUID → users.id | No       | The user who wrote the comment. Set on creation; never changed.              |
| `entity_type` | String          | No       | The type name of the target entity. E.g. `client`, `opportunity`, `project`. |
| `entity_id`   | UUID            | No       | The primary key of the target entity record.                                 |
| `visibility`  | Enum            | No       | Who can read this comment: `public` \| `restricted`. Defaults to `public`.   |

## Visibility Rules

| Value        | Description                                                               |
| ------------ | ------------------------------------------------------------------------- |
| `public`     | Visible to all authenticated users with read access to the parent entity. |
| `restricted` | Visible only to users with the `super_admin` role or the comment author.  |

## Rules

- `body` MUST NOT be empty or whitespace-only.
- `author_id` is set automatically from the authenticated session; callers MUST NOT supply it.
- `entity_type` and `entity_id` together form a polymorphic reference. The referenced entity
  MUST exist and MUST NOT be hard-deleted at comment creation time.
- Comments are immutable after creation — edits are not supported in v1. Deletion is a soft
  delete via `_deleted = true`.
- A user may only delete their own comments; Super Admins may delete any comment.
- Restricted comments MUST NOT appear in list responses for users who are not the author or a
  Super Admin.

## Relationships

- `author_id` → [User](/domain/core/entities/user.md)
- Polymorphic: `entity_type` + `entity_id` → any entity (Client, Opportunity, Project, Employee, etc.)
