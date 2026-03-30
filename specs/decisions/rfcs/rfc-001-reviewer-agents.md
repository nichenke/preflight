---
status: Draft
date: 2026-03-30
owner: nic
author: nic
version: 0.1.0
type: rfc
reviewers: []
related_requirements:
  - FR-017
  - FR-018
  - FR-019
  - FR-020
  - NFR-001
  - NFR-004
  - NFR-005
resulting_adrs: []
---

# RFC-001: Specialized Reviewer Agents for Document Quality Assessment

## Meta

- Author: nic
- Status: Draft
- Created: 2026-03-30
- Last Updated: 2026-03-30
- Reviewers: TBD — nic
- Related Requirements: FR-017, FR-018, FR-019, FR-020, NFR-001, NFR-004, NFR-005
- Resulting ADRs: (filled after acceptance)

## Executive Summary

The preflight review skill evaluates documents inline against a flat rule table, which cannot scale to deeper quality assessment as rule count grows and cannot express confidence in findings. This RFC proposes replacing the monolithic rule evaluation with specialized review agents — one per doc type — that implement confidence scoring, severity tiering, and two-stage review (rule compliance then quality assessment).

## Problem Statement

The current `review` skill (skills/review/SKILL.md) evaluates all rules for all doc types in a single skill prompt. Three measurable problems result:

1. **Rule evaluation attention degrades at scale.** The review skill is 137 lines and handles rule-table checking across 7 doc types and 40+ rules. As rule counts grow, single-prompt evaluation misses violations that a focused agent would catch. The superpowers project's spec-document reviewer explicitly notes: "Only flag issues that would cause real problems" — a discipline that requires focused attention, not a combined pass over all rule types simultaneously.
2. **Binary findings, no confidence signal.** Every finding is reported as either a violation or not. The pr-review-toolkit and code-review plugin both filter findings at confidence ≥ 80/100 — eliminating false positives before the user sees them. The current review skill produces no signal about certainty, leading to low-confidence warnings that erode trust in the review output.
3. **No quality-level assessment beyond rule compliance.** Rules check structural correctness (frontmatter present, IDs assigned, sections non-empty). They do not assess anti-patterns: RFC with no real alternatives, ADR with no measurable consequences, requirements doc with vague NFRs that technically have numbers. The parallax project's review agents demonstrate that phase-aware finding classification (survey/calibrate/design/plan gap) catches a qualitatively different class of problems than rule checking.

## Scope

### In Scope

- 7 specialized reviewer agents (one per doc type: requirements, adr, rfc, architecture, interface-contract, test-strategy, constitution) in `agents/reviewers/`
- Two-stage review pipeline within each agent: rule compliance (stage 1) then quality assessment (stage 2)
- Confidence scoring 0–100 per finding, with configurable threshold (default: 80)
- Structured output: Critical / Important / Suggestions / Strengths tiers
- False positive exclusion taxonomy embedded in each agent prompt
- Updated `skills/review/SKILL.md` to orchestrate agents instead of inline evaluation
- ExitPlanMode hook (PreToolUse) that suggests preflight doc formats when exiting plan mode in a scaffolded project

### Out of Scope

- Cross-document review agent (single agent reviewing multiple docs simultaneously) — requires multi-file context design, deferred to follow-on RFC
- Auto-fix capabilities — review remains advisory (consistent with current skill behavior)
- Custom agent creation by target project users — agents are plugin-internal
- Agent eval framework based on reverse-judge precision and must-find recall — referenced as future work in the Appendix; the parallax approach is unvalidated

## Proposed Solution

### Agent architecture

Seven agents live under `agents/reviewers/`, one per doc type:

```
agents/
  reviewers/
    requirements-reviewer.md
    adr-reviewer.md
    rfc-reviewer.md
    architecture-reviewer.md
    interface-contract-reviewer.md
    test-strategy-reviewer.md
    constitution-reviewer.md
```

Each agent file has YAML frontmatter (name, description, tools: \[Read, Glob, Grep]) followed by a system prompt with:

- **Role**: domain expertise framing for the specific doc type
- **Stage 1 — Rule compliance**: load applicable rules from `.preflight/_rules/`, evaluate each rule, assign confidence 0–100 per finding
- **Stage 2 — Quality assessment**: apply doc-type-specific quality heuristics (anti-patterns from the rules-source files, completeness checks, structural patterns)
- **False positive exclusion list**: pre-existing issues out of scope, implementation-detail nitpicks, style preferences, hypothetical future concerns, context-dependent findings
- **Output format**: structured findings with rule_id, severity, tier, confidence, violation description, fix suggestion, location

