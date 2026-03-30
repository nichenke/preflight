#!/usr/bin/env bash
# Preflight plugin test suite
# Run: ./tests/test-plugin.sh
# Covers: content integrity, plugin structure validation, skill frontmatter, file references
set -euo pipefail

PASS=0
FAIL=0
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

pass() { ((PASS++)); printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { ((FAIL++)); printf "  \033[31mFAIL\033[0m %s\n" "$1"; }
section() { printf "\n--- %s ---\n" "$1"; }

# ============================================================
section "Plugin manifest"
# ============================================================

if [[ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]]; then
  pass "plugin.json exists"
else
  fail "plugin.json missing"
fi

if python3 -c "import json, sys; d=json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json')); sys.exit(0 if all(k in d for k in ['name','description','version']) else 1)" 2>/dev/null; then
  pass "plugin.json has required fields (name, description, version)"
else
  fail "plugin.json missing required fields"
fi

if python3 -c "
import json, re, sys
d = json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))
v = d.get('version', '')
sys.exit(0 if re.match(r'^\d+\.\d+\.\d+$', v) else 1)
" 2>/dev/null; then
  pass "plugin.json version is semver"
else
  fail "plugin.json version is not semver"
fi

# ============================================================
section "Templates (content/templates/)"
# ============================================================

EXPECTED_TEMPLATES=(adr architecture constitution interface-contract requirements rfc test-strategy)
for tmpl in "${EXPECTED_TEMPLATES[@]}"; do
  f="$PLUGIN_ROOT/content/templates/${tmpl}-template.md"
  if [[ -f "$f" ]]; then
    pass "template: ${tmpl}-template.md"
    if head -1 "$f" | grep -q '^---'; then
      pass "  frontmatter: ${tmpl}-template.md"
    else
      fail "  missing frontmatter: ${tmpl}-template.md"
    fi
  else
    fail "template missing: ${tmpl}-template.md"
  fi
done

ACTUAL_COUNT=$(find "$PLUGIN_ROOT/content/templates" -name '*.md' | wc -l | tr -d ' ')
if [[ "$ACTUAL_COUNT" -eq "${#EXPECTED_TEMPLATES[@]}" ]]; then
  pass "template count: $ACTUAL_COUNT (no unexpected files)"
else
  fail "template count: $ACTUAL_COUNT (expected ${#EXPECTED_TEMPLATES[@]})"
fi

# ============================================================
section "Rules (content/rules-source/)"
# ============================================================

EXPECTED_RULES=(adr architecture constitution cross-doc requirements rfc universal)
for rule in "${EXPECTED_RULES[@]}"; do
  f="$PLUGIN_ROOT/content/rules-source/${rule}-rules.md"
  if [[ -f "$f" ]]; then
    pass "rule: ${rule}-rules.md"
    if grep -qE '\b[A-Z]+-[A-Z]*-?[0-9]+' "$f"; then
      pass "  has rule IDs: ${rule}-rules.md"
    else
      fail "  no rule IDs found: ${rule}-rules.md"
    fi
  else
    fail "rule missing: ${rule}-rules.md"
  fi
done

# ============================================================
section "Reference (content/reference/)"
# ============================================================

EXPECTED_REFS=(adoption-order agent-optimization cross-doc-relationships doc-taxonomy ears-notation greenfield-rfc-vs-adr)
for ref in "${EXPECTED_REFS[@]}"; do
  f="$PLUGIN_ROOT/content/reference/${ref}.md"
  if [[ -f "$f" ]]; then
    pass "reference: ${ref}.md"
  else
    fail "reference missing: ${ref}.md"
  fi
done

# ============================================================
section "Scaffolds (content/scaffolds/)"
# ============================================================

EXPECTED_SCAFFOLDS=(adr-001-use-preflight constitution-skeleton glossary-skeleton)
for scf in "${EXPECTED_SCAFFOLDS[@]}"; do
  f="$PLUGIN_ROOT/content/scaffolds/${scf}.md"
  if [[ -f "$f" ]]; then
    pass "scaffold: ${scf}.md"
    if head -1 "$f" | grep -q '^---'; then
      pass "  frontmatter: ${scf}.md"
    else
      fail "  missing frontmatter: ${scf}.md"
    fi
  else
    fail "scaffold missing: ${scf}.md"
  fi
done

# ============================================================
section "Skills"
# ============================================================

EXPECTED_SKILLS=(scaffold new review)
for skill in "${EXPECTED_SKILLS[@]}"; do
  skill_file="$PLUGIN_ROOT/skills/${skill}/SKILL.md"
  if [[ -f "$skill_file" ]]; then
    pass "skill file: ${skill}/SKILL.md"

    # Check frontmatter has required fields
    # Extract frontmatter (between first two --- lines)
    fm=$(sed -n '/^---$/,/^---$/p' "$skill_file" | head -20)

    if echo "$fm" | grep -q '^name:'; then
      pass "  frontmatter name: ${skill}"
    else
      fail "  missing frontmatter name: ${skill}"
    fi

    if echo "$fm" | grep -q '^description:'; then
      pass "  frontmatter description: ${skill}"
    else
      fail "  missing frontmatter description: ${skill}"
    fi

    # Check skill reads from .preflight/ project directory (not hardcoded plugin paths)
    if grep -q '\.preflight/' "$skill_file"; then
      pass "  reads from .preflight/: ${skill}"
    else
      fail "  missing .preflight/ references: ${skill}"
    fi
  else
    fail "skill file missing: ${skill}/SKILL.md"
  fi
