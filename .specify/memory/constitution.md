<!--
SYNC IMPACT REPORT
==================
Version change: 1.1.0 → 2.0.0
Bump rationale: MAJOR — removed Definition of Done and Governance sections; replaced
  duplicated Tech Stack and Domain Model Structure content with references to authoritative
  sources (CLAUDE.md, domain/README.md).
-->

# Replenishment Management System Constitution

**Version**: 2.0.0 | **Ratified**: 2026-04-20 | **Last Amended**: 2026-04-20

---

## Core Principles

### I. Spec-Driven Development

Every feature MUST begin with a written spec before any implementation. AI agents MUST follow
the speckit workflow in order: `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` →
`/speckit-implement`. A feature is not "in progress" until its `specs/<###-name>/spec.md` exists
and is committed.

### II. Type Safety & Code Quality

All TypeScript MUST pass `npm run type-check` (zero errors, no `any`), `npm run lint` (zero
warnings), and `npm test` (all green) before a PR is merged. See `.ai/rules/typescript-rules.md`
and `.ai/rules/unit-testing.md` for conventions.

### III. Security by Default

RLS MUST be enabled on every Supabase table. RBAC permissions MUST be enforced at the database
layer, not only in application code. No secrets in version control. See `.ai/rules/` and
`CLAUDE.md` for implementation conventions.

### IV. Test-First Quality Gate

Unit tests MUST be written before the corresponding implementation (TDD). Integration tests MUST
cover every API route and Supabase query. See `.ai/rules/unit-testing.md`.

### V. Production-Grade SDLC

Branch naming (`feature/`, `task/`), Conventional Commits, PR-only merges to `main`,
pre-commit hooks (lint-staged + prettier). See `.ai/rules/git-conventions.md`.

### VI. Simplicity & No Premature Abstraction

Code solves the current requirement only. Server Components by default; `"use client"` only when
strictly required. See `.ai/rules/nextjs-rules.md`.

---

## References

| Topic              | Authoritative source                         |
| ------------------ | -------------------------------------------- |
| Tech stack & arch  | `CLAUDE.md`                                  |
| Domain model & DDD | `domain/README.md`                           |
| Coding conventions | `.ai/rules/` (typescript, nextjs, git, test) |
| Permission system  | `domain/core/permission-model.md`            |
