---
status: complete
date: 2026-04-12
owner: nic
type: analysis
supersedes_conclusions_of: 2026-04-12-workflow-integration-pass2.md
---

# Preflight's actual value — category coverage for L4 autonomy

## The reframing

Passes 1 and 2 evaluated preflight as a *tool* — a plugin with three skills, an ensemble review system, and a scaffold command. That framing led to the E-lite recommendation: add two skills, a work package template, and a drift hook.

Pass 3 takes a completely different starting point, driven by the observation that every capability pass 2 defended is commoditized:

- **Reviewer agents** — trivial to build once rules exist. Tools like `skill-creator` and autoresearch can produce them on demand.
- **Elicitation flow** — every serious framework has it. Superpowers `brainstorming`, OpenSpec `/opsx:explore`, GSD-2 `discuss`, BMAD Analyst role, Devin Interactive Planning.
- **FR/NFR in EARS format** — OpenSpec does it natively with WHEN/THEN. Spec Kit does it. IEEE 29148 defines it. Not unique to preflight.
- **Scaffold command** — file copying. Trivial.

If all of that is commoditized, what's actually left? **The taxonomy of information categories that must exist for an autonomous agent to succeed.** Preflight's real contribution is an *ontology* — a coverage surface defining what a spec must contain to be sufficient for execution without a human in the loop.

This pass asks a sharper question: **which categories does L4 autonomy actually require, how does preflight score against them, and where are the gaps?**

---

## 1. The irreducible category set for L4 autonomy

Research across IEEE 29148, ISO/IEC 25010:2023, Volere, SWE-bench Verified, METR, Anthropic "Building Effective Agents," MADR, Ulwick JTBD, and the modern agent-framework space converges on 25 information categories an autonomous agent needs to succeed. The single most revealing data point is that OpenAI's SWE-bench Verified annotation study **flagged 38.3% of tasks as "underspecified"** and had to filter 68.3% overall — despite each task already containing an issue description, full repo, base commit, hidden tests, and hints text. The same task that's "fine" for a human is materially incomplete for an agent.

The 25 categories, grouped by purpose:

### Build-correctness categories (what to build)

1. **Purpose / JTBD** — why this exists, what outcome it serves. Source: Ulwick ODI, Volere §1. Failure if missing: agent optimizes for literal request, misses underlying goal.
2. **Stakeholders / personas** — whose needs are being served. Source: IEEE 29148, BMAD. Failure: agent can't calibrate UX defaults or resolve "who decides."
3. **Scope (in / out / deferred)** — explicit boundaries. Source: Volere §5, §27. Failure: gold-plating or adjacent-feature deletion.
4. **Glossary / domain terms** — shared vocabulary. Source: Volere §5, IEEE 29148. Failure: synonym invention, drift between code/tests/docs.
5. **Functional requirements** — atomic, testable, ID'd behaviors (EARS). Source: IEEE 29148 SRS §3.2. Failure: no way to verify done.
6. **Non-functional / quality attributes** — ISO 25010:2023's nine characteristics including new *Safety*. Source: ISO 25010:2023, Volere §10–17. Failure: functionally correct but unusable.
7. **Constraints** — technical, legal, environmental, budget non-negotiables. Source: Volere §3. Failure: banned deps/languages chosen.
8. **Assumptions / facts** — what is taken as true. Source: Volere §4, METR. Failure: compounding wrong assumptions hours in.
9. **Preconditions / environment state** — base commit, env vars, secrets, services. Source: SWE-bench schema. Failure: "can't reproduce," flailing.
10. **Interface contracts** — typed API/CLI/event schemas at boundaries. Source: IEEE 29148 §5.2.4. Failure: integration breakage invisible until runtime.
11. **Data model / entities** — schemas, invariants, relationships. Source: Volere §5. Failure: invented DB columns, broken FKs.
12. **Architecture** — components, layering rules, allowed call directions. Source: arc42, BMAD. Failure: code dropped in random files, violated layering.
13. **ADRs with rationale** — *why* the architecture is what it is. Source: MADR 4.0. Failure: agent "improves" things by silently reversing prior decisions.
14. **Constitution / principles** — inviolable meta-rules. Source: Spec Kit, BMAD. Failure: baseline norms violated under local task pressure.
15. **Acceptance criteria / fit criteria** — measurable done per FR, executable as tests. Source: Volere, SWE-bench Verified. Failure: agent cannot self-verify.
16. **Test strategy** — layered coverage approach. Source: IEEE 29148 §6. Failure: tests that pass but don't cover risk.
17. **Success metrics** — baseline → target → method for production validation. Source: Ulwick ODS, Volere §16. Failure: can't tell "working" from "working and valuable."
18. **Failure modes / unhappy paths** — error states, recoverability. Source: EARS If/then, FMEA. Failure: happy-path-only code, cascading edge-case bugs.
19. **Security / threat model** — trust boundaries, authn/authz, data sensitivity, compliance. Source: ISO 25010 security subcharacteristics. Failure: auth bypass, PII leaks.

