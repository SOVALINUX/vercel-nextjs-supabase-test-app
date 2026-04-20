# AGENTS.md

Agent guidance for the Replenishment Management System.

## Project

Full-stack training app that served as a prototype and accelerator for the Enterprise-grade replenishment system

## Tech Stack

- **Framework**: Next.js (App Router, TypeScript)
- **Database**: Supabase (Postgres + Auth + Row Level Security)
- **Deployment**: Vercel
- **Styling**: Tailwind CSS + shadcn/ui

## Dev Commands

See package.json for the full list of commands

```bash
npm run dev          # Start dev server (localhost:3000)
npm run build        # Production build
npm run lint         # ESLint check
npm run db:*         # number of Supabase DB commands
```

## Architecture

Next.js App Router (`app/`), shadcn/ui components (`components/`), Supabase clients in `lib/supabase/` (browser: `client.ts`, server: `server.ts`), session refresh middleware at `proxy.ts`. Schema migrations in `supabase/migrations/`, local seed in `supabase/seed/seed.sql`.

See `.ai/rules/nextjs-rules.md` and `.ai/rules/supabase-db-rules.md` for detailed conventions.

## Domain Model

Entity definitions and bounded contexts live in `domain/`. Always consult `domain/` before
designing or specifying entities. When a feature adds or changes an entity, update the
corresponding `domain/<subdomain>/entities/<entity>.md` alongside the migration.

See `domain/README.md` for structure and conventions.

## Speckit Workflow

All features MUST follow the speckit workflow:

```
/speckit-specify → /speckit-plan → /speckit-tasks → /speckit-implement
```

No implementation begins without a committed `specs/<###-name>/spec.md`.  
See `.specify/memory/constitution.md` for the full constitution.

## AI Configuration

Rules and skills live in `.ai/` — single source of truth. Claude Code commands reference them
from `.claude/commands/`.

- **Rules** (`.ai/rules/`): auto-applied by file glob — typescript, nextjs-rules, supabase-db-rules, git-conventions, unit-testing
- **Skills** (`.ai/skills/`): on-demand via `/skill-name` — do-a-pr, fix-pr-comments, npm-update-dependency, finish-worktree

See `.ai/README.md` for details.

## PR / MR Workflow

When working on a PR or MR, **always commit and push at the end** of each work session unless
explicitly told otherwise. Leave the branch in a clean, pushed state.
