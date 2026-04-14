---
status: complete
date: 2026-04-11
owner: nic
type: analysis
---

# Preflight workflow integration research

## Executive summary

Preflight has two workflow gaps: (1) no defined process for creating features — docs drift from reality, and (2) no "idea to implementation requirements" breakdown flow. This analysis evaluated six integration options against eight criteria using FirstPrinciples decomposition, IterativeDepth scoring, Council debate, and RedTeam stress-testing.

**Recommendation: Evolve preflight in place toward Tack Room readiness.** Add a task-plan doc type and post-build review rules now, as concrete improvements to the working plugin. Keep Tack Room as the north-star architecture. Do not adopt external frameworks (Superpowers, GSD-2, BMAD) or import OpenSpec as a methodology layer. Absorb useful ideas directly into skill behavior.

---

## The problem decomposed (FirstPrinciples)

An idea becomes verified implementation through five irreducible transforms:

| Transform | What it does | Natural owner |
|-----------|-------------|---------------|
| T1 Clarification | Vague intent → falsifiable statement | **Preflight** (new + review) |
| T2 Decomposition | Statement → work units sized for one actor | **PAI Algorithm** (PLAN phase) |
| T3 Construction | Work unit → artifact (code, config, docs) | **Tack Room** inner loop (builder) |
| T4 Verification | Artifact → checked against T1 statement | **Split**: Preflight (doc verification), Tack Room (runtime verification) |
| T5 Integration | Verified artifacts → shared model updated | **Tack Room** outer loop (post-build gate) |

Every framework (OpenSpec, Superpowers, GSD-2, BMAD) implements these same five transforms with different names and sequencing. None adds a sixth.

### Three actual gaps

| Gap | Transform | What's missing | Fix |
|-----|-----------|---------------|-----|
| A | T2 | No structured format for task decomposition output | Task-plan doc type in preflight |
| B | T5 | Nothing forces post-build spec updates | Post-build review rules + harness gate |
| C | T3 | Builder doesn't know which specs govern its files | Spec-aware context loading (Tack Room concern) |

---

## Framework landscape

### OpenSpec (Fission AI, ~32k stars)

**Flow**: `/opsx:explore` → `/opsx:propose` → `/opsx:apply` → `/opsx:archive`

**Strengths**: Brownfield-first with delta semantics (ADDED/MODIFIED/REMOVED). WHEN/THEN behavioral specs with RFC 2119 formalism. Lightweight (~250 lines). The explore/propose discipline forces thinking before building.

**Weaknesses**: No multi-agent orchestration. No execution framework. No verification beyond optional `/opsx:verify`. No learning output. Fire-and-forget.

**Relevant insight**: The explore/propose cognitive split is valuable. The tooling is not — it competes with preflight's doc structure.

### Superpowers (obra, ~95k stars)

**Flow**: brainstorm → plan → execute → review (two-stage: spec compliance + code quality)

**Strengths**: Strongest execution and verification in the landscape. TDD enforcement ("iron law"). Subagent-driven development with fresh context per task. Empirical evidence: self-review (30s checklist) matches subagent review (25 min) for defect rate — what you check matters more than who checks.

**Weaknesses**: No behavioral spec layer. Plans are implementation-oriented, not requirement-traceable. Full dependency on upstream project. Own execution model conflicts with PAI Algorithm.

**Relevant insight**: Two-stage review architecture is validated. Preflight's ensemble review (checklist + bogey) is architecturally equivalent and already exists.

### GSD-2 (gsd-build, ~34k stars)

**Flow**: discuss → plan → execute → verify → complete → reassess

**Strengths**: Context rot prevention (70% utilization → fresh window). State machine controls execution externally. Parallel wave-based task execution. Stuck detection.

**Weaknesses**: High token overhead (fresh 200k context per task). No structured learning output. Context isolation is the value prop — weakens as model context windows improve.

**Relevant insight**: The 70% context fill limit is a validated engineering constraint. Adopted in Tack Room architecture already.

### BMAD (bmad-code-org, ~41k stars)

**Flow**: 12+ agent personas (Analyst → PM → Architect → Dev → QA) with agile sprint decomposition

**Strengths**: Role separation prevents single-agent blind spots. Three parallel adversarial reviewers (Blind Hunter, Edge Case Hunter, Acceptance Auditor). Sprint-story decomposition.