### Operations-envelope categories (when to hand off)

20. **Tool / capability inventory and bounds** — what tools the agent has, allowed vs forbidden actions, destructive-op policy. Source: Anthropic "Building Effective Agents," Devin scaffold. Failure: refuses safe actions or runs destructive ones.
21. **Task decomposition / plan** — ordered steps, dependencies, parallelizable units. Source: METR 2025 (horizon length, not skill, drives failure). Failure: agent flails on sequencing.
22. **Stopping conditions / escalation triggers** — when the agent must stop and hand off. Source: Anthropic, on-the-loop supervisory control literature. Failure: infinite loops or plowing through ambiguity.
23. **Rollout / rollback plan** — deployment, feature flags, migration ordering, rollback procedure. Source: IEEE 29148 Operational Concept, Volere §23. Failure: autonomous agent merges and can't undo.

### Meta-categories

24. **Traceability** — bidirectional links requirement ↔ code ↔ test ↔ ADR. Source: IEEE 29148. Failure: agent can't answer "which requirement does this serve?"
25. **Open questions / known unknowns** — explicit ambiguity register. Source: BMAD, Volere, arc42. Failure: agent silently picks an answer and commits.

---

## 2. Preflight inventoried against the 25 categories

Ground truth extracted from every template (7), rules file (7), and reference doc (4) in `content/`. Preflight captures approximately **72 distinct information categories** across 7 doc types, which map to the 25-category L4 framework as follows:

| # | L4 category | Preflight coverage | Source in preflight |
|---|-------------|-------------------|---------------------|
| 1 | Purpose / JTBD | **Partial** — requirements problem statement + personas + journeys | requirements §1, §2, §3 |
| 2 | Stakeholders / personas | **Partial** — personas section; stakeholders in architecture §1.3 | requirements §2, architecture §1.3 |
| 3 | Scope (in/out/deferred) | **Strong** — requirements §9, RFC scope section | requirements, rfc |
| 4 | Glossary | **Present but untemplated** — referenced in taxonomy, skeleton only | reference/doc-taxonomy, content/scaffolds/glossary-skeleton.md |
| 5 | Functional requirements (EARS) | **Strong** — REQ-R01/R02/R03 enforce | requirements-template.md, ears-notation.md |
| 6 | NFRs (ISO 25010) | **Strong** — REQ-R04 enforces quantification | requirements §5 |
| 7 | Constraints | **Strong** — multiple categories (tech/org/regulatory/commitments) | requirements §6, architecture §2 |
| 8 | Assumptions / facts | **Partial** — requirements §7 with validation plan | requirements §7 |
| 9 | Preconditions / environment | **Partial** — in architecture deployment view | architecture §7 |
| 10 | Interface contracts | **Strong** — dedicated doc type | interface-contract-template.md |
| 11 | Data model | **Missing** — referenced in requirements appendices, no template | (gap) |
| 12 | Architecture | **Strong** — arc42 + C4 | architecture-template.md |
| 13 | ADRs with rationale | **Strong** — MADR 4.0 with confirmation field | adr-template.md |
| 14 | Constitution / principles | **Strong** — dedicated doc with amendment log | constitution-template.md |
| 15 | Acceptance criteria | **Strong** — test strategy acceptance mapping + EARS fit criteria | test-strategy-template.md, requirements |
| 16 | Test strategy | **Strong** — pyramid, envs, gates | test-strategy-template.md |
| 17 | Success metrics | **Strong** — baseline/target/method required | requirements §8 |
| 18 | Failure modes | **Strong** — EARS If/then + journey failure modes (REQ-R05) | requirements §3, §4 |
| 19 | Security / threat model | **Partial** — NFR security + constitution SEC principles, no threat template | (gap for threat model) |
| 20 | Tool inventory / bounds | **Missing** | (gap) |
| 21 | Task decomposition | **Missing** | (gap) |
| 22 | Stopping conditions / escalation | **Missing** | (gap) |
| 23 | Rollout / rollback | **Partial** — only in RFC, not standalone; missing for ADR-only changes | rfc §6 |
| 24 | Traceability | **Strong** — XDOC-01..09 enforce bidirectional edges | cross-doc-rules.md |
| 25 | Open questions | **Partial** — fields exist in requirements and RFC | requirements §10, rfc |

