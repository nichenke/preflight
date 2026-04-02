# Git workflow

Use worktrees with feature branches for all changes — `git worktree add .worktrees/<name> -b feature/<name>`.

Commits, merges, and pushes to main are blocked by hook (FR-028). If blocked, create a worktree first.
