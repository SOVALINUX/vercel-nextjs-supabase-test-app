# Next.js Rules

## App Router Conventions

- Server Components by default — add `"use client"` only when browser APIs or React state/effects are needed
- Co-locate data fetching in Server Components; pass data down as props
- Route Handlers (`app/api/**/route.ts`) for API endpoints — use `NextRequest`/`NextResponse`
- Use `loading.tsx` and `error.tsx` for async suspense boundaries

## Supabase Client Usage

- **Client Components**: `createBrowserClient` from `@supabase/ssr`
- **Server Components / Route Handlers**: `createServerClient` with Next.js `cookies()`
- **Admin operations** (skip RLS): server-only `createClient` with `SUPABASE_SERVICE_ROLE_KEY`
- Never import server-only clients in `"use client"` files

## Auth / Middleware

- `middleware.ts` at project root refreshes the Supabase session cookie on every request
- Protected routes redirect to `/login` if session is absent
- Public routes (login, register, landing) must be listed in the middleware matcher exclusions

## Data Mutations

Prefer Route Handlers over Server Actions for explicit REST semantics. Return consistent JSON: `{ data, error }`.

## Performance

- Use `next/image` for all images
- Avoid `useEffect` for data that can be fetched server-side
