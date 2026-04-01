---
date: 2026-03-31
reviewer: preflight-review (checklist-reviewer + bogey-reviewer)
document: /Users/paipilot/src/pai-projects/skunkworks/projects/tack-room-program/docs/requirements/requirements.md
doc_type: requirements (program-level)
rules_applied:
  - universal-rules.md (v2.0.0)
  - requirements-rules.md (v2.0.0)
  - program-requirements-rules.md (v1.0.0)
  - cross-doc-rules.md (v2.0.0)
related_docs_loaded:
  - /Users/paipilot/src/pai-projects/skunkworks/projects/tack-room-program/docs/spikes/constitution.md
  - /Users/paipilot/src/pai-projects/skunkworks/specs/constitution.md
  - ADR-001, ADR-004 (sampled for cross-doc)
---

# Requirements review — Tack Room program

Document: `requirements.md` v0.5.0, status Draft, owner Nic, dated 2026-03-28.

---

## Checklist-reviewer pass

### Stage 1 — Rule compliance

---

**[Important] multiple-nfrs-lack-quantitative-criteria** (confidence: 92, REQ-R04)

NFR-003, NFR-004, NFR-006, and NFR-007 all explicitly state their quantitative acceptance criteria are deferred:

- NFR-003: "Quantitative target to be set after first 10 learnings transported."
- NFR-004: "Quantitative timeout to be set after baseline observation of blocker frequency and resolution patterns."
- NFR-006: "Minimum retention period to be set after 3 months of observation."
- NFR-007: "Quantitative target to be set after monthly reviews establish a baseline."

REQ-R04 requires every NFR to have a quantitative acceptance criterion. Four of seven NFRs have none.

**Consequence:** Agents and implementers have no testable acceptance threshold for nearly 60% of the NFR set. Review gates based on NFR satisfaction cannot fire — pass/fail is undefined.

**Fix:** For each of the four NFRs, add a qualitative acceptance criterion now (e.g., "must not require manual acknowledgment to continue" for NFR-004) even if quantitative targets are deferred. The current state admits any implementation as compliant.

---

**[Important] claude-code-in-constraints-is-implementation-choice** (confidence: 95, PROG-R15)

The Constraints section states: "Claude Code is the current execution environment (implementation choice, not a permanent constraint)." The document simultaneously places it in the Constraints section and labels it "not a permanent constraint." These are incompatible positions.

**Consequence:** Downstream implementers reading Constraints to understand hard boundaries will be confused about whether Claude Code is binding. Agents scaffolding architecture from this document may inadvertently treat it as a hard constraint or as a non-constraint — with no way to resolve the ambiguity from the text alone.

**Fix:** Remove "Claude Code is the current execution environment" from Constraints entirely. If this reflects an active ADR decision, reference the ADR by ID. If no ADR exists, move it to Assumptions with a validation plan.

---

**[Important] success-measures-targets-incomplete** (confidence: 88, REQ-R06)

The success measures table requires baseline, target, and measurement method. Multiple rows have placeholder or deferred targets:

- "Work quality over time" target: "First-pass quality improves over time" — qualitative, no definition of what measurable improvement looks like.
- "On-the-loop feature completion" target: "Spec'd workstreams increasingly complete without Nic taking over execution" — qualitative, measurement deferred ("set quantitative target from that baseline").

REQ-R06 requires baseline, target, and measurement method in the success measures.

**Consequence:** The program has no quantitative completion criteria. Milestone reviews cannot produce a defensible pass/fail verdict. The targets are functionally unfalsifiable.

**Fix:** For each qualitative target, either add a threshold ("X% of workstreams complete without takeover") or explicitly mark as "target to be set after baseline month" and add a due date. The current text implies targets exist when they don't.

---

**[Important] unresolved-notion-comment-markup-in-constraints** (confidence: 95, UNIV-03)

The document contains raw Notion comment export syntax in substantive positions. Three instances in section 7 (Constraints) and section 9 (Out of Scope):

- Section 7: `macOS :comment[only]{#comment-1774737122164 text="primarily, linux for hosted agents..."}`
- Section 9: `**Automated learning transport:** :comment[Manual bridge first (PROG-04 is last priority)]{#comment-1774737178852...}`
- Section 9: `**Elaborate validation infrastructure:** :comment[Yolo-in-prod for personal tools]{#comment-1774737210713...}`

The embedded comment text contains editorial material that changes the meaning of the surrounding text (e.g., the Linux note materially modifies the platform constraint), but it is not rendered as spec content — it is buried in a markup artifact.

