#!/usr/bin/env bash
# Unit tests for hooks/exit-plan-mode.sh
# Run: ./tests/test-hooks.sh
# Requires: bash, mktemp (no external dependencies)
set -euo pipefail

PASS=0
FAIL=0
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_SCRIPT="$PLUGIN_ROOT/hooks/exit-plan-mode.sh"

pass() { ((PASS++)); printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { ((FAIL++)); printf "  \033[31mFAIL\033[0m %s\n" "$1"; }
section() { printf "\n--- %s ---\n" "$1"; }

# ============================================================
section "Script existence and permissions"
# ============================================================

if [[ -f "$HOOK_SCRIPT" ]]; then
  pass "exit-plan-mode.sh exists"
else
  fail "exit-plan-mode.sh missing"
  printf "\n\033[1m=== Results: %d passed, %d failed ===\033[0m\n" "$PASS" "$FAIL"
  exit 1
fi

if [[ -x "$HOOK_SCRIPT" ]]; then
  pass "exit-plan-mode.sh is executable"
else
  fail "exit-plan-mode.sh is not executable"
fi

# ============================================================
section "Behavior without .preflight/_templates (non-preflight project)"
# ============================================================

# Run from a temp directory without .preflight/
tmpdir=$(mktemp -d)
trap 'command rm -rf "$tmpdir"' EXIT

output=$(cd "$tmpdir" && "$HOOK_SCRIPT" 2>&1)
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
  pass "exits 0 when .preflight/_templates absent"
else
  fail "exits non-zero ($exit_code) when .preflight/_templates absent"
fi

if [[ -z "$output" ]]; then
  pass "no output when .preflight/_templates absent"
else
  fail "unexpected output when .preflight/_templates absent: $output"
fi

# ============================================================
section "Behavior with .preflight/_templates (preflight project)"
# ============================================================

mkdir -p "$tmpdir/.preflight/_templates"
output=$(cd "$tmpdir" && "$HOOK_SCRIPT" 2>&1)
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
  pass "exits 0 when .preflight/_templates present"
else
  fail "exits non-zero ($exit_code) when .preflight/_templates present"
fi

if [[ -n "$output" ]]; then
  pass "produces output when .preflight/_templates present"
else
  fail "no output when .preflight/_templates present"
fi

# Output must be valid JSON
if python3 -c "import json, sys; json.loads(sys.stdin.read())" <<< "$output" 2>/dev/null; then
  pass "output is valid JSON"
else
  fail "output is not valid JSON: $output"
fi

# Output must contain a systemMessage field
if python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
sys.exit(0 if 'systemMessage' in d else 1)
" <<< "$output" 2>/dev/null; then
  pass "output JSON contains systemMessage field"
else
  fail "output JSON missing systemMessage field"
fi

# systemMessage must mention /preflight new
if echo "$output" | grep -q '/preflight new'; then
  pass "systemMessage mentions /preflight new"
else
  fail "systemMessage does not mention /preflight new"
fi

# ============================================================
section "Always exits 0 (never blocks ExitPlanMode)"
# ============================================================

# Test both with and without .preflight/ — already covered above, but be explicit
for scenario in "absent" "present"; do
  if [[ "$scenario" == "absent" ]]; then
    command rm -rf "$tmpdir/.preflight"
    label="without .preflight/"
  else
    mkdir -p "$tmpdir/.preflight/_templates"
    label="with .preflight/"
  fi
  code=$(cd "$tmpdir" && "$HOOK_SCRIPT" >/dev/null 2>&1; echo $?)
  if [[ "$code" -eq 0 ]]; then
    pass "exits 0 ($label)"
  else
    fail "exits non-zero $code ($label)"
  fi
done

# ============================================================
printf "\n\033[1m=== Results: %d passed, %d failed ===\033[0m\n" "$PASS" "$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
