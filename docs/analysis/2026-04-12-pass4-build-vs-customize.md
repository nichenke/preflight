---
status: complete
date: 2026-04-12
owner: nic
type: analysis
supersedes_conclusions_of: 2026-04-12-pass3-category-coverage.md
---

# Pass 4 — build on preflight vs customize OpenSpec

Three analytical lenses applied to the same question: **given preflight's L4 autonomy gaps (operations-envelope categories 20–23), should we extend preflight in place or customize OpenSpec?**

- Lens 1 — buy-vs-build weighted criteria (15 dimensions)
- Lens 2 — time-horizon projection (7, 30, 180 days)
- Lens 3 — backward walk from a fully-implemented Tack Room

All three converge on the same primary recommendation but disagree on one load-bearing detail about ordering. That disagreement is the most important finding of this pass.

---

## 1. The three paths (precise definitions)

**Path A — Build on preflight.** Extend the existing preflight plugin with:
1. Completeness-contract view (`/preflight review --coverage`) — groups the 48 rules by L4 category and reports coverage per change
2. Operations-envelope doc type (Cat 20 + 22: tool inventory, stopping conditions)
3. Rollback-criteria field required on behavioral ADRs (Cat 23)
4. Task-plan doc type (Cat 21)
5. Explore/propose skills + work-package.yaml serializer
6. Post-implementation drift hook
7. Later: data model, threat model, JTBD framing (Cats 1, 11, 19)

**Path B1 — OpenSpec config-customized.** Ship `openspec/schemas/preflight/` with preflight's 7 doc templates. Flatten the 48 rules into OpenSpec's `rules:` field as soft AI guidance. Preflight's `/preflight review` remains as a standalone validator outside OpenSpec. User runs two tools.

**Path B2 — OpenSpec hard fork.** Fork OpenSpec (~4000 lines of TypeScript workflow templates), rebrand commands to `/preflight:*`, port the 48 rules to custom Zod validators, maintain rebase against an upstream shipping 12 releases per 90 days.

**Path C — Hybrid.** Path A primary. Borrow OpenSpec's task.md format specifically for Cat 21 (task decomposition) as a round-trippable file format. No runtime dependency on OpenSpec; just format compatibility at a single artifact boundary.

---

## 2. Lens 1 — buy-vs-build weighted criteria

### 2.1 The 15 criteria and their weights

Ten classical buy-vs-build criteria plus five criteria specific to this project, weighted to reflect that this is personal/team infrastructure (not enterprise procurement):

| # | Criterion | Weight |
|---|-----------|--------|
| 1 | Strategic differentiation | 3× |
| 2 | Core competency alignment | 2× |
| 3 | Total cost of ownership | 2× |
| 4 | Time to value | 2× |
| 5 | Control & customization | 3× |
| 6 | Vendor risk | 2× |
| 7 | Integration complexity | 2× |
| 8 | Upgrade path | 2× |
| 9 | Network effects | 1× |
| 10 | Reversibility | 2× |
| 11 | PAI Algorithm compatibility | 3× |
| 12 | Tack Room harness fit | 3× |
| 13 | Preflight rules preservation | 3× |
| 14 | 25-category coverage | 3× |
| 15 | Daily workflow friction | 2× |

Max score: 35 criteria × 5 = 175.

### 2.2 Results

| Path | Weighted score | % of max | Gap to next |
|------|---------------:|---------:|------------:|
| **A — Build on preflight** | **161** | **92%** | — |
| B2 — Hard fork OpenSpec | 96 | 55% | 65 |
| B1 — OpenSpec config-customize | 85 | 49% | 11 |

The gap between A and the nearest alternative is 65 weighted points. This is not close on the numbers.

### 2.3 The decisive criteria

Three criteria drove most of the gap:

**Preflight rules preservation (weight 3×).** B1 scores 1/5 because the 48 rules become soft AI guidance in OpenSpec's `rules:` field — they stop being enforced, they become suggestions. This violates nic's explicit hard requirement. A weighted loss of 12 points on one criterion closes most of the gap.

**Tack Room harness fit (weight 3×).** Preflight's content already lives in `.preflight/` and is consumed as-is by the harness content model. B1 scores 2/5 because OpenSpec uses a different directory layout and requires re-plumbing. B2 scores 3/5 because you can fork and rebrand but it's not free.

