# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A training/learning project for building full-stack apps with **React + Next.js (App Router) + Supabase Postgres + Vercel**. Entities include: users, clients, projects, employees. Covers UI management and REST/RPC API layers.

## Tech Stack

- **Framework**: Next.js (App Router, TypeScript)
- **Database**: Supabase (Postgres + Auth + Row Level Security)
- **Deployment**: Vercel
- **Styling**: Tailwind CSS (expected)

## Dev Commands

```bash
npm run dev     # Start Next.js dev server (localhost:3000)
npm run build   # Production build
npm run lint    # ESLint check
```

## Architecture

### App Router layout

```
app/
  layout.tsx              # Root layout — ThemeProvider + Geist font
  page.tsx                # Home page — tutorial/onboarding UI
  globals.css             # Tailwind base + CSS vars for theming
  auth/
    confirm/route.ts      # OTP email verification route handler
    error/page.tsx        # Auth error display
    login/page.tsx
    sign-up/page.tsx
    sign-up-success/page.tsx
    forgot-password/page.tsx
    update-password/page.tsx
  protected/
    layout.tsx            # Nav + footer shell for authenticated pages
    page.tsx              # Shows user claims; redirects if unauthenticated

components/
  ui/                     # shadcn/ui primitives (badge, button, card, etc.)
  tutorial/               # Onboarding step components (can be deleted)
  auth-button.tsx         # Server component: shows user email + logout, or sign-in/sign-up links
  login-form.tsx          # "use client" form → supabase.auth.signInWithPassword
  sign-up-form.tsx        # "use client" form → supabase.auth.signUp
  forgot-password-form.tsx
  update-password-form.tsx
  logout-button.tsx       # "use client" → supabase.auth.signOut
  theme-switcher.tsx      # light/dark/system dropdown

lib/
  supabase/
    client.ts             # createBrowserClient (use in "use client" components)
    server.ts             # createServerClient with cookies() (Server Components, Route Handlers)
    proxy.ts              # updateSession() — called from proxy.ts middleware
  utils.ts                # cn() helper + hasEnvVars check

proxy.ts                  # Next.js middleware — refreshes Supabase session on every request
```

### Supabase client rules

- `lib/supabase/client.ts` — browser only (`"use client"` files)
- `lib/supabase/server.ts` — server only (Server Components, Route Handlers, middleware); create a new instance per request/function, never store in a global
- The env var name is `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (not `ANON_KEY`)

### Auth flow

`proxy.ts` (middleware) calls `updateSession()` on every request to refresh the JWT. Unauthenticated requests to non-`/auth` paths are redirected to `/auth/login`. Email confirmation goes through `app/auth/confirm/route.ts` which calls `supabase.auth.verifyOtp()`.

### Theming

CSS variables in `app/globals.css` drive all colors. `tailwind.config.ts` maps them to Tailwind utility names. Dark mode is class-based via `next-themes`.

## Environment Variables

```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=
```

## AI Configuration

Rules and skills live in `.ai/` — the single source of truth. Claude Code commands reference them from `.claude/commands/`.

- **Rules** (`.ai/rules/`): conventions always in effect
- **Skills** (`.ai/skills/`): on-demand task procedures, invoke via `/skill-name`

@.ai/README.md
