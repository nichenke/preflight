# Preflight Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the PM Documentation Framework repo into a Claude Code plugin called "preflight" with three skills (scaffold, new, review) and auto-loaded rules.

**Architecture:** Pure markdown plugin — no code, no dependencies. Content files (templates, rules, reference) move from `specs/` into `content/`. Three SKILL.md files orchestrate the user-facing workflows. Scaffold generates `.claude/rules/preflight.md` with concrete paths in target projects.

**Tech Stack:** Claude Code plugin system (plugin.json, skills/, content/), markdown, YAML frontmatter

**Spec:** `docs/specs/2026-03-28-preflight-plugin-design.md`

---

## Task 1: Create plugin manifest and directory structure

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `content/` directory tree (empty — populated in later tasks)
- Create: `skills/` directory tree (empty — populated in later tasks)

- [ ] **Step 1: Create `.claude-plugin/plugin.json`**

```json
{
  "name": "preflight",
  "description": "Spec-driven development framework — scaffold project docs, guided elicitation for requirements/ADRs/RFCs, and rule-based review",
  "version": "0.1.0",
  "author": {
    "name": "Nic Henke",
    "email": "nichenke@gmail.com"
  },
  "repository": "https://github.com/nichenke/preflight",
  "license": "MIT",
  "keywords": [
    "specs",
    "requirements",
    "adr",
    "rfc",
    "documentation",
    "ears",
    "elicitation"
  ]
}
```

- [ ] **Step 2: Create empty directory structure**

