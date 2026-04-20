<!--
SYNC IMPACT REPORT
==================
Version change: 0.0.0 (template) → 1.0.0
Bump rationale: MAJOR — first concrete adoption; all placeholders replaced with project-specific
  governance.

Modified principles:
  [PRINCIPLE_1_NAME] → I. Spec-Driven Development
  [PRINCIPLE_2_NAME] → II. Type Safety & Code Quality
  [PRINCIPLE_3_NAME] → III. Security by Default
  [PRINCIPLE_4_NAME] → IV. Test-First Quality Gate
  [PRINCIPLE_5_NAME] → V. Production-Grade SDLC
  [PRINCIPLE_6_NAME] → VI. Simplicity & No Premature Abstraction (added)

Added sections:
  - "Tech Stack Constraints" (replaces generic [SECTION_2_NAME])
  - "Definition of Done" (replaces generic [SECTION_3_NAME])

Removed sections: none

Templates requiring updates:
  ✅ .specify/templates/plan-template.md — Constitution Check gates now reference
     named principles (I–VI) and this project's tech stack context.
  ✅ .specify/templates/spec-template.md — no structural change needed; template
     already supports DoD via Success Criteria section.
  ✅ .specify/templates/tasks-template.md — task phases already reflect
     test-first and security patterns; no structural change needed.

Deferred TODOs: none
-->

# Replenishment Management System Constitution

## Core Principles

### I. Spec-Driven Development

Every feature MUST begin with a written specification (`spec.md`) before any
implementation starts. The spec defines user scenarios, acceptance criteria,
and key entities. AI agents MUST follow the speckit workflow in order:
`/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`.

Skipping the spec phase is not permitted. A feature is not "in progress" until
its `specs/<###-feature-name>/spec.md` exists and is committed.

### II. Type Safety & Code Quality

All TypeScript code MUST satisfy the following gates before a PR can be merged:

- `npm run type-check` — zero errors; no `any` types permitted
- `npm run lint` — zero ESLint warnings/errors
- `npm test` — all tests green

Types for database rows MUST come from `types/supabase.ts` (Supabase generated
types). Imports are ordered: external packages → `@/` aliases → relative paths.
Naming: `PascalCase` components, `useCamelCase` hooks, `camelCase` utilities.

### III. Security by Default

Authentication and authorisation are non-negotiable in every feature that
touches data:

- Supabase Row Level Security (RLS) MUST be enabled on every table.
- Role-based access control (RBAC) and granular permissions MUST be enforced
  at the database layer (RLS policies), not only at the UI layer.
- The server-only Supabase client (`lib/supabase/server.ts`) MUST never be
  imported in `"use client"` files.
- The `SUPABASE_SERVICE_ROLE_KEY` (admin/bypass-RLS) MUST only be used in
  server-side code for explicitly justified administrative operations.
- Auth session refresh MUST run through the `proxy.ts` middleware on every
  request.
- No secrets or tokens may be committed to version control.

### IV. Test-First Quality Gate

Tests are a first-class deliverable, not an afterthought:

- Unit tests MUST be written (and failing) before the corresponding
  implementation is written (TDD, Red-Green-Refactor).
- Integration tests MUST cover every API route handler and Supabase query.
- The test suite MUST pass (`npm test`) before a PR is created.
- Test files live alongside source under `__tests__/` or co-located as
  `*.test.ts` / `*.spec.ts`.

### V. Production-Grade SDLC

Even as a training project this codebase operates under production-grade
process discipline:

- **Branches**: `feature/<desc>`, `fix/<desc>`, `chore/<desc>` — never commit
  directly to `main`.
- **Commits**: Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`).
- **PRs**: Every change enters `main` via a pull request; pre-commit hooks
  (lint-staged + prettier) MUST pass.
- **Release notes**: Required for user-facing features and breaking changes.
- **Deployment**: Vercel; environment variables managed via Vercel dashboard or
  `vercel env`; never hard-coded.

### VI. Simplicity & No Premature Abstraction

Code MUST solve the current requirement, not hypothetical future ones:

- Three similar lines are preferable to a premature helper.
- No half-finished abstractions or feature flags for scenarios that do not
  exist yet.
- Server Components by default; `"use client"` only when browser APIs or
  React state/effects are strictly required.
- Route Handlers (`app/api/**/route.ts`) for API endpoints returning
  `{ data, error }` JSON — prefer over Server Actions for explicit REST
  semantics.
- Comments only when the WHY is non-obvious; never describe what the code does.

## Tech Stack Constraints

**Framework**: Next.js (App Router, TypeScript strict mode)
**Database**: Supabase Postgres — Auth, RLS, and generated TypeScript types
**Deployment**: Vercel (Fluid Compute, Node.js 22+)
**Styling**: Tailwind CSS with shadcn/ui primitives
**State / Data**: Server Components for data fetching; client state minimal
**Testing**: Jest (unit + integration); `npm test` in CI
**Code Quality**: ESLint (`eslint-config-next`), Prettier, TypeScript strict
**AI Tooling**: spec-kit speckit workflow; `.ai/rules/` conventions auto-applied

All third-party libraries MUST be added to `dependencies` (runtime) or
`devDependencies` (build/test only) with pinned semantic versions. No `@anywhere`
scoped packages.

**Domain entities (core)**:

- `Client` — organisation contracting work
- `Project` — engagement scoped to a client
- `Employee` — internal staff resource
- `Staffing` / `Assignment` — employee-to-project allocation
- `SupplyDemand` — replenishment matching: open demand vs. available supply
- `Role` / `Permission` — RBAC model

## Definition of Done

A feature is **Done** when ALL of the following are true:

1. `spec.md` committed under `specs/<###-feature-name>/`
2. Implementation merged to `main` via PR
3. `npm run type-check` passes (zero errors)
4. `npm run lint` passes (zero warnings)
5. `npm test` passes (all tests green, no skipped tests without justification)
6. RLS policies in place for any new or modified table
7. Release notes entry committed if the change is user-facing or a breaking
   change
8. PR description includes Summary and Test Plan sections

## Governance

This constitution supersedes all other informal practices. Amendments follow
this process:

1. **Propose**: Open a PR modifying `.specify/memory/constitution.md` with a
   clear rationale in the PR description.
2. **Version**: Bump `CONSTITUTION_VERSION` per semantic versioning:
   - MAJOR — principle removal or backward-incompatible redefinition
   - MINOR — new principle or section added
   - PATCH — wording clarification, typo fix
3. **Review**: At least one approving review required before merge.
4. **Propagate**: Update `.specify/templates/` files if constitution changes
   affect plan/spec/task structure.
5. **Compliance**: Every PR author is responsible for verifying their changes
   comply with the current constitution before requesting review.

Use `CLAUDE.md` and `.ai/rules/` for runtime development guidance. The
constitution governs principles; the rules files govern day-to-day conventions.

**Version**: 1.0.0 | **Ratified**: 2026-04-20 | **Last Amended**: 2026-04-20