**Control & customization (weight 3×).** Path A gets 5/5 (total control over every template, rule, and command). B1 gets 2/5 because OpenSpec's customization surface is narrow — commands, validator, and adapter registry are all locked. B2 gets 5/5 via fork but pays it back in ongoing rebase burden.

### 2.4 Five things the scoring oversimplifies

1. **Bus factor is understated for Path A.** Path A scores 5/5 on vendor risk because there's no vendor, but bus factor 1 (nic is the only maintainer) is a separate problem that the scoring doesn't capture. If nic disappeared for three months, B1 is the only path where the tool keeps improving via community commits. A more rigorous model separates "external vendor risk" (zero for A) from "internal continuity risk" (high for A, medium for B1 because OpenSpec has a community fallback).

2. **Network effects are underweighted at 1×.** OpenSpec's 39k stars and monthly adapter releases represent real inbound value — new AI tool support arrives for free on B1. Preflight will never get that at current user count. Weighting this at 1× reflects "personal infra" but hides long-term compounding: in two years OpenSpec likely supports 3× more AI tools than today, and preflight supports what nic builds.

3. **Time to value is monolithic but shouldn't be.** Path A's 4/5 averages across six deliverables of wildly different sizes. Cat 20 (tool inventory template) is a day. Cat 21 (task decomposition with plan generation) is larger than OpenSpec's entire task.md surface. A sharper model scores time-to-first-gap-closed separately from time-to-full-coverage. Path A wins decisively on the first, narrowly on the second.

4. **Upgrade path for A hides ongoing taxonomy drift.** The L4 taxonomy itself evolves — pass 3 identified 25 categories; research could identify 30 next year. Path A must track this manually, forever. B1 at least ships new schemas when the community discovers new needs. Path A's upgrade-path 5/5 assumes taxonomy stability, which is not a safe assumption.

5. **The EARS validator footgun is a sleeper for B1/B2.** OpenSpec's validator is hard-coded to EARS patterns, which means every non-spec doc type (operations envelope, task plan, data model, threat model) throws warnings or needs validator bypass. This collapses B1 into B2 in practice for half of preflight's category set. The scoring treats this as a "control & customization" detail but it deserves its own line — it is the primary technical reason B1 cannot cover the full 25-category surface.

### 2.5 Five conditions that would flip the decision

1. **OpenSpec ships rule-as-code in v1.4 or v2.0** — first-class enforceable rules instead of soft AI guidance. This is the single most impactful upstream change that would flip the decision.
2. **A second maintainer joins preflight** — bus factor changes the calculus. Ownership costs drop and sharing becomes worth the effort.
3. **Preflight gets external users** — three or more projects outside nic's work adopting preflight would jump network-effects weight from 1× to 2×, strengthening Path A further.
4. **Nic's stack shifts to TypeScript** — unlikely, but would rescore B2's core-competency criterion from 1 to 3-4.
5. **The L4 taxonomy stabilizes as an external standard** — if OpenSpec adopts the 25-category framework, B1's coverage score would rise and Path A's upgrade-path score would drop.

The decision is not close today. It could be close in 12-18 months if any two of those five conditions materialize.

---

## 3. Lens 2 — time-horizon projection

### 3.1 Day 7 (by 2026-04-19)

**Path A — Build on preflight.** Ships: operations-envelope template, task-plan template, `/preflight review --coverage` view, work-package.yaml schema, explore/propose skills scaffolded. Version bump v0.7.0. Review suite grows ~8 rules. Demo: nic runs `/preflight new ops-envelope` on dispatch, gets a populated envelope with tool bounds and stopping conditions, `/preflight review` validates it. Tests stay green. Daily workflow unchanged — new doc types slot into existing pattern.

**Path B1 — OpenSpec config-only.** Ships: `openspec/schemas/preflight/` with 7 schema files mirroring templates, config.yaml with 48 rules flattened, wrapper script `preflight-openspec`. No preflight version bump. Demo: `openspec new requirements` produces a preflight-shaped doc; `preflight review` validates it. Daily workflow now has two CLIs with different command vocabularies, different config files, different update cadences.

**Path C — Hybrid.** Ships: everything in Path A except work-package.yaml uses OpenSpec's task.md format for the "reviewable steps" sub-section. New task.md doc type with OpenSpec-compatible frontmatter. Demo: nic writes tasks.md in a preflight project, copies it into an OpenSpec-using project unchanged, and it works there. One artifact, two tool ecosystems.

