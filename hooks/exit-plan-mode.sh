#!/usr/bin/env bash
# PreToolUse hook for ExitPlanMode
# Suggests preflight doc formats when exiting plan mode in a scaffolded project.
# Never blocks ExitPlanMode — always exits 0.
set -euo pipefail

# Only activate in preflight-scaffolded projects
if [[ ! -d ".preflight/_templates" ]]; then
  exit 0
fi

echo '{"systemMessage": "This project uses preflight for spec-driven development. Consider capturing this plan as a structured document:\n- /preflight new rfc \u2014 for proposals with alternatives to evaluate\n- /preflight new adr \u2014 for decisions already made\n- /preflight new requirements \u2014 for defining what to build\n- /preflight new architecture \u2014 for system design\n\nRun /preflight new <type> to create a properly structured document."}'
