# Domain Model

This folder contains the bounded-context definitions for the Replenishment Management System,
organised following Domain-Driven Design (DDD) principles.

## Structure

```
domain/
├── README.md              ← this file — folder conventions
├── base-entity.md         ← shared audit fields inherited by all entities
├── core/                  ← identity & access management bounded context
│   ├── permission-model.md  ← URN permission scheme, Permission and Group entity definitions
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

- `core/` — the identity and access subdomain (users, roles, permissions, groups, comments).
  Always present.
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

Supplementary reference documents (e.g. `permission-model.md`) may live directly inside a
subdomain folder alongside the `entities/` / `workflows/` / `services/` directories.

### Entity files

- Each entity file describes: purpose, fields, rules, and relationships.
- Relationships use root-relative links: `/domain/<subdomain>/entities/<entity>.md`.
- All entities extend [Base Entity](/domain/base-entity.md) which provides the standard
  system metadata fields: `id`, `_created_by`, `_created_at`, `_updated_by`, `_updated_at`,
  `_deleted`. All system fields except `id` are prefixed with `_`.

### Permission model

The `core/` subdomain owns the permission system. See
[core/permission-model.md](/domain/core/permission-model.md) for the full URN format,
Permission entity, and Group entity definitions. Key points:

- Permissions are URN strings: `urn:<tenant>:<resource-type>:<resource-name>:<resource-path>:<verb>`
- A `!` prefix denotes a deny permission; denies override all allows.
- Roles aggregate permissions; users accumulate roles (many-to-many via `user_roles`).
- Groups aggregate users and can hold permissions; groups can nest and sync from external
  directories (Active Directory, LDAP, SCIM).

### Adding a new subdomain

1. Create `domain/<subdomain-name>/` with `entities/`, `workflows/`, and `services/`
   subdirectories.
2. Add entity files under `entities/`.
3. Reference the new subdomain in `specs/` and update this README.

## Current Subdomains

| Subdomain           | Purpose                                          | Entities / References                           |
| ------------------- | ------------------------------------------------ | ----------------------------------------------- |
| `core`              | Identity, authentication, RBAC, groups, comments | User, Role, Group, Comment; permission-model.md |
| `client-management` | Client records, contacts, and opportunities      | Client, Opportunity                             |
| `staffing`          | Supply-demand matching and staffing workflows    | Employee                                        |
