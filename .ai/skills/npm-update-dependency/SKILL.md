---
name: npm-update-dependency
description: Update an npm package to the latest or a specific version — installs, verifies types/lint/tests, commits. Use when the user asks to update a dependency, upgrade a package, or bump a library version.
---

# NPM Update Dependency

## Process

1. Ensure everything is committed
2. Run `npm install <package>@latest` (or `@<version>` for a specific version)
3. Verify `package.json` and `package-lock.json` both reflect the new version
4. Run `npm run type-check` — must pass
5. Run `npm run lint` — must pass
6. Run `npm test` — must pass
7. Commit: `chore: update <package> to <version>`
8. Push

## Commands

```bash
npm install <package>@latest
npm outdated          # see what's behind
```