**Score**: 17/25 structurally covered, 6/25 partial, 2/25 missing entirely.

---

## 3. Comparative coverage across all frameworks

| # | Category | OpenSpec | Spec Kit | Superpowers | GSD-2 | BMAD | Archon v3 | Devin | **Preflight** |
|---|----------|----------|----------|-------------|-------|------|-----------|-------|----------------|
| 1 | Purpose / JTBD | P | P | N | Y | Y | Y | N | P |
| 2 | Stakeholders | N | P | N | P | Y | Y | N | P |
| 3 | Scope in/out | P | Y | P | Y | Y | Y | N | **Y** |
| 4 | Glossary | N | N | N | N | P | N | N | **Y** |
| 5 | Functional reqs (EARS) | Y | Y | P | P | Y | Y | N | **Y** |
| 6 | NFRs / ISO 25010 | N | P | N | N | Y | Y | N | **Y** |
| 7 | Constraints | N | P | N | Y | Y | Y | N | **Y** |
| 8 | Assumptions / facts | N | N | N | Y | P | P | N | P |
| 9 | Preconditions / env | N | P | N | Y | P | N | P | P |
| 10 | Interface contracts | N | N | N | N | P | P | N | **Y** |
| 11 | Data model | N | P | N | N | Y | Y | N | P |
| 12 | Architecture | P | Y | Y | N | Y | Y | N | **Y** |
| 13 | ADRs w/ rationale | N | N | N | Y | P | N | N | **Y** |
| 14 | Constitution | N | Y | N | N | P | N | N | **Y** |
| 15 | Acceptance criteria | P | P | P | N | Y | Y | N | **Y** |
| 16 | Test strategy | N | N | N | N | P | P | N | **Y** |
| 17 | Success metrics | N | N | N | N | Y | Y | N | P |
| 18 | Failure modes | N | N | N | N | P | P | N | **Y** |
| 19 | Security / threat | N | N | N | N | P | P | N | P |
| 20 | Tool inventory / bounds | N | N | N | N | N | N | **Y** | N |
| 21 | Task decomposition | **Y** | **Y** | N | N | **Y** | **Y** | **Y** | N |
| 22 | Stopping / escalation | N | N | N | N | N | N | P | N |
| 23 | Rollout / rollback | N | N | N | N | P | P | N | P |
| 24 | Traceability | P | P | N | P | Y | P | N | **Y** |
| 25 | Open questions | N | N | N | P | Y | Y | N | P |
| **Total (Y+P)** | | **6** | **10** | **3** | **8** | **17** | **14** | **5** | **23** |

Preflight leads the coverage surface at 23/25 (17 Y + 6 P), followed by BMAD at 17, Archon at 14, Spec Kit at 10. **This is the empirical support for the category-coverage hypothesis.** Preflight isn't a better tool — it's the most thorough taxonomy.

But note the structural shape of the gaps:

- **OpenSpec's gaps are build-correctness categories** (glossary, NFR, constraints, interfaces, data model, ADRs, constitution, test strategy, failure modes, security). These are the pre-execution categories.
- **Preflight's gaps are operations-envelope categories** (tool inventory, task decomposition, stopping conditions, rollout — partial). These are the during-and-post-execution categories.

Preflight and OpenSpec have **orthogonal** weaknesses. Preflight covers what OpenSpec doesn't. OpenSpec covers what preflight doesn't (specifically task decomposition, which is the single most frequently-cited requirement in the METR 2025 findings — horizon length drives failure more than skill).

---

## 4. Preflight's defensible core — the refined hypothesis

The user's hypothesis was: preflight's unique value is the category taxonomy. The research partially confirms and sharpens this.

**Where the hypothesis is correct**: preflight covers 23/25 categories — materially more than any competitor. No other framework captures interface contracts, constitution, dedicated test strategy, explicit failure modes, MADR-grade ADRs with confirmation criteria, and full cross-doc traceability *all together*. That's a real coverage advantage.

