---
name: fix-pr-comments
description: Address unresolved GitHub PR review comments — fetches open review threads, applies the requested code changes, runs quality gates, commits, and pushes. Use when the user asks to fix PR comments, address review feedback, resolve reviewer notes, fix code review issues, or respond to GitHub PR discussions.
---

# Fix PR Comments

## Process

1. **Check for merge conflicts**: Run `git fetch origin main && git merge --no-commit --no-ff origin/main 2>&1; git merge --abort 2>/dev/null || true`. If output contains "CONFLICT", rebase onto main before proceeding.
2. **Get PR data**: Run `gh pr view --json number,title,body,baseRefName,headRefName` to understand the PR context and intent.
3. **Get unresolved comments**: Run `bash .ai/skills/fix-pr-comments/scripts/get_unresolved_comments.sh`. Pass a PR number or URL as argument to target a specific PR. **Always run this at the start — even if recently invoked, new comments may have appeared since then.**
4. **If no unresolved comments**: Stop — no code changes or commit needed.
5. **Analyze**: Understand each comment and the required change.
6. **Fix**: Apply changes according to project rules (`.ai/rules/`). Make targeted fixes — only change what comments request.
7. **Verify**: Run quality gates (see below). All must pass before committing.
8. **Commit**: Commit with a descriptive message (see format below).
9. **Push**: Push the commit to the branch.
10. **Don't resolve**: Leave threads unresolved — the reviewer resolves their own comments.

## Getting unresolved comments

```bash
bash .ai/skills/fix-pr-comments/scripts/get_unresolved_comments.sh          # auto-detects PR for current branch
bash .ai/skills/fix-pr-comments/scripts/get_unresolved_comments.sh 42       # by PR number
bash .ai/skills/fix-pr-comments/scripts/get_unresolved_comments.sh <PR_URL> # by full URL
```

Output per thread: `thread_id`, `file:line`, `author`, `comment text`, replies.

## Quality Gates

```bash
npm run lint        # ESLint — must pass
npm run build       # Next.js build — must pass (catches type errors)
npm test            # Jest — must pass if tests exist
```

## Commit Format

```
fix: address PR comments - <brief description>

- Fix <specific issue from comment>
- Update <another issue>
```

## Guidelines

- Follow all project rules (`.ai/rules/typescript-rules.md`, `.ai/rules/nextjs-rules.md`, etc.)
- Make targeted fixes — only change what the comment requests
- Group related fixes in a single commit when logical
- If a comment is unclear, ask the user before proceeding
- Never force-push
