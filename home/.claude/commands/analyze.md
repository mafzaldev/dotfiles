---
description: Analyze the codebase or a specific area for structure, quality, and issues
argument-hint: [file, folder, or focus like "security" / "performance"]
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git ls-files:*), Bash(cat:*), Bash(find:*)
---

Analyze $ARGUMENTS (if empty, analyze the whole project).

Start by exploring: project structure, entry points, config files, dependencies, and recent git history.

Then report on:

1. **Overview**: what it does, tech stack, architecture, and how the main pieces connect.
2. **Code quality**: duplication, overly complex functions, inconsistent patterns, poor naming, dead code.
3. **Bugs and risks**: likely bugs, unhandled errors, edge cases, race conditions.
4. **Security**: hardcoded secrets, injection risks, unsafe input handling, outdated or vulnerable dependencies.
5. **Performance**: inefficient loops or queries, unnecessary re-renders, memory leaks, missing caching.
6. **Testing**: what's covered, what's missing, and which areas are riskiest without tests.

Finish with a **prioritized action list**: the top 5 fixes ranked by impact vs. effort, with file paths and line numbers.

Do NOT modify any files. Analysis only.