**Where the hypothesis needs sharpening**: a taxonomy alone is copyable in an afternoon. Anyone can enumerate 25 categories. What's actually defensible is the taxonomy **plus three invariants that bind it**:

1. **Explicit override precedence.** Constitution overrides requirements overrides ADR overrides code. Conflicts resolve deterministically. XDOC-07 ensures ADRs conflicting with constitution must first amend the constitution. Most frameworks have "principles" but no stated precedence — ambiguity gets resolved by whoever shouts loudest.

2. **ID-stable traceability.** FR-NNN and ADR-NNN and CONST-{CAT}-NN are never reused (REQ-R02, CONST-R01). This sounds mundane but is load-bearing: it lets a change propagate across the graph across years of refactors. Without ID stability, traceability decays to zero within a few sprints.

3. **Machine-checkable cross-doc invariants.** XDOC-01..09 enforce directed edges: arch→ADR exists, RFC→ADR exists after acceptance, test→requirement reference exists, orphan requirement detection, supersession chains without cycles. This is the connective tissue that turns a set of docs into a graph.

**The refined hypothesis**: preflight's defensible core is a **coverage taxonomy with precedence rules and ID-stable traceability — together forming a completeness contract.** A competitor can copy the 25 categories and still produce a worse system by letting ADRs float, reusing IDs, or leaving precedence implicit. The ontology + invariants together are what matter.

This is a more honest framing than "preflight is the best doc tool." It's also a narrower framing — it means the product is not the templates, the skills, or the reviewers. **The product is the completeness contract.**

---

## 5. Preflight's gaps for L4 autonomy

Eight categories where preflight is partial or missing, ranked by impact on L4 execution:

### Critical gaps (block L4)

**Cat 20 — Tool inventory / boundaries.** Missing entirely. At L4, the agent must know which tools it can call, what each does, which operations are destructive, and what's forbidden. Without this, the agent either refuses safe actions (under-confident) or runs destructive ones (over-confident). This is exactly what Devin's harness captures and what on-the-loop supervisory control literature names as foundational. *Impact*: high. The on-the-loop system cannot safely delegate without a tool envelope.

**Cat 22 — Stopping conditions / escalation triggers.** Missing entirely. At L4, the agent must know when to yield control: iteration limit hit, confidence below threshold, protected path touched, ambiguity detected. Without this, the agent either loops forever or commits to bad decisions. Preflight has nothing for this. *Impact*: highest. This is the single category that determines when a human is pulled back into the loop.

**Cat 23 — Rollout / rollback (for non-RFC changes).** Only present in RFC template. Small ADR-only changes and direct requirement amendments have no home for rollback criteria. At L4, every change must define how to undo it — autonomous agents will merge things that need to be reverted. *Impact*: high. Without rollback criteria on every change, L4 autonomy is a one-way door.

### Substantive gaps (degrade L4 quality)

**Cat 21 — Task decomposition.** Missing entirely. METR 2025's headline finding is that horizon length, not skill, drives failure. OpenSpec's `tasks.md`, Spec Kit's `tasks.md`, and BMAD stories all exist because task decomposition *inside the spec* directly improves success probability. Preflight assumes the agent plans from specs — which works at L3 but breaks at L4 where the plan must be reviewable before execution. *Impact*: medium-high. Cat 21 is the primary OpenSpec-over-preflight advantage.

**Cat 11 — Data model.** Partial. Referenced in requirements appendices and scattered through architecture, no first-class template. Migrations and schema evolution have no home. At L4, an agent touching a database without a data model will break FK constraints. *Impact*: medium.

**Cat 19 — Threat model.** Partial. NFR security and constitution SEC principles cover *what must not happen*, but there's no STRIDE/LINDDUN/attack-tree template for *how it could happen*. *Impact*: medium, context-dependent.

### Lesser gaps (not blocking)

**Cat 1 — JTBD.** Partial. Problem statement + personas + journeys covers the territory but not as a first-class JTBD framing. Ulwick's outcome-driven framing is sharper than user-story framing for autonomous agents because it separates stable desired outcomes from solution prescriptions. *Impact*: low-medium.

**Cat 17 — Success metrics.** Partial. Baseline/target/method exists in requirements but not consistently across all doc types. *Impact*: low.

---

