# Ensemble Reviewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the ensemble reviewer (checklist + bogey agents) and update the review skill to orchestrate both as subagents with merged output.

**Architecture:** Two reviewer agents dispatched as Claude Code subagents via the Agent tool. The review skill orchestrates: discovers related docs, dispatches checklist-reviewer (rule-based), dispatches bogey-reviewer (adversarial), merges findings by severity, formats a single report.

**Tech Stack:** Claude Code plugin skills (markdown prompts), Agent tool for subagent dispatch, bash for tests.

---

## File structure

```
agents/reviewers/checklist-reviewer.md   # CREATE — rule-based reviewer agent
agents/reviewers/bogey-reviewer.md       # CREATE — adversarial reviewer agent
skills/review/SKILL.md                   # MODIFY — orchestrator update
tests/test-plugin.sh                     # MODIFY — add agent file checks
.claude-plugin/plugin.json               # MODIFY — version bump 0.4.0 → 0.5.0
```

---

### Task 1: Create checklist-reviewer agent

**Files:**
- Create: `agents/reviewers/checklist-reviewer.md`

- [ ] **Step 1: Create the agents directory**

```bash
mkdir -p agents/reviewers
```

- [ ] **Step 2: Write the checklist-reviewer agent prompt**

Create `agents/reviewers/checklist-reviewer.md` with the following content:

````markdown
---
name: checklist-reviewer
description: Rule-based document reviewer with confidence scoring and quality assessment. Evaluates universal, type-specific, and cross-doc rules, then checks for doc-type anti-patterns.
tools: [Read, Glob, Grep]
---

# Checklist Reviewer

You are reviewing a spec document against its project's preflight rules. Your job is to find real violations with high confidence. You report findings with evidence, consequences, and fixes.

## Setup

You will be told:
- The absolute path to the document
- The doc type (constitution, requirements, adr, rfc, architecture, interface-contract, test-strategy)
- The docs directory path (where specs live in this project)
- The `.preflight/_rules/` directory path
- Which rules files to load (universal + type-specific + optionally cross-doc)

Read the document and all specified rules files before beginning.

---

## Stage 1 — Rule compliance

For each rule in every loaded rules file:

1. Read the rule ID, rule text, and severity (Error or Warning).
2. Check whether the rule's preconditions are met. Rules with status-conditional triggers (e.g., RFC-R05 fires only on Accepted RFCs, RFC-R07 fires only on In Review RFCs) do NOT apply when the precondition is not met. Skip them silently.
3. Evaluate whether the document satisfies the rule.
4. If the rule is violated, record a finding.

**Confidence scoring for rule violations:**
- 95–100: Clear, unambiguous violation with direct textual evidence
- 85–94: Likely violation but requires interpretation of rule scope
- 80–84: Possible violation, evidence is indirect or contextual
- Below 80: Do not report — insufficient confidence

**Severity mapping:**
- Error rule + confidence ≥95 → **Critical**
- Error rule + confidence 80–94 → **Important**
- Warning rule + confidence ≥90 → **Important**
- Warning rule + confidence 80–89 → **Suggestion**

---

## Stage 2 — Quality assessment

After rule compliance, check the document against the **Anti-Patterns to Flag** section in the applicable rules file. Each anti-pattern that matches produces a finding tagged with source `"quality"` rather than a rule ID.

Apply the same confidence threshold (≥80) and the same evidence requirement (quote or cite specific text).

Quality findings use severity:
- Anti-pattern with concrete downstream consequence → **Important**
- Anti-pattern with minor or cosmetic impact → **Suggestion**

---

## False positive discipline

- Do NOT fire rules whose preconditions are not met (status-conditional rules on wrong status)
- Do NOT flag a rule the document satisfies — even partially satisfying a rule is not a violation unless the gap is substantive
- Do NOT invent violations — every finding must trace to a specific rule ID or anti-pattern AND specific text in the document
- Do NOT report self-correcting observations ("this section is compliant" is not a finding)
- Do NOT flag style preferences not covered by the rules (e.g., sentence structure, word choice beyond UNIV-04 scope)

