# Implementation Plan: Clients UI

**Branch**: `002-clients-ui` | **Date**: 2026-04-21 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/002-clients-ui/spec.md`

## Summary

Add a Clients section to the protected area: a navigation link in the header, a `/protected/clients` dashboard page with a data table and "New Client" button, and a `/protected/clients/[id]` profile page with an inline "Edit" action. The `clients` and `client_representatives` tables already exist in Supabase with RLS policies. Implementation requires generating DB types, adding missing shadcn/ui primitives, building Route Handler API endpoints, and wiring up Server + Client Components following App Router conventions.

## Technical Context

**Language/Version**: TypeScript 5 / Next.js (latest App Router)  
**Primary Dependencies**: Supabase SSR (`@supabase/ssr`, `@supabase/supabase-js`), Tailwind CSS 3, shadcn/ui (Radix UI primitives), lucide-react  
**Storage**: Supabase Postgres — tables `public.clients`, `public.client_representatives`, `public.users` (all exist; no new migration needed)  
**Testing**: No test runner installed in the project (no jest/vitest); see Constitution Check below  
**Target Platform**: Next.js App Router (Vercel / Node.js)  
**Project Type**: Web application  
**Performance Goals**: Dashboard loads in < 2 s under normal conditions  
**Constraints**: No `any` TypeScript; zero ESLint warnings; RLS respected at DB layer; permissions explicitly out of scope  
**Scale/Scope**: Single-tenant app; client table seeded with ~3 records for dev; scalable to hundreds

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

- [x] **I. Spec-Driven** — `specs/002-clients-ui/spec.md` exists on branch `002-clients-ui`
- [x] **II. Type Safety** — plan uses generated `database.types.ts` row types; no `any`; all new entities typed
- [x] **III. Security** — RLS already enabled on `clients` and `client_representatives`; existing policies cover select/insert/update; insert policy enforces `_created_by = auth.uid()` — Route Handler must supply auth UID; permissions explicitly out of scope per spec
- [~] **IV. Test-First** — ⚠️ No test runner (jest/vitest) is installed in this project; unit/integration tests cannot be written without first adding a test framework. This feature will document what tests _would_ be written and leave stubs. Adding a test framework is a separate initiative.
- [x] **V. SDLC** — branch `002-clients-ui` follows project's speckit sequential numbering convention (existing project convention overrides `feature/` prefix for speckit branches); Conventional Commits; PR-only merge
- [x] **VI. Simplicity** — Server Components for data fetching; `"use client"` only for form interactivity; no premature abstractions; no repository pattern; direct Supabase calls in Route Handlers
- [x] **VII. Domain SOT** — `Client` entity defined in `domain/client-management/entities/client.md`; no changes to the entity needed; `client_representatives` is already documented in the same file; no domain file updates required

**Complexity note (IV)**: Constitution IV violation is pre-existing project state (no test tooling), not introduced by this feature.

## Project Structure

### Documentation (this feature)

```text
specs/002-clients-ui/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/           ← Phase 1 output
│   └── clients-api.md
└── tasks.md             ← Phase 2 output (created by /speckit-tasks)
```

### Source Code

```text
app/
└── protected/
    ├── layout.tsx                    ← MODIFY: add "Clients" nav link
    └── clients/
        ├── page.tsx                  ← NEW: Clients dashboard (Server Component)
        └── [id]/
            └── page.tsx              ← NEW: Client profile page (Server Component)

app/api/
└── clients/
    ├── route.ts                      ← NEW: GET (list all), POST (create)
    └── [id]/
        └── route.ts                  ← NEW: GET (single), PATCH (update)

components/
└── clients/
    ├── clients-table.tsx             ← NEW: table with clickable names (Client Component)
    ├── client-form.tsx               ← NEW: create / edit dialog form (Client Component)
    └── client-profile-card.tsx       ← NEW: read-only profile display (Server Component)

lib/supabase/
└── database.types.ts                 ← GENERATE: npm run db:types (does not exist yet)
```

**shadcn/ui components to add** (not yet present in `components/ui/`):

- `table` — clients list
- `dialog` — create/edit modal
- `form` — react-hook-form + Zod wrapper
- `select` — user picker for account_manager / sales_executive
- `sonner` (toast) — success/error notifications

---

## Phase 0: Research

See [research.md](./research.md).

---

## Phase 1: Design & Contracts

See [data-model.md](./data-model.md) and [contracts/clients-api.md](./contracts/clients-api.md).

---

## Complexity Tracking

| Violation              | Why Needed                                           | Simpler Alternative Rejected Because                             |
| ---------------------- | ---------------------------------------------------- | ---------------------------------------------------------------- |
| IV. No test runner     | Test framework not installed; pre-existing gap       | Adding jest/vitest is a separate, larger initiative; out of scope |
