# Git Conventions

## Branch Naming

- `feature/<short-description>` — new features
- `fix/<short-description>` — bug fixes
- `chore/<short-description>` — tooling, deps, config

Never commit directly to `main`.

## Commit Messages

Follow Conventional Commits:
- `feat: <description>`
- `fix: <description>`
- `chore: <description>`
- `refactor: <description>`

## Pull Requests

- PRs target `main`
- Title follows commit convention
- Use `--delete-branch` after merge
