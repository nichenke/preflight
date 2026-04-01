---
date: 2026-03-31
reviewer: checklist-reviewer + bogey-reviewer
document: specs/requirements.md
---

## Review: requirements.md

Document type: requirements | Rules: universal-rules.md, requirements-rules.md, cross-doc-rules.md

---

### Findings

#### Critical

None.

---

#### Important

**\[Important] compound-fr-023** (confidence: 90, quality)
FR-023 contains two distinct behaviors under one ID: "the plugin shall identify downstream docs (requirements, architecture, constitution, interfaces) that need updates to reflect the decision, propose specific changes, and apply approved changes" AND "The plugin shall flag any ADR consequences that cannot be traced to a downstream doc." Identify+propose+apply is an interactive workflow; flagging is a passive check. These are separate activation modes bundled into one requirement.
**Consequence:** An implementer cannot tell whether partial fulfillment (flag only, or identify but not apply) passes the requirement. Tests cannot target each behavior independently. A future agent could satisfy one half while ignoring the other.
**Fix:** :comment[Split FR-023 into two IDs — FR-023 for the identify/propose/apply propagation workflow, and FR-024 for the flag-when-no-downstream-doc behavior.]{#comment-1774989915869 text="agree"}

---

**\[Important] nfr-004-misses-const-qa01-baseline** (confidence: 88, structural)
NFR-004 defines the quality gate as "scoring ≥80% for rule following, activation ordering, and triggering accuracy" with no mention of measuring improvement over the manual workflow baseline. The constitution CONST-QA-01 states: "Skills must demonstrate measurable effectiveness improvement over manual workflow before shipping." NFR-004 satisfies the eval threshold but silently drops the comparative baseline requirement.
**Consequence:** A developer building the eval suite per NFR-004 would not know they need to establish a manual workflow baseline. Skills could pass NFR-004 while failing the constitutional quality requirement, leaving CONST-QA-01 unmet at release.
**Fix:** :comment[Add to NFR-004: "The ≥80% targets shall be evaluated against a manual-workflow baseline for at least rule following and triggering accuracy, establishing that the skill improves on the baseline."]{#comment-1774990056348 text="I think this one needs a deeper think - what are we trying to get from both this scoring criteria and the manual baseline ?"}
\[Convergence: flagged by both Layer 1 cross-doc conflict and Layer 2 H2 silent conflict]

---

**\[Important] unverifiable-appropriate-elicitation** (confidence: 85, REQ-R01 / quality)
FR-011 states "the plugin shall walk through guided elicitation appropriate to that doc type." "Appropriate" has no observable test. FR-012 through FR-014 enumerate elicitation steps for requirements, ADR, and RFC — but Architecture, Interface contract, Test strategy, and Constitution are listed in Journey 2 Step 3 without corresponding FRs that enumerate what "appropriate" means for each.
**Consequence:** An agent implementing or testing FR-011 for the four uncovered doc types cannot determine pass/fail. The journey description provides non-normative guidance, but the FRs are the binding contract.
**Fix:** :comment[Add FRs for Architecture, Interface contract, Test strategy, and Constitution doc types (matching the Journey 2 Step 3 enumeration), or extend FR-011 with an explicit reference: "as specified in FR-012 through FR-014 for requirements, ADR, and RFC, and as listed in Journey 2 Step 3 for all other doc types."]{#comment-1774990144924 text="do we need FRs for each doc type or can we have a general rule that it walks through all of the sections required for each doc type?"}

---

#### Suggestions

**\[Suggestion] fr-022-passive-missing-actor** (confidence: 82, REQ-R01 / quality)
FR-022: "The auto-loaded rules shall include: the read-before-coding sequence..." uses passive "auto-loaded" without identifying the actor or trigger. This does not follow EARS ubiquitous form (which requires a clear subject) nor event-driven form (which requires a trigger).
**Consequence:** Minor: ambiguity about whether the plugin installs these rules (one-time), whether Claude Code loads them each session, or both. Not blocking but creates agent confusion about responsibility.
**Fix:** :comment[Rewrite as: "When the plugin installs rules via /preflight scaffold, the plugin shall include in the auto-loaded rules file: the read-before-coding sequence..."]{#comment-1774990165255 text="approve"}

---

**\[Suggestion] const-dist02-incomplete-vs-fr009** (confidence: 82, structural)
Constitution CONST-DIST-02 lists protected files as "constitution, glossary, requirements, ADRs, RFCs." FR-009 protects a superset: also `architecture.md`, `test-strategy.md`, `interfaces/`. The constitution's list is less complete than the requirement it governs.
**Consequence:** An agent following CONST-DIST-02 literally could overwrite `architecture.md` without violating the constitution. The constitution is the authoritative source per its preamble.
**Fix:** :comment[Amend CONST-DIST-02 (via ADR per CONST-PROC-02) to match FR-009's complete protected-file list: constitution, glossary, requirements, architecture, test-strategy, ADRs, RFCs, interfaces/.]{#comment-1774990219125 text="i think constitution should remain generic, not implementation details. We don**SQUOTE**t overwrite the files that are the content of the host repo. "}

---

### Strengths

1. **Complete failure mode coverage**: All five user journeys document at least one failure mode with explicit recovery behavior (Journey 2 has three). This exceeds REQ-R05 and directly addresses a common requirements gap.
2. **Traceable success measures**: Section 8 provides all three required columns — baseline, target, and measurement method — for every metric. Most requirements specs leave the baseline column blank or omit it entirely.
3. **Explicit out-of-scope section**: Section 9 names six excluded items with rationale markers ("future," "stays manual," "identified gap, not addressed in v1"). This is rarer in practice than REQ-R07's anti-pattern note suggests.

---

### Summary

0 Critical, 3 Important, 2 Suggestions
Sources: 2 rule-based (REQ-R01, quality anti-patterns), 3 structural/cross-doc
