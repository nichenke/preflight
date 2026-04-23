---
status: Proposed
date: 2026-04-22
deciders: nic
consulted: claude-code (research agents across spec-kit, BMAD, GSD, Superpowers, OpenSpec, Gas Town)
informed: (none external)
---

# ADR-008: Adopt property-test + illustrative scaffolding as the preflight rule shape for qualitative constraints

## Context and Problem Statement

Preflight rules that express qualitative quality constraints — "no implementation details", "no vague language", "principles must be outcome-focused" — have historically been written as narrow enumerations of forbidden shapes. CONST-R04 ("Principles SHALL NOT prescribe specific tools or versions") is the representative case. It catches CLI invocations but silently passes function names (`getPaiDir()`), file paths (`settings.json`), environment variable expressions (`process.env.PAI_DIR`), and directory paths (`MEMORY/`) — every shape it does not literally enumerate.

Issue #13 surfaced this gap. The natural first fix is to broaden the enumeration. That path immediately bifurcates into two failure modes:

1. **Open-ended enumeration** ("including but not limited to") — unverifiable. The reviewer cannot know when detection is complete; two reviewers disagree on novel shapes; success criteria that depend on counting flagged violations become undefined.
2. **Strict enumeration** (closed list of shapes) — heavyweight and brittle. Every new shape requires a rule-text amendment, an ADR (per CONST-PROC-02), and backward-compatibility work. Authors evade the rule by using a shape not on the list.

Cross-framework research (per `.claude/rules/rule-design.md`, raw artifacts in `cache/repos/`) dispatched six agents in parallel — spec-kit, BMAD, GSD, Superpowers, OpenSpec, Gas Town. All six converged on the same shape. The normative rule is a **property test** or **invariance test** that the reviewer applies to each candidate; the shape list, when present, is **illustrative scaffolding** — examples that calibrate reviewer judgment without defining the universe of violations.

Concrete convergence:

- **spec-kit** — "would this survive reimplementation in a different language/runtime/layout?" + good/bad exemplar pairs (`cache/repos/spec-kit/templates/commands/specify.md:298-327`)
- **BMAD** — "does removing this change WHAT the principle requires?" with a non-exhaustive category list as scaffolding (`cache/repos/bmad/src/bmm-skills/2-plan-workflows/bmad-validate-prd/steps-v/step-v-07-implementation-leakage-validation.md:83-111`)
- **OpenSpec** — "could this change without changing externally visible behavior?" + routing rule (the normative SHALL targets placement, not detection) (`cache/repos/openspec/openspec/specs/openspec-conventions/spec.md:16-26`)
- **Gas Town** — "would this still hold if we swapped the implementation?" + closed output schema over open rule (`cache/repos/gas-town/internal/formula/formulas/code-review.formula.toml:142-156`)
- **Superpowers** — qualitative rule + rationalization table (captures excuses not shapes) + Red Flags list with explicit open closer (`cache/repos/superpowers/skills/verification-before-completion/SKILL.md:52-75`)
- **GSD** — closed verdict enum (`pass | flag | omitted`) + open but bounded guidance + testable surrogate (`cache/repos/gsd/src/resources/extensions/gsd/gate-registry.ts:45-168`)

The convergence is the signal. When six frameworks independently land on the same shape, the shape is the right axis. This ADR commits preflight to that shape for rules expressing qualitative constraints, with CONST-R04 as the first application (feature `001-fix-const-reviewer-impl-detection`).

## Decision Drivers

- **Reviewer verifiability** — every rule must produce a defensible flag/pass decision. Rules that cannot be consistently applied across reviewers erode trust in the entire pipeline.
- **Author trust** — over-flagging trains authors to dismiss findings; under-flagging lets leaks ship. The rule shape must support both.
- **Rule-file maintainability** — new leak shapes emerge as the codebase evolves. Discovering a seventh category of implementation detail should not require a new ADR.
- **Rule-ID stability (CONST-CI-03)** — existing constitutions, prior review outputs, and external references must continue to resolve. Renaming or re-numbering rules is costly.
- **Consistency with peer frameworks** — preflight does not need to invent review patterns. Borrowing the shape that six peer frameworks have validated reduces risk.
- **Scope discipline** — the decision is about rule *shape*, not about specific rule *text*. Individual rules (CONST-R04 et al.) remain editable without re-triggering this ADR.

## Considered Options

