---
description: Supabase database conventions — migrations, RLS, seed, and types
globs:
  - "supabase/**"
  - "lib/supabase/**"
  - "**/*.sql"
alwaysApply: false
---

# Supabase DB Rules

## Migrations

- All schema changes go in `supabase/migrations/` as numbered SQL files (`YYYYMMDDHHmmss_<description>.sql`)
- Create via `npm run db:migrate -- <name>` — never hand-craft the timestamp
- Migrations are append-only: never edit a committed migration; create a new one instead
- Always run `npm run db:reset` locally to verify the full migration stack applies cleanly

## Row Level Security

- RLS MUST be enabled on every table: `alter table public.<t> enable row level security;`
- Define explicit policies for every operation (select, insert, update, delete)
- Use `auth.uid()` for user-scoped policies; never rely on application-layer filtering alone
- Service-role key bypasses RLS — only use server-side for admin operations

## Audit Fields

All tables inherit from the base entity pattern (`domain/base-entity.md`):

```sql
id          uuid primary key default gen_random_uuid(),
created_at  timestamptz not null default now(),
created_by  uuid not null references auth.users (id),
updated_at  timestamptz not null default now(),
updated_by  uuid not null references auth.users (id)
```

Use the shared `public.set_updated_at()` trigger to auto-update `updated_at`.

## Seed Data

- `supabase/seed/seed.sql` is for local dev only — never reference production data
- Seed resolves the test user dynamically from `auth.users` (do not hardcode UUIDs)
- Test user: `dev@example.com` / `password123` (auto-created by `supabase start`)

## TypeScript Types

- Regenerate after every migration: `npm run db:types`
- Commit the updated `lib/supabase/database.types.ts` in the same PR as the migration
- Use generated row types — never hand-write DB shape types

## CI/CD

Migrations deploy automatically on merge to `main` via `.github/workflows/supabase-migrations.yml`.  
Required GitHub secrets: `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_ID`, `SUPABASE_DB_PASSWORD`.