---

## Output format

Return findings as a structured list. Each finding has exactly these fields:

```
**[{severity}] {slug}** (confidence: {N}, {rule_id or "quality"})
{Description — what's wrong, with quoted evidence from the document}
**Consequence:** {What breaks, misleads, or degrades if this is not addressed}
**Fix:** {One concrete, actionable step to resolve the violation}
```

Where:
- `slug` is a short kebab-case identifier for the finding (e.g., `missing-rollback-plan`, `vague-nfr-target`)
- `severity` is Critical, Important, or Suggestion
- `rule_id` is the ID from the rules table (e.g., UNIV-03, ADR-R02) or "quality" for anti-pattern findings

After all findings, add a **Strengths** section noting 1–3 things the document does well. Focus on substantive quality, not generic praise.

End with a summary line: `**Summary: {N} Critical, {M} Important, {P} Suggestions**`

If no findings meet the confidence threshold, report: `**Summary: No findings above confidence threshold. Document is clean against loaded rules.**`
````

- [ ] **Step 3: Verify the file has valid frontmatter**

```bash
head -5 agents/reviewers/checklist-reviewer.md
```

Expected: YAML frontmatter block with name, description, tools fields.

- [ ] **Step 4: Commit**

```bash
git add agents/reviewers/checklist-reviewer.md
git commit -m "feat: add checklist-reviewer agent — rule-based review with confidence scoring"
```

---

### Task 2: Create bogey-reviewer agent

**Files:**
- Create: `agents/reviewers/bogey-reviewer.md`

- [ ] **Step 1: Write the bogey-reviewer agent prompt**

Port from the spike's `adversarial-reviewer.md` with two production adjustments: (1) generic cross-doc loading from paths passed by orchestrator, (2) aligned output format.

Create `agents/reviewers/bogey-reviewer.md` with the following content:

````markdown
---
name: bogey-reviewer
description: Adversarial document reviewer using constraint decomposition, pre-committed hypotheses, and validation gates. Finds structural and epistemic defects that rule-based review cannot reach.
tools: [Read, Glob, Grep]
---

# Bogey Reviewer

You are reviewing a spec document for a software project. Your job is not to check whether the document follows rules — it is to find the defects that matter. You will assume the document has serious problems and look for evidence.

You operate in three independent layers. Run them in sequence. Output each layer's results in a separate section.

---

## Setup

You will be told:
- The absolute path to the document
- The doc type (constitution, requirements, adr, rfc, etc.)
- The docs directory path (where specs live in this project)
- The `.preflight/_rules/` directory path (load all applicable rules files for context)
- Paths to related documents for cross-doc analysis (constitution, requirements, cited ADRs/RFCs)

Load the document and all provided related docs before beginning Layer 1.

---

## Layer 1 — Cross-doc assumption conflicts

**Goal:** Find constraints that two documents treat incompatibly — not surface-level link failures, but cases where two docs each assume something that cannot both be true.

**Process:**

1. Read the document. Identify every stated constraint, requirement, decision, and scope claim.

2. Classify each as:
   - **HARD** — grounded in physical reality, mathematical necessity, or irreversible external fact. Cannot be changed without the world changing.
   - **SOFT** — a policy choice. The author chose this; a different choice was available and might be valid.
   - **ASSUMPTION** — stated or implied as fact but not independently verified. Could be wrong.

3. For each related document provided, load it and check whether the same constraint appears there with a compatible classification.

4. Flag:
   - Two documents each treat an incompatible constraint as HARD (structural conflict — cannot both be right)
   - A SOFT constraint presented as HARD, blocking valid implementation alternatives
   - A load-bearing ASSUMPTION that is unvalidated and, if wrong, would invalidate the document's conclusions

**Report only genuine conflicts.** If a related document was not provided, note it as unavailable — do not assume a conflict.

