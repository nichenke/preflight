---
doc_under_review: /Users/paipilot/src/pai-projects/skunkworks/specs/constitution.md
doc_type: constitution
review_date: 2026-03-31
reviewer: preflight dual-pass (checklist-reviewer + bogey-reviewer)
rules_loaded:
  - universal-rules.md (v2.0.0)
  - constitution-rules.md (v2.0.0)
  - cross-doc-rules.md (v2.0.0)
related_docs_loaded:
  - requirements.md: NOT FOUND
---

# Review: skunkworks/specs/constitution.md

---

## Checklist-reviewer pass

### Stage 1 — Rule compliance

**[Critical] no-ratifiers-named** (confidence: 99, CONST-R06 / quality)
The `ratified_by` frontmatter field is `[]` (empty array) and no ratifiers are named anywhere in the document. Per the constitution-rules anti-pattern: "A constitution without designated ratifiers has no authority."
**Consequence:** Without named ratifiers, the amendment process defined in constitution-rules.md ("Ratification: Explicitly approved by designated ratifiers") cannot function. Any downstream agent or engineer can treat the document as purely advisory, undermining its stated role as the override authority.
**Fix:** Populate `ratified_by` with at least one named ratifier (e.g., `ratified_by: [Nic]`) to establish the authority chain.

---

**[Important] version-without-amendment-log** (confidence: 88, CONST-R06)
The document is at `version: 0.3.0` but the Amendment Log table is empty, and both `last_amended:` and `amendment_adrs: []` are blank/empty. If the document is genuinely at v0.3.0, at least two prior versions existed — none of those changes are recorded.
**Consequence:** The amendment history is opaque. Downstream agents and engineers cannot determine what changed between versions or which ADRs authorized changes. The constitution's own change governance is violated by its own amendment log.
**Fix:** Either (a) populate the Amendment Log with entries for changes from v0.1.0 through v0.3.0 referencing the ADRs that authorized them, or (b) if this is genuinely the first written version and 0.3.0 reflects informal iteration, reset to v0.1.0 and document that explicitly.

---

**[Important] multi-sentence-principles** (confidence: 90, CONST-R03)
Multiple principles violate the "single, testable imperative statement" requirement by embedding rationale or follow-on guidance as additional sentences within the same principle entry. Most egregious examples:

- CONST-BUILD-01: "Each deliverable produces evidence independently. If a slice can't demonstrate a result on its own, split it further. No multi-month build plans — each slice refines the next." — Three sentences; the latter two are amplification and anti-pattern guidance.
- CONST-DEC-01: "All technical decisions require code-level verification. Research findings are hypotheses until tested with spikes. Claims about capabilities must be verified against source code (clone repos locally if needed), not documentation." — Three sentences with escalating specificity.
- CONST-BUILD-03: "Challenge the requirement, simplify, optimize — then automate. Automation applied too early locks in the wrong process at speed." — Second sentence is rationale.
- CONST-BUILD-04: "'Should we build X?' gets a written, falsifiable trigger. Build only when it fires. Preserves the option without paying the cost." — Third sentence is benefit narration.

**Consequence:** Multi-sentence principles are harder for agents to evaluate mechanically. A reviewer cannot determine which sentence constitutes the testable claim and which is explanatory. Automated compliance checks will either over-flag or under-flag.
**Fix:** Restructure each principle as a single imperative sentence. Move rationale to a non-normative annotation block below the principle (e.g., using blockquote or italic), making clear it is explanatory only.

---

**[Important] empty-amendment-log-no-tbd** (confidence: 88, UNIV-03)
The Amendment Log section contains a table with headers but zero data rows and no "TBD" marker with an assigned owner. The section is functionally empty.
**Consequence:** Automated UNIV-03 checks will flag this as an empty section. More substantively, there is no indication whether absence of entries is intentional (genuinely no amendments) or an oversight.
**Fix:** If no amendments have occurred, add a single row with `—` entries and a note such as "No amendments to date" or add a TBD annotation with owner. If amendments exist but are undocumented, see `version-without-amendment-log` finding above.

---

