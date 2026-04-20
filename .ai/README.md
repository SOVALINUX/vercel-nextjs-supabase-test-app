# AI Configuration

Single source of truth for AI rules and skills.

## Structure

```
.ai/
├── rules/    # Conventions (auto-applied by file glob)
└── skills/   # Task procedures (on-demand)
    └── {name}/
        └── SKILL.md
```

**Rules**: git-conventions, typescript-rules, nextjs-rules, supabase-db-rules, unit-testing

**Skills**: do-a-pr, fix-pr-comments, npm-update-dependency, finish-worktree

## Usage

**Claude Code**: `/command-name`

### Rules (auto-applied by glob)

| Rule                | Applies to                                      |
| ------------------- | ----------------------------------------------- |
| `git-conventions`   | all files (`alwaysApply: true`)                 |
| `typescript-rules`  | `**/*.ts`, `**/*.tsx`                           |
| `nextjs-rules`      | `app/**`, `components/**`, `lib/**`, `proxy.ts` |
| `supabase-db-rules` | `supabase/**`, `lib/supabase/**`, `**/*.sql`    |
| `unit-testing`      | `**/*.test.ts`, `**/*.spec.ts`, `__tests__/**`  |

### Skills (on-demand)

- `do-a-pr` — Create a GitHub pull request
- `fix-pr-comments` — Address unresolved GitHub PR review threads
- `npm-update-dependency` — Update npm packages with quality gates
- `finish-worktree` — Safely clean up a git worktree

## Add New

**Rule**: Create `.ai/rules/name.md` (with YAML frontmatter) + `.claude/rules/name.md` (mirror with `@` import)  
**Skill**: Create `.ai/skills/name/SKILL.md` + `.claude/commands/name.md` (mirror with `@` import)

## Adapters

| Tool        | Rules adapter        | Skills adapter                        |
| ----------- | -------------------- | ------------------------------------- |
| Claude Code | `.claude/rules/*.md` | `.claude/commands/*.md` (`@` imports) |

Edit only `.ai/` files — `.claude/` adapters reference them via `@` imports.
