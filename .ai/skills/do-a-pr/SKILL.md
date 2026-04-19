---
name: do-a-pr
description: Create a GitHub pull request — runs quality gates, commits, pushes, and opens a PR via the gh CLI. Use when the user asks to create a PR, open a pull request, submit code for review, or finalize work with a GitHub PR.
---

# Create Pull Request

## Process

1. **Finalize task**: Review changes, ensure implementation is complete
2. **Quality gates**: Run `npm run type-check`, `npm run lint`, and `npm test` — all must pass
3. **Branch validation**: Verify current branch follows git conventions (`feature/`, `fix/`, `chore/`) — never use `main`
4. **Commit**: Create a commit with a descriptive Conventional Commit message. Never run `git commit` in background — wait for it to complete before pushing.
5. **Push**: Push branch to remote. Verify the branch has commits (`git log --oneline -1`) before pushing.
6. **Create PR**: Use `gh pr create` with title and body.
7. **Share link**: Display the PR URL.

## PR Description Format

**Summary** — what was done (bullet list for multiple changes, paragraph for a single focused change).

**Test plan** — what to check manually or which tests cover it.

Omit **Test plan** if the change is trivial or fully covered by automated tests.

## Create PR Command

```bash
gh pr create \
  --title "<conventional-commit-title>" \
  --body "$(cat <<'EOF'
## Summary
- <change 1>
- <change 2>

## Test plan
- [ ] <manual step or test>
EOF
)" \
  --base main
```

Use `--draft` for work-in-progress PRs.

`gh` authenticates via `GITHUB_TOKEN` or `gh auth login`. Verify with `gh auth status`.
