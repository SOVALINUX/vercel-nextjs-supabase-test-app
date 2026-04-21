# Quickstart: Clients UI

**Branch**: `002-clients-ui`

## Prerequisites

1. Local Supabase running: `npm run db:start`
2. `.env.local` set up with `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`

## Setup Steps

### 1. Generate database types

```bash
npm run db:types
# Generates lib/supabase/database.types.ts
```

### 2. Install new shadcn/ui components

```bash
npx shadcn@latest add table
npx shadcn@latest add dialog
npx shadcn@latest add form
npx shadcn@latest add select
npx shadcn@latest add sonner
npx shadcn@latest add badge   # only if not already present
```

### 3. Install form validation dependencies

```bash
npm install react-hook-form zod @hookform/resolvers
```

### 4. Run dev server

```bash
npm run dev
```

### 5. Navigate to Clients

Visit http://localhost:3000/protected/clients after logging in.

## Key Files to Implement (in order)

1. `lib/supabase/database.types.ts` — generated in step 1
2. `app/api/clients/route.ts` — GET list + POST create
3. `app/api/clients/[id]/route.ts` — GET single + PATCH update
4. `components/clients/client-form.tsx` — shared create/edit dialog
5. `components/clients/clients-table.tsx` — dashboard table
6. `components/clients/client-profile-card.tsx` — profile read view
7. `app/protected/clients/page.tsx` — dashboard Server Component
8. `app/protected/clients/[id]/page.tsx` — profile Server Component
9. `app/protected/layout.tsx` — add "Clients" nav link

## Verify

- `npm run lint` — zero warnings
- `npm run build` — zero type errors
- Manually test: create client → view in table → click to profile → edit → save