**Weaknesses**: Heavy — 19 agents, 34+ workflows. Steep learning curve. Agent personas directly conflict with PAI Algorithm phases. Not for brownfield.

**Relevant insight**: Adversarial review mandate (must find issues, zero = halt) is aggressive but honest about AI review limits.

---

## Six options evaluated

### Scoring criteria

| # | Criterion | What it measures |
|---|-----------|-----------------|
| 1 | Goal alignment | Solves both stated gaps (workflow process + implementation flow) |
| 2 | Review preservation | Preflight's ensemble review (checklist + bogey) survives intact |
| 3 | Tack Room fit | Works as harness content for autonomous building |
| 4 | PAI compatibility | Plays well with ISC/Algorithm/effort tiers |
| 5 | Maintenance burden | How much to build and maintain (5=low burden) |
| 6 | Migration risk | Transition risk (5=low risk) |
| 7 | Framework dependency | Exposure to upstream changes (5=no dependency) |
| 8 | Immediate value | What gets better on day one (5=immediate) |

---

### Option A: Preflight standalone extension

**Description**: Add `/preflight explore` and `/preflight decompose` skills. Keep everything in one plugin.

**Strengths**: Zero dependencies. Full control. Review preserved intact. Incremental.

**Weaknesses**: Stretches preflight's identity — workflow engine bolted onto document tool. Every behavioral change needs ADR + version bump (CONST-PROC-01). Not harness content — still requires human invocation.

| Criterion | Score | Reason |
|-----------|-------|--------|
| Goal alignment | 3 | Addresses both gaps but awkwardly — workflow in a doc tool |
| Review preservation | 5 | Unchanged |
| Tack Room fit | 2 | Plugin skills aren't harness content |
| PAI compatibility | 3 | Works but doesn't leverage Algorithm naturally |
| Maintenance burden | 2 | Large surface area under governance rules |
| Migration risk | 4 | Incremental, low blast radius |
| Framework dependency | 5 | Zero |
| Immediate value | 3 | Usable once built |
| **Total** | **27** | |

**Biggest risk**: Scope creep turns preflight into unmaintainable monolith.
**What gets better immediately**: New doc type available for task planning.

---

### Option B: Preflight + Superpowers integration

**Description**: Downscope preflight to review rules. Adopt Superpowers for brainstorm→plan→execute→review.

**Strengths**: Real workflow engine. Battle-tested execution. 95k stars of community validation.

**Weaknesses**: Downscoping preflight discards elicitation and scaffold value. Hard dependency on upstream. Superpowers' execution model conflicts with Algorithm.

| Criterion | Score | Reason |
|-----------|-------|--------|
| Goal alignment | 4 | Workflow engine directly solves both gaps |
| Review preservation | 3 | Rules survive but in different execution context |
| Tack Room fit | 2 | Superpowers is its own framework, not harness content |
| PAI compatibility | 2 | Competing execution model |
| Maintenance burden | 3 | Integration layer needs ongoing work |
| Migration risk | 3 | Downscoping preflight is destructive |
| Framework dependency | 1 | Full upstream dependency |
| Immediate value | 3 | Only after integration built |
| **Total** | **21** | |

**Biggest risk**: Superpowers evolves incompatibly; you've already gutted preflight.
**What gets better immediately**: Brainstorming discipline (if adopted standalone).

---

### Option C: OpenSpec methodology + Preflight review

**Description**: Adopt OpenSpec's explore→propose discipline as methodology. Preflight reviews enforce quality. No tooling dependency.

**Strengths**: Lowest risk — additive only. Methodology layers over Algorithm phases. Immediate process improvement via documentation.

**Weaknesses**: Methodology without enforcement degrades under pressure. No mechanical guardrail for "did you explore first?"

| Criterion | Score | Reason |
|-----------|-------|--------|
| Goal alignment | 3 | Addresses gaps but lacks enforcement |
| Review preservation | 5 | Unchanged |
| Tack Room fit | 3 | Methodology encodable in harness prompts (soft guidance) |
| PAI compatibility | 4 | Layers cleanly over Algorithm |
| Maintenance burden | 4 | Lightweight docs |
| Migration risk | 5 | Additive only |
| Framework dependency | 4 | Methodology, not tooling |
| Immediate value | 4 | Process improvement available now |
| **Total** | **32** | |