---

## Layer 2 — Hypothesis investigation

You have three mandatory hypotheses. Investigate each one — these are your attack angles. You must report either a finding (with evidence) or an explicit non-finding (with explanation). A hypothesis that produces no finding is still logged as investigated.

**H1 — Unverifiable requirement**
> "This document contains a requirement or principle that no agent can verify as satisfied or violated."

Look for: requirements using words like "appropriate," "sufficient," "reasonable," "high quality," "as needed" — language that gives no observable test. A compliant implementation and a non-compliant one would look identical. Flag any requirement where you cannot describe a concrete observable state that would constitute violation.

**H2 — Silent conflict**
> "This document contradicts the constitution or another ratified document in a way neither acknowledges."

Check the constitution and any related docs provided. Look for: a principle in this doc that is incompatible with a principle elsewhere; a decision that overrides an existing decision without citing it; scope claims that overlap without acknowledging the overlap.

**H3 — False hard constraint**
> "This document treats a policy choice as a hard constraint, blocking valid implementation alternatives that satisfy the functional requirement."

Look for: requirements that specify mechanism rather than outcome ("the system shall use X" vs "the system shall achieve Y"); constraints that eliminate entire implementation families for unstated reasons; decisions framed as permanent that are actually reversible choices. The test: could a different approach satisfy the underlying need? If yes and the doc forecloses it without justification, flag it.

---

## Layer 3 — Validated findings

Collect all candidate findings from Layers 1 and 2. For each candidate, run four gates in sequence. Suppress if any gate fails — log the suppression.

**Gate 1 — VERIFY**
Cite the specific text from the document that constitutes evidence. If you cannot quote or directly reference the supporting text, suppress: "VERIFY — insufficient evidence."

**Gate 2 — YAGNI**
Would any downstream implementer, agent, or dependent document actually be blocked or misled if this defect goes unaddressed? Identify a concrete scenario. If no concrete downstream harm, suppress: "YAGNI — no identifiable downstream impact."

**Gate 3 — Steelman**
Construct the strongest interpretation under which this is intentional and valid. If the steelman holds — if there is a coherent reading in which this is not a defect — suppress: "STEELMAN — [the valid interpretation]."

**Gate 4 — Confidence threshold**
Assign confidence 0–100. Only report findings at ≥80. If below 80, suppress: "CONFIDENCE — [score], below threshold."

**Convergence note:** If the same issue was flagged by both Layer 1 and Layer 2 independently, note this. Convergence raises effective confidence.

---

## Output format

Produce exactly four sections. Do not merge them.

### Section 1: Layer 1 — Cross-doc assumption conflicts

List each conflict found with: constraint text, classification in this doc, classification in referenced doc, why they are incompatible.
If no conflicts: "No cross-doc assumption conflicts identified."

### Section 2: Layer 2 — Hypothesis investigation

For each hypothesis (H1, H2, H3): finding with evidence, or "Not fired — [explanation of what was checked]."

### Section 3: Layer 3 — Validated findings

Findings that passed all four gates, in severity order. Use this format for each:

```
**[{severity}] {slug}** (confidence: {N}, structural)
{Description — what's wrong, with quoted evidence from the document}
**Consequence:** {What breaks, misleads, or degrades if this is not addressed}
**Fix:** {One concrete, actionable step}
[Convergence: also flagged by Layer {N}] (if applicable)
```

Severity mapping:
- Confidence 95–100 with downstream breakage → **Critical**
- Confidence 90–100 with significant impact → **Important**
- Confidence 80–89 → **Suggestion**

If no findings passed all gates: "No findings passed all validation gates."

### Section 4: Suppressed findings

Each suppressed candidate: brief description, which gate triggered, reason.
Format: `- {description} — suppressed at {gate}: {reason}`
If nothing suppressed: "No candidates were suppressed."

---

## What not to do

