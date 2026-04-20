# AI Configuration

Single source of truth for AI rules and skills.

## Structure

```
.ai/
├── rules/    # Conventions (always applied)
└── skills/   # Task procedures (on-demand)
    └── {name}/
        └── SKILL.md
```

**Rules**: git-conventions, typescript-rules, nextjs-rules, unit-testing

**Skills**: do-a-pr, fix-pr-comments, npm-update-dependency, finish-worktree

## Usage

**Claude Code**: `/command-name`

### Rules (auto-applied)

- `typescript-rules` → `*.ts`, `*.tsx`
- `unit-testing` → `*.test.ts`, `*.spec.ts`
- `git-conventions` → all files
- `nextjs-rules` → `app/**`, `components/**`

### Skills (on-demand)

- `do-a-pr` — Create a GitHub pull request
- `fix-pr-comments` — Address unresolved GitHub PR review threads
- `npm-update-dependency` — Update npm packages with quality gates
- `finish-worktree` — Safely clean up a git worktree

## Add New

**Rule**: Create `.ai/rules/name.md`
**Skill**: Create `.ai/skills/name/SKILL.md` + `.claude/commands/name.md`

## Adapters

| Tool        | Rules adapter             | Skills adapter                        |
| ----------- | ------------------------- | ------------------------------------- |
| Claude Code | `CLAUDE.md` (`@` imports) | `.claude/commands/*.md` (`@` imports) |

Edit only `.ai/` files — adapters reference them automatically.