**[Important] unquantified-sufficient** (confidence: 87, UNIV-04)
CONST-BUILD-02: "The RFC process ensures sufficient research depth in both directions." The adjective "sufficient" is unquantified — no definition of what constitutes sufficient research depth is provided.
**Consequence:** Two engineers (or agents) evaluating whether an RFC demonstrates "sufficient" research will reach different conclusions. The principle cannot be mechanically checked.
**Fix:** Replace "sufficient research depth" with a concrete, observable criterion — e.g., "The RFC cites at least two evaluated alternatives with documented tradeoffs" or reference a separate RFC template that defines required depth.

---

**[Suggestion] mechanism-not-outcome** (confidence: 82, CONST-R04)
CONST-DEC-01: "Claims about capabilities must be verified against source code (clone repos locally if needed), not documentation." The parenthetical "(clone repos locally if needed)" prescribes a specific mechanism (local clone) rather than an outcome (independent verification). This is borderline tool-specific: it forecloses verification via remote browsing, API inspection, or other valid means.
**Consequence:** Low — the intent is clear. But a strict reading blocks valid verification approaches, and the mechanism may become dated as tooling evolves.
**Fix:** Remove the parenthetical mechanism hint, or reframe as an outcome: "Claims about capabilities must be verified against primary source artifacts (source code, not documentation)."

---

### Stage 2 — Quality assessment (anti-patterns)

**[Important] agent-invisible-principles** (confidence: 86, quality)
Two principles lack observable violation states:

- CONST-DEC-02: "Intuition is valuable for forming hypotheses — fast and often directionally correct. But it needs data before it becomes a decision." There is no observable state for "intuition was appropriately bounded by data." An agent reviewing a decision cannot determine compliance.
- CONST-EXEC-01: "Knowing what good looks like isn't enough. Stay close to the work — direct contact with real output keeps judgment calibrated." "Stay close to the work" and "direct contact with real output" cannot be mechanically verified.