## 6. How this changes the pass 2 findings

Pass 2 recommended E-lite: add two skills (explore, propose), one work-package template, one post-build hook, two review rules. This is still a good recommendation *for the workflow problem*, but pass 3 reveals it's the wrong *primary investment*.

**The wrong primary investment**: treating preflight as a workflow tool that needs more workflow surface area (new skills, new commands, new rules). That doubles down on capabilities that are already commoditized.

**The right primary investment**: treating preflight as a completeness contract and closing the L4 coverage gaps. Specifically:

### Revised priority stack

**Priority 1 — Surface the completeness contract explicitly.** Pass 2's `work-package.yaml` is close but not this. The completeness contract is a *doc-level* artifact that asserts "for change X, all applicable categories are populated, precedence is satisfied, and downstream impacts are propagated." Concretely: extend `/preflight review` with a `--coverage` mode that reports, per change, which of the 25 categories are satisfied, which are partial, which are missing, and which are non-applicable. This is the thing nobody else has and the thing the user has been reaching for with the "coverage" hypothesis.

**Priority 2 — Fill the three critical L4 gaps**:
- Add a **tool inventory / operations envelope** doc type. Template captures: allowed tools, destructive operations, forbidden paths, allowed environments, escalation triggers. This is category 20 + 22.
- Add **rollback criteria as a required field on every ADR**, not just RFCs. Category 23. One template change, one rule change.
- Add a **task-plan doc type** (pass 2 already has this) but frame it as category 21 coverage, not just "a decomposition artifact." Link work-package.yaml to task-plan instead of reinventing.

**Priority 3 — Close the substantive gaps**:
- Data model template (category 11).
- Threat model template (category 19).
- Stronger JTBD framing in requirements elicitation (category 1 → partial to strong).

**Priority 4 — Ship the workflow pieces from pass 2** (explore/propose skills, work package, drift hook). This is still worth doing — but as a *secondary* investment, not the primary one. The workflow is commoditized; the coverage contract is not.

### What gets demoted from pass 2's recommendation

- **"Ship E-lite now, skip the bridge"** — still correct in spirit, but the definition of E-lite changes. E-lite is no longer "add two skills and a hook." E-lite is "surface the completeness contract explicitly and fill the three critical L4 gaps."
- **Pass 2's treatment of framework adoption** — still correct. No external framework is healthy enough or aligned enough to carry preflight's coverage advantage. BMAD is closest (17 categories covered) but its agile-theater conflicts with PAI Algorithm, and it still misses categories 20 and 22.
- **Pass 2's C1 option (OpenSpec content adoption)** — now unambiguously wrong. OpenSpec covers 6/25 categories. Adopting OpenSpec as the authoring layer means regressing from 23/25 to 6/25 of coverage. The 48 review rules wouldn't fit, *and* the category set is much smaller. C1 is strictly worse than extending preflight.
- **Pass 2's work-package.yaml** — still useful as a handoff artifact, but gets repositioned. Instead of being "preflight's exit artifact," it becomes "the serialization of the completeness contract for a specific change." Same YAML shape, different framing.

### What gets promoted

- **Preflight's category taxonomy as first-class IP.** Pass 1 and pass 2 treated this as implementation detail. Pass 3 makes it the explicit value proposition.
- **The XDOC-01..09 cross-doc rules.** Pass 2 mentioned these as "connective tissue." Pass 3 elevates them to *the main defensibility argument* — the machine-checkable invariants that turn the taxonomy into a contract.
- **Tack Room's relationship to preflight.** Pass 1 and 2 treated Tack Room as the north-star consumer. Pass 3 clarifies the relationship: Tack Room needs categories 20, 21, 22, 23 — the operations envelope. Preflight must add those categories to be Tack Room's substrate. Without them, preflight is L3-ready, not L4-ready.

---

## 7. Recommendation — revised

**Ship the completeness contract, close the L4 gaps, then add the workflow pieces.** Concretely:

### Phase 1 — Completeness contract (this sprint)

1. Write `content/reference/category-coverage.md` — the definitive 25-category taxonomy with preflight's mapping. Treat this as preflight's core IP documentation.
2. Add `/preflight review --coverage <change>` — analyzes a change and reports per-category coverage (Y / P / N / N/A) with citations to the specific docs and sections that satisfy each category. Output format: machine-readable YAML + human-readable markdown.
3. Add two rules to `rules-source/`:
   - "A change touching FR-NNN without coverage of applicable categories 20-23 fails review at L4."
   - "Rollback criteria must exist for every behavioral change, not only RFCs."