**Biggest risk**: Methodology without enforcement is aspirational — agents skip explore under long contexts.
**What gets better immediately**: Conscious separation of explore/propose phases.

---

### Option D: Preflight + GSD-2 integration

**Description**: Use GSD-2's phase model. Preflight rules become verification rules in GSD's verify phase.

**Strengths**: Phase model maps to gaps. Context isolation pattern is proven.

**Weaknesses**: GSD phases compete with Algorithm phases. Rules need format translation. Full framework adoption required.

| Criterion | Score | Reason |
|-----------|-------|--------|
| Goal alignment | 4 | Phase model addresses both gaps |
| Review preservation | 3 | Rules need adaptation to GSD format |
| Tack Room fit | 2 | GSD is a framework, not harness content |
| PAI compatibility | 2 | Competing execution model |
| Maintenance burden | 3 | Integration + tracking upstream |
| Migration risk | 3 | Moderate — new framework |
| Framework dependency | 2 | Hard dependency |
| Immediate value | 2 | Requires full adoption first |
| **Total** | **21** | |

**Biggest risk**: Two competing execution frameworks (Algorithm vs GSD phases).
**What gets better immediately**: Very little until fully adopted.

---

### Option E: Preflight as Tack Room harness content

**Description**: Preflight's templates, rules, and review agents are content consumed by Tack Room's builder. PAI Algorithm handles workflow. No external framework.

**Strengths**: Architecturally honest — preflight = content, Algorithm = workflow. No external dependencies. Perfect Tack Room and PAI alignment.

**Weaknesses**: Tack Room doesn't exist yet (design doc only). "Harness content" undervalues preflight's behavioral capabilities (elicitation, ensemble review orchestration).

| Criterion | Score | Reason |
|-----------|-------|--------|
| Goal alignment | 4 | Both gaps addressed via Algorithm + content |
| Review preservation | 5 | Rules ARE the content |
| Tack Room fit | 5 | This IS the Tack Room integration |
| PAI compatibility | 5 | Algorithm drives workflow; preflight passive — zero conflict |
| Maintenance burden | 4 | Content only, no framework glue |
| Migration risk | 3 | Requires Tack Room maturity |
| Framework dependency | 5 | No external framework |
| Immediate value | 3 | Full value needs Tack Room readiness |
| **Total** | **34** | |

**Biggest risk**: Tack Room is vaporware — freezing preflight for an unbuilt system is the rewrite trap.
**What gets better immediately**: Conceptual clarity on what preflight owns.

---

### Option F: Preflight + BMAD integration

**Description**: Adopt BMAD agent personas. Preflight rules feed QA/review agents. Sprint decomposition handles breakdown.

**Strengths**: Role separation. Adversarial review mandate.

**Weaknesses**: 19 agents is heavy. Persona model conflicts with Algorithm. Low incremental value over existing capabilities.

| Criterion | Score | Reason |
|-----------|-------|--------|
| Goal alignment | 3 | Addresses gaps through heavy abstraction |
| Review preservation | 3 | Rules filtered through persona indirection |
| Tack Room fit | 2 | Personas don't map to harness model |
| PAI compatibility | 1 | Direct conflict with Algorithm |
| Maintenance burden | 1 | Heavy framework adoption |
| Migration risk | 2 | Large surface, hard to partially adopt |
| Framework dependency | 2 | Hard BMAD dependency |
| Immediate value | 2 | Requires full adoption |
| **Total** | **16** | |

**Biggest risk**: Parallel governance structure fights Algorithm for control.
**What gets better immediately**: Nothing meaningful.

---

## Thinking skill results

### Council debate verdict

Three perspectives debated (Pragmatist, Architect, User Advocate). Consensus:

**"Ship E-lite now. Skip the bridge."**

- Add task-plan template to preflight (pure T1, no architectural risk)
- Add post-build review rules for spec-drift detection (pure T4 doc-verification)
- Do NOT import OpenSpec as methodology layer — absorb useful ideas directly into skill behavior
- Tack Room remains north star; preflight stays a full plugin until Tack Room exists

**Dissents**:
- Architect: keep post-build rules focused on document content only (no runtime artifacts)
- User Advocate: without an Algorithm REFLECT hint, user still won't remember to run review

### RedTeam attacks

