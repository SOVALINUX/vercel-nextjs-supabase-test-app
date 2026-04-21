# Tasks: Clients UI

**Input**: Design documents from `specs/002-clients-ui/`
**Prerequisites**: plan.md ✅ spec.md ✅ research.md ✅ data-model.md ✅ contracts/ ✅ quickstart.md ✅

**Tests**: No test runner is installed in this project (pre-existing gap noted in plan.md Constitution Check IV). No test tasks are included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Install dependencies and generate types that all subsequent tasks need.

- [x] T001 Generate database types: run `npm run db:types` to create `lib/supabase/database.types.ts`
- [x] T002 Install form dependencies: run `npm install react-hook-form zod @hookform/resolvers`
- [x] T003 [P] Add shadcn/ui `table` component: `npx shadcn@latest add table` (adds `components/ui/table.tsx`)
- [x] T004 [P] Add shadcn/ui `dialog` component: `npx shadcn@latest add dialog` (adds `components/ui/dialog.tsx`)
- [x] T005 [P] Add shadcn/ui `form` component: `npx shadcn@latest add form` (adds `components/ui/form.tsx`)
- [x] T006 [P] Add shadcn/ui `select` component: `npx shadcn@latest add select` (adds `components/ui/select.tsx`)
- [x] T007 [P] Add shadcn/ui `sonner` component: `npx shadcn@latest add sonner` (adds `components/ui/sonner.tsx`)

**Checkpoint**: Types generated and all UI primitives installed — verify `lib/supabase/database.types.ts` exists and `components/ui/` has the new files.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: API Route Handlers and shared form component that all user story phases depend on.

⚠️ **CRITICAL**: No user story work can begin until this phase is complete.

- [x] T008 Create `app/api/clients/route.ts` — `GET` handler: query `public.clients` joining `users` for `account_manager` and `sales_executive`, query `client_representatives` for representatives list, return `ClientWithRelations[]` as `{ data, error }`. Filter `_deleted = false`.
- [x] T009 Create `app/api/clients/route.ts` — `POST` handler (same file as T008): validate request body with Zod `clientFormSchema`, read auth UID from server Supabase client, insert into `public.clients` with `_created_by = auth.uid()`, insert representative rows into `public.client_representatives`, return `{ data, error }` with status 201.
- [x] T010 Create `app/api/clients/[id]/route.ts` — `GET` handler: fetch single client by ID with same joins as T008, return 404 `{ data: null, error: "Client not found" }` if not found.
- [x] T011 Create `app/api/clients/[id]/route.ts` — `PATCH` handler (same file as T010): validate partial body, update `public.clients`, reconcile `client_representatives` diff (delete removed, insert added), set `_updated_by = auth.uid()`, return updated record.
- [x] T012 Create `components/clients/client-form.tsx` — `"use client"` dialog component used for both create and edit: `react-hook-form` + Zod `clientFormSchema`, `<Dialog>` wrapper, fields for name, link, account_manager_id (`<Select>`), sales_executive_id (`<Select>` optional), representative_ids (multi-select with badge removal), submit button, inline validation errors. Accepts `client?: ClientWithRelations`, `users: UserPickerOption[]`, `onSuccess: () => void` props. Calls `POST /api/clients` or `PATCH /api/clients/[id]` depending on whether `client` prop is provided. Shows `toast.success` / `toast.error` on outcome.

**Checkpoint**: Route Handlers return correct JSON for all four operations; form component renders and validates correctly in isolation.

---

## Phase 3: User Story 1 — View Clients Dashboard (Priority: P1) 🎯 MVP

**Goal**: Logged-in user can navigate to `/protected/clients` and see all clients in a table.

**Independent Test**: Navigate to `/protected/clients` after login — table renders with Name, Account Manager, Sales Executive columns; each name is a link.

### Implementation for User Story 1

- [x] T013 [US1] Create `components/clients/clients-table.tsx` — `"use client"` component: receives `clients: ClientWithRelations[]` prop, renders shadcn `<Table>` with columns Name (as `<Link href="/protected/clients/[id]">`), Account Manager, Sales Executive. Empty state row when list is empty.
- [x] T014 [US1] Create `app/protected/clients/page.tsx` — Server Component: fetch `GET /api/clients` using server Supabase client directly (or internal fetch), pass data to `<ClientsTable>`. Include page heading "Clients" and `<ClientForm>` trigger button "New Client" — pass `users` list for the picker (fetched server-side from `public.users` where `_deleted = false AND is_active = true`).
- [x] T015 [US1] Add `<Toaster />` from `sonner` to `app/protected/layout.tsx` so toasts appear across all protected pages.
- [x] T016 [US1] Update `app/protected/layout.tsx` nav: add `<Link href="/protected/clients">Clients</Link>` next to the existing nav links.

**Checkpoint**: Visit `/protected/clients` — "Clients" nav link works, table renders, "New Client" button opens dialog, form validates and submits, new client appears in table.

---

## Phase 4: User Story 2 — View Client Profile (Priority: P2)

**Goal**: Clicking a client name opens `/protected/clients/[id]` showing full client details.

**Independent Test**: Navigate directly to `/protected/clients/[id]` with a known ID — all fields displayed; non-existent ID shows "not found".

### Implementation for User Story 2

- [x] T017 [US2] Create `components/clients/client-profile-card.tsx` — Server Component: receives `client: ClientWithRelations` prop, renders card with: Name, Website Link (anchor if set, "—" if not), Account Manager name, Sales Executive name (or "—"), Representatives list (badges). No interactivity.
- [x] T018 [US2] Create `app/protected/clients/[id]/page.tsx` — Server Component: fetch `GET /api/clients/[id]` (or query Supabase directly), render `<ClientProfileCard>`. If client not found (`data === null`), render a "Client not found" message with a back link to `/protected/clients`.

