---
description: Incrementally commit changes as small logical commits, no co-author
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*)
---

Review all current changes with `git status` and `git diff`.

Group them into small, logical commits, one concern per commit. Do not make one big commit.
For each group:
1. Stage only the relevant files or hunks.
2. Write a clear, conventional commit message (e.g. `feat:`, `fix:`, `refactor:`).
3. Commit it.

IMPORTANT: Do NOT add any "Co-Authored-By" trailer, "Generated with Claude Code" line,
or any other attribution to the commit messages.

When finished, show a summary with `git log --oneline` of the new commits.

Extra instructions (if any): $ARGUMENTS
