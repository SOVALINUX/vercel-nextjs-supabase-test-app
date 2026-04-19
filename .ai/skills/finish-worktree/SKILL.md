---
name: finish-worktree
description: Safely clean up and remove a git worktree after work is done — checks for uncommitted changes, unpushed commits, and branch merge status before removing. Use when the user asks to finish, clean up, or remove a worktree.
---

# Finish Worktree

## Process

1. Verify you are inside a git worktree (not the primary repo): `git worktree list`
2. Check for uncommitted changes: `git status`
3. Check for unpushed commits: `git log @{u}..HEAD`
4. Warn and ask for confirmation if uncommitted or unpushed work exists
5. Check if the branch is merged into `main`: `git branch -r --merged origin/main`
6. Warn and ask for confirmation if branch is not yet merged
7. Remove the worktree: `git worktree remove <path>` from the primary repo
8. Show the command to return to the primary repo