**Consequence:** Agents and reviewers reading the document see `macOS only` as the constraint text. The clarification that Linux is a secondary supported platform for hosted agents is invisible unless the reviewer specifically inspects the raw markup. This creates a silent scope discrepancy between the stated constraint and the author's intent.

**Fix:** Resolve each comment inline: promote important notes to spec text (e.g., revise the platform constraint to "macOS for home and work machines; Linux secondary for hosted agents"), and discard editorial comments that are not load-bearing.

---

**[Suggestion] nfr-004-promptly-is-vague** (confidence: 90, UNIV-04)

NFR-004: "On-the-loop execution shall report blockers **promptly** rather than stalling silently."

"Promptly" is a vague adjective without quantification (UNIV-04). The corresponding FR-003 mentions "a configurable timeout period" but NFR-004 does not reference or constrain it.

**Consequence:** Two implementations — one that reports blockers in 10 seconds and one that reports in 10 minutes — are both compliant with NFR-004 as written.

**Fix:** Replace "promptly" with a threshold ("within a configurable timeout not to exceed X seconds by default") or reference FR-003 explicitly: "blockers shall be reported within the configurable timeout defined in FR-003."

---

**[Suggestion] learning-defect-prevention-measure-describes-mechanism** (confidence: 82, PROG-R11)

The "Learning impact — defect prevention" success measure's "How we'll know" column reads: "Primary: session-level data — track corrections, flag repeats after rules added."

This describes the tracking mechanism, not the outcome being measured. PROG-R11 requires success measures to describe the outcome, not the implementation mechanism used to measure it.

**Consequence:** Reviewers cannot evaluate whether the program is succeeding without also knowing whether the tracking mechanism is correctly implemented. The outcome (fewer repeated mistakes) is buried behind the mechanism description.

**Fix:** Rewrite the "How we'll know" text to describe the observable outcome: "Repeated corrections on the same pattern decrease after a rule is added for that pattern. Verified by monthly review comparing correction frequencies before and after rule addition."

---

### Stage 2 — Quality assessment

---

**[Important] claude-code-constraint-is-outcome-shaped-implementation** (confidence: 90, quality)

Anti-pattern: **outcome-shaped implementation**. The Constraints section names "Claude Code" as the execution environment. As the program-requirements rules note, constraints at program level should be genuinely non-negotiable business boundaries. "Claude Code" is not the outcome — "AI-assisted autonomous execution" is the outcome. Naming a specific tool as a constraint converts a design choice into a hard boundary without rationale.

The document partially acknowledges this ("implementation choice, not a permanent constraint") but does not remove the item.

**Consequence:** Future architecture and design work will treat Claude Code as a floor constraint when evaluating alternatives, even if the author intended it as a default. The self-contradiction in the text will be resolved in favor of the containing section's label ("Constraints") by automated agents.

**Fix:** Remove from Constraints. If Claude Code is the current implementation vehicle, record that in an ADR and reference it here by ID. If no ADR exists, the decision should get one before being enshrined in program requirements.

---

**[Suggestion] fr-010-fr-011-name-techniques-not-behaviors** (confidence: 80, quality)

Anti-pattern: **premature specificity**. FR-010 and FR-011 include technique names as examples:

- FR-010: "at least two independent perspectives (e.g., reviewer + attacker, council debate, red team)"
- FR-011: "multiple distinct analytical approaches (e.g., decomposition from fundamentals, progressive depth exploration, multi-perspective debate)"

The core requirements are correctly behavioral. The "(e.g., ...)" clauses name specific techniques that tie the requirement to a particular implementation family. PROG-R13 warns against defining capabilities by naming specific tools or techniques.

**Consequence:** Low risk at the example/parenthetical level. However, agents implementing to spec may anchor on the named techniques rather than finding the best approach that satisfies the behavioral requirement.

**Fix:** If the parenthetical examples are editorial (illustrative only), mark them explicitly: "(e.g., in the sense of 'multiple viewpoints' — implementation is a design choice)." If they are intended as actual constraints, move them to an ADR.

---

### Strengths

1. **EARS notation is consistently applied.** All 33 FRs use correct EARS patterns (When/While/Where/If-then/Ubiquitous as appropriate) with proper actor/trigger/response structure. This is unusually clean for a v0.5.0 draft.

2. **Outcome-first structure.** The document leads with problem statement and outcome vision before any requirements. The success measures table structure (baseline + target + measurement method) is well-formed even where cells are underpopulated.

