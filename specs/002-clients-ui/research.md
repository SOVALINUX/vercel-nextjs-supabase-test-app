# Research: Clients UI

**Branch**: `002-clients-ui` | **Date**: 2026-04-21

## Decision Log

### R-001: Database types

**Decision**: Run `npm run db:types` before writing any TypeScript to generate `lib/supabase/database.types.ts`. Use the generated `Database["public"]["Tables"]["clients"]["Row"]` and related types throughout. Never hand-write DB shapes.

**Rationale**: The `clients` and `client_representatives` tables exist; types just haven't been generated yet (file absent). Supabase CLI is in devDependencies.

**Alternatives considered**: Hand-writing types — rejected because they diverge from schema over time and violate Constitution II.

---

### R-002: API layer — Route Handlers vs Server Actions

**Decision**: Route Handlers (`app/api/clients/route.ts`, `app/api/clients/[id]/route.ts`) for create, update, and fetch operations.

**Rationale**: The `.ai/rules/nextjs-rules.md` explicitly prefers Route Handlers over Server Actions for explicit REST semantics. They are also easier to test in isolation and integrate naturally with `fetch` calls from Client Components.

**Alternatives considered**: Server Actions — rejected per project rule; direct Supabase calls in Client Components — rejected because it exposes service-role concerns and bypasses auth middleware.

---

### R-003: Form management

**Decision**: Use `react-hook-form` with `zod` for client-side form validation in the create/edit dialog.

**Rationale**: Standard practice for Next.js + shadcn/ui forms. shadcn/ui `form` component wraps react-hook-form. Enables type-safe schema validation without extra dependencies beyond what shadcn adds.

**Alternatives considered**: Uncontrolled forms with FormData — simpler but provides no inline validation UX; native HTML5 validation — insufficient for async field validation and custom error messages.

**Note**: `react-hook-form` and `zod` will need to be added as dependencies.

---

### R-004: User picker for account_manager / sales_executive

**Decision**: Load the full `public.users` list once on dashboard page load (server-side), pass as props to the dialog form, and render as a `<Select>` with the user's `name` as the label and `id` as the value.

**Rationale**: The users table is expected to be small (internal team). Pre-fetching server-side avoids client-side round-trips on form open. No autocomplete/search needed at this scale.

**Alternatives considered**: Combobox with search — rejected as premature; fetching on form open — rejected as adds latency without benefit for small lists.

---

### R-005: Representatives management in edit form

**Decision**: In the edit form, display current representatives as a removable list (badges with ×), plus an "Add representative" picker from the same users list. Deletions and insertions are sent as arrays in the PATCH body; the Route Handler diffs and reconciles the `client_representatives` join table.

**Rationale**: The spec requires editing representatives from the profile page. A diff-and-reconcile approach in the Route Handler keeps the client payload simple (just the desired final state) while making the DB mutations easy to reason about.

**Alternatives considered**: Individual add/remove API calls per representative — more complex client-side coordination; no representative editing — rejected since spec explicitly includes it.

---

### R-006: Toast notifications

**Decision**: Add the `sonner` package for toast notifications. Use `<Toaster />` in the protected layout and `toast.success()` / `toast.error()` in Client Components after mutations.

**Rationale**: `sonner` is the shadcn/ui recommended toast package. Consistent with shadcn tooling already in the project.

**Alternatives considered**: Browser `alert()` — not production-grade; custom toast state — unnecessary complexity.

---

### R-007: shadcn/ui missing components

**Decision**: Add the following via `npx shadcn@latest add <component>`: `table`, `dialog`, `form`, `select`, `sonner`. Also add `badge` if not present (already present per file listing). Add `@radix-ui/react-dialog`, `@radix-ui/react-select` as Radix primitives are installed by the `add` commands automatically.

**Rationale**: The project already uses shadcn/ui. All new UI should use the same primitive system for visual consistency and to avoid reimplementing accessibility.

**Alternatives considered**: Plain HTML table / modal — rejected, inconsistent styling and missing accessibility.

---

### R-008: No new DB migration needed

**Decision**: No new migration. The `clients` and `client_representatives` tables with RLS policies already exist in `20260420000006_client_management.sql`.

**Rationale**: The spec notes permissions are out of scope. RLS is already configured. No schema changes required.

**Alternatives considered**: Adding a migration for any schema extension — not needed for this feature.

---

### R-009: Insert `_created_by` enforcement

**Decision**: The Route Handler for POST `/api/clients` reads `auth.uid()` from the Supabase server client session and sets `_created_by` to the authenticated user's ID before inserting. The DB RLS policy `_created_by = auth.uid()` validates this.

**Rationale**: The insert RLS policy requires `_created_by = auth.uid()`. The server-side Supabase client has access to the session cookie.

**Alternatives considered**: Let the DB default populate `_created_by` — not possible; it has no default and requires an explicit value.