### Confidence and severity tiers

Confidence score (0–100):

- 0–49: Do not report (false positive or too uncertain)
- 50–79: Do not report (valid but below threshold)
- 80–89: Report as Suggestion
- 90–99: Report as Important
- 100: Report as Critical

Severity tiers map to existing review output:

- **Critical** (confidence 100): must fix — maps to Error severity rules at maximum confidence
- **Important** (confidence 90–99): should fix — high-confidence violations of Warning-severity rules, or lower-confidence Error violations
- **Suggestions** (confidence 80–89): nice to have — valid findings below Important threshold
- **Strengths**: what the document does well — quality stage only, no rule mapping

### Updated review skill flow

`skills/review/SKILL.md` becomes an orchestrator:

1. Steps 1–4 unchanged: resolve file, identify type, verify `.preflight/_rules/` exists, load rules (unchanged — agents still load rules, but from within their own prompts)
2. **Step 5 (changed)**: dispatch to the appropriate reviewer agent based on doc type, passing the document path and applicable rules paths
3. **Step 6 (changed)**: receive structured findings from agent, filter below confidence threshold, format into report (Error/Warning grouping maintained for backward compatibility — Critical/Important map to Error/Warning in the output header)
4. **Step 7 (new)**: report Strengths at end of output

### ExitPlanMode hook

A PreToolUse hook fires when Claude calls `ExitPlanMode` in a preflight-scaffolded project:

- `hooks/hooks.json`: registers a PreToolUse hook with `matcher: "ExitPlanMode"`
- `hooks/exit-plan-mode.sh`: pure bash script, no external dependencies
  - Checks if `.preflight/_templates` exists; exits 0 silently if not (non-preflight project)
  - Outputs a `systemMessage` JSON suggesting the appropriate `/preflight new` command
  - Never blocks ExitPlanMode (always exits 0)

The hook operates as guidance, not enforcement — it surfaces the option to capture the plan as a preflight document without requiring it.

## Alternatives Considered

- **Keep monolithic review skill, add more rules**
  - Description: Continue inline evaluation within SKILL.md, append new rules to the table
  - Pros: No architectural change, simpler to maintain a single file
  - Cons: Attention limits get worse as rule count grows; no path to confidence scoring or quality assessment; fundamentally different class of review (quality heuristics) can't be added as rule table rows
  - When to reconsider: If rule count stabilizes below 20 per doc type and quality issues remain rare
- **Single universal reviewer agent, parameterized by doc type**
  - Description: One agent that receives the doc type and applicable rules as parameters
  - Pros: One file to maintain, consistent prompting structure
  - Cons: Loses specialization — requirements quality heuristics (EARS pattern violations, vague NFRs) require different reasoning than ADR quality heuristics (no measurable consequences, missing confirmation criteria); single prompt handling all types is the same problem as the monolithic skill
  - When to reconsider: If prompt quality proves equivalent across doc types in eval runs
- **External shell script rule checker**
  - Description: Bash script using grep/sed to check rules mechanically
  - Pros: NFR-001 compatible, fast, deterministic
  - Cons: Can only check mechanical properties (section exists, ID pattern matches); cannot evaluate quality, completeness, or semantic correctness; eliminates the primary value of an LLM reviewer
  - When to reconsider: Never for quality assessment; could supplement agents for mechanical checks

## Migration / Rollout Plan

**Phase 1** — Additive (this RFC): Add agent files alongside existing review skill, add hook files, add tests. No behavior change to review skill in phase 1. Agents exist but are not invoked yet. Version bump: 0.3.0 → 0.4.0.

**Phase 2** — Review skill orchestration (follow-on): Update `skills/review/SKILL.md` to dispatch to agents instead of inline evaluation. Version bump: 0.4.0 → 0.5.0. Requires ADR-004 (behavioral change to review output format).

**Rollback plan**: Phase 1 is fully additive — rollback means removing the agent files and hook files. Phase 2 rollback: revert `skills/review/SKILL.md` to the pre-agent version; the agents remain but are not invoked. No data migration required — no persistent state is written.