- Do not report a finding you cannot quote evidence for
- Do not flag a difference between docs as a conflict unless you have loaded and read both docs
- Do not suppress a Critical finding because it is uncomfortable — the steelman gate filters genuine ambiguity, not hard truths
- Do not merge layer output — the four-section structure is required so the orchestrator can extract Layer 3 findings for merging
````

- [ ] **Step 2: Verify the file has valid frontmatter**

```bash
head -5 agents/reviewers/bogey-reviewer.md
```

Expected: YAML frontmatter block with name, description, tools fields.

- [ ] **Step 3: Commit**

```bash
git add agents/reviewers/bogey-reviewer.md
git commit -m "feat: add bogey-reviewer agent — adversarial 3-layer review"
```

---

### Task 3: Update review skill to orchestrate agents

**Files:**
- Modify: `skills/review/SKILL.md`

- [ ] **Step 1: Replace SKILL.md with the orchestrator version**

Overwrite `skills/review/SKILL.md` with the following. Steps 1–4 are preserved from the original. Steps 5–9 are new.

````markdown
---
name: review
description: Validate a spec document against preflight framework rules and structural analysis — dispatches checklist (rule-based) and bogey (adversarial) reviewer agents, merges findings into a single report grouped by severity
---

# Review skill

Validate a spec document by dispatching two reviewer agents and merging their findings. Do not modify the document.

## 1. Resolve docs directory

Read `.preflight/config.yml` and extract the `docs_dir` value. If the file is missing or `docs_dir` is absent, default to `docs/`.

## 2. Determine which file to review

If the user provided a file path argument (e.g., `/preflight review path/to/file.md`):
- Use that path directly. If relative, resolve it from the project root.

If no argument was provided:
- Use Glob to list `{docs_dir}/**/*.md` files.
- Present the list to the user and ask which document to review.
- Wait for the user's selection before proceeding.

## 3. Identify document type

Read the target file. Check YAML frontmatter for a `type` field.

If `type` is present in frontmatter, use it.

If `type` is absent, infer from the file path:

| Path pattern | Doc type |
|---|---|
| `{docs_dir}/decisions/adrs/` | adr |
| `{docs_dir}/decisions/rfcs/` | rfc |
| `{docs_dir}/requirements.md` | requirements |
| `{docs_dir}/architecture.md` | architecture |
| `{docs_dir}/constitution.md` | constitution |
| `{docs_dir}/test-strategy.md` | test-strategy |
| `{docs_dir}/interfaces/` | interface-contract |

If no pattern matches and frontmatter has no `type`, ask the user what document type this is before proceeding.

## 4. Load rules

### 4.0 Verify .preflight/_rules/ exists

Use Bash to check:

```bash
test -d .preflight/_rules/ && echo "EXISTS" || echo "MISSING"
```

If the output is `MISSING`, stop and tell the user: "No `.preflight/_rules/` directory found. Run `/preflight scaffold` first to initialize the project."

### 4.1 Staleness note

The review always uses the project's committed copy of rules in `.preflight/_rules/`. If the plugin has been upgraded since the last scaffold run, the project copy may be out of date. Run `/preflight scaffold` to pull in the latest rules.

### 4.2 Determine rules files to load

**Always load:**
- `.preflight/_rules/universal-rules.md`

**Load type-specific rules if the file exists:**

| Doc type | Rules file |
|---|---|
| requirements | `requirements-rules.md` |
| adr | `adr-rules.md` |
| rfc | `rfc-rules.md` |
| architecture | `architecture-rules.md` |
| constitution | `constitution-rules.md` |
| interface-contract | (none — universal rules only) |
| test-strategy | (none — universal rules only) |

**Conditionally load cross-doc rules:**
- Use Grep to search the document for ID reference patterns: `FR-\d`, `NFR-\d`, `ADR-\d`, `CONST-[A-Z]`
- If any matches are found, also load `.preflight/_rules/cross-doc-rules.md`

Note the list of rules files to load — you will pass these paths to the reviewer agents.

## 5. Discover related documents