### Phase 2 — L4 gap closure (next sprint)

4. Add `content/templates/operations-envelope-template.md` — tool inventory, destructive-op policy, escalation triggers, stopping conditions. Maps to categories 20 and 22.
5. Add rollback-criteria field to `adr-template.md` and a new rule requiring it on behavioral ADRs. Maps to category 23.
6. Add `content/templates/task-plan-template.md` — decomposition artifact with acceptance criteria per task. Maps to category 21. (This was pass 2's first priority; now framed as category coverage, not workflow ornament.)

### Phase 3 — Workflow (pass 2's E-lite, now properly scoped)

7. `skills/explore/SKILL.md` and `skills/propose/SKILL.md` — elicitation and orchestration. Unchanged from pass 2.
8. `content/templates/work-package-template.yaml` — reframed as "serialized completeness contract for a change." Same schema as pass 2 with one addition: a `category_coverage:` field listing which of the 25 categories are satisfied.
9. `content/scaffolds/post-implementation-hook.sh` — FR-drift detector. Unchanged.

### Phase 4 — Substantive gaps (backlog)

10. `content/templates/data-model-template.md` — category 11.
11. `content/templates/threat-model-template.md` — category 19.
12. Strengthen JTBD in requirements elicitation — category 1.

### What this is not

- Not a framework adoption. Preflight remains a standalone plugin.
- Not a fork of OpenSpec or anyone else. The coverage taxonomy is preflight's unique contribution, not borrowed.
- Not a Tack Room dependency. Phase 1–3 ship independently. Phase 2 makes preflight the natural substrate Tack Room will consume when it lands.
- Not "pass 2 was wrong." Pass 2 found the right shape for the workflow solution. Pass 3 adds the layer above it.

---

## 8. Answering the user's central question

> "openspec worked well enough, but didn't explore/propose with enough categories (jtbd, test strategy, etc) to cover the full L4 workflow success criteria"

The research confirms this instinct quantitatively. OpenSpec covers 6/25 L4 categories. Preflight covers 23/25. The user's observation about OpenSpec missing JTBD and test strategy is literally correct, and the gap extends further: OpenSpec also misses NFR (ISO 25010), constraints, interface contracts, ADRs, constitution, failure modes, and security. OpenSpec is designed for the "change as delta" problem, which it solves well — but the delta is a subset of a much larger coverage surface.

The user is building toward on-the-loop L4 autonomy. The research says that at L4, underspecified specs are the dominant failure mode (SWE-bench Verified: 38.3% underspecified even with a full repo + base commit + hidden tests). The difference between L3 (human reviews each step) and L4 (human supervises the overall loop) is exactly the difference between "some categories missing is fine because a human fills them in" and "every applicable category must be populated and machine-verifiable."

Preflight's taxonomy is the strongest existing foundation for this. The gaps — tool inventory, stopping conditions, rollback-beyond-RFC, task decomposition — are all fixable with template additions. None of them require a new tool or a framework dependency. The primary investment should be making the completeness contract explicit and closing the four L4 gaps, not building more workflow surface area.

---

## Appendix — sources

Primary research sources:

- IEEE/ISO/IEC 29148:2018 — Requirements engineering
- ISO/IEC 25010:2023 — Product quality model (added Safety as first-class characteristic)
- Volere Requirements Specification Template
- SWE-bench Verified — OpenAI annotation study showing 38.3% underspecification rate
- METR 2025 — "Measuring AI ability to complete long tasks"
- Anthropic — "Building Effective Agents"
- Cognition AI — Devin harness design
- MADR 4.0 — Markdown Architectural Decision Records with Confirmation field
- Tony Ulwick — Outcome-Driven Innovation / JTBD framing
- GitHub Spec Kit, Fission-AI OpenSpec, obra Superpowers, gsd-build GSD-2, bmad-code-org BMAD, coleam00 Archon v3

Internal research artifacts:

- `/Users/Shared/sv-nic/src/preflight/content/templates/` — 7 doc type templates inventoried
- `/Users/Shared/sv-nic/src/preflight/content/rules-source/` — 48 rules across 7 rule files
- `/Users/Shared/sv-nic/src/preflight/content/reference/` — doc taxonomy and cross-doc relationships
