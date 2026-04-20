---
description: TypeScript quality and style conventions
globs:
  - "**/*.ts"
  - "**/*.tsx"
alwaysApply: false
---

# TypeScript Rules

## Quality Gates (run before committing)

```bash
npm run type-check   # must pass
npm run lint         # must pass
npm test             # must pass
```

## Type Safety

- No `any` — use `unknown` + narrowing or proper types
- Use Supabase generated types from `lib/supabase/database.types.ts` for DB row types
- Prefer `type` over `interface` for plain data shapes; use `interface` for extendable contracts

## Imports

Order: external packages → internal `@/` aliases → relative paths. No unused imports.

## Naming

- Components: `PascalCase`
- Hooks: `useCamelCase`
- Utilities / helpers: `camelCase`
- Types: `PascalCase`
