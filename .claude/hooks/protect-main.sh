#!/bin/bash
# PreToolUse hook: block commits, merges, and pushes on main branch (FR-028)
# Reads tool input from stdin as JSON

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only check Bash tool calls
[ "$TOOL_NAME" = "Bash" ] || exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -n "$COMMAND" ] || exit 0

# Get current branch
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")

# Block git commit on main
if [ "$BRANCH" = "main" ] && echo "$COMMAND" | grep -qE 'git\s+commit'; then
  echo "BLOCKED: Cannot commit directly to main. Use a worktree with a feature branch:" >&2
  echo "  git worktree add .worktrees/<name> -b feature/<name>" >&2
  exit 2
fi

# Block git merge on main
if [ "$BRANCH" = "main" ] && echo "$COMMAND" | grep -qE 'git\s+merge'; then
  echo "BLOCKED: Cannot merge directly to main. Use a PR instead." >&2
  exit 2
fi

# Block git push to main (direct push, not via PR)
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*\bmain\b'; then
  echo "BLOCKED: Cannot push directly to main. Use a feature branch and PR." >&2
  exit 2
fi

exit 0
