---
status: complete
date: 2026-04-13
owner: nic
type: analysis
purpose: spike reference
supersedes_framing_of:
  - 2026-04-12-pass4-build-vs-customize.md
  - 2026-04-13-framework-customization-depth.md
---

# Composable architecture — spec-kit + preflight + PAI

## Tldr

The workflow research arc spent 31 passes asking "preflight vs substrate X" — a substitution question. The honest framing is composition: **spec-kit owns authoring and lifecycle, preflight owns rules and governance, PAI owns decomposition and execution.** Each layer owns a surface the others don't touch. Drop spec-kit's `tasks.md` because PAI has ISC. Wire preflight review into spec-kit's `after_specify` and `after_plan` hooks at LLM-prompt-enforcement level. Spec-kit's multi-agent CommandRegistrar (17+ agents) is the Tack Room glue I dismissed across every pass — that was the biggest analytical miss of the arc.

This document captures the composable framing as reference material for the upcoming spikes. ADR-007's shape decisions still hold; what changes is which layer implements them.

---

## 1. The framing miss — substitution vs composition

Across passes 1–5, the re-analysis, and the framework customization depth doc, the question was always "which one wins, A or B?" Pass 1 scored 6 options. Pass 4 scored Path A vs B1 vs B2. The customization depth doc scored A vs B3 vs B4. Every pass treated preflight, OpenSpec, spec-kit, BMAD, and GSD-2 as substitutes for the same job.

They are not substitutes. They live at different layers:

- **Authoring + lifecycle** (spec-kit, OpenSpec, BMAD) — frameworks that scaffold doc folders, manage propose/apply/archive flows, and orchestrate command surfaces across AI tools.
- **Rules + governance** (preflight) — content validation, severity grading, traceability, procedural enforcement (CONST-PROC-01/02), the 25-category L4 coverage taxonomy.
- **Decomposition + execution** (PAI Algorithm) — atomic ISC criteria generation, builder execution, memory, session state.

When the layers are framed as substitutes, every "alternative considered" loses to Path A on the criteria that only matter to the layer where they happen to be strongest. The substitution framing forces fights between things that don't need to fight.

**The composition framing**: instead of "which one do we pick," ask "which layer of the stack does each cover, and what's the seam?" Frameworks that cover non-overlapping layers compose. Frameworks that fight over the same layer require substitution.

This was not in the meta-methodology doc. It is now angle 2.10 (see §10).

---

## 2. The Tack Room multi-agent miss

Pass 4's Layer 6 backward-walk asked "what must be true for a different builder to consume the same package?" and answered with **file portability**: any builder can `cat work-package.yaml`. Every later pass inherited this framing.

That's a weaker claim than what Tack Room actually needs. Tack Room is on-the-loop autonomy *across agents*. The architectural target is multi-agent coordination, not single-agent execution with portable files. For multi-agent coordination, the question isn't "can they all read the file" — it's "can they all be invoked the same way."

Spec-kit's `CommandRegistrar` answers the second question. It writes commands to `.claude/commands/`, `.gemini/commands/`, `.cursor/commands/`, `.windsurf/commands/`, and ~13 other agent directories automatically when a preset is installed. One preset write → 17+ agents see the same `/speckit.specify` command. This is **native command portability**, not just file portability, and it is the closest existing mechanism to Tack Room's multi-builder coordination requirement.

I dismissed this as "near-zero value" in the customization depth doc and in the prior conversation turn. That was wrong. The multi-agent reach is directly Tack Room's bullseye, and it would be expensive to build natively in preflight (preflight is a Claude Code plugin and would need new infrastructure for every additional agent target).

**Net**: spec-kit's multi-agent reach is one of the highest-value features for Tack Room specifically, and the entire research arc under-weighted it because the framing was substitution rather than composition. Under composition, multi-agent reach is a thing you *gain by composing* rather than something you *lose by adopting*.

---

## 3. The three-layer composable architecture

