# Agent Safety & Protection Rules

## Destructive Commands Prevention
To prevent data loss and preserve project integrity, the following commands are **STRICTLY PROHIBITED**:

- `git clean -fdX`: Never use this as it removes untracked and ignored files (like `.env` or build artifacts) that might be critical.
- `git reset --hard`: Never use without explicit user confirmation, as it destroys local changes.
- `rm -rf`: Never use on root directories or without careful scoping.

## Safe Git Workflow
- Always use `git status` to verify the state before any operation.
- Use `git add` specifically for intended files rather than `git add .` when unsure.
- If a cleanup is needed, ask the user for manual intervention or use safer alternatives.