**Day 7 winner**: **Path A**. Fastest to value, zero dependency risk, every hour of work lands in nic's own tool. Path B1 is slowest because two-tool friction is immediate. Path C is nearly tied with A but pays a small format-study tax.

### 3.2 Day 30 (by 2026-05-12)

**Path A.** In production: v0.8.0 with Cats 20–23 covered. 25/25 L4 categories addressed at template + rules level. Review suite ~65 rules. Reviewer agents updated with new category prompts. **First real test**: dispatch or tack-room-program runs an end-to-end feature from `/preflight new requirements` through `explore` → `propose` → `work-package.yaml` → implementation → `review`. Unexpected friction: completeness-contract view is synthetic (derived from three source docs) and stale-view bugs appear. Solution: make it a rule check, not a stored doc.

**Path B1.** In production: OpenSpec adapters work for nic's existing projects. Coverage is still 23/25 because config-only doesn't add new doc types. **First real test**: OpenSpec ships a minor release (v1.4.x given 12 releases per 90 days, 3-4 in the window) and either the customization survives cleanly or needs rewriting. Unexpected friction: OpenSpec's `rules:` field is soft guidance — agents inconsistently honor it. Hard validation still lives in preflight, so nic is maintaining two rule expressions of the same 48 rules. Drift is inevitable.

**Path C.** In production: 25/25 L4 coverage plus OpenSpec task.md interop. v0.8.0 with task.md conformance test pinned to OpenSpec v1.3.0 format spec. **First real test**: OpenSpec ships v1.4 and changes task.md format subtly. Nic either updates the preflight schema (small cost) or pins to v1.3.0 and accepts drift. Early signal of long-term maintenance cost.

**Day 30 winner**: **Path A ≈ Path C** (toss-up). Both reach 25/25 L4 coverage. C has marginally more strategic optionality; A has marginally less maintenance. Path B1 is clearly behind — still at 23/25 and now carrying upstream-tracking cost.

### 3.3 Day 180 (by 2026-10-09)

**Path A.** Ceiling: full L4 spec-ops toolkit at ~v1.2.0, 80-100 rules, 10-12 doc types. Tack Room's harness substrate is buildable. Bus factor still 1. Sustained maintenance: one evening per week for rule tuning. External pressures: PAI Algorithm changes may force reviewer agent reformatting; OpenSpec hits v2.0 and adds features preflight lacks (e.g., diff-based change proposals) — migration cost grows monthly. New L4 research may invalidate Cat 22 template design.

**Path B1.** Ceiling: fundamentally limited by what OpenSpec exposes to config. The 2 uncovered L4 categories stay uncovered unless OpenSpec adds the right extension points or preflight Path-A-ifies anyway. Tack Room betting on TabishB's roadmap (66% commit concentration — bus factor 1 on their side too). Sustained maintenance: one evening per OpenSpec release, ~4 evenings/month.

**Path C.** Ceiling: highest of the three. Preflight owns authoring and review loop (Path A's strength), Tack Room builds on preflight substrate (Path A's affordance), and task.md format gives nic's work an export path into the broader ecosystem. If Tack Room later wants to delegate execution to an OpenSpec-native agent, the handoff already exists. Sustained maintenance: Path A's cost plus ~1 evening per OpenSpec minor release = ~6-8 evenings/month.

**Day 180 winner**: **Path C**. Path A's ceiling is real — it's a personal tool that never leaves nic's projects, and if Tack Room needs ecosystem interop it has to be added later at higher cost. Path C buys that optionality cheaply at the one place it matters (agent handoff). Path B1's upstream-tracking cost compounds and its coverage gaps persist.

### 3.4 Divergence point

**Day 30-45.** This is when OpenSpec's release cadence (~1 release every 7-8 days) first exerts sustained pressure on the paths that depend on it. Path B1 feels it as regression work; Path C feels it as one file to retest; Path A doesn't feel it at all. Before Day 30, the paths look equivalent. After Day 45, their maintenance profiles diverge.

### 3.5 Compounding vs decay