**Consequence:** These principles will be consistently unenforced. Per CONST-ENF-01 (the constitution's own enforcement principle): any process that depends on user compliance under stress will fail. These principles depend entirely on voluntary self-assessment.
**Fix:** Either (a) convert each to a verifiable process requirement (e.g., "All decisions cite a measured result or spike output as evidence"), or (b) move them to a non-normative principles preamble and remove them from the numbered principle list — they are design philosophy, not enforceable rules.

---

**[Suggestion] evaluation-criteria-not-imperative** (confidence: 87, quality)
CONST-AGT-04: "Skills evaluated on: does this change agent behavior measurably? Is the change in the right direction? Would removing it cause regressions?" This is evaluation criteria presented as questions, not an imperative statement. It does not tell an agent what to do — it describes a framework for a human to use when reviewing skills.
**Consequence:** An agent reading this cannot determine what action is required or what a violation looks like.
**Fix:** Rewrite as an imperative: "Skills SHALL be retained only when they demonstrably change agent behavior in the intended direction and removal would cause measurable regression. Skills that fail these tests SHALL be pruned."

---

### Strengths

1. **Principle categorization is well-structured.** The five categories (BUILD, DEC, ENF, AGT, EXEC) produce a scannable, logically grouped document. The ID scheme (CONST-{CATEGORY}-NN) is consistently applied and supports cross-referencing.

2. **Self-referential enforcement principle is sound.** CONST-ENF-01 ("Design test: 'would this be disabled at 2am under deadline pressure?'") is a sharp, testable heuristic that the document itself exemplifies — the principle can be applied recursively to the other principles in this document, which is architecturally elegant.

3. **Principle count is appropriately constrained.** At 17 principles the constitution is well within the 30-principle ceiling (CONST-R05), leaving room for growth without becoming a standards manual.

**Summary: 0 Critical, 4 Important, 3 Suggestions** *(checklist pass)*

---

---

## Bogey-reviewer pass

### Section 1: Layer 1 — Cross-doc assumption conflicts

`requirements.md` was not found at `/Users/paipilot/src/pai-projects/skunkworks/specs/requirements.md`. No requirements document is available for cross-doc conflict analysis.

No other related documents were provided or found. Cross-doc conflict analysis is limited to the constitution itself.

**Internal observation (not a conflict, no second document to conflict with):** The constitution declares "All technical decisions require code-level verification" (CONST-DEC-01) while also stating "Community tools and patterns first. Both build and buy decisions require an RFC" (CONST-BUILD-02). These are compatible policies, but the RFC process is described as the enforcement mechanism for CONST-BUILD-02 with no corresponding enforcement mechanism for CONST-DEC-01. This is a structural gap within one document rather than a cross-doc conflict.

No cross-doc assumption conflicts identified (insufficient related documents loaded).

---

### Section 2: Layer 2 — Hypothesis investigation

**H1 — Unverifiable requirement**

Finding. Multiple principles contain requirements no agent can verify as satisfied or violated.

Evidence 1 — CONST-DEC-02: "Intuition is valuable for forming hypotheses — fast and often directionally correct. But it needs data before it becomes a decision." The operative constraint is that intuition "needs data before it becomes a decision." What constitutes "data" is undefined. A one-sentence Slack message citing a gut check could qualify. A six-month study might not. No observable state exists for "decision was adequately grounded in data."

Evidence 2 — CONST-EXEC-01: "Stay close to the work — direct contact with real output keeps judgment calibrated." There is no observable test for "direct contact with real output." This principle is aspirational guidance, not a testable rule.

Evidence 3 — CONST-BUILD-04: "'Should we build X?' gets a written, falsifiable trigger. Build only when it fires." The principle requires a "written, falsifiable trigger" but specifies no location, format, or registry. An agent reviewing a build decision cannot determine whether a trigger exists or was evaluated.

Evidence 4 — CONST-AGT-04: "Skills evaluated on: does this change agent behavior measurably?" No measurement method, threshold, or record location is specified. "Measurably" has no operationalized definition here.

**H2 — Silent conflict**

Not fired — this document IS the constitution. No second ratified document was loaded against which to check conflicts. `requirements.md` was not found. No ADRs were loaded. Cannot identify silent conflicts without a second document to compare against.

**H3 — False hard constraint**

Finding. CONST-DEC-01 treats a preferred verification methodology as the only valid approach, foreclosing valid alternatives without justification.

Evidence: "Claims about capabilities must be verified against source code (clone repos locally if needed), not documentation." The phrase "not documentation" frames well-maintained documentation (API references, published specs, official changelogs) as categorically invalid for capability verification. In practice, authoritative documentation (e.g., language spec, IETF RFC, OpenAPI schema) is often the correct source of truth — not implementation code, which may contain bugs. The constraint is stated as HARD (a "must") but is a SOFT policy choice that blocks valid verification paths.

Partial finding on CONST-BUILD-02: "Both build and buy decisions require an RFC." This treats RFC process as a HARD requirement for all decisions regardless of scope or reversibility. A 20-line utility function addition and a database engine migration are both "build decisions" — the same governance process is mandated for both. The constraint doesn't scope by decision magnitude, which is a policy choice presented as universal law. Confidence: 80 — threshold pass but marginal, noting the steelman: "all decisions" may be intentionally strict to avoid scope ambiguity.

---

### Section 3: Layer 3 — Validated findings

**[Critical] agent-unverifiable-principles-h1** (confidence: 92, structural)
Multiple principles state requirements that no agent (or consistent human process) can verify as satisfied or violated: CONST-DEC-02 ("needs data before it becomes a decision"), CONST-EXEC-01 ("stay close to the work"), CONST-BUILD-04 (trigger exists but no location/format specified), and CONST-AGT-04 ("measurably" undefined). Per the constitution's own CONST-ENF-01: "Any process that depends on user compliance under stress will fail. Enforcement must be structural." These principles violate CONST-ENF-01 by their own standard.
**Consequence:** These principles will be selectively enforced at best and systematically ignored at worst. Agents executing against this constitution cannot determine compliance. The constitution's authority over agent behavior is undermined in exactly the categories (decision-making, execution quality, skill governance) where it most needs to be operational.
**Fix:** For each unverifiable principle: (a) rewrite to specify an observable artifact (a written trigger document, a spike PR, a measurement record), OR (b) move the principle to a non-normative preamble section explicitly labeled "design philosophy — not mechanically enforceable," which preserves the intent without false authority.
[Convergence: also flagged by checklist-reviewer quality pass]

---

**[Important] verification-forecloses-valid-sources** (confidence: 83, structural)
CONST-DEC-01: "Claims about capabilities must be verified against source code (clone repos locally if needed), not documentation." The "not documentation" prohibition is a SOFT policy framed as a HARD constraint. It forecloses authoritative documentation — language specs, published RFCs, official API schemas — which in many cases is the more reliable source than a specific implementation (which may have bugs not yet reflected in docs, or represent a specific version).
**Consequence:** An agent or engineer following this principle strictly would be required to clone and read source for every capability claim, even when authoritative specs exist. This adds work, may produce wrong conclusions (reading implementation instead of spec), and blocks valid research paths.
**Fix:** Reframe as a default with an override: "Claims about capabilities SHALL be verified against primary source artifacts (source code or authoritative published specifications), not secondary documentation or AI-generated summaries."

---

**[Suggestion] rfc-scope-unbound** (confidence: 80, structural)
CONST-BUILD-02: "Both build and buy decisions require an RFC." This mandates RFC process for all build/buy decisions regardless of scope, complexity, or reversibility. The word "both" implies symmetry but the principle doesn't scope what counts as a "build decision."
**Consequence:** Either the RFC process gets ignored for small decisions (eroding the norm) or it gets applied to trivially small decisions (creating overhead that undermines adoption). Neither outcome serves the principle's intent.
**Fix:** Add a scope qualifier: "Substantive build and buy decisions require an RFC" with a definition of "substantive" (e.g., "decisions affecting shared infrastructure, data contracts, or agent behavior at scale"), or reference an RFC template that specifies when a lightweight vs. full RFC is required.

---

### Section 4: Suppressed findings

- CONST-ENF-01 "inflated pass rates" as vague per UNIV-04 — suppressed at CONFIDENCE: 75, below threshold. The phrase is descriptive/explanatory in context rather than a quantitative requirement.
- CONST-BUILD-02 RFC-for-all-decisions as HARD constraint (Layer 1 internal gap) — suppressed at STEELMAN: The intent may be intentionally strict to prevent "small decision" carve-outs from eroding governance. Reported as Suggestion instead with lower confidence.
- CONST-AGT-01 reading order as tool-specific per CONST-R04 — suppressed at STEELMAN: Specifying document types to read is process definition, not tool prescription. A different documentation system using different filenames would not violate the principle's intent.
- CONST-DEC-02 "fast and often directionally correct" as vague per UNIV-04 — suppressed at YAGNI: This phrase is explanatory narration accompanying a principle, not itself a quantitative requirement. No downstream agent would make a compliance decision based on this phrase alone.

---

---

## Merged findings summary

The following table merges findings from both passes, deduplicating where both reviewers flagged the same issue (noted as convergent).

| Severity | Slug | Source | Convergent |
|----------|------|--------|------------|
| Critical | agent-unverifiable-principles-h1 | bogey L2/L3 | yes — checklist quality pass |
| Critical | no-ratifiers-named | checklist CONST-R06/quality | no |
| Important | multi-sentence-principles | checklist CONST-R03 | no |
| Important | version-without-amendment-log | checklist CONST-R06 | no |
| Important | empty-amendment-log-no-tbd | checklist UNIV-03 | no |
| Important | unquantified-sufficient | checklist UNIV-04 | no |
| Important | verification-forecloses-valid-sources | bogey H3/L3 | no |
| Important | agent-invisible-principles | checklist quality | yes — bogey H1 |
| Suggestion | mechanism-not-outcome | checklist CONST-R04 | no |
| Suggestion | evaluation-criteria-not-imperative | checklist quality | no |
| Suggestion | rfc-scope-unbound | bogey H3/L3 | no |

**Final summary: 2 Critical, 6 Important, 3 Suggestions**

### Key structural observation

The constitution's most significant defect is self-referential: CONST-ENF-01 states that any process depending on user compliance under stress will fail, and enforcement must be structural. Several principles in the same document (CONST-DEC-02, CONST-EXEC-01, CONST-BUILD-04, CONST-AGT-04) are themselves unverifiable and enforcement-by-compliance-only. The document sets a quality bar it does not consistently meet. Addressing the `agent-unverifiable-principles-h1` finding would bring the constitution into alignment with its own enforcement standard.