1. **Keep narrow enumeration** — preserve the status quo (CONST-R04 lists "tools or versions" only)
2. **Broaden to strict closed enumeration** — amend CONST-R04 (and peer rules) to enumerate every known leak shape
3. **Broaden to open enumeration** ("including but not limited to") — list known shapes with an open-ended escape clause
4. **Adopt property-test + illustrative scaffolding** — normative rule is a property test, shape list is non-normative exemplars (this ADR's recommendation)
5. **Pure invariance test, no list** — rely entirely on the reviewer's judgment, no scaffolding

## Decision Outcome

Chosen option: **Option 4 — property-test + illustrative scaffolding**.

The rule shape for any preflight rule that expresses a **qualitative quality constraint** is:

1. **Normative clause** — a single property test the reviewer applies to each candidate. Concrete form for CONST-R04: *"flag any principle whose stated behavior is bound to a specific implementation shape rather than an implementation-agnostic outcome. Test: would the principle still hold, unchanged in meaning, if the underlying implementation were replaced with a different language, tool, filesystem layout, or module structure?"*
2. **Illustrative scaffolding** — a non-normative, non-exhaustive list of common violation shapes paired with good/bad exemplars. The scaffolding calibrates reviewer judgment but does not define the universe of violations. Shapes absent from the list are still flagged when they fail the property test.
3. **Explicit exemption clause** — any deliberate carve-out (e.g., named references to published standards) stated as a boundary case, with the property test resolving edge cases the clause cannot enumerate.

Rules expressing **structural or mechanical constraints** (e.g., "document IDs follow `FR-NNN`", "every ADR has status frontmatter") remain as direct enumerations or regex checks — they do not need the property-test shape because their violation universe is closed and mechanically testable. This ADR applies only to qualitative rules.

### Consequences

- Good, because six peer frameworks converged on this shape independently — reduces the risk of preflight re-inventing a local solution
- Good, because the shape list can grow without requiring a new ADR every time a new leak shape is discovered
- Good, because the property test dissolves edge cases (version-pinned standards, indirect references) that strict enumeration cannot resolve without proliferating sub-rules
- Good, because rule-ID stability is preserved — existing CONST-R04 references continue to resolve under the broadened rule text
- Bad, because the property test requires reviewer judgment rather than pattern-matching — reviewer prompts must be written to guide that judgment reliably
- Bad, because the substitution test is abstract for some principles, and may feel forced when applied to narrowly-scoped invariants
- Bad, because subsequent rule authors must resist the temptation to re-enumerate; rule-design review (per `.claude/rules/rule-design.md`) exists partly to catch that drift
- Neutral, because exemplar pairs must be authored alongside the rule — one-time cost per rule family

### Confirmation

Feature `001-fix-const-reviewer-impl-detection` is the first application. The acceptance signal is the feature's four Success Criteria:

- **SC-001** — issue #13 examples all flagged (regression coverage for the original defect)
- **SC-002** — control constitution of implementation-agnostic principles produces zero flags (false-positive gate)
- **SC-003** — scaffolding-shapes fixture exercises the three shapes not covered by issue #13 (tool/vendor, inline code token, version-pinned standard), completing the coverage of the rule's 8-shape claim
- **SC-004** — multi-phrase fixture exercises phrase-level flagging (the rule's "each offending phrase flagged independently" claim)

All four have pinned test corpora — SC-001 draws from issue #13, SC-002 from a hand-curated control set, SC-003 and SC-004 from sibling benchmarks — so none depend on the reviewer as its own oracle.

If the feature passes its SCs and the reviewer output is consistent across re-runs of the seeded benchmark, this ADR promotes from `Proposed` to `Accepted`. If reviewer output is inconsistent, the ADR is revised before further rule families adopt the shape.

**Scope of this decision**: this ADR authorizes the property-test + illustrative-scaffolding shape as a reusable template. Each application of the shape to a new rule family (e.g., converting a different rule from enumeration to property-test) is a behavioral change under CONST-PROC-02 and requires its own ADR — ADR-008 provides the template, not the authorization. Refining **non-normative content** within an already-applied rule — the scaffolding list, the exemplar table, the exemption enumeration — is rule-text clarification and does not require a new ADR. Revisions to the **normative property test itself** (the substitution invariance clause, its dimensions, or its pass/fail criteria) are behavioral changes and require their own ADR, because the property-test wording IS the reviewer behavior; changing it changes what gets flagged.

## Pros and Cons of the Options

### Option 1 — Keep narrow enumeration

Status quo: CONST-R04 catches CLI invocations only.

- Good, because no governance overhead
- Bad, because issue #13 and the pai-source v1.0.0 review both demonstrated the current wording is too narrow to serve its stated purpose
- Bad, because the rule's authority erodes every time a reviewer silently passes a leak the author recognizes as a violation

### Option 2 — Strict closed enumeration

Amend CONST-R04 (and peer rules) to list every known leak shape. New shapes require rule-text amendment with an ADR.

- Good, because reviewer behavior is fully deterministic
- Bad, because every new shape requires a rule-text amendment + ADR — governance cost compounds
- Bad, because authors evade the rule by finding a shape not on the list
- Bad, because the rule file becomes a growing taxonomy rather than a shape boundary
- Bad, because cross-framework research shows zero peer frameworks adopt this pattern for qualitative rules

### Option 3 — Open enumeration ("including but not limited to")

List known shapes with an open-ended escape clause.

- Good, because appears to combine determinism with flexibility
- Bad, because the reviewer cannot know when detection is complete
- Bad, because success criteria that count violations become undefined (no closed universe of what to count)
- Bad, because two reviewers disagree on novel shapes without a shared test to adjudicate
- Bad, because the bogey reviewer flagged this exact shape as a Critical unverifiability defect during the feature 001 review

### Option 4 — Property-test + illustrative scaffolding (chosen)

Normative rule is a property test; shape list is non-normative exemplars.

- Good, because six peer frameworks converged on this shape independently
- Good, because the list can grow without re-triggering governance
- Good, because edge cases (version-pinned standards, indirect references) are resolved by the property test rather than by proliferating sub-rules
- Good, because reviewer judgment is guided by the test and calibrated by exemplars, not left unbounded
- Bad, because reviewer prompts must elicit the property test reliably — prompt quality becomes load-bearing
- Bad, because the property test is more abstract than pattern-matching

### Option 5 — Pure invariance test, no list

Rely entirely on the property test; omit the scaffolding list.

- Good, because maximally minimalist
- Bad, because reviewer judgment is uncalibrated — two reviewers apply the test differently without shared exemplars
- Bad, because authors have no reference for rewriting flagged principles
- Bad, because no peer framework adopts this pattern — all six with convergent evidence pair the test with scaffolding

## More Information

### Research foundation

Raw research artifacts live in `cache/repos/<framework>/` per `.claude/rules/rule-design.md`. They are not committed (see `.gitignore`). Each agent's report is preserved in session transcript and summarized below:

- `cache/repos/spec-kit/` — GitHub spec-kit templates and command prompts
- `cache/repos/bmad/` — BMAD-METHOD validation steps and review skills
- `cache/repos/gsd/` — GSD-2 gate registry and validators
- `cache/repos/superpowers/` — Superpowers skills (verification-before-completion, brainstorming)
- `cache/repos/openspec/` — Fission-AI OpenSpec conventions spec and validator source
- `cache/repos/gas-town/` — Gas Town formulas and quality-review plugin

### Related governance

- CONST-R04 (principles shall not prescribe specific tools or versions) — first application of this ADR's shape; spec at `specs/001-fix-const-reviewer-impl-detection/spec.md`
- CONST-CI-03 (rule IDs are stable) — preserved; this ADR does not renumber CONST-R04
- CONST-PROC-02 (ADR on behavioral requirement change) — this ADR satisfies the governance requirement for the rule-shape template decision and for the first application to CONST-R04. Converting any other rule family to this shape is a behavioral change and requires its own ADR citing this one as the shape template.
- ADR-007 (feature-folder lifecycle) — feature 001 applies this ADR's decision and lives in the feature-folder shape ADR-007 defines

### Scope — what this ADR does NOT decide

- Specific rule text for CONST-R04 — decided in feature 001's `/speckit.plan` phase
- Number or content of exemplar pairs — decided per rule family at authoring time
- Whether other rule families (UNIV, REQ-R, ADR-R, RFC-R, ARCH-R, XDOC) adopt this shape — decided per rule family when each is next revised; this ADR establishes the option, not a mandate to retrofit
- Reviewer prompt engineering to elicit the property test reliably — that is a reviewer-agent concern, addressed when reviewer prompts are next revised

### Follow-ups

- Feature 001 SC-001, SC-002, SC-003, and SC-004 validate the shape empirically. Promote this ADR from `Proposed` to `Accepted` on successful validation of all four.
- At next revision of each qualitative rule family, evaluate adoption of this shape. Non-qualitative rules (mechanical/structural) retain their current form.
- `.claude/rules/rule-design.md` governs the research pattern used for this decision; it is the process artifact that produced this ADR.