3. **Explicit scope management.** The Out of Scope section names specific exclusions with rationale. FR-006 explicitly documents scope progression (session → workstream → project → program), which grounds the scope constraint in behavioral requirements rather than just policy.

**Summary: 0 Critical, 4 Important, 3 Suggestions** (checklist pass)

---

## Bogey-reviewer pass

### Section 1: Layer 1 — Cross-doc assumption conflicts

**Conflict 1: Platform constraint vs spike constitution scope**

The requirements document states (section 7 Constraints): "**Platform:** macOS only (home and work machines)." This is treated as a hard boundary.

The spike execution constitution (`docs/spikes/constitution.md`) states in CONST-SPIKE-TEST-01: "All spike artifacts shall be tested in a temporary environment (`/tmp/claude-spike-NNN/` or equivalent)..." The `/tmp/...` path pattern is Linux-conventional and may differ on macOS (`$TMPDIR` is `/var/folders/...`). More substantively, the Notion comment embedded in the platform constraint reads: "primarily, linux for hosted agents (docker, VM, etc) secondary." This indicates the author intends Linux support for hosted agent scenarios.

Classification in requirements.md: **HARD** (platform constraint)
Classification in spike constitution: **ASSUMPTION** (implicitly assumes `/tmp/`-style paths work, consistent with Linux secondary support)

These are not directly incompatible — but the requirements document's stated constraint ("macOS only") conflicts with its own author note and with spike execution patterns that presuppose Linux compatibility for hosted agents.

**Conflict 2: "Full capability set without modification" vs "no validation infrastructure"**

FR-024 requires: "when installed in a new environment, the system shall provide the full capability set (execution, learning, research, review, thinking) without modification."

The Out of Scope section states: "**Elaborate validation infrastructure:** Yolo-in-prod for personal tools."

FR-024 is classified as **HARD** (a program requirement). The out-of-scope validation statement is **SOFT** (policy choice). ADR-004 references FR-024 as a decision driver. However, FR-024 makes no claim about whether capabilities can be validated — it only requires they be present. The conflict is not between the documents but within the requirements: you cannot claim "full capability set...without modification" is satisfied without some validation evidence, yet the document explicitly declines to build validation infrastructure.

This is an internal tension: the requirement sets a bar that the document simultaneously disclaims the ability to verify.

---

### Section 2: Layer 2 — Hypothesis investigation

**H1 — Unverifiable requirement**

**Fired.** Two findings:

1. NFR-007: "Adversarial review shall surface non-obvious concerns in reviewed artifacts. Quantitative target to be set after monthly reviews establish a baseline."

"Non-obvious" has no operational definition. There is no test that distinguishes an obvious finding from a non-obvious one. An implementation that produces only trivially obvious findings satisfies NFR-007 as written — because "non-obvious" is in the eye of the beholder. The success measure row for "Adversarial review value" acknowledges the measurement challenge ("sample recent reviews, assess whether findings added value Nic wouldn't have caught solo") but this requires a human judgment call with no threshold. A compliant implementation and a non-compliant one look identical to any automated test.

2. NFR-003: "Learning transport shall preserve distilled learnings such that they are applicable and actionable in the target environment."

"Applicable and actionable" is undefined. These terms have no observable test — two implementations that produce different learning outputs (one useful, one not) are both compliant if both deliver learnings that someone could claim are "applicable."

**H2 — Silent conflict**

**Partially fired.**

The requirements document states in section 7: "**Platform:** macOS only (home and work machines)." The parent project constitution (`specs/constitution.md`) CONST-BUILD-05 states: "Both home and work contexts from day one. Not home-first-then-work. Simultaneous. **Work data cannot bleed to home.** Work learnings can be distilled, stripped of work-specific data."

These are not in conflict. However, the requirements document's FR-025 states: "While installed in multiple environments, the system shall ensure runtime state in one environment is not readable or writable from another environment." CONST-BUILD-05 says "work learnings can be distilled." FR-028 through FR-030 address learning transport. These are compatible — but the requirements document does not acknowledge that FR-025 (strict isolation) and FR-028/FR-029 (cross-environment learning) must coexist without contradiction. The "distilled learnings" exception to isolation is implicit in the FRs but never stated as a deliberate carve-out. This is a silent scope tension, not a contradiction.

**H3 — False hard constraint**

**Fired.**

The Constraints section states: "**Model:** Claude is the underlying AI model. Claude Code is the current execution environment (implementation choice, not a permanent constraint)."

