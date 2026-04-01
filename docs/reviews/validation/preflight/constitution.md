## Review: constitution.md

Document type: constitution | Rules: universal-rules.md, constitution-rules.md, cross-doc-rules.md

---

### Findings

#### Critical

**\[Critical] missing-adr-001** (confidence: 97, CONST-R06 / structural)
The amendment log entry for v1.0.0 references ADR-001 but ADR-001 does not exist in `specs/decisions/adrs/`. The entry reads: `"1.0.0 | 2026-03-25 | ADR-001 | Initial ratification (pre-plugin, ADR not migrated)"`. The parenthetical acknowledges the gap but does not provide an alternative reference or migration date.
**Consequence:** Any agent or reviewer auditing constitution change history cannot verify the initial ratification. CONST-R06 requires every amendment to have an ADR reference — a reference pointing to a non-existent file satisfies the letter but not the intent of the rule.
:comment[Fix]{#comment-1774989005911 text="approved"}**:** Either migrate the pre-plugin ADR-001 content into `specs/decisions/adrs/adr-001-initial-ratification.md` or, if no such content exists, replace the ADR-001 reference with a prose note explaining the bootstrapping decision and remove the dead link.
\[Convergence: also flagged by bogey Layer 1 cross-doc check]

---

#### Important

**\[Important] unverifiable-qa-effectiveness-gate** (confidence: 88, CONST-R03 / quality)
`CONST-QA-01` states: "Skills must demonstrate measurable effectiveness improvement over manual workflow before shipping." The word "measurable" appears without a defined measurement method, baseline, threshold, or evaluator. No observable pass/fail state can be constructed from this principle alone.
**Consequence:** An agent enforcing pre-ship quality gates cannot determine whether CONST-QA-01 is satisfied. Any implementation team can self-certify compliance; the principle cannot block a shipment. ADR-004 cites CONST-QA-01 as a decision driver — if the constitution's gate is untestable, the gate has no enforcement power at the constitutional level.
:comment[Fix: Add a measurement clause to CONST-QA-01, e.g.: "Skills must demonstrate measurable effectiveness improvement over manual workflow before shipping — measured by eval accuracy ≥80% on the defined skill corpus (see NFR-004)." Alternatively, split into a principle (constitutional) and a threshold (requirements/NFR-004).]{#comment-1774989047747 text="this doesn**SQUOTE**t feel like the right scope for constitution. walk me through the template/rules for that file to discuss."}

**\[Important] eval-coverage-no-threshold** (confidence: 88, CONST-R03)
`CONST-QA-02` states: "Evals must cover rule following, activation ordering, and skill triggering accuracy." The principle names three coverage dimensions but defines no passing threshold. An eval that covers all three at 10% accuracy satisfies this principle as written.
**Consequence:** CONST-QA-02 functions as a list of topics, not a testable gate. Combined with CONST-QA-01's undefined threshold, the Quality section has no mechanically enforceable gate at the constitutional level.
**Fix:** Add a minimum threshold to CONST-QA-02, or reference NFR-004 explicitly: "Evals must cover rule following, activation ordering, and skill triggering accuracy, scoring ≥80% on each dimension (NFR-004)." If thresholds belong in requirements, note the delegation explicitly.

---

#### Suggestions

**\[Suggestion] const-ci-01-dual-statement** (confidence: 82, CONST-R03)
`CONST-CI-01` reads: "All framework content must be usable without Notion access — the git repo is the standalone distribution." The dash-appended clause "the git repo is the standalone distribution" adds a second assertive statement rather than qualifying the first. CONST-R03 calls for "a single, testable imperative statement."
**Consequence:** Minor: the clause is complementary not contradictory, but two statements create ambiguity about which is the enforceable obligation. A future tool change (e.g., moving away from git) could satisfy the first clause while violating the implied second.
**Fix:** :comment[Rewrite as a single imperative: "All framework content must be usable without Notion access — the git repository is the sole required distribution medium." or separate into two principles if both are independently enforceable.]{#comment-1774989749445 text="rewrite, but make git canonical source. I think we can drop Notion entirely."}

---

### Strengths

1. **Principle count discipline**: 13 principles across 4 categories is well within the 30-principle ceiling. The constitution is genuinely memorizable, not a standards manual in disguise.
2. **Amendment log is substantive**: The amendment log records versions, dates, ADR references, and change summaries — not placeholder entries. The v1.1.0 entry is specific about which principles were added and why (CONST-QA-03 through QA-05).
3. **Ratifier named and authority explicit**: The preamble statement — "All agents, all features, and all code must comply. Amendments require an ADR with explicit ratification" — is unambiguous. `ratified_by: [nic]` in frontmatter satisfies the anti-pattern check for named ratifiers.

---

### Summary

1 Critical, 2 Important, 1 Suggestion
Sources: 3 rule-based (CONST-R03 x3, CONST-R06), 1 structural/cross-doc (missing-adr-001)
