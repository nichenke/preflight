# Ensemble reviewer — Phase 2 design

## Overview

Build the ensemble reviewer architecture authorized by ADR-004: `checklist-reviewer` (rule-based, impl-c) as primary + `bogey-reviewer` (adversarial, impl-d) as complement. Update `skills/review/SKILL.md` to orchestrate both as subagents and merge output into a single report.

## Files

```
agents/reviewers/checklist-reviewer.md   # Rule-based reviewer (impl-c)
agents/reviewers/bogey-reviewer.md       # Adversarial reviewer (impl-d)
skills/review/SKILL.md                   # Updated orchestrator
```

## Orchestrator flow (SKILL.md)

Steps 1–4 unchanged: resolve docs_dir, find file, identify type, load rules.

**Step 5 — Discover related docs.** Before dispatching agents:
1. Always include `{docs_dir}/constitution.md` if it exists
2. Grep the document for ID references (ADR-NNN, RFC-NNN, FR-NNN, NFR-NNN, CONST-)
3. Resolve ADR/RFC references to `{docs_dir}/decisions/adrs/` or `{docs_dir}/decisions/rfcs/`
4. Include `{docs_dir}/requirements.md` if any FR/NFR references found
5. Cap at 5 related docs

**Step 6 — Dispatch checklist-reviewer subagent.** Pass: document path, doc type, rules file paths, docs_dir. Agent reads doc + rules, produces structured findings.

**Step 7 — Dispatch bogey-reviewer subagent.** Pass: document path, doc type, repo root, `.preflight/_rules/` path, related doc paths from step 5. Agent runs 3-layer architecture, produces structured findings.

**Step 8 — Merge and deduplicate.** Read both outputs. Deduplicate by substance (not slug). Take higher confidence on duplicates. Sort by severity.

**Step 9 — Format and report.** Single merged report.

## Output format

```
## Review: {filename}
Document type: {type} | Rules: {rules files loaded}

### Findings

**[Critical] {slug}** (confidence: {N}, {rule_id or "structural"})
{What's wrong — specific, with quoted evidence from the doc}
**Consequence:** {What breaks or misleads if unaddressed}
**Fix:** {One concrete action}

**[Important] {slug}** (confidence: {N}, {rule_id or "structural"})
...

**[Suggestion] {slug}** (confidence: {N}, {rule_id or "structural"})
...

### Strengths
- {What the document does well}

### Summary
{N} Critical, {M} Important, {P} Suggestions
Sources: {K} rule-based, {J} structural/cross-doc
```

Findings grouped by severity, not by source agent. Source tagged as rule_id or "structural" for traceability. Consequence line on every finding. Quoted evidence so you can evaluate without opening the source doc.

## Checklist-reviewer agent design

Two-stage review in a single subagent invocation.

**Stage 1 — Rule compliance.** Load all applicable rules files passed by the orchestrator. Evaluate each rule against the document. For each violation: assign confidence 0–100, severity (Critical for Error rules at high confidence, Important for Warning rules at high confidence or Error at moderate confidence, Suggestion for lower confidence valid findings). Quote evidence.

**Stage 2 — Quality assessment.** Apply the anti-patterns section from the doc-type rules file (e.g., ADR anti-patterns like "retroactive justification," "consequence-free decisions"). These produce findings tagged as quality judgments rather than rule IDs.

**False positive discipline.** Don't fire rules whose preconditions aren't met (e.g., RFC-R05 on a Draft RFC). Don't flag rules the document satisfies. Don't invent violations.

**Output:** Structured list of findings: slug, rule_id (or "quality"), severity tier, confidence, description with quoted evidence, consequence, fix.

## Bogey-reviewer agent design

Ported from the spike's adversarial-reviewer.md with two production adjustments:

1. **Generic cross-doc loading.** The orchestrator passes related doc paths instead of hardcoded corpus paths. Layer 1 loads the document + passed related docs.
2. **Output format alignment.** Validated findings use the same structured format as checklist-reviewer (slug, source tagged "structural", severity, confidence, description, consequence, fix). Layer attribution in metadata, not main output.

The 3-layer architecture is unchanged:
- **Layer 1:** HARD/SOFT/ASSUMPTION constraint decomposition + cross-doc conflict detection
- **Layer 2:** Three pre-committed hypotheses (H1: unverifiable requirement, H2: silent conflict, H3: false hard constraint)
- **Layer 3:** VERIFY → YAGNI → Steelman → confidence ≥80 gates

Four-section output preserved (L1, L2, L3 validated, suppressed). The orchestrator extracts validated findings from L3 for merging. Suppressed findings stay in the raw agent output but don't appear in the merged report.

## Acceptance criteria

ADR-004 acceptance is gated on manual review of actual output:
- Run against preflight, skunkworks, and tack-room repos
- Findings must be actionable with minimal false positives
- Output must be digestible without deep re-reading of source docs
- Some iteration expected; major rework signals pause-and-re-evaluate