| # | Attack | Severity | Finding |
|---|--------|----------|---------|
| 1 | Timing | Critical | Tack Room is vaporware — need interim value NOW |
| 2 | Scope | High | "Content" undervalues behavioral capabilities (elicitation, ensemble review) |
| 3 | Alternative | Medium | Internal dependency on unbuilt system is also a dependency |
| 4 | Completeness | High | Template ≠ process; post-build detection is reactive, not proactive |
| 5 | Evidence | Medium | No spike, no prototype, no user testing |

**RedTeam verdict**: Architectural direction is sound but needs concrete interim deliverables independent of Tack Room.

---

## Final ranking

| Rank | Option | Score | One-line verdict |
|------|--------|-------|-----------------|
| 1 | **E: Tack Room harness** | **34** | Right architecture, wrong timing without interim plan |
| 2 | **C: OpenSpec methodology** | **32** | Low risk but enforcement-free methodology fades under pressure |
| 3 | **A: Standalone extension** | **27** | Safe but stretches preflight beyond its architectural identity |
| 4 | **B: Superpowers** | **21** | Good engine, dangerous dependency, Algorithm conflict |
| 4 | **D: GSD-2** | **21** | Same structural flaw as B with different framework |
| 6 | **F: BMAD** | **16** | Too heavy, direct Algorithm conflict, low incremental value |

---

## Recommendation: E-lite — evolve in place toward Tack Room

The synthesis across all four thinking skills:

### What to build now (independent of Tack Room)

1. **Task-plan doc type** — Add `content/templates/task-plan-template.md` with review rules in `content/rules-source/task-plan-rules.md`. This is a new preflight doc type for T2 decomposition output. Structured format: spec ID references, work units with acceptance criteria, dependency ordering.

2. **Post-build review profile** — Add rules in `content/rules-source/post-build-rules.md` that the existing review skill can enforce. Rules check: architecture.md freshness vs recent changes, requirement IDs referenced in code but missing from specs, ADR coverage for behavioral changes.

3. **Algorithm REFLECT integration** — One-line addition to Algorithm guidance: after VERIFY, suggest running `/preflight review --profile post-build` against governing specs. This solves the "when" problem without building hooks.

### What NOT to do

- Do NOT downscope preflight — its behavioral capabilities (guided elicitation, ensemble review, scaffold) are genuine value that "harness content" framing undervalues
- Do NOT import OpenSpec as a methodology layer — absorb the useful idea (explore/define separation) directly into the `new` skill's elicitation flow
- Do NOT adopt Superpowers, GSD-2, or BMAD — they all introduce competing execution models that conflict with PAI Algorithm

### Tack Room north star (when it exists)

When Tack Room ships:
- Preflight's templates and rules become harness content the builder agent loads
- Post-build review becomes a Tack Room gate (inner loop, harness-mandated)
- Spec-aware context loading uses preflight's cross-doc reference system
- Preflight's interactive skills (scaffold, new, review) continue working for human pairing sessions

### What gets absorbed from each framework

| Framework | Idea absorbed | How |
|-----------|--------------|-----|
| OpenSpec | Explore/define phase separation | Built into `new` skill elicitation: ask "have you explored alternatives?" before converging |
| Superpowers | "What you check matters more than who checks" | Validates preflight's rule-based approach over adding more review agents |
| GSD-2 | 70% context fill limit | Already in Tack Room architecture |
| BMAD | Adversarial review mandate | Already exists as bogey-reviewer agent |

### Migration path

1. **This sprint**: Add task-plan doc type + post-build review rules to preflight (two issues, two PRs)
2. **Next sprint**: Add Algorithm REFLECT hint for post-build review trigger
3. **When Tack Room ships**: Preflight content auto-consumed via harness; no migration needed because content format is already harness-compatible (markdown templates + rules in `content/`)

---

## Appendix: Prior work incorporated

- **RFC-001** (execution framework): Recommended hybrid (OpenSpec methodology + Superpowers execution). This analysis re-evaluates with Tack Room architecture context and user's evolved goals. The hybrid is rejected in favor of E-lite because Tack Room's builder harness subsumes Superpowers' execution role.
- **Tack Room execution architecture**: Defines inner/outer loop and harness content model. Preflight's content already fits this model without restructuring.
- **Session execution engine comparison**: Framework landscape evaluation confirming PAI Algorithm's unique strengths (ISC + structured learning).