**Checkpoint**: Click any client name in the dashboard → correct profile loads with all fields; navigate to `/protected/clients/nonexistent-id` → "Client not found" shown.

---

## Phase 5: User Story 3 — Create New Client (Priority: P3)

**Goal**: "New Client" button on dashboard opens form, submitting creates a client that appears in the table.

**Independent Test**: Click "New Client", fill Name + Account Manager, submit — new client row appears in the dashboard table; submitting with empty Name shows inline validation error.

### Implementation for User Story 3

- [x] T019 [US3] Wire `<ClientForm>` in `app/protected/clients/page.tsx`: pass `onSuccess` callback that triggers router refresh (`router.refresh()`) so the table re-fetches and shows the new client without a full page reload. Ensure the dialog closes on success.
- [x] T020 [US3] Add client-side URL validation to `clientFormSchema` in `components/clients/client-form.tsx`: ensure empty string for `link` is treated as `null` (not an invalid URL) before submitting to the API.

**Checkpoint**: End-to-end create flow works: open dialog → fill form → submit → dialog closes → new client visible in table → toast shown.

---

## Phase 6: User Story 4 — Edit Client from Profile (Priority: P4)

**Goal**: "Edit" button on client profile opens the pre-filled form; saving persists changes.

**Independent Test**: Open any client profile, click "Edit", change the name, save — profile page shows updated name; clicking "Cancel" discards the change.

### Implementation for User Story 4

- [x] T021 [US4] Update `app/protected/clients/[id]/page.tsx`: add `<ClientForm>` in edit mode (pass `client` prop pre-populated with current data and `users` list). Add "Edit" button that opens the dialog. On `onSuccess`, call `router.refresh()` to re-fetch updated data.
- [x] T022 [US4] Verify `PATCH /api/clients/[id]` in `app/api/clients/[id]/route.ts` correctly sets `_updated_by = auth.uid()` and reconciles representative changes (confirm T011 handles this edge case: representatives array with no changes causes no DB writes).

**Checkpoint**: Full edit flow: open profile → click Edit → form pre-filled with existing values → change field → save → profile shows new value → toast shown; Cancel closes without changes.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Consistency, error handling, and final QA across all stories.

- [x] T023 [P] Add `loading.tsx` at `app/protected/clients/loading.tsx` — skeleton or spinner shown while dashboard data fetches.
- [x] T024 [P] Add `loading.tsx` at `app/protected/clients/[id]/loading.tsx` — skeleton while profile fetches.
- [x] T025 [P] Add `error.tsx` at `app/protected/clients/error.tsx` — `"use client"` error boundary with retry button for dashboard.
- [x] T026 Audit all Route Handlers for consistent `{ data, error }` response shape and correct HTTP status codes (401 for missing session, 400 for validation, 404 for not found, 403 for RLS/forbidden).
- [x] T027 Run `npm run lint` and fix any ESLint warnings introduced by new files.
- [x] T028 Run `npm run build` and fix any TypeScript errors (zero `any`, zero type errors).
- [ ] T029 Manual QA: follow quickstart.md verification checklist — create → view → edit flow end-to-end; check empty states, not-found page, form validation errors, toast messages.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately; T003–T007 can run in parallel
- **Foundational (Phase 2)**: Depends on Phase 1 completion (types + UI primitives needed) — BLOCKS all user stories
- **User Stories (Phases 3–6)**: All depend on Phase 2 completion
  - US1 (Phase 3) should be completed before US2–US4 as it provides the nav entry point and layout changes
  - US2, US3, US4 can proceed after Phase 2; US3 and US4 depend on the `<ClientForm>` from Phase 2 (T012)
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (P1)**: After Phase 2 — no story dependencies; delivers the dashboard entry point
- **US2 (P2)**: After Phase 2 — no story dependencies; profile page is a standalone route
- **US3 (P3)**: After Phase 2 (needs T012 `<ClientForm>`) — T019 wires into the dashboard built in US1, so US1 should be done first
- **US4 (P4)**: After Phase 2 (needs T012 `<ClientForm>`) — T021 extends the profile page built in US2, so US2 should be done first

### Within Each Phase

- Models/types before services (T001 first in Phase 1)
- Route Handlers (T008–T011) before shared form component (T012) in Phase 2
- API before UI within each story phase

### Parallel Opportunities

- Phase 1: T003, T004, T005, T006, T007 all install different components — fully parallel
- Phase 2: T008+T009 (one file) and T010+T011 (one file) can be written in parallel; T012 depends only on types from T001
- Phase 7: T023, T024, T025 are separate files — fully parallel

---

## Parallel Example: Phase 2 (Foundational)

```text
Parallel group A: app/api/clients/route.ts (T008 + T009)
Parallel group B: app/api/clients/[id]/route.ts (T010 + T011)

Then sequential: components/clients/client-form.tsx (T012) — uses types from T001
```

---

## Implementation Strategy

### MVP (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T007)
2. Complete Phase 2: Foundational (T008–T012)
3. Complete Phase 3: User Story 1 (T013–T016)
4. **STOP and VALIDATE**: Dashboard works end-to-end (nav → table → create)
5. Deploy / demo if ready

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. US1 → dashboard + create (**MVP demo**)
3. US2 → client profile view
4. US3 → wire create form fully (router refresh, edge cases)
5. US4 → edit from profile
6. Polish → loading states, error boundaries, QA

---

## Notes

- [P] tasks touch different files — safe to parallelise
- [Story] labels map each task to a user story for traceability
- No test runner installed; test tasks omitted (Constitution IV pre-existing gap)
- Commit after each phase checkpoint
- `npm run db:types` must re-run any time the schema changes; not expected for this feature