```
┌─────────────────────────────────────────────────────────┐
│ spec-kit — authoring + lifecycle + multi-agent reach    │
│   • spec.md / plan.md templates (preset overrides)       │
│   • apply / archive / propose lifecycle                  │
│   • CommandRegistrar — 17+ agent dirs                    │
│   • after_specify / after_plan / after_tasks /           │
│     after_implement hooks                                │
│   • SKIP tasks.md — PAI owns task decomposition          │
├─────────────────────────────────────────────────────────┤
│ preflight — governance + rules + doc-type completeness   │
│   • 48 rules with severity, run via spec-kit hooks       │
│   • Templates for the 7 doc types spec-kit doesn't       │
│     cover (constitution, requirements, architecture,     │
│     ADR, RFC, interface contract, test strategy)         │
│   • CONST-PROC-01 / CONST-PROC-02 governance             │
│   • 25-category L4 coverage reference                    │
│   • Review skill exposed as a spec-kit extension         │
│     command (`speckit.preflight.review`)                 │
├─────────────────────────────────────────────────────────┤
│ PAI — decomposition + execution + memory                 │
│   • Algorithm reads plan.md, decomposes to ISC           │
│   • Per-session PRD as ephemeral execution state         │
│   • Memory + session registry stay PAI-native            │
│   • Skips tasks.md entirely — has its own surface        │
└─────────────────────────────────────────────────────────┘
```

### Why each layer owns its surface cleanly

**spec-kit** owns the surface where multi-agent reach and lifecycle ergonomics matter most. Preflight could build apply/archive natively (ADR-007 says so) but would duplicate work spec-kit ships in production today. Preflight could build multi-agent registration but it would require new infrastructure per agent target.

**preflight** owns the surface where deterministic content validation and procedural governance matter. Spec-kit cannot enforce the 48 rules — its `rules:` field equivalent is prompt-level only. Preflight's review engine does not duplicate anything spec-kit owns.

**PAI** owns the surface where atomic task decomposition and execution context happen. Spec-kit's `tasks.md` is the artifact that conflicts here, which is exactly why we drop it from the preset. Without `tasks.md`, spec-kit has nothing in the execution layer; PAI's Algorithm reads `plan.md` directly and produces ISC in its own PRD.

The seams between layers are file-on-disk: `spec.md` and `plan.md` are written by spec-kit, validated by preflight, consumed by PAI. Each transition is a markdown file in a known location. No tight coupling, no shared runtime, no upstream API dependency at the file boundaries.

---

## 4. Concrete flow — IssueResolver as the worked example

Using dispatch PR #10 (the IssueResolver design doc walkthrough from pass 2) as a concrete trace, under the composable architecture:

1. **Initiation**: `/speckit.specify "Add IssueResolver to dispatch — automated issue-to-PR agentic workflow"` — invoked through spec-kit's preset, which writes the command to all 17+ agent directories so the same call works from Claude Code, Cursor, etc.
2. **Spec scaffolding**: spec-kit creates `specs/NNN-issue-resolver/spec.md` using the preflight preset's overridden `spec-template.md`. The template includes:
   - Intent (prose)
   - L4 coverage section (25-category checklist)
   - Requirements delta — full file copy of `requirements.md` per ADR-007 Option C
   - Architecture delta — full file copy of `architecture.md` if architecture changes
   - References (FRs touched, ADRs blocked-on, RFCs referenced)
