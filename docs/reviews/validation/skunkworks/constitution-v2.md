## Review: constitution.md
Document type: constitution | Rules: universal-rules.md, constitution-rules.md, cross-doc-rules.md

### Findings

**[Important] unverifiable-principles** (confidence: 92, structural; also flagged by CONST-R03, quality)
Three principles are philosophical observations rather than testable imperatives. CONST-DEC-02: "Intuition is valuable for forming hypotheses — fast and often directionally correct. But it needs data before it becomes a decision." CONST-EXEC-01: "Stay close to the work — direct contact with real output keeps judgment calibrated." CONST-EXEC-02: "Full PM framework adoption, AI fills team roles. Learning the framework at professional depth is a goal, not overhead." No agent or automated reviewer can determine compliance or violation — a compliant state and a non-compliant state are indistinguishable. This also contradicts the constitution's own enforcement philosophy: CONST-ENF-01 states "Any process that depends on user compliance under stress will fail."
**Consequence:** Agents reading the constitution per CONST-AGT-01 encounter these principles and either ignore them (making the constitution partially decorative) or hallucinate compliance (producing false verification claims).
**Fix:** Rewrite each as a testable imperative. For example, CONST-DEC-02 could become: "No technical decision SHALL be ratified without supporting data — intuition informs hypotheses, data confirms decisions." Push the philosophical motivation into a parenthetical or remove it.

---

**[Suggestion] descriptive-not-imperative** (confidence: 85, structural)
CONST-AGT-03 reads: "Under-specified work produces agent thrash. Investing in decomposition quality upstream is cheaper than course-correcting downstream." This is a descriptive observation about a phenomenon, not an imperative statement. There is no "shall," "must," or action verb directing behavior. It functions as motivation for CONST-AGT-02 rather than a standalone principle.
**Consequence:** An agent encountering this principle has no action to take — it describes why decomposition matters but not what to do about it. The principle occupies an ID slot without adding a checkable constraint.
**Fix:** Either merge as motivating context into CONST-AGT-02, or rewrite as an imperative: "Work items dispatched to agents SHALL be decomposed to a level where each subtask has a single verifiable outcome."

### Strengths
- Clean, consistent ID taxonomy (CONST-{CATEGORY}-NN) across all 17 principles with no gaps or duplicates
- Strong enforcement philosophy (CONST-ENF-01 and CONST-ENF-02) that is itself structurally testable and self-consistent
- Well-scoped at 17 principles — avoids standards-doc bloat while covering build, decide, enforce, agent, and execution concerns

### Summary
0 Critical, 1 Important, 1 Suggestion
Sources: 1 structural/cross-doc, 1 rule-based (CONST-R03, quality convergence)