"Claude is the underlying AI model" is presented as a hard constraint with no qualification. This is a **SOFT** constraint wearing a **HARD** label. The program defines what the system must do (outcomes, journeys, FRs). Whether Claude is the model is an implementation choice that depends on what meets the behavioral requirements. Framing it as a hard constraint forecloses alternatives that might satisfy all FRs — including future Anthropic models, locally-hosted models, or competing AI systems — without any justification for why those alternatives are ruled out.

The document itself partially understands this: it marks Claude Code as "implementation choice, not a permanent constraint" but makes no equivalent qualification for "Claude is the underlying AI model."

---

### Section 3: Layer 3 — Validated findings

**[Critical] non-obvious-nfr-is-untestable** (confidence: 95, structural)

NFR-007: "Adversarial review shall surface **non-obvious** concerns in reviewed artifacts."

Gate 1 — VERIFY: Text is directly quoted.
Gate 2 — YAGNI: Any agent implementing adversarial review capability cannot determine whether its output satisfies NFR-007 without an external human judgment. Acceptance testing against NFR-007 is impossible to automate. If this requirement is used as a milestone gate (per FR-031), the validation type cannot be "automatable" — but the document provides no alternative validation method for NFR-007.
Gate 3 — Steelman: "Non-obvious" could be interpreted as a quality signal, not a threshold. The success measure row provides the measurement method ("sample reviews, assess whether findings added value Nic wouldn't have caught solo"). Steelman does not hold — the success measure itself requires subjective judgment without a threshold, making it advisory rather than a gate criterion.
Gate 4 — Confidence: 95.

**Consequence:** Milestone reviews that include adversarial review quality as a gate criterion cannot produce a defensible pass verdict. The requirement is unfalsifiable without a threshold or operational definition of "non-obvious."

**Fix:** Replace "non-obvious" with an operational criterion: "At least one finding per reviewed artifact that was not present in Nic's own review of the same artifact" — or defer to the success measure and remove the word from the NFR body entirely, leaving the measurement in the success measures table.

[Convergence: also flagged by H1 in Layer 2]

---

**[Critical] claude-as-model-is-false-hard-constraint** (confidence: 92, structural)

Section 7 Constraints: "**Model:** Claude is the underlying AI model."

Gate 1 — VERIFY: Directly quoted. No qualification accompanies this statement (unlike the Claude Code entry which is marked "implementation choice").
Gate 2 — YAGNI: An architect working from these requirements would treat "Claude as model" as a non-negotiable constraint when selecting and designing the execution runtime. Implementation alternatives (self-hosted models, future Anthropic models beyond "Claude") are foreclosed without a stated rationale. ADR-001 and ADR-004 were written under this constraint assumption.
Gate 3 — Steelman: "Nic has chosen Claude and this is a personal tool — of course Claude is the model." This is a valid business decision for a personal tool. The steelman holds on intent. However, at program requirements level, embedding an implementation choice as a hard constraint without an ADR violates PROG-R15/R16 — the concern is structural, not whether the choice is reasonable.
Gate 4 — Confidence: 92.

**Consequence:** Without an ADR, there is no documented rationale for why this is a hard constraint vs. a soft default. Future maintainers (or agents) cannot distinguish "non-negotiable business requirement" from "current implementation default." If Claude is truly a hard boundary, an ADR should say why — model capabilities, API availability, Nic's personal preference. As a constraint without rationale, it creates ambiguity that will be resolved differently by different implementers.

**Fix:** Create an ADR that documents why Claude is a hard constraint (or acknowledges it as a current default that could change). Reference the ADR in Constraints. This makes the constraint traceable and revisable when circumstances change.

[Convergence: also flagged by H3 in Layer 2]

---

**[Important] isolation-carve-out-for-learning-transport-is-implicit** (confidence: 85, structural)

FR-025: "While installed in multiple environments, the system shall ensure runtime state in one environment is not **readable or writable** from another environment."

FR-028: "Where learning transport is configured, the system shall make distilled learnings (patterns, rules, corrections) from one environment available in the other."

Gate 1 — VERIFY: Both requirements are directly quoted.
Gate 2 — YAGNI: An implementer reading FR-025 in isolation will design a hard isolation boundary. FR-028 then requires punching a read path through that boundary. The two requirements are compatible only with a deliberate "distilled learnings are not runtime state" carve-out — but that carve-out appears nowhere in the document. A compliant implementation of FR-025 that blocks all cross-environment reads would fail FR-028.
Gate 3 — Steelman: FR-029 clarifies that "the system shall exclude environment-specific data" during transport. One could read this as implicitly defining the boundary: runtime state = project state, and distilled learnings are distinct. This steelman is plausible but requires significant inference — it is not stated.
Gate 4 — Confidence: 85.

