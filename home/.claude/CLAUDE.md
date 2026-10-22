# Global Instructions

## Communication
- Be concise. Skip preamble and summaries unless I ask.
- If a request is ambiguous, ask one clarifying question before starting big changes.
- When you're unsure about something, say so instead of guessing.

## Git
- NEVER add "Co-Authored-By", "Generated with Claude Code", or any attribution to commits or PRs.
- Use conventional commits: feat:, fix:, refactor:, chore:, docs:, test:
- Make small, focused commits, one logical change each.
- Never force-push, rebase shared branches, or commit to main without asking.

## Code Style
- Match the existing style and patterns of the codebase before introducing new ones.
- Prefer simple, readable code over clever code.
- Don't add new dependencies without asking.
- No leftover debug logs, commented-out code, or TODOs unless I ask.

## Workflow
- Read the relevant code before editing it.
- For non-trivial tasks, outline a short plan first.
- Run tests/linters after changes if the project has them.
- Don't modify files unrelated to the task.
- Never touch .env files or secrets.

## Environment
- OS: Linux
- Package managers: [pnpm / uv]
- Main stack: [e.g. TypeScript, React, Node, Python]