**Backward compatibility**: The review output format in phase 1 is unchanged. Phase 2 adds confidence and tier fields to the output, but the Error/Warning grouping header is preserved for scripts or users reading the output format.

## Risks & Open Questions

### Known Risks

- Risk: Agent prompts may be too long, causing degraded output quality on smaller models
  - Likelihood: Medium
  - Impact: High (defeats the purpose of specialization)
  - Mitigation: Each agent covers only one doc type; keep stage 1 focused on rules, stage 2 on heuristics; measure with skill-creator evals before shipping phase 2
- Risk: Confidence scores are subjective without calibration data
  - Likelihood: High
  - Impact: Medium (threshold may need tuning; wrong threshold causes false positives or false negatives)
  - Mitigation: Calibrate threshold with eval suite using this RFC itself as the initial scoring subject — run the reviewer agent against RFC-001 and the source material RFCs (BMAD, GSD v2, Kiro) as ground truth; parallax's reverse-judge precision approach (see Appendix) is a validated calibration method worth adopting in a follow-on
- Risk: ExitPlanMode hook may be noisy in non-spec contexts
  - Likelihood: Medium
  - Impact: Low (advisory only, never blocks; easy to ignore)
  - Mitigation: Hook already skips projects without `.preflight/_templates`; no action needed unless user feedback indicates noise

### Open Questions

- ~~Question: Should the review skill in phase 2 run both stages sequentially (one agent call) or dispatch separate agents for each stage?~~
  - **Resolved:** Dispatch separate agents per stage — cleaner separation of concerns, independent failure modes
  - Closed: 2026-03-30
- ~~Question: Should the confidence threshold be configurable via `.preflight/config.yml`?~~
  - **Resolved:** Yes — threshold is configurable via `.preflight/config.yml` (key: `review.confidence_threshold`, default: 80)
  - Closed: 2026-03-30

## Dependencies

- Other teams affected: None
- Services that need changes: None
- External systems: None
- Timeline dependencies: ADR-004 (behavioral change authorization) must be accepted before phase 2 ships

## Success Criteria

- All 7 reviewer agent files exist with valid frontmatter and pass plugin structure validation (NFR-006)
- Hook tests pass: exit 0 in all cases, no output outside preflight projects, correct system message in preflight projects (NFR-005)
- `tests/test-plugin.sh` passes with new Hooks section (NFR-005)
- Phase 2 (follow-on): review skill evals show ≥85% rule-following accuracy with confidence filtering, false positive rate ≤15% on well-formed documents (NFR-004)

---

## Appendix: Source Material for Future Review

The following frameworks were surveyed during RFC research. They are included for future reference but have not been validated against preflight's constraints.

### parallax (experimental — [nichenke/parallax](https://github.com/nichenke/parallax))

10 review agents with phase-aware finding classification (survey / calibrate / design / plan). Key patterns worth evaluating:

- **Reverse-judge precision scorer**: for each finding, asks a judge LLM "Is this genuine?" — measures precision directly rather than relying on threshold tuning
- **Must-find recall scorer**: given a curated ground-truth flaw list, asks "Did the reviewer find this?" — measures recall
- **Blind-spot check**: meta-finding appended to every review asking what the agent might have missed
- **False positive exclusion list**: pre-existing issues, hallucinated constraints, style preferences, hypothetical futures, context-dependent findings — should be adapted for doc review

### BMAD ([bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD))

12+ named agents (Analyst, PM, Architect, Developer, QA, Orchestrator) in four phases with human checkpoints. Relevant to preflight: dedicated QA agent as independent reviewer (not the Developer agent reviewing its own work), file-based context handoff (PRD feeds Architect, architecture feeds Developer).

### GSD v2 ([gsd-build/gsd-2](https://github.com/gsd-build/gsd-2))

State machine pipeline: Plan → Execute → Complete → Reassess → Validate. Fresh context per task prevents context rot. Relevant: Reassess as an explicit pipeline stage (not just a pass/fail); context budget management (orchestrator uses 15% budget, spawns subagents).

### Kiro ([kirodotdev/Kiro](https://github.com/kirodotdev/Kiro))

Spec-driven: converts specs to Hypothesis property tests. Separate implementation agent and property test generation agent. Closest to a holdout model — the test generator has no knowledge of the implementation, only the spec.