3. **after_specify hook fires**: invokes `speckit.preflight.review` extension command, which runs the 48-rule review engine over `spec.md` and any whole-file copies. Findings flow back as an LLM prompt the user must address before continuing. **LLM-prompt enforcement, not blocking exit code** — accepted per the "enforced running, not 100% airtight" contract.
4. **Plan generation**: `/speckit.plan` — spec-kit creates `plan.md` for the first PR using preflight's plan template (intent, prose acceptance, inlined context). One plan per PR. Multi-PR features create multiple plans inside `specs/NNN-issue-resolver/plans/`.
5. **after_plan hook fires**: review runs again over plan + current spec. Drift between plan acceptance and spec acceptance is flagged. Same LLM-prompt-enforcement model.
6. **Skip tasks.md**: the preset overrides or removes `/speckit.tasks` from the agent dirs. The next step is not spec-kit's task generation — it is PAI invocation.
7. **PAI execution**: the user runs PAI Algorithm against `specs/NNN-issue-resolver/plans/001-triage-phase.md`. PAI's OBSERVE phase reads the plan's intent + acceptance, applies the Splitting Test, generates ISC criteria in the session PRD, builds, ships.
8. **Post-implementation**: spec-kit's `after_implement` hook (or a separate post-PR-merge hook) runs preflight's drift check using the two-tier FR lookup (main first, then in-flight feature folders). Drift findings are PR comments.
9. **Repeat for each PR** in the multi-PR feature. Each PR produces its own plan inside the same feature folder.
10. **Ratification**: `/speckit.apply` (or the preset's override) atomically replaces main's `requirements.md` and `architecture.md` with the feature folder's whole-file copies, archives the feature folder to `specs/features/archive/NNN-issue-resolver/`, and bumps plugin version per CONST-PROC-01 if applicable.

The flow looks substantively identical to ADR-007 v1, but it is implemented across three layers instead of inside preflight alone.

---

## 5. Path A-prime — composable scoring

Rough re-score against pass 4's 15-criterion matrix (full re-scoring is a follow-up if the spikes validate this path):

| Criterion | Standalone A | Path A-prime (composable) | Δ |
|---|---:|---:|---:|
| Strategic differentiation (3×) | 5 | 5 | — |
| Core competency alignment (2×) | 5 | 5 | — |
| Total cost of ownership (2×) | 4 | 5 | +2 (lifecycle reused, not built) |
| Time to value (2×) | 4 | 5 | +2 (preset is faster than skills) |
| Control + customization (3×) | 5 | 4 | -3 (some lifecycle behavior moves upstream) |
| Vendor risk (2×) | 5 | 3 | -4 (spec-kit pre-1.0 churn) |
| Integration complexity (2×) | 5 | 3 | -4 (preset + extension API surface) |
| Upgrade path (2×) | 5 | 4 | -2 (preset versioning vs internal evolution) |
| Network effects (1×) | 1 | 5 | +4 (community-validated shape) |
| Reversibility (2×) | 5 | 4 | -2 (preset migration cost if abandoned) |
| PAI Algorithm compatibility (3×) | 5 | 5 | — |
| Tack Room harness fit (3×) | 4 | 5 | +3 (multi-agent reach delivered) |
| Preflight rules preservation (3×) | 5 | 5 | — (rules still live in preflight) |
| 25-category coverage (3×) | 5 | 5 | — |
| Daily workflow friction (2×) | 4 | 4 | — |

**Standalone Path A**: 161/175 (pass 4)
**Path A-prime estimate**: ~155–160/175 — within noise of standalone, with a meaningfully different risk profile

The composable path trades **reduced control** (vendor lock-in to spec-kit's preset format), **vendor risk** (spec-kit pre-1.0 churn), and **integration complexity** (preset + extension API surface to learn) for **lower TCO** (reused lifecycle), **faster time to value** (preset is faster than building skills), **community network effects** (validated shape), and **direct Tack Room fit** (multi-agent reach).

The trade is not obviously a win or loss in the abstract. It depends on whether spec-kit's preset API stabilizes within 6 months and whether Tack Room actually needs the multi-agent reach. **Both are spike-testable.**

---

## 6. PAI brownfield composition

The earlier brownfield concern was: "spec-kit's authoritative-folder model fights PAI's distributed source-of-truth nature." Under the composable framing, this concern dissolves.

**Reframe**: spec-kit isn't trying to be authoritative over PAI. It is the **upstream coordination layer** for in-flight changes. PAI's distributed truth (CLAUDE.md, skills, rules files, the Algorithm, memory) stays exactly where it is. Spec-kit manages the propose/apply lifecycle for *changes to* that distributed truth, not the truth itself.

Concrete map for PAI:
- `specs/NNN-feature/spec.md` — the proposal for a PAI change (e.g., "add a new skill," "modify the Algorithm," "introduce a new rule file")
- `specs/NNN-feature/requirements.md` — preflight-format requirements distilled from the change (FRs the new skill introduces, NFRs the Algorithm change must respect)
- `specs/NNN-feature/plans/` — per-PR briefs that PAI consumes
- `specs/NNN-feature/architecture.md` — only when the Algorithm or memory layout changes
- The actual PAI implementation files (`~/.claude/CLAUDE.md`, `$PAI_DIR/PAI/Algorithm/`, etc.) stay where they are; the feature folder *describes the change to them*, it doesn't replace them

Composition reads: "spec-kit owns the lifecycle of *changes* to PAI; PAI continues to own *itself*." The boundary is clean.

This also resolves the earlier "PRD vs plan.md duplication" concern. PRD is **execution state** for one Algorithm run. plan.md is **the durable spec** for a unit of work. PAI generates a new PRD from the plan.md every time it runs. plan.md is upstream; PRD is downstream and ephemeral. They serve different lifecycles and don't compete.

---

## 7. ADR-007 — does this require a rewrite?

**No.** ADR-007's shape decisions all hold:

- Feature folder as the unit of in-flight change ✓
- Whole-file copy of requirements.md (Option C) ✓
- One plan per PR, plans/ subfolder ✓
- Mid-build ADR escalation pause ✓
- Atomic ratification PR on ship ✓
- Two-tier FR lookup for drift detection ✓
- /preflight:explore as elicitation entry ✓ (becomes a preset command override of /speckit.specify)
- RFC stays independent ✓
- ADR conditional on requirement change ✓

What changes is **the implementation layer**. ADR-007 v1 assumes preflight builds these as native skills. The composable path implements them as a spec-kit preset + extension command + hooks. The user-facing flow is nearly identical; the substrate is different.

**Recommendation**: do not amend ADR-007 v1 today. The shape is correct under either implementation. Let the spikes determine which layer implements it. After the spikes, either:
- Promote ADR-007 v1 (preflight-native) if spikes show preset friction is too high, or
- Amend ADR-007 to v2 (composable) if spikes validate the preset path

This avoids paper revisions ahead of empirical data.

---

## 8. Reshaped spike plan

Three spikes, each testing a different axis of Path A-prime:

### Spike 1 — small preflight github issue, preset path

**Goal**: validate that a spec-kit preset can carry preflight's templates and rule invocations cleanly for a trivial change.

**Steps**:
1. Pick one open preflight github issue (small surface — a rule tweak, a template fix, a typo correction)
2. Author a minimal spec-kit preset (`presets/preflight/`) containing:
   - Override of `spec-template.md` with one preflight doc type's structure
   - Extension command `speckit.preflight.review` that shells out to `preflight review`
   - Hook wiring `after_specify` → `speckit.preflight.review`
3. Run the preset: `/speckit.specify <issue title>` → spec produced → hook runs review → fix findings → done
4. Capture frictions in `docs/spikes/2026-04-NN-spike1-preset-small.md`

**Pass criteria**:
- Preset installs cleanly without modifying spec-kit source
- Hook fires and review runs
- Findings flow back to user via LLM prompt
- Total spike time < 1 day
- Preset feels native enough that the spec-kit branding doesn't impose noticeable overhead

**Fail criteria**:
- Preset API requires forking spec-kit
- Hook integration is silent or unreliable
- Spec-kit's command vocabulary creates user-visible friction that compounds

### Spike 2 — tack-room launcher, multi-agent test

**Goal**: validate that spec-kit's multi-agent reach delivers usable Tack Room glue, and that the composable path holds for a multi-plan feature with mid-build ADR discovery.

**Steps**:
1. Resume the aborted tack-room launcher feature
2. Apply the preflight preset from spike 1 (extended to cover all 7 preflight doc types if spike 1 succeeded)
3. Use `/speckit.specify` to generate the feature folder
4. Use `/speckit.plan` for the first PR of the launcher
5. Have PAI consume `plan.md` directly, build, ship
6. **Test multi-agent reach**: install the preset on a second AI tool target (Cursor or Gemini, whichever is easiest to spin up) and verify the same `/speckit.preflight.*` commands appear and fire
7. Force a mid-build ADR discovery scenario to test the pause/escalate/resume flow
8. Capture findings in `docs/spikes/2026-04-NN-spike2-launcher-multi-agent.md`

**Pass criteria**:
- 2+ plans produced and shipped
- Mid-build ADR discovery handled per ADR-007's pause/escalate flow
- Multi-agent registration verified — same commands work from at least two agent targets
- Ratification PR atomically replaces main's specs

**Fail criteria**:
- Multi-agent registration is harder than expected, or only works on Claude Code in practice
- Preset cannot express enough of preflight's surface to feel complete
- Mid-build escalation breaks down because spec-kit's lifecycle assumes linear forward progress

### Spike 3 — PAI brownfield micro-spike

**Goal**: validate that spec-kit + preflight compose onto PAI without fighting PAI's distributed authority.

**Steps**:
1. Pick one small PAI change that is real but not urgent (a rule edit, a small skill addition, a CLAUDE.md adjustment)
2. Without implementing the change, sketch what the feature folder would look like inside PAI:
   - Where does `specs/` sit relative to `$PAI_DIR/`?
   - Does the spec.md duplicate or reference existing CLAUDE.md content?
   - Does the plan.md feel like a natural input to PAI's Algorithm or like a foreign artifact?
3. Confirm: PAI reads plan.md without choking on it, ISC generation works on prose acceptance criteria, no namespace collisions with existing PAI commands
4. Capture findings in `docs/spikes/2026-04-NN-spike3-pai-brownfield.md`

**Pass criteria**:
- Feature folder fits cleanly into PAI's existing structure (probably as a top-level `specs/` peer to `$PAI_DIR/`)
- spec.md references CLAUDE.md / rules files rather than duplicating them
- PAI's Algorithm reads plan.md and decomposes to ISC without any modification
- No `tasks.md` is produced or required

**Fail criteria**:
- Authoritative-folder smell — `specs/` wants to own things PAI already owns elsewhere
- Plan.md format is foreign to PAI's Algorithm and requires PAI-side adapter code
- Multi-agent CommandRegistrar interferes with PAI's existing command surface

### Order

Spike 1 first (cheapest, validates the basic preset mechanic). Spike 3 second (cheap, validates brownfield composition with concrete PAI realities). Spike 2 last (largest, tests the full multi-agent + multi-plan flow once the smaller spikes have de-risked the basics).

---

## 9. Open questions per spike

These are the questions the spikes should answer empirically, not in advance:

1. **Spike 1**: Does a spec-kit preset feel native enough that the spec-kit branding (command names, file layout) doesn't create persistent friction for daily preflight use?
2. **Spike 1**: Does `after_specify` LLM-prompt enforcement reliably get acted on by users, or does the advisory nature cause review findings to drift past?
3. **Spike 2**: Is multi-agent CommandRegistrar a real productivity gain, or is it cosmetic — do users actually invoke commands from the secondary agent dirs?
4. **Spike 2**: Does the apply/archive lifecycle handle multi-plan features cleanly, or does it expect a single proposal-to-apply transition?
5. **Spike 3**: Where does `specs/` live in PAI? Does it sit at the repo root alongside `$PAI_DIR/`, or does it need to live somewhere PAI considers project-scoped?
6. **Spike 3**: Does PAI's Algorithm OBSERVE phase happily read plan.md, or does it assume PRD-format input?
7. **Cross-cutting**: What is the upgrade story when spec-kit ships a breaking preset API change? Is the maintenance burden tractable for one maintainer?
8. **Cross-cutting**: Does dropping `tasks.md` cause any spec-kit lifecycle steps to fail (apply, archive) or are those steps tolerant of the missing artifact?

---

## 10. Methodology angle 2.10 — composition-first before substitution

**What it does**: before scoring options as substitutes (A vs B vs C), ask whether they cover the same layer of the problem. If they cover different layers, the question is composition topology, not selection.

**What it catches**: framing errors where a multi-layer architecture gets analyzed as a single-layer choice. Substitution framing forces fights between things that don't need to fight; composition framing reveals the seams where they can coexist.

**When to use**: when the candidate "substrates" are extensible by design AND the "build" option duplicates surface the substrate already owns. Both conditions were true for preflight + spec-kit + PAI and the arc missed it across 31 passes.

**Failure mode prevented**: scoring frameworks against each other on criteria that are only meaningful within one layer. Pass 4's 15-criterion matrix scored Path A and B1 against each other on multi-agent reach (network effects), and B1 scored 1× weight because we treated it as nice-to-have rather than load-bearing for Tack Room. Under composition framing, multi-agent reach is a *gain you compose in* rather than a *lose-by-adopting* — the same criterion flips sign.

**Load-bearing in**: this doc, which produced the recommendation to test composable Path A-prime via spikes rather than commit to standalone Path A.

**Cost**: requires identifying the layers up front, which is sometimes hard. If layer boundaries are ambiguous (because two frameworks legitimately fight over the same surface), composition framing collapses back to substitution. Use only when the layers are clean.

**Proposal for `docs/analysis/2026-04-12-meta-evaluation-methodology.md`**: add this as a new angle in §2 between 2.7 (Backward-walking) and 2.8 (Criteria-first re-scoring). It is a pre-step to scoring, not an alternative to it. The pattern is: identify layers → identify which framework owns which layer → score only across options that cover the same layer → if composition is possible, score the composed stack as its own option.

---

## 11. Tripwire revisions

Day-60 tripwire (2026-06-13) gains additional watch conditions per this analysis:

1. **spec-kit ships breaking preset API change** that would make Path A-prime unmaintainable for one maintainer — re-evaluate composable path
2. **spec-kit reaches v1.0 with stable preset/extension API** — strengthens Path A-prime, lowers vendor risk
3. **spec-kit's CommandRegistrar adds or drops major agent targets** — affects Tack Room fit calculation
4. **Tack Room program's actual multi-agent requirements clarify** — if it turns out Claude-Code-only in practice, the multi-agent reach value drops back toward zero and standalone Path A regains its lead
5. (carried forward) spec-kit ships blocking hook semantics — strengthens enforcement gate, but no longer decisive under "LLM-prompt enforcement is sufficient"
6. (carried forward) OpenSpec ships pre-apply validator hooks — would re-open B3
7. (carried forward) OpenSpec ships rule-as-code DSL — would re-open B1

---

## 12. What this doc supersedes

- **Pass 4 §2 (buy-vs-build scoring)**: not the conclusion (Path A still wins by some flavor), but the framing. Path A and B1/B2 should not have been scored as substitutes. Re-running pass 4's matrix under composition framing produces Path A-prime as a new option that scores within noise of standalone Path A but trades risk profile.
- **Pass 5's tripwire condition list**: extended per §11.
- **Customization depth doc §3.3 (spec-kit verdict)**: the "blocking gap is decisive" claim is withdrawn. Under "LLM-prompt enforcement is sufficient" + composition framing, spec-kit's hooks are not a decisive gap — they are an acceptable enforcement layer for non-deterministic content checks.
- **Customization depth doc §5.2 (Option B4 scoring at 130)**: B4 was scored as substitution. Under composition (Path A-prime), the same underlying mechanism scores closer to 155–160 because it is no longer "lose preflight rules" but "compose preflight rules onto spec-kit's lifecycle."

What this doc does **not** supersede:

- **ADR-007 shape decisions**: feature folder, whole-file copy, ratification, two-tier FR lookup, mid-build ADR escalation. All hold under either implementation.
- **Pass 5 re-analysis 4-item plan**: the four items still need to ship; this doc only changes which layer ships them.
- **Pass 4's decisive criterion list**: rules preservation, Tack Room harness fit, control/customization. All still load-bearing — they just score differently under composition.

---

## 13. The one-paragraph version (for memory aid)

Spec-kit owns authoring and lifecycle and multi-agent reach. Preflight owns rules and governance and the doc types spec-kit doesn't cover. PAI owns task decomposition and execution. Drop spec-kit's tasks.md because PAI has ISC. Wire preflight review into spec-kit's after_specify and after_plan hooks — LLM-prompt enforcement is sufficient because content rules are non-deterministic anyway. Spec-kit's CommandRegistrar reaches 17+ AI agent targets, which is the closest existing answer to Tack Room's multi-builder coordination problem; the entire research arc under-weighted this. ADR-007's shape is right under either implementation; the spikes determine which layer implements it. Three spikes: small preflight issue via preset, tack-room launcher with multi-agent verification, PAI brownfield composition micro-spike. Methodology lesson: composition-first before substitution, when frameworks cover non-overlapping layers.