- **Path A**: compounding. Every doc type nic writes in his own projects feeds rule refinement. Tight feedback loop. Decay risk: isolation from OpenSpec community means missing emerging conventions.
- **Path B1**: decay-dominant early (customization fights upstream), compounding late only if OpenSpec becomes the de facto L4 standard. High-variance bet. No current signal that OpenSpec is standardizing.
- **Path C**: compounding. Owns its core, borrows at the edges. Task.md interop attracts zero maintenance when OpenSpec is quiet, small maintenance when noisy. Strategic position improves as both ecosystems mature.

### 3.6 Best-early-worst-late pattern

**Path A** has the classic best-early-worst-late shape: fastest start, lowest ceiling. If Tack Room grows into a community tool, Path A requires a retrofit.

**Path B1** is worst-early-best-late *only* if OpenSpec wins the L4 standards race. No current evidence of that — 39k stars is traction, not standardization.

**Path C** is the rare shape that starts near the top and stays there — small upfront cost for the format borrow, small ongoing maintenance, high ceiling from the optionality.

### 3.7 Surprise scenarios

**Path A surprise.** At Day 90, Tack Room prototyping reveals agents need a streaming-event contract, not a static yaml. Cat 21 work gets rewritten. Net: still ahead of Path B1, behind a hypothetical "wait and co-design with Tack Room" path.

**Path B1 surprise.** At Day 120, OpenSpec v2.0 ships plugin-registered commands. Third parties can register new commands and doc types inside OpenSpec. The customization story inverts overnight — preflight-as-OpenSpec-plugin becomes first-class, and Day-7 schema work becomes foundation. Nic goes from worst-positioned to best-positioned without writing a line. This is the scenario that justifies keeping Path B1 as a hedge.

**Path C surprise.** Late 2026, a new L4 paper establishes "capability envelopes" as canonical runtime contract and ops-envelope.md becomes the lingua franca. Preflight is positioned perfectly — it already has the doc type, and task.md interop means the envelope travels with the tasks. The hybrid becomes the reference implementation that a small community adopts. Bus factor rises from 1 to 3-4. Path C's optionality premium pays off 10×.

---

## 4. Lens 3 — backward from Tack Room

Working backwards from a fully-implemented L4 Tack Room to today's decision, walking through 7 architectural layers. At each layer the question is: "what must be true at the layer below for this layer to work?"

### Layer 7 — Builder agent executing autonomously

For `claude -p --permission-mode dontAsk` to finish a story without a human in the loop, the context must contain five things:

1. **Normative rules** — constitution + EARS requirements + architecture invariants, terse, ID-addressable (FR-042), loaded in priority order so constitution wins when it contradicts an ADR.
2. **The work package** — one story with entry state, exit criteria, affected files, review rubric. Cat 20 + 21 + 22 fused.
3. **Operations envelope** — tool allow-list, forbidden actions, escalation triggers. Without this the builder wanders (METR's horizon-length failure is really a stopping-condition failure).
4. **Review rules** — the same 48 rules that will grade its output at PR time. Builders that can read their own rubric self-correct.
5. **Reporting contract** — state.json format, escalation signal, done signal.

**Which path?** Path A. Preflight already owns the rules, already emits stable IDs, already has the review engine that will grade the output. Path B1 forces the builder to load OpenSpec's proposal-oriented format *and* preflight's rule IDs in the same context — two mental models, two traversal patterns, two failure modes in one run.

### Layer 6 — Work package hand-off

For a different builder to consume the same package, the hand-off has to be a **file on disk** inside the worktree. The launcher is framework-independent by construction; any non-Claude builder can `cat work-package.yaml` but cannot replay a Claude-specific prompt.

Fields that must serialize: story ID, parent workstream, entry assertions, exit assertions (ISC criteria), affected paths, forbidden paths, tool allow-list, max iterations, context-fill ceiling, escalation triggers, review rubric reference (pointer to rule IDs, not inlined), handoff notes.

**Which path?** Path A, but not decisively. Preflight has no work-package format today — it has to be built. OpenSpec has task.md which is closer to a checklist-per-change than a work package (doesn't encode tool bounds, context ceilings, or escalation triggers). **Path C's contribution shows up here**: steal OpenSpec's task.md ergonomics for the checklist-of-reviewable-steps sub-section, but own the outer envelope in preflight.

### Layer 5 — Pre-build validation gate

The launcher must refuse to start the builder when the spec is incomplete. Validation must be **blocking by default with an explicit override flag**, and the failure mode must print the missing category names, not a generic "incomplete."

**Which path?** Path A, clearly. Preflight's review engine *is* the validation gate with a different entry point — same rules, same IDs, same severity model. Adding the `--coverage` view that groups rules by L4 category is a day of work and reuses the existing infrastructure. Path B1 requires a shim that understands both dialects — the glue-code tax.

### Layer 4 — Post-build drift detection — **the one layer where Path B1 has a real advantage**

After the builder ships, specs must still describe the code. Drift detection must run at build cadence and emit either a proposed spec diff or a failing assertion. The loop has to close: drift detected → spec updated → next build uses updated spec.

**Which path?** **Path B1 on a "today" horizon; Path A on a 12-month horizon.** OpenSpec's core mental model is proposal-as-deltas. Drift detection fits that model natively. Path A's current model is edit-in-place, so drift detection has to emit diffs that humans apply manually. *But* nothing prevents preflight from adopting a proposal-as-delta workflow for drift specifically, as a second authoring mode alongside edit-in-place. Path B1's advantage is "today," not "structurally." The gap is one well-scoped feature.

### Layer 3 — Spec authoring flow

Authoring must be the lowest-friction surface because this is where time is spent. Must support interactive elicitation (new docs), template fill-in (well-understood shapes), and freeform editing with linting (mature specs). Cross-doc propagation is what makes spec-driven development work.

**Which path?** Path A, close call. Preflight's `/preflight new` elicitation is in place but shallow — it knows the templates but not the cross-doc coupling. OpenSpec's authoring flow is more opinionated but narrower (proposals, not constitution + requirements + architecture + ADRs + interfaces). For nic's daily flow spanning all doc types, Path A is closer. **Path C contribution**: borrow OpenSpec's proposal-driven authoring specifically for requirement changes that need ADR coverage, because that's where deltas-as-first-class shine.

### Layer 2 — Category taxonomy

The taxonomy is the asset. Rules, templates, validation gates, and work-package serializers are all derived from it. Must live as **structured data** (YAML), not prose, so rules reference categories by ID and the completeness contract is generated.

**Which path?** Path A, unambiguously. Preflight already has the versioning discipline (plugin.json bumps + ADRs per CONST-PROC-02) for exactly this kind of evolution. Path B1 externalizes the taxonomy's fate.

### Layer 1 — Today's decision

Walking forward from what layers 7–2 require:
- Layer 7 wants preflight's rule IDs and review engine in builder context → **A**
- Layer 6 wants a file-on-disk work package with Cat 20/22/23 fields → **A (with C borrow from task.md)**
- Layer 5 wants the validation gate to reuse the review engine → **A**
- Layer 4 wants drift-as-proposed-delta → **B1 today, A after one feature**
- Layer 3 wants elicitation across all doc types → **A**
- Layer 2 wants the taxonomy owned in a tool with versioning discipline → **A**

**Five layers cleanly favor Path A. One layer (drift) favors Path B1 today but is closable with a feature.**

### 4.1 The lookback letter — what the 2027 retrospective says

A summary of the backward-walk agent's lookback letter, which produced the most important finding of this pass:

> Path A was right, but the load-bearing reason wasn't "preflight already has the rules." It was the taxonomy. Once Cat 20–23 became first-class rule categories in `.preflight/_rules/`, everything downstream — work-package serializer, pre-build gate, builder context loader — became a matter of querying the taxonomy rather than reimplementing it. **The taxonomy is the keel of the boat. Nothing else you built would have held without it living in a tool you fully owned.**
>
> The mistake: underestimating how much Layer 4 (drift) would hurt in months 2-4. Between shipping Path A's initial scaffold and shipping drift-as-delta, a backlog of specs accumulated that no longer matched the code, and the builder started producing confidently-wrong output because its context was stale. **If doing it again, build drift-as-delta before the autonomous builder, not after.** The order matters: a broken drift loop with no autonomy is annoying; a broken drift loop with autonomy is dangerous.
>
> The OpenSpec borrow was smaller than expected. Pulling in task.md checklist format for the "reviewable steps" sub-section of work-package.yaml was the entire contribution — approximately 40 lines of format borrow. Proposal format was never needed because preflight's ADR workflow was already doing that job under a different name.
>
> The framing mistake: it wasn't really A vs B vs C. It was **"build the substrate you'll own for a decade" vs "duct-tape two tools for the next quarter."** Framed that way it was never close.

---

## 5. Where the three lenses agree and disagree

### 5.1 Unanimous findings

All three lenses converge on these conclusions:

1. **Path A beats Path B1** on every dimension that matters to the stated goals. Buy-vs-build: 161 vs 85. Time horizons: A wins Day 7, ties at Day 30, beats B1 at Day 180. Backward walk: A wins 5 of 6 layers.

2. **Path A beats Path B2** (hard fork) even more decisively. The TypeScript rebase burden and upstream cadence eliminate it for a single maintainer on a Python/bash stack.

3. **The preflight rules must remain first-class.** Every lens treats this as load-bearing. OpenSpec's soft-guidance model is fundamentally wrong for an L4 target because the whole point of the harness is that the agent cannot drift below the rule floor.

4. **Cat 21 (task decomposition) is the one place where OpenSpec's design is directly useful.** All three lenses recommend borrowing task.md format, not building from scratch. The borrow is ~40 lines of schema work.

5. **The taxonomy is the asset.** The buy-vs-build scoring, the 180-day projection, and the backward walk all independently reach this finding. The 25-category framework in `.preflight/_rules/` is the keel.

### 5.2 The one disagreement — ordering

Buy-vs-build and time-horizon lenses recommend shipping the operations-envelope categories first (Cat 20, 22, 23) as the highest-impact L4 gaps. These are the things preflight most obviously lacks.

The backward-walk lens says **drift detection must ship before the autonomous builder**, not after. Layer 4 is the one layer where Path B1 has a legitimate advantage today, and the gap closes only when preflight adopts proposal-as-delta for drift.

The backward-walk lens is right. Here's why:

- The operations-envelope categories (Cat 20, 22, 23) are inert templates until there's something running. Until the builder is executing autonomously, they're documentation.
- Drift detection is active infrastructure. Every time someone (or an agent) commits code, drift accumulates. The cost of shipping drift-as-delta late is measured in accumulated stale specs, not in missed template coverage.
- The lookback letter names the exact failure mode: "between shipping Path A's initial scaffold and shipping drift-as-delta, a backlog of specs accumulated that no longer matched the code, and the builder started producing confidently-wrong output."
- At L4, stale specs + autonomy = confidently wrong output. The human isn't reviewing each step, so drift is invisible until it's everywhere.

**This is an order-of-operations finding, not a path selection finding.** Path A still wins. But within Path A, priorities reshuffle.

---

## 6. The revised priority stack

Merging all three lenses, with the ordering correction from the backward walk:

### Phase 1 — Drift loop (Days 1-10)

**Why first**: at L4, stale specs plus autonomy equals dangerous. Drift is active infrastructure that must exist before autonomous execution is safe.

1. **Post-implementation hook** (~30 lines bash) — diffs FR IDs in PR commit trailers against FR IDs expected by the work package. Non-blocking, surfaces drift as PR comments.
2. **`/preflight review --drift`** mode — accepts a PR diff and emits proposed spec changes (not hand-edited diffs, actual proposals the user can accept). This is the "drift-as-delta" feature that closes Layer 4's gap.
3. **Drift review rule** in `rules-source/drift-rules.md` — catches orphan FR references in code, dangling ADR references, constitution-requirement conflicts.

### Phase 2 — Completeness contract (Days 11-18)

**Why second**: the contract is what lets the builder know when a spec is complete enough to execute against. Must exist before the builder runs autonomously.

4. **L4 category taxonomy file** at `content/reference/l4-categories.yaml` — structured data listing the 25 categories, their required fields, and which preflight doc types satisfy them. The keel.
5. **`/preflight review --coverage <change>`** — analyzes a change and reports per-category coverage (Y/P/N/N/A) with citations to specific docs and sections that satisfy each category. Output: machine-readable YAML + human-readable markdown. This is what the Tack Room pre-build gate will invoke.
6. **Completeness rules** — "propose refuses to emit with critical findings," "explore escalates on requirement-ID touch," "category coverage must reach N of 25 for L4 mode."

### Phase 3 — Operations envelope (Days 19-30)

**Why third**: these categories (20, 22, 23) are inert templates until there's something running. Ship them once drift and coverage are in place so the categories are enforced, not just documented.

7. `content/templates/operations-envelope-template.md` — tool inventory, destructive-op policy, escalation triggers, stopping conditions. Covers Cat 20 + 22.
8. **Rollback-criteria field** added to `adr-template.md` as a required field for behavioral ADRs. Covers Cat 23.
9. `content/templates/task-plan-template.md` — using OpenSpec's task.md format as prior art (~40 lines of format borrow per the backward walk). Covers Cat 21.

### Phase 4 — Workflow skills (Days 31-45)

**Why last**: the skills are the user-visible glue. They depend on Phases 1-3 being in place or they create work that has to be revisited.

10. `skills/explore/SKILL.md` — elicitation loop with L4 category awareness. Escalates to governance path on requirement-ID touches.
11. `skills/propose/SKILL.md` — orchestrates `new` per doc type, runs `review --coverage`, emits `work-package.yaml` only if coverage reaches the required threshold.
12. `content/templates/work-package-template.yaml` — the handoff artifact. Same schema as pass 2 with added `category_coverage:` field listing which of the 25 categories are satisfied.

### Phase 5 — Substantive gaps (backlog)

13. Data model template (Cat 11)
14. Threat model template (Cat 19)
15. Stronger JTBD framing in requirements elicitation (Cat 1 → strong)
16. Tripwire check at Day 365: if OpenSpec has shipped rule-as-code, re-run buy-vs-build analysis.

---

## 7. Recommendation summary

**Build on preflight (Path A) with the OpenSpec task.md format borrow for Cat 21 (Path C element), in the order specified by the revised priority stack above.**

**Confidence: high** on rejecting B1 and B2. **High** on Path A being the right foundation. **Medium-high** on the specific ordering (drift before builder) — this is the most consequential finding of pass 4 and the one most likely to be wrong if I've misunderstood how drift accumulates in practice.

**What would flip the recommendation**:

1. OpenSpec shipping first-class enforceable rules (rule-as-code) in v1.4 or v2.0 → re-run B1 analysis
2. A second maintainer joining preflight → network effects and bus-factor calculus change
3. Tack Room design revealing that agents need a streaming-event contract instead of work-package.yaml → Phase 4 gets rewritten
4. L4 research invalidating the operations-envelope categories → Phase 3 gets rewritten
5. Three or more external projects adopting preflight → network effects rescore, strengthening Path A further

**The tripwire**: at Day 365 (2027-04-12), check whether OpenSpec has shipped plugin-registered commands or first-class rule enforcement. If yes, re-run the buy-vs-build scoring. If no, continue on Path A.

---

## 8. What this changes from pass 3

Pass 3 recommended E-lite (Path A) and correctly identified the 25-category taxonomy as preflight's defensible core. Pass 4 sharpens this in three ways:

1. **Reordering**: drift detection before the autonomous builder, not after. This was not in pass 3.
2. **Path C formalized**: the OpenSpec task.md borrow is a concrete, small (~40 lines), recoverable addition that gives Cat 21 the best available prior art. Pass 3 did not evaluate this explicitly.
3. **The tripwire**: an explicit 12-month re-evaluation point keyed to specific OpenSpec upstream changes. Pass 3 hand-waved this.

Pass 2's `work-package.yaml` survives into pass 4 unchanged in shape but repositioned: it's no longer "preflight's exit artifact" — it's "the serialization of the completeness contract for a specific change, emitted in Phase 4 after the contract infrastructure (Phases 1-2) is in place."

Pass 1's score-based option table is now obsolete. The real decision was never about comparing six options against eight criteria. The real decision was always "build the substrate you'll own for a decade vs duct-tape two tools for the next quarter" — and that framing only became clear at pass 4.

---

## Appendix — the research streams

Three background agents produced the inputs for this pass:

- **Buy-vs-build scoring** — 15 weighted criteria across Path A, B1, B2. Scored A: 161/175, B2: 96/175, B1: 85/175. Identified 5 conditions that would flip the decision.
- **Time-horizon projection** — 7/30/180 day projections for Path A, B1, C with compounding/decay analysis, pain events, and surprise scenarios. Found divergence point at Day 30-45.
- **Backward from Tack Room** — 7-layer walk from the target state (builder executing autonomously) to today's decision. Produced the critical ordering finding (drift before builder) and the lookback letter framing.

All three are preserved in `.dispatch/` output files from the background agent runs.