done

# ============================================================
section "Commands"
# ============================================================

for cmd in scaffold new review; do
  cmd_file="$PLUGIN_ROOT/commands/${cmd}.md"
  if [[ -f "$cmd_file" ]]; then
    pass "commands/${cmd}.md exists"
  else
    fail "commands/${cmd}.md missing"
  fi

  if [[ -f "$cmd_file" ]]; then
    fm=$(sed -n '/^---$/,/^---$/p' "$cmd_file" | head -20)
    if echo "$fm" | grep -q '^description:'; then
      pass "commands/${cmd}.md has frontmatter description"
    else
      fail "commands/${cmd}.md missing frontmatter description"
    fi
    if grep -q "preflight:${cmd}" "$cmd_file"; then
      pass "commands/${cmd}.md delegates to preflight:${cmd} skill"
    else
      fail "commands/${cmd}.md missing delegation to preflight:${cmd} skill"
    fi
  fi
done

# ============================================================
section "Skill file references"
# ============================================================

# scaffold skill should reference all three content categories
scaffold_file="$PLUGIN_ROOT/skills/scaffold/SKILL.md"
for cat in templates rules-source reference scaffolds; do
  if grep -q "content/${cat}" "$scaffold_file"; then
    pass "scaffold references content/${cat}"
  else
    fail "scaffold missing reference to content/${cat}"
  fi
done

# new skill should read templates from project .preflight/ directory
new_file="$PLUGIN_ROOT/skills/new/SKILL.md"
if grep -q '\.preflight/_templates' "$new_file"; then
  pass "new skill reads templates from .preflight/_templates/"
else
  fail "new skill missing reference to .preflight/_templates/"
fi

# new skill should read rules from project .preflight/ directory
if grep -q '\.preflight/_rules' "$new_file"; then
  pass "new skill reads rules from .preflight/_rules/"
else
  fail "new skill missing reference to .preflight/_rules/"
fi

# review skill should read from .preflight/_rules/ (project copy)
review_file="$PLUGIN_ROOT/skills/review/SKILL.md"
if grep -q '.preflight/_rules/' "$review_file"; then
  pass "review skill reads from .preflight/_rules/ (project copy)"
else
  fail "review skill should read from .preflight/_rules/, not plugin source"
fi

# ============================================================
section "No orphan directories"
# ============================================================

for dir in specs/_templates specs/_rules specs/_reference; do
  if [[ -d "$PLUGIN_ROOT/$dir" ]]; then
    fail "orphan directory: $dir (should have been removed)"
  else
    pass "no orphan: $dir"
  fi
done

# ============================================================
section "No junk files"
# ============================================================

junk_count=$(find "$PLUGIN_ROOT" -name '.DS_Store' -o -name 'node_modules' -o -name '*.pyc' -o -name '__pycache__' 2>/dev/null | wc -l | tr -d ' ')
if [[ "$junk_count" -eq 0 ]]; then
  pass "no junk files (.DS_Store, node_modules, .pyc, __pycache__)"
else
  fail "found $junk_count junk files"
fi

# ============================================================
section "Hooks"
# ============================================================

if [[ -f "$PLUGIN_ROOT/hooks/hooks.json" ]]; then
  pass "hooks/hooks.json exists"
else
  fail "hooks/hooks.json missing"
fi

if python3 -c "import json, sys; json.load(open('$PLUGIN_ROOT/hooks/hooks.json'))" 2>/dev/null; then
  pass "hooks/hooks.json is valid JSON"
else
  fail "hooks/hooks.json is invalid JSON"
fi

if python3 -c "
import json, sys
d = json.load(open('$PLUGIN_ROOT/hooks/hooks.json'))
has_desc = 'description' in d
has_hooks = 'hooks' in d
sys.exit(0 if has_desc and has_hooks else 1)
" 2>/dev/null; then
  pass "hooks/hooks.json has required fields (description, hooks)"
else
  fail "hooks/hooks.json missing required fields"
fi

if [[ -f "$PLUGIN_ROOT/hooks/exit-plan-mode.sh" ]]; then
  pass "hooks/exit-plan-mode.sh exists"
else
  fail "hooks/exit-plan-mode.sh missing"
fi

if [[ -x "$PLUGIN_ROOT/hooks/exit-plan-mode.sh" ]]; then
  pass "hooks/exit-plan-mode.sh is executable"
else
  fail "hooks/exit-plan-mode.sh is not executable"
fi

# Verify no external binary dependencies (NFR-001)
for binary in jq node npm python3; do
  if grep -q "\b${binary}\b" "$PLUGIN_ROOT/hooks/exit-plan-mode.sh" 2>/dev/null; then
    fail "hooks/exit-plan-mode.sh uses external binary: ${binary} (violates NFR-001)"
  else
    pass "hooks/exit-plan-mode.sh: no dependency on ${binary}"
  fi
done

# ============================================================
section "Project docs preserved"
# ============================================================

for f in specs/constitution.md specs/requirements.md specs/decisions/adrs/adr-002-convert-to-plugin.md specs/decisions/adrs/adr-003-plugin-quality-gates.md specs/decisions/rfcs/rfc-001-reviewer-agents.md; do
  if [[ -f "$PLUGIN_ROOT/$f" ]]; then
    pass "project doc: $f"
  else
    fail "project doc missing: $f"
  fi
done

# ============================================================
printf "\n\033[1m=== Results: %d passed, %d failed ===\033[0m\n" "$PASS" "$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