```
mkdir -p content/templates content/rules-source content/reference content/scaffolds
mkdir -p skills/scaffold skills/new skills/review
```

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add plugin manifest and directory structure"
```

---

## Task 2: Move templates to `content/templates/`

**Files:**
- Move: `specs/_templates/*.md` → `content/templates/`

- [ ] **Step 1: Move all template files**

```bash
git mv specs/_templates/adr-template.md content/templates/
git mv specs/_templates/architecture-template.md content/templates/
git mv specs/_templates/constitution-template.md content/templates/
git mv specs/_templates/interface-contract-template.md content/templates/
git mv specs/_templates/requirements-template.md content/templates/
git mv specs/_templates/rfc-template.md content/templates/
git mv specs/_templates/test-strategy-template.md content/templates/
```

- [ ] **Step 2: Verify all 7 templates landed**

```bash
ls content/templates/
```

Expected: 7 .md files

- [ ] **Step 3: Commit**

```bash
git commit -m "refactor: move templates to content/templates/"
```

---

## Task 3: Move rules to `content/rules-source/`

**Files:**
- Move: `specs/_rules/*.md` → `content/rules-source/`

- [ ] **Step 1: Move all rules files**

```bash
git mv specs/_rules/adr-rules.md content/rules-source/
git mv specs/_rules/architecture-rules.md content/rules-source/
git mv specs/_rules/constitution-rules.md content/rules-source/
git mv specs/_rules/cross-doc-rules.md content/rules-source/
git mv specs/_rules/requirements-rules.md content/rules-source/
git mv specs/_rules/rfc-rules.md content/rules-source/
git mv specs/_rules/universal-rules.md content/rules-source/
```

- [ ] **Step 2: Verify all 7 rules files landed**

```bash
ls content/rules-source/
```

Expected: 7 .md files

- [ ] **Step 3: Commit**

```bash
git commit -m "refactor: move rules to content/rules-source/"
```

---

## Task 4: Move reference files to `content/reference/`

**Files:**
- Move: 6 reference files from `specs/_reference/` → `content/reference/`
- Delete: 2 research artifacts not shipped in plugin

- [ ] **Step 1: Move the 6 reference files that ship with the plugin**

```bash
git mv specs/_reference/adoption-order.md content/reference/
git mv specs/_reference/agent-optimization.md content/reference/
git mv specs/_reference/cross-doc-relationships.md content/reference/
git mv specs/_reference/doc-taxonomy.md content/reference/
git mv specs/_reference/ears-notation.md content/reference/
git mv specs/_reference/greenfield-rfc-vs-adr.md content/reference/
```

- [ ] **Step 2: Remove research artifacts that don't ship**

```bash
git rm specs/_reference/execution-framework-gap-analysis.md
git rm specs/_reference/frameworks-and-tools.md
```

- [ ] **Step 3: Verify**

```bash
ls content/reference/
```

Expected: 6 .md files. `specs/_reference/` should be empty or gone.

- [ ] **Step 4: Commit**

```bash
git commit -m "refactor: move reference files to content/reference/, remove research artifacts"
```

---

## Task 5: Create scaffold content files

**Files:**
- Create: `content/scaffolds/constitution-skeleton.md`
- Create: `content/scaffolds/glossary-skeleton.md`
- Create: `content/scaffolds/adr-001-use-preflight.md`

These are the files that scaffold copies into target projects. They're starter versions,
not the full templates.

- [ ] **Step 1: Create constitution skeleton**

A minimal constitution with the preamble, standard categories as placeholders, and
the amendment log. Based on `content/templates/constitution-template.md` but stripped
to just the structure with placeholder principles.

```markdown
---
status: Draft
version: 0.1.0
date: YYYY-MM-DD
ratified_by: []
last_amended:
amendment_adrs: []
---

# Engineering Constitution

## Preamble

This constitution defines non-negotiable engineering principles for this project.
All agents, all features, and all code must comply. Amendments require an ADR with
explicit ratification.

## Code Standards
<!-- Add principles: [CONST-CS-01] Each principle is imperative and testable -->

## Testing
<!-- Add principles: [CONST-TEST-01] -->

## Security
<!-- Add principles: [CONST-SEC-01] -->

## Documentation & Process
- [CONST-DOC-01] All behavioral requirement changes require an ADR (REQ-R07)
- [CONST-DOC-02] ADRs use MADR 4.0 format
- [CONST-DOC-03] All constitution amendments require an ADR with ratification

## Amendment Log
| Version | Date | ADR | Change Summary |
|---------|------|-----|----------------|
| 0.1.0 | YYYY-MM-DD | — | Initial draft |
```

- [ ] **Step 2: Create glossary skeleton**

```markdown
---
status: Draft
date: YYYY-MM-DD
owner: TBD
version: 0.1.0
---

# Glossary / Domain Model

Shared vocabulary and entity relationships — the ubiquitous language.

## Terms

| Term | Definition | Context / Notes |
|------|-----------|-----------------|
<!-- Add terms as they emerge during requirements and design work -->
```

- [ ] **Step 3: Create meta-ADR for preflight adoption**

Rewrite `adr-001-use-pm-doc-framework.md` for the plugin context. This ADR records
that the project adopted preflight for spec-driven development.

```markdown
---
status: Accepted
date: YYYY-MM-DD
deciders: []
consulted: []
informed: []
---

# ADR-001: Use Preflight for Spec-Driven Development

## Context and Problem Statement

AI coding agents produce better results when given structured, unambiguous specifications
rather than ad-hoc prompts. Without a consistent documentation framework, each project
re-invents its own spec format, requirements drift without traceability, and agents make
assumptions that diverge from intent.

## Decision Drivers

- Agents need structured, behavior-oriented specs to generate correct code
- Requirements changes must be traceable to prevent silent scope drift
- Decisions need to be recorded so agents don't relitigate them
- Interface boundaries must be explicit — agents can't infer implicit contracts

## Considered Options

1. Ad-hoc documentation per project
2. Adopt preflight framework (EARS + MADR + arc42 + structured templates)

## Decision Outcome

Chosen option: "Adopt preflight framework", because it provides structured templates
with machine-checkable review rules, uses industry standards (EARS, MADR 4.0, arc42),
and integrates natively with Claude Code via plugin.

### Consequences

- Good, because agents get structured, parseable specs with unique IDs and EARS notation
- Good, because requirements changes are governed by ADRs, preventing silent scope drift
- Good, because machine-checkable review rules catch issues before code is written
- Bad, because there is upfront effort to write constitution and initial requirements

### Confirmation

Revisit after completing initial requirements and first ADR cycle. Success: agents
produce code that aligns with specs on first pass more often than without the framework.
```

- [ ] **Step 4: Commit**

```bash
git add content/scaffolds/
git commit -m "feat: add scaffold content — constitution skeleton, glossary skeleton, meta-ADR"
```

---

## Task 6: Clean up old directory structure

**Files:**
- Remove: `specs/_templates/` (now empty)
- Remove: `specs/_rules/` (now empty)
- Remove: `specs/_reference/` (now empty)
- Remove: `specs/glossary.md` (replaced by scaffold skeleton)
- Remove: `decisions/adrs/adr-001-use-pm-doc-framework.md` (replaced by scaffold meta-ADR)
- Remove: `docs/prompts/framework-review-prompt.md` (replaced by review skill)
- Keep: `specs/constitution.md`, `specs/requirements.md` (project's own docs)
- Keep: `decisions/adrs/adr-002-convert-to-plugin.md` (project's own ADR)

- [ ] **Step 1: Remove emptied directories and replaced files**

```bash
git rm -r specs/_templates/ specs/_rules/ specs/_reference/
git rm specs/glossary.md
git rm decisions/adrs/adr-001-use-pm-doc-framework.md
git rm docs/prompts/framework-review-prompt.md
```

Note: `specs/_templates/`, `specs/_rules/`, `specs/_reference/` should already be empty
from tasks 2-4. If git complains they don't exist, skip them.

- [ ] **Step 2: Verify remaining structure**

```bash
find . -type f -not -path './.git/*' | sort
```

Expected to remain:
- `.claude-plugin/plugin.json`
- `content/templates/*.md` (7 files)
- `content/rules-source/*.md` (7 files)
- `content/reference/*.md` (6 files)
- `content/scaffolds/*.md` (3 files)
- `skills/` (empty dirs for now)
- `specs/constitution.md`
- `specs/requirements.md`
- `decisions/adrs/adr-002-convert-to-plugin.md`
- `decisions/rfcs/.gitkeep`
- `docs/specs/2026-03-28-preflight-plugin-design.md`
- `docs/plans/2026-03-28-preflight-plugin-implementation.md`
- `docs/reviews/2026-03-23-framework-rules-review.md`
- `CLAUDE.md`, `README.md`, `LICENSE`, `.gitignore`

- [ ] **Step 3: Commit**

```bash
git commit -m "refactor: remove old directory structure — content now in content/"
```

---

## Task 7: Write the scaffold skill

**Files:**
- Create: `skills/scaffold/SKILL.md`

This is the most complex skill. It handles both fresh scaffold and update-existing flows.

- [ ] **Step 1: Write `skills/scaffold/SKILL.md`**

The skill needs:

**Frontmatter:**
```yaml
---
name: scaffold
description: Bootstrap or update a project's preflight directory structure — creates .preflight/ with templates/rules/reference, project docs directory with skeleton constitution/glossary/meta-ADR, and .claude/rules/preflight.md with concrete paths
---
```

**Body — the skill instructions must cover:**

1. **Detection:** Check if `.preflight/` exists → fresh vs update flow
2. **Fresh flow:**
   - Ask user for docs directory (default: `docs/`)
   - Create `.preflight/` and copy framework content from `${CLAUDE_PLUGIN_ROOT}/content/`:
     - `templates/` → `.preflight/_templates/`
     - `rules-source/` → `.preflight/_rules/`
     - `reference/` → `.preflight/_reference/`
   - Create project docs in chosen directory:
     - Copy `${CLAUDE_PLUGIN_ROOT}/content/scaffolds/constitution-skeleton.md` → `{docs_dir}/constitution.md`
     - Copy `${CLAUDE_PLUGIN_ROOT}/content/scaffolds/glossary-skeleton.md` → `{docs_dir}/glossary.md`
     - Create `{docs_dir}/interfaces/.gitkeep`
     - Copy `${CLAUDE_PLUGIN_ROOT}/content/scaffolds/adr-001-use-preflight.md` → `{docs_dir}/decisions/adrs/adr-001-use-preflight.md`
     - Create `{docs_dir}/decisions/rfcs/.gitkeep`
   - Write `.preflight/config.yml` with `docs_dir: {chosen_dir}`
   - Generate `.claude/rules/preflight.md` with concrete paths (template in spec)
   - Report everything created
3. **Update flow (FR-008):**
   - Read `.preflight/config.yml` for docs_dir
   - Compare framework files in `.preflight/_templates/`, `_rules/`, `_reference/` against `${CLAUDE_PLUGIN_ROOT}/content/`
   - Report diffs, ask user which to accept
   - Never touch anything in `{docs_dir}/` (FR-009)
   - Update `.claude/rules/preflight.md` if needed
4. **Protected files (FR-009):** List explicitly — constitution, glossary, requirements, architecture, test-strategy, interfaces/*, decisions/*

Read `${CLAUDE_PLUGIN_ROOT}/content/templates/`, `${CLAUDE_PLUGIN_ROOT}/content/rules-source/`, and `${CLAUDE_PLUGIN_ROOT}/content/reference/` to enumerate which files to copy. Do not hardcode the list — read the directories so new content files are picked up automatically.

For the rules file template, use the exact content from the design spec (section "Auto-loaded rules file"), replacing `{docs_dir}` with the user's chosen path.

- [ ] **Step 2: Verify skill frontmatter**

The `description` field must trigger on: "scaffold", "bootstrap", "set up preflight", "initialize project", "update preflight". Keep it specific enough to avoid false activation.

- [ ] **Step 3: Commit**

```bash
git add skills/scaffold/SKILL.md
git commit -m "feat: add scaffold skill — bootstrap and update project structure"
```

---

## Task 8: Write the review skill

**Files:**
- Create: `skills/review/SKILL.md`

Writing review before new because: the new skill dispatches a review subagent after
creating a doc. Understanding the review process first makes the new skill's
post-creation step clearer.

- [ ] **Step 1: Write `skills/review/SKILL.md`**

**Frontmatter:**
```yaml
---
name: review
description: Validate a spec document against preflight framework rules — checks type-specific, universal, and cross-doc rules from .preflight/_rules/, reports findings grouped by severity (Error/Warning) with rule IDs and fix suggestions
---
```

**Body — the skill instructions must cover:**

1. **Entry:** Read `.preflight/config.yml` for docs_dir. If no file argument given, ask which doc to review.
2. **Doc type identification:** Check YAML frontmatter for `type` field. If absent, infer from file path:
   - `{docs_dir}/decisions/adrs/` → ADR
   - `{docs_dir}/decisions/rfcs/` → RFC
   - `{docs_dir}/requirements.md` → requirements
   - `{docs_dir}/architecture.md` → architecture
   - `{docs_dir}/constitution.md` → constitution
   - `{docs_dir}/test-strategy.md` → test-strategy
   - `{docs_dir}/interfaces/` → interface-contract
3. **Load rules:** Read from `.preflight/_rules/` (project's committed copy):
   - Type-specific rules file (e.g., `requirements-rules.md`)
   - `universal-rules.md` (always)
   - `cross-doc-rules.md` (when doc references other docs — check for FR-/NFR-/ADR-/CONST- ID references)
4. **Check each rule** against the document
5. **Report:** Group by severity (Error first, then Warning). Each finding: rule ID, what's wrong, fix suggestion.
6. **Pass criteria:** Zero Errors → report as passing (FR-020)
7. **Advisory only:** Do not modify the document

- [ ] **Step 2: Commit**

```bash
git add skills/review/SKILL.md
git commit -m "feat: add review skill — rule-based document validation"
```

---

## Task 9: Write the new skill

**Files:**
- Create: `skills/new/SKILL.md`

The most complex skill — handles 7 doc types with guided elicitation flows.

- [ ] **Step 1: Write `skills/new/SKILL.md`**

**Frontmatter:**
```yaml
---
name: new
description: Create a new spec document with guided elicitation — walks through structured questions for requirements (EARS), ADRs (MADR 4.0), RFCs, architecture, interface contracts, test strategy, or constitution, then writes the doc and runs automated review
---
```

**Body — the skill instructions must cover:**

1. **Entry:**
   - Read `.preflight/config.yml` for docs_dir
   - If doc type not specified as argument, present choices: requirements, adr, rfc, architecture, interface-contract, test-strategy, constitution
   - Route to appropriate flow

2. **Filename handling:**
   - Singletons (requirements, architecture, constitution, glossary, test-strategy): fixed filename at `{docs_dir}/{type}.md`
   - Sequential (ADR, RFC): scan `{docs_dir}/decisions/adrs/` or `rfcs/` for highest existing ID, increment. Ask user for a short slug. Produce `adr-NNN-{slug}.md`
   - Named (interface-contract): ask for boundary name, produce `{docs_dir}/interfaces/{name}.md`
   - If target file already exists, report and ask how to proceed

3. **Elicitation flows:**
   For each doc type, read the template from `${CLAUDE_PLUGIN_ROOT}/content/templates/{type}-template.md` to understand structure. Then walk the user through one section at a time:

   - **Requirements:** problem statement → personas → user journeys (include failure modes for each) → EARS functional requirements (guide: use When/While/Where/If-then patterns, assign FR-NNN IDs) → non-functional requirements (guide: quantitative criteria, assign NFR-NNN IDs) → constraints → assumptions → success measures → out-of-scope
   - **ADR:** context and problem statement → decision drivers → at least 2 options (for each: description, pros, cons) → decision outcome with consequences → confirmation criteria → **impact propagation** (see below)
   - **RFC:** executive summary → problem statement (with measurable evidence) → scope → proposed solution → at least 1 alternative → migration/rollout plan with rollback → risks → success criteria
   - **Architecture:** requirements overview → system context (C4 level 1) → solution strategy → building blocks (C4 level 2)
   - **Interface contract:** protocol/transport → endpoints or operations → SLA (latency, throughput, availability) → error handling contract
   - **Test strategy:** test pyramid levels → acceptance criteria mapping → test environments
   - **Constitution:** preamble → categories (let user define) → principles (guide: each must be imperative, testable, with CONST-{CAT}-NN ID)

4. **ADR impact propagation (FR-023):**
   After writing the ADR:
   - Read existing downstream docs: `{docs_dir}/requirements.md`, `{docs_dir}/architecture.md`, `{docs_dir}/constitution.md`, files in `{docs_dir}/interfaces/`
   - For each, identify what needs to change to reflect the ADR's decision and consequences
   - Propose specific changes (new FRs/NFRs, architecture updates, constraint additions)
   - Present propagation plan to user for approval
   - Apply approved changes
   - Flag any consequences that can't be traced to a downstream doc

5. **Post-creation:**
   - Populate YAML frontmatter: status: Draft, date: today, owner: ask or infer, version: 0.1.0
   - Assign next sequential ID where applicable
   - Write the file
   - Dispatch review subagent: read applicable rules from `${CLAUDE_PLUGIN_ROOT}/content/rules-source/` (plugin source, not `.preflight/_rules/` — project copy may be stale or missing). Run universal-rules and cross-doc-rules too. Auto-fix Error-severity findings. Report Warning-severity findings to user.

- [ ] **Step 2: Commit**

```bash
git add skills/new/SKILL.md
git commit -m "feat: add new skill — guided elicitation for 7 doc types with ADR impact propagation"
```

---

## Task 10: Update CLAUDE.md for plugin context

**Files:**
- Modify: `CLAUDE.md`

The repo's own CLAUDE.md needs to reflect the new plugin structure. This is for
developers working on the plugin itself, not for target projects.

- [ ] **Step 1: Rewrite CLAUDE.md**

Replace current content with plugin-development instructions:

```markdown
# Preflight — Claude Code Plugin

Plugin for spec-driven development. Provides three skills:
- `/preflight scaffold` — bootstrap or update project structure
- `/preflight new` — guided doc creation with elicitation
- `/preflight review` — rule-based document validation

## Repo structure

```
.claude-plugin/plugin.json   # Plugin manifest
skills/                       # Skill definitions (SKILL.md per skill)
content/
  templates/                  # Doc type templates (copied to .preflight/_templates/)
  rules-source/               # Review rules (copied to .preflight/_rules/)
  reference/                  # Framework reference material (copied to .preflight/_reference/)
  scaffolds/                  # Starter files for new projects
specs/                        # This plugin's own specs (requirements, constitution)
decisions/                    # This plugin's own ADRs and RFCs
docs/                         # Design docs and plans for this plugin
```

## Before modifying plugin behavior

1. Read `specs/constitution.md` — overrides everything
2. Read `specs/requirements.md` — EARS requirements with FR/NFR IDs
3. Read `decisions/adrs/` — accepted ADRs constrain choices
4. Any behavioral change requires a version bump in plugin.json (CONST-PROC-01)
5. Any behavioral requirement change requires an ADR (CONST-PROC-02)

## Content files

Templates, rules, and reference material in `content/` are the single source of truth
(CONST-CI-02). The scaffold skill copies these into target projects. Edit them here,
not in a target project's `.preflight/` directory.
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for plugin development context"
```

---

## Task 11: Verify complete plugin structure

- [ ] **Step 1: List all files and verify against design spec**

```bash
find . -type f -not -path './.git/*' | sort
```

Verify these exist:
- `.claude-plugin/plugin.json`
- `content/templates/` — 7 template files
- `content/rules-source/` — 7 rules files
- `content/reference/` — 6 reference files
- `content/scaffolds/` — 3 scaffold files
- `skills/scaffold/SKILL.md`
- `skills/new/SKILL.md`
- `skills/review/SKILL.md`
- `specs/constitution.md`, `specs/requirements.md`
- `decisions/adrs/adr-002-convert-to-plugin.md`
- `CLAUDE.md`, `README.md`, `LICENSE`

- [ ] **Step 2: Verify plugin.json is valid JSON**

```bash
python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('valid')"
```

- [ ] **Step 3: Count lines in rules file template**

Check the auto-loaded rules content in the design spec is under 80 lines (NFR-003).
The template is embedded in the scaffold skill — grep for it and count lines.

- [ ] **Step 4: Verify no orphaned files from old structure**

```bash
ls specs/_templates/ specs/_rules/ specs/_reference/ 2>&1
```

Expected: "No such file or directory" for all three.

---

## Task 12: Plugin validation

Run the plugin-dev validator to check the plugin structure is correct before testing.

- [ ] **Step 1: Run `/plugin-dev:plugin-validator`**

Invoke the plugin-validator agent against the repo root. It checks:
- `plugin.json` structure and required fields
- Skill frontmatter format
- File references resolve correctly
- No orphaned or missing components

- [ ] **Step 2: Fix any issues found**

Address validation errors. Re-run validator until clean.

- [ ] **Step 3: Commit fixes if any**

```bash
git add -A && git commit -m "fix: address plugin validation findings"
```

---

## Task 13: Test install the plugin locally

Install the plugin from the local repo and verify Claude Code recognizes it.

- [ ] **Step 1: Install plugin from local path**

```bash
claude plugin add /path/to/worktree
```

Or add to `~/.claude/settings.json` plugins array temporarily.

- [ ] **Step 2: Verify skills appear in skill list**

Start a new Claude Code session and confirm these skills appear:
- `preflight:scaffold`
- `preflight:new`
- `preflight:review`

- [ ] **Step 3: Document any installation issues**

If the plugin doesn't load or skills don't appear, document the error and fix.

---

## Task 14: Functional test — scaffold fresh project

Test the scaffold skill end-to-end in a temporary directory.

- [ ] **Step 1: Create a temporary test project**

```bash
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init
echo "# Test project" > README.md
git add README.md && git commit -m "init"
```

- [ ] **Step 2: Run `/preflight scaffold` with default docs dir**

Accept the default `docs/` directory. Verify the skill:
- Asks for docs directory
- Creates `.preflight/` with `_templates/`, `_rules/`, `_reference/`
- Creates `docs/` with constitution, glossary, interfaces/, decisions/adrs/, decisions/rfcs/
- Creates `docs/decisions/adrs/adr-001-use-preflight.md`
- Creates `.preflight/config.yml` with `docs_dir: docs`
- Creates `.claude/rules/preflight.md` with concrete paths using `docs/`

- [ ] **Step 3: Verify file counts**

```bash
# Framework content
ls .preflight/_templates/ | wc -l   # Expected: 7
ls .preflight/_rules/ | wc -l       # Expected: 7
ls .preflight/_reference/ | wc -l   # Expected: 6

# Project docs
test -f docs/constitution.md && echo "OK" || echo "MISSING"
test -f docs/glossary.md && echo "OK" || echo "MISSING"
test -f docs/decisions/adrs/adr-001-use-preflight.md && echo "OK" || echo "MISSING"
test -f .preflight/config.yml && echo "OK" || echo "MISSING"
test -f .claude/rules/preflight.md && echo "OK" || echo "MISSING"
```

- [ ] **Step 4: Verify rules file has concrete paths and is under 80 lines**

```bash
grep -c "docs/" .claude/rules/preflight.md   # Should find concrete paths
wc -l < .claude/rules/preflight.md            # Must be < 80
```

- [ ] **Step 5: Verify config.yml content**

```bash
cat .preflight/config.yml
```

Expected: `docs_dir: docs`

- [ ] **Step 6: Document results**

---

## Task 15: Functional test — scaffold with custom docs dir

- [ ] **Step 1: Create another temporary test project**

```bash
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init
echo "# Test project" > README.md
git add README.md && git commit -m "init"
```

- [ ] **Step 2: Run `/preflight scaffold` and specify `specifications/` as docs dir**

Verify all project docs land under `specifications/` instead of `docs/`.

- [ ] **Step 3: Verify paths in generated files**

```bash
cat .preflight/config.yml                     # docs_dir: specifications
grep "specifications/" .claude/rules/preflight.md  # Concrete paths use specifications/
test -f specifications/constitution.md && echo "OK" || echo "MISSING"
test -f specifications/decisions/adrs/adr-001-use-preflight.md && echo "OK" || echo "MISSING"
```

---

## Task 16: Functional test — scaffold update flow (FR-008, FR-009)

- [ ] **Step 1: Use the test project from Task 14**

- [ ] **Step 2: Modify a project doc to verify it's not overwritten**

```bash
echo "# My custom constitution" > docs/constitution.md
```

- [ ] **Step 3: Run `/preflight scaffold` again**

Verify:
- Plugin detects `.preflight/` exists
- Reports diffs in framework files (if any)
- Does NOT touch `docs/constitution.md` (FR-009)
- `docs/constitution.md` still contains "My custom constitution"

```bash
cat docs/constitution.md  # Must still be "# My custom constitution"
```

---

## Task 17: Functional test — `/preflight new adr` with impact propagation

This is the most complex functional test — exercises FR-013, FR-015, FR-016, FR-023.

- [ ] **Step 1: Use the test project from Task 14, add a requirements doc**

Create a minimal requirements doc so impact propagation has something to check:

```bash
cat > docs/requirements.md << 'EOF'
---
status: Draft
version: 0.1.0
date: 2026-03-28
owner: test
---

# Requirements

## Functional Requirements

- FR-001: The system shall accept user input.
EOF
```

- [ ] **Step 2: Run `/preflight new adr`**

Walk through the elicitation:
- Provide context about a test decision (e.g., "use PostgreSQL for data storage")
- Provide at least 2 options with pros/cons
- Select a decision

Verify:
- Skill asks for a slug
- Assigns next sequential ID (adr-002 since adr-001 exists)
- Produces `docs/decisions/adrs/adr-002-{slug}.md`
- YAML frontmatter has status: Draft, date, version

- [ ] **Step 3: Verify ADR impact propagation fires**

After the ADR is written, the skill should:
- Read downstream docs (requirements.md at minimum)
- Propose changes (e.g., new FR for database storage)
- Ask for approval before applying

Verify the propagation step happens and proposes reasonable changes.

- [ ] **Step 4: Verify post-creation review runs**

After writing, the skill should dispatch a review subagent and report findings.

---

## Task 18: Functional test — `/preflight new requirements`

- [ ] **Step 1: Create a fresh test project (scaffold first)**

- [ ] **Step 2: Run `/preflight new requirements`**

Walk through guided elicitation: problem → personas → journeys → EARS FRs → NFRs.

Verify:
- Creates `docs/requirements.md` (singleton — no slug prompt)
- Populates YAML frontmatter
- Uses EARS patterns (When/While/Where/If-then) in requirements
- Assigns sequential FR-NNN and NFR-NNN IDs
- Post-creation review runs

---

## Task 19: Functional test — `/preflight review`

- [ ] **Step 1: Use the test project with the ADR from Task 17**

- [ ] **Step 2: Run `/preflight review docs/decisions/adrs/adr-002-*.md`**

Verify:
- Identifies doc type as ADR
- Loads rules from `.preflight/_rules/adr-rules.md` and `universal-rules.md`
- Reports findings grouped by severity
- Each finding has rule ID, description, fix suggestion
- If no Errors, reports as passing

- [ ] **Step 3: Test review on a doc with known issues**

Create a deliberately broken requirements doc (missing IDs, vague language) and
run review. Verify it catches Error-severity issues.

```bash
cat > docs/requirements-broken.md << 'EOF'
---
status: Draft
version: 0.1.0
---

# Requirements

## Functional Requirements

- The system should maybe handle some input.
- It needs to do stuff with data.
EOF
```

```bash
# Run: /preflight review docs/requirements-broken.md
# Expected: Error findings for missing IDs, vague language, missing EARS patterns
```

---

## Task 20: Bash test suite for content integrity

Create automated tests that verify plugin content is self-consistent, run without
Claude Code, and can be added to CI.

**Files:**
- Create: `tests/test-content-integrity.sh`

- [ ] **Step 1: Write bash test script**

```bash
#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

pass() { ((PASS++)); echo "  PASS: $1"; }
fail() { ((FAIL++)); echo "  FAIL: $1"; }

echo "=== Preflight content integrity tests ==="

# Test: plugin.json is valid JSON
echo "--- plugin.json ---"
if python3 -c "import json; json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))"; then
  pass "plugin.json is valid JSON"
else
  fail "plugin.json is invalid JSON"
fi

# Test: all 7 templates exist
echo "--- templates ---"
for tmpl in adr architecture constitution interface-contract requirements rfc test-strategy; do
  if [[ -f "$PLUGIN_ROOT/content/templates/${tmpl}-template.md" ]]; then
    pass "template: ${tmpl}-template.md"
  else
    fail "template missing: ${tmpl}-template.md"
  fi
done

# Test: all 7 rules files exist
echo "--- rules ---"
for rule in adr architecture constitution cross-doc requirements rfc universal; do
  if [[ -f "$PLUGIN_ROOT/content/rules-source/${rule}-rules.md" ]]; then
    pass "rule: ${rule}-rules.md"
  else
    fail "rule missing: ${rule}-rules.md"
  fi
done

# Test: all 6 reference files exist
echo "--- reference ---"
for ref in adoption-order agent-optimization cross-doc-relationships doc-taxonomy ears-notation greenfield-rfc-vs-adr; do
  if [[ -f "$PLUGIN_ROOT/content/reference/${ref}.md" ]]; then
    pass "reference: ${ref}.md"
  else
    fail "reference missing: ${ref}.md"
  fi
done

# Test: all 3 scaffold files exist
echo "--- scaffolds ---"
for scf in adr-001-use-preflight constitution-skeleton glossary-skeleton; do
  if [[ -f "$PLUGIN_ROOT/content/scaffolds/${scf}.md" ]]; then
    pass "scaffold: ${scf}.md"
  else
    fail "scaffold missing: ${scf}.md"
  fi
done

# Test: all 3 skills exist with frontmatter
echo "--- skills ---"
for skill in scaffold new review; do
  skill_file="$PLUGIN_ROOT/skills/${skill}/SKILL.md"
  if [[ -f "$skill_file" ]]; then
    pass "skill file: ${skill}/SKILL.md"
    # Check frontmatter has name and description
    if head -5 "$skill_file" | grep -q "^name:"; then
      pass "skill frontmatter name: ${skill}"
    else
      fail "skill missing frontmatter name: ${skill}"
    fi
    if head -10 "$skill_file" | grep -q "^description:"; then
      pass "skill frontmatter description: ${skill}"
    else
      fail "skill missing frontmatter description: ${skill}"
    fi
  else
    fail "skill file missing: ${skill}/SKILL.md"
  fi
done

# Test: templates have YAML frontmatter
echo "--- template frontmatter ---"
for tmpl in "$PLUGIN_ROOT"/content/templates/*-template.md; do
  name=$(basename "$tmpl")
  if head -1 "$tmpl" | grep -q "^---"; then
    pass "frontmatter: $name"
  else
    fail "missing frontmatter: $name"
  fi
done

# Test: rules files have rule IDs
echo "--- rule IDs ---"
for rule in "$PLUGIN_ROOT"/content/rules-source/*-rules.md; do
  name=$(basename "$rule")
  if grep -qE '\b[A-Z]+-[A-Z]*-?[0-9]+' "$rule"; then
    pass "has rule IDs: $name"
  else
    fail "no rule IDs found: $name"
  fi
done

# Test: scaffold skeleton files have YAML frontmatter
echo "--- scaffold frontmatter ---"
for scf in "$PLUGIN_ROOT"/content/scaffolds/*.md; do
  name=$(basename "$scf")
  if head -1 "$scf" | grep -q "^---"; then
    pass "frontmatter: $name"
  else
    fail "missing frontmatter: $name"
  fi
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
```

- [ ] **Step 2: Make executable and run**

```bash
chmod +x tests/test-content-integrity.sh
./tests/test-content-integrity.sh
```

Expected: all pass.

- [ ] **Step 3: Commit**

```bash
git add tests/test-content-integrity.sh
git commit -m "test: add content integrity test suite"
```

---

## Task 21: Code review — skills quality

Run code review on the three skill files to catch issues before shipping.

- [ ] **Step 1: Run `/simplify` on each skill file**

Review `skills/scaffold/SKILL.md`, `skills/new/SKILL.md`, `skills/review/SKILL.md`
for clarity, consistency, and redundancy.

- [ ] **Step 2: Run code-reviewer agent on the full diff**

```bash
git diff main...HEAD
```

Review the full changeset for:
- Consistency between skills (e.g., config reading, error handling)
- Missing edge cases
- Frontmatter quality (will it trigger correctly?)

- [ ] **Step 3: Fix any findings and commit**

```bash
git add -A && git commit -m "fix: address code review findings"
```

---

## Task 22: Skill eval with /skill-creator (CONST-QA-01)

Each skill must be validated with evals before shipping (NFR-004).

- [ ] **Step 1: Run /skill-creator eval on scaffold skill**

Test: activation ordering, rule following, triggering accuracy.
Target: >90% activation accuracy, >85% rule following.

- [ ] **Step 2: Run /skill-creator eval on new skill**

Same criteria. Pay special attention to elicitation flow ordering and
EARS pattern usage in generated requirements.

- [ ] **Step 3: Run /skill-creator eval on review skill**

Same criteria. Verify it correctly identifies doc types and loads
the right rules files.

- [ ] **Step 4: Fix any eval failures and re-run**

Iterate until all three skills meet the quality bar.

- [ ] **Step 5: Commit improvements**

```bash
git add -A && git commit -m "fix: address skill eval findings"
```

---

## Task 23: Final integration test and cleanup

- [ ] **Step 1: Run content integrity tests**

```bash
./tests/test-content-integrity.sh
```

Must pass with 0 failures.

- [ ] **Step 2: Full end-to-end walkthrough**

In a fresh temp directory:
1. Install plugin
2. `/preflight scaffold` (fresh)
3. `/preflight new requirements` (create a doc)
4. `/preflight review docs/requirements.md` (validate it)
5. `/preflight new adr` (create ADR, verify impact propagation)
6. `/preflight scaffold` (update — verify no overwrites)

- [ ] **Step 3: Clean up test directories**

```bash
# Remove any temp test directories created during testing
```

- [ ] **Step 4: Final commit if any cleanup needed**

```bash
git add -A && git commit -m "chore: final cleanup after integration testing"
```