**Consequence:** An agent implementing FR-025 as a hard isolation constraint will produce a system that violates FR-028. The missing carve-out means the two requirements are practically contradictory without an explicit definition of which data categories qualify as "runtime state" vs. "distilled learnings."

**Fix:** Add a clarifying statement to FR-025 or to a new definitional section: "Runtime state excludes distilled learnings (patterns, rules, corrections) as defined in FR-028 through FR-030. Learning transport is an explicitly permitted cross-environment read path."

---

### Section 4: Suppressed findings

- "XDOC-09: FR/NFR coverage by architecture or tests" — suppressed at YAGNI: document is Draft v0.5.0 with no architecture doc yet present in the project. Expecting FR coverage by architecture components is premature for a pre-architecture draft.
- "PROG-R08: success measures session-scoped" — suppressed at Steelman: "Project resume friction" measures a per-session behavior that is the direct expression of the program outcome (instant startup). Session-scoped measurement is appropriate here because the outcome is inherently per-session.
- "REQ-R03: FR-026 references a specific file path" — suppressed at Steelman: the file path in FR-026 is a pointer to documentation, not a prescription of implementation mechanism. It does not constrain how prerequisites are validated, only where post-install documentation lives.
- "PROG-R13: FR-009 names 'web, documentation, code, APIs' as source types" — suppressed at CONFIDENCE (75): these are categories of sources, not specific tools. Below threshold.
- "FR-026 passive voice — 'The installation mechanism shall'" — suppressed at Steelman: "The installation mechanism" is a component-level actor that is clearly defined by context. Not materially ambiguous.
- "CONST-BUILD-05 vs FR-025 silent conflict (H2)" — suppressed at Steelman: FR-028/29 provide explicit learning transport FRs that represent the intended carve-out. The tension exists but the same document resolves it (promoted to Layer 3 as a precision finding, not a cross-doc conflict).

---

## Merged summary

The following table deduplicates findings from both passes. Findings that appeared in both passes are marked with a convergence note.

| # | Severity | Slug | Source | Convergence |
|---|----------|------|--------|-------------|
| 1 | Critical | non-obvious-nfr-is-untestable | H1 + checklist (NFR-007 + REQ-R04 overlap) | Bogey H1 + Checklist REQ-R04 |
| 2 | Critical | claude-as-model-is-false-hard-constraint | Bogey H3 + Layer 3 | Bogey H3 + Layer 3 |
| 3 | Important | multiple-nfrs-lack-quantitative-criteria | Checklist REQ-R04 | — |
| 4 | Important | claude-code-in-constraints-is-implementation-choice | Checklist PROG-R15 + Bogey H3 | Checklist + Bogey H3 |
| 5 | Important | isolation-carve-out-for-learning-transport-is-implicit | Bogey Layer 3 | — |
| 6 | Important | success-measures-targets-incomplete | Checklist REQ-R06 | — |
| 7 | Important | unresolved-notion-comment-markup-in-constraints | Checklist UNIV-03 | — |
| 8 | Important | claude-code-constraint-is-outcome-shaped-implementation | Checklist quality | Overlaps with finding 4 |
| 9 | Suggestion | nfr-004-promptly-is-vague | Checklist UNIV-04 | — |
| 10 | Suggestion | learning-defect-prevention-measure-describes-mechanism | Checklist PROG-R11 | — |
| 11 | Suggestion | fr-010-fr-011-name-techniques-not-behaviors | Checklist quality | — |

Note: findings 4 and 8 are the same underlying issue (Claude Code in Constraints); they are listed separately above to preserve traceability to each pass but should be addressed together.

**Merged summary: 2 Critical, 6 Important (including 1 duplicate), 3 Suggestions**

Highest-priority fixes in order:
1. Define "non-obvious" in NFR-007 operationally, or remove it from the NFR and leave measurement to the success measures table.
2. Create an ADR for "Claude as underlying model" and reference it from Constraints, or move it to Assumptions.
3. Remove Claude Code from Constraints or move to a referenced ADR.
4. Add a definitional carve-out clarifying that distilled learnings are not "runtime state" under FR-025.
5. Resolve the four NFRs with no current quantitative criteria — add qualitative acceptance thresholds now, defer quantitative targets with explicit dates.
6. Strip the `:comment[...]` Notion markup from section 7 and 9, promoting load-bearing notes to spec text.
