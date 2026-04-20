# Domain Model

This folder contains the bounded-context definitions for the Replenishment Management System,
organised following Domain-Driven Design (DDD) principles.

## Structure

```
domain/
├── README.md              ← this file — folder conventions
├── base-entity.md         ← shared audit fields inherited by all entities
├── core/                  ← identity & access management bounded context
│   ├── entities/          ← domain entity definitions
│   ├── workflows/         ← multi-step business process definitions
│   └── services/          ← domain service definitions (stateless operations)
├── client-management/     ← client relationship management bounded context
│   ├── entities/
│   ├── workflows/
│   └── services/
└── staffing/              ← supply-demand & staffing bounded context
    ├── entities/
    ├── workflows/
    └── services/
```

## Conventions

### Subdomain folders

- `core/` — the identity and access subdomain (users, roles, permissions). Always present.
- Additional subdomains (e.g. `client-management/`, `staffing/`) group entities and processes
  that share a coherent business language and change together.
- Each subdomain is a **bounded context**: terms defined inside it are precise and may differ
  from the same term in another subdomain.

### Subfolders inside each subdomain

| Folder       | Contents                                                                 |
| ------------ | ------------------------------------------------------------------------ |
| `entities/`  | Entity definition files (`*.md`). One file per entity.                   |
| `workflows/` | Multi-step business process files describing state transitions and flow. |
| `services/`  | Domain service files — stateless operations that span multiple entities. |

### Entity files

- Each entity file describes: purpose, fields, rules, and relationships.
- Relationships use root-relative links: `/domain/<subdomain>/entities/<entity>.md`.
- All entities extend [Base Entity](/domain/base-entity.md) which provides the standard
  system metadata fields: `id`, `created_by`, `created_at`, `updated_by`, `updated_at`.

### Adding a new subdomain

1. Create `domain/<subdomain-name>/` with `entities/`, `workflows/`, and `services/`
   subdirectories.
2. Add entity files under `entities/`.
3. Reference the new subdomain in `specs/` and update this README.

## Current Subdomains

| Subdomain           | Purpose                                       | Entities              |
| ------------------- | --------------------------------------------- | --------------------- |
| `core`              | Identity, authentication, role-based access   | User, Role            |
| `client-management` | Client records and commercial contacts        | Client                |
| `staffing`          | Supply-demand matching and staffing workflows | Employee, Opportunity |
