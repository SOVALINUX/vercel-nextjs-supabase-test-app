---
description: Unit and integration testing conventions
globs:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/*.spec.tsx"
  - "**/__tests__/**"
alwaysApply: false
---

# Unit Testing Guidelines

## Running Tests

- Use `npx jest <filename_pattern> --coverage false` to run tests
- Run tests **module by module** rather than test by test
- Add `--verbose` when debugging failures

```bash
npx jest --testPathPattern="clients.*test"
npx jest src/lib/clients/
npx jest --coverage
```

## Test File Structure

- Test files: `__tests__/*.test.ts` or co-located `*.test.ts` / `*.spec.ts`
- Organised by module/feature area

## Common Patterns

### Imports

Always use ES6 `import` — never `require()`:

```typescript
// ❌
const module = require("./module");
// ✅
import { module } from "./module";
```

### Types in Tests

Never use `as any` or `as never`. Use `as unknown as Type` if casting is unavoidable:

```typescript
// ❌
const config = {} as any;
// ✅
const config = {} as unknown as MyConfig;
```

### Expectations

Prefer single-line expectations with rich matchers over multiple weak assertions:

```typescript
// ❌
expect(result).toContain("foo");
expect(result).toContain("bar");

// ✅
expect(result).toEqual(
  expect.objectContaining({
    foo: expect.any(String),
    bar: "expected value",
  }),
);
```

### Mocking

- Prefer `jest.spyOn` over `(method as unknown as jest.Mock)`
- Declare `jest.mock(...)` at the top of the file, not inside individual tests
- Use clean `jest.requireActual` pattern — no intermediate variables:

```typescript
// ✅
jest.mock("./lib", () => ({
  ...jest.requireActual<typeof import("./lib")>("./lib"),
  myFn: jest.fn(),
}));
```

- Avoid `.mock.calls[]` indexing — use `.toHaveBeenCalledWith()` with `expect.objectContaining()` instead

## Quality Gate

`npm test` MUST pass (all green, no skipped tests without justification) before a PR is created.