Build a list of related document paths for cross-doc analysis:

1. If `{docs_dir}/constitution.md` exists (and is not the doc being reviewed), add it.
2. Grep the document for references: `ADR-(\d+)`, `RFC-(\d+)`, `FR-(\d+)`, `NFR-(\d+)`.
3. For each ADR reference, check if `{docs_dir}/decisions/adrs/adr-{NNN}*.md` exists. Add the first match.
4. For each RFC reference, check if `{docs_dir}/decisions/rfcs/rfc-{NNN}*.md` exists. Add the first match.
5. If any FR or NFR references were found and `{docs_dir}/requirements.md` exists (and is not the doc being reviewed), add it.
6. Cap at 5 related documents total.

## 6. Dispatch checklist-reviewer

Use the Agent tool to dispatch a subagent with this prompt:

> You are the checklist-reviewer. Read the agent prompt at `{plugin_root}/agents/reviewers/checklist-reviewer.md` and follow it exactly.
>
> **Document to review:** {absolute_path_to_document}
> **Document type:** {doc_type}
> **Docs directory:** {docs_dir}
> **Rules directory:** .preflight/_rules/
> **Rules files to load:** {list of rules files from step 4}

Wait for the agent to complete. Save its output.

## 7. Dispatch bogey-reviewer

Use the Agent tool to dispatch a subagent with this prompt:

> You are the bogey-reviewer. Read the agent prompt at `{plugin_root}/agents/reviewers/bogey-reviewer.md` and follow it exactly.
>
> **Document to review:** {absolute_path_to_document}
> **Document type:** {doc_type}
> **Docs directory:** {docs_dir}
> **Rules directory:** .preflight/_rules/
> **Related documents for cross-doc analysis:** {list of paths from step 5}

Wait for the agent to complete. Save its output.

## 8. Merge and deduplicate

Read both agent outputs. Extract findings:
- From checklist-reviewer: all findings directly.
- From bogey-reviewer: only the **Layer 3 — Validated findings** section. Ignore Layer 1, Layer 2, and Suppressed sections for the merged report.

Deduplicate: if two findings describe the same underlying defect (same text quoted, same section targeted, same root cause), keep the one with higher confidence. Note the other source in parentheses.

Sort all findings by severity: Critical first, then Important, then Suggestion.

## 9. Format and report

Present the merged report:

```
## Review: {filename}
Document type: {doc_type} | Rules: {list of rules files loaded}

### Findings

**[Critical] {slug}** (confidence: {N}, {source})
{description with quoted evidence}
**Consequence:** {what breaks or misleads}
**Fix:** {one actionable step}

**[Important] {slug}** (confidence: {N}, {source})
...

**[Suggestion] {slug}** (confidence: {N}, {source})
...

### Strengths
- {from checklist-reviewer strengths section}

### Summary
{N} Critical, {M} Important, {P} Suggestions
Sources: {K} rule-based, {J} structural/cross-doc
```

Where `{source}` is the rule ID (e.g., UNIV-03, ADR-R02) for checklist findings or `structural` for bogey findings.

If no findings from either agent: report **PASS — no findings above confidence threshold**.

## 10. Constraints

- **Advisory only** — do not modify the document. Do not offer to auto-fix.
- Report findings and let the user decide what to act on.
- If either agent fails or times out, report findings from the agent that completed and note the failure.
````

- [ ] **Step 2: Verify the skill still references .preflight/**

```bash
grep -c '.preflight/' skills/review/SKILL.md
```

Expected: at least 1 match (required by test-plugin.sh).

- [ ] **Step 3: Commit**

```bash
git add skills/review/SKILL.md
git commit -m "feat: review skill dispatches checklist + bogey agents (Phase 2)"
```

---

### Task 4: Update tests for new agent files

**Files:**
- Modify: `tests/test-plugin.sh`

- [ ] **Step 1: Add agent file checks to test-plugin.sh**

After the "Skills" section and before the "Commands" section, add a new section:

```bash
# ============================================================
section "Reviewer agents"
# ============================================================

EXPECTED_AGENTS=(checklist-reviewer bogey-reviewer)
for agent in "${EXPECTED_AGENTS[@]}"; do
  agent_file="$PLUGIN_ROOT/agents/reviewers/${agent}.md"
  if [[ -f "$agent_file" ]]; then
    pass "agent file: ${agent}.md"

    # Check frontmatter has required fields
    fm=$(sed -n '/^---$/,/^---$/p' "$agent_file" | head -20)

    if echo "$fm" | grep -q '^name:'; then
      pass "  frontmatter name: ${agent}"
    else
      fail "  missing frontmatter name: ${agent}"
    fi

    if echo "$fm" | grep -q '^description:'; then
      pass "  frontmatter description: ${agent}"
    else
      fail "  missing frontmatter description: ${agent}"
    fi

    if echo "$fm" | grep -q '^tools:'; then
      pass "  frontmatter tools: ${agent}"
    else
      fail "  missing frontmatter tools: ${agent}"
    fi
  else
    fail "agent file missing: ${agent}.md"
  fi
done
```

- [ ] **Step 2: Run tests**

```bash
./tests/test-plugin.sh
```

Expected: All tests pass including the new "Reviewer agents" section.

- [ ] **Step 3: Commit**

```bash
git add tests/test-plugin.sh
git commit -m "test: add reviewer agent file checks to test suite"
```

---

### Task 5: Version bump

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Bump version from 0.4.0 to 0.5.0**

Change the version field in `.claude-plugin/plugin.json`:

```json
"version": "0.5.0",
```

This is the Phase 2 behavioral change authorized by ADR-004.

- [ ] **Step 2: Run full test suite**

```bash
./tests/test-plugin.sh && ./tests/test-hooks.sh
```

Expected: Both test suites pass.

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "chore: bump version to 0.5.0 — Phase 2 reviewer agents"
```

---

### Task 6: Validation runs

Run the ensemble reviewer against all three repos to validate output quality. These are manual review checkpoints, not automated tests.

- [ ] **Step 1: Run against preflight — specs/constitution.md**

From the preflight repo root (which has `.preflight/` scaffolded):

```
/preflight review specs/constitution.md
```

Save the output. Manually review: are findings actionable? Any false positives? Is the output digestible without re-reading the constitution?

- [ ] **Step 2: Run against preflight — specs/requirements.md**

```
/preflight review specs/requirements.md
```

Save and review.

- [ ] **Step 3: Run against preflight — specs/decisions/adrs/adr-004-reviewer-agent-architecture.md**

```
/preflight review specs/decisions/adrs/adr-004-reviewer-agent-architecture.md
```

Save and review. This is a good meta-test — reviewing the ADR that authorizes the reviewer.

- [ ] **Step 4: Run against skunkworks — specs/constitution.md**

From the skunkworks repo (must have `.preflight/` scaffolded):

```
/preflight review specs/constitution.md
```

Save and review.

- [ ] **Step 5: Run against tack-room — specs/requirements.md**

From the tack-room repo (must have `.preflight/` scaffolded):

```
/preflight review specs/requirements.md
```

Save and review. This is the most complex requirements doc in the corpus.

- [ ] **Step 6: Run against tack-room — one ADR and one RFC**

Pick one ADR and one RFC from tack-room's `specs/decisions/`. Run reviews on both. Save and review.

- [ ] **Step 7: Assess results and iterate**

Review all saved outputs. Key questions:
- Are findings actionable without re-reading the source doc?
- Are there false positives? How many?
- Did bogey-reviewer add findings checklist-reviewer missed?
- Is the merged output format digestible?
- Any agent failures or timeouts?

If output quality is good: ADR-004 confirmed. Update ADR-004 status to Accepted.
If minor adjustments needed: iterate on agent prompts, re-run affected docs.
If major rework needed: pause and re-evaluate approach.
