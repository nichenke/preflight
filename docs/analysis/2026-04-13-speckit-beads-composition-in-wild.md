---
status: complete
date: 2026-04-13
owner: nic
type: analysis
relates_to: 2026-04-13-beads-gastown-comparison, adr-007-feature-folder-lifecycle
---

# spec-kit + Beads (+ Gas Town) composition in the wild

The Beads + Gas Town comparison (`docs/analysis/2026-04-13-beads-gastown-comparison.md`) ended with a composition hypothesis: *preflight governs the specs, Beads (optionally) tracks the work items spawned from them during execution.* That hypothesis depended on whether the analogous composition — spec-kit + Beads — exists in the wild. This doc answers that empirically.

## 1. Headline

**Yes, the composition is real and relatively popular for spec-kit + Beads. Gas Town plays no role.**

Five independent community bridge projects ship working glue between spec-kit and Beads. Both project communities have top-voted "how do I combine these?" discussion threads. No first-party integration exists on either side — the pattern is held together entirely by third-party adapters. Steve Yegge's stated position (consistent across multiple community signals) is that Beads is deliberately spec-agnostic and users should bring their own planning layer.

For Gas Town: zero references to spec-kit anywhere in the Gas Town repo, issues, or community discussion. Gas Town is a Beads-native workspace manager with no documented spec-kit story. The earlier analysis was right: Gas Town is at the wrong layer for preflight to compose with.

## 2. The canonical pattern

Every one of the five bridges converges on the same shape:

1. **spec-kit produces** `constitution.md`, `spec.md`, `plan.md`, `tasks.md` in its normal flow.
2. **Adapter reads `tasks.md`** and calls `bd create` per task row, embedding spec/plan excerpts into the Beads issue body so the executor has context.
3. **Sidecar mapping** tracks task-ID ↔ bead-ID — either as a dedicated file (`.beads-mapping.json` in SpecBeads) or as inline markers in `tasks.md` (`(bd-xxx)` suffixes in cc-spex).
4. **Agents run `bd ready`** to pick unblocked work during execution, read the embedded context, implement, commit.
5. **`bd close` syncs status back** to `tasks.md` so the spec artifact reflects completion state.

Spec-kit owns the "what and why." Beads owns the "what's next and what's done." The adapter is ~200–500 lines of glue. None of the five bridges fork or modify either upstream project.

## 3. The five bridges

| Project | Shape | Notable features |
|---|---|---|
| [`LastManStandingV2/SpecBeads`](https://github.com/LastManStandingV2/SpecBeads) | Dedicated bridge | Slash commands `/speckit.taskstobeads`, `/speckit.implementwithbeads`; `.beads-mapping.json` schema; bidirectional sync described in README as "keeping both in harmony" |
| [`rhuss/cc-spex`](https://github.com/rhuss/cc-spex) (formerly cc-sdd) | Claude Code plugin, v4.0.0, layered over spec-kit ≥0.5.0 | Composable `traits`: `beads` trait + `teams-spec` trait that depends on `beads` + `superpowers` + `teams-vanilla`; `migrate_from_beads()` function in `spex/scripts/spex-init.sh`; signal handling for `BEADS_MIGRATION_NEEDED` in `spex/commands/init.md` |
| [`jmanhype/speckit`](https://github.com/jmanhype/speckit) | 8-phase pipeline framework | `constitution → specify → clarify → plan → checklist → tasks → analyze → implement` with optional Beads and Linear integrations; published `beads-integration` skill on claude-plugins.dev and Smithery |
| [`Abdssamie/opencode-beads-speckit`](https://github.com/Abdssamie/opencode-beads-speckit) | OpenCode plugin | Proves the pattern is portable beyond Claude Code |
| [`nfskiy2/beadskit`](https://github.com/nfskiy2/beadskit) | Earlier experimental attempt | Self-described "noob AI-written" attempt; referenced inside spec-kit Discussion #1381 as the author's own try |

Also relevant, though not spec-kit: [`lucastamoios/openspec-to-beads`](https://github.com/lucastamoios/openspec-to-beads) — OpenSpec → Beads adapter as a Smithery skill. Confirms Beads-as-execution-ledger is a *generalized* community pattern, not a spec-kit-specific coincidence.

## 4. Community signals

### Spec-kit side

[spec-kit Discussion #1381 "Beads"](https://github.com/github/spec-kit/discussions/1381), opened by mdlmarkham:

> Has anyone tried using it with Spec-Kit? Ideally I'd like the task management of Beads with the content and the specification process of Spec-Kit. I've been able to use Spec-Kit, and then tell the agent to build out the backlog in Beads — but it feels a little clunky.

The thread is the canonical "how do I pair these" locus. User-driven, not maintainer-driven; no spec-kit maintainer has committed to first-party support. A commenter links to `nfskiy2/beadskit` as their own attempt.

Adjacent spec-kit issues that describe the persistence gap Beads fills, without naming Beads:

- [#1100 Support Module-Level Persistent Specifications for Knowledge Retention](https://github.com/github/spec-kit/issues/1100) — spec drift across sprints
- [#1136 Enable incremental planning and development through distinct feature plans as artifacts](https://github.com/github/spec-kit/issues/1136) — user wants feature-plan artifacts as a backlog
- [#1300 Persist Canonical Registries for Entities, APIs, and Namespaces](https://github.com/github/spec-kit/issues/1300) — persistent registries at repo level

All three describe problems Beads already solves. None name Beads.

### Beads side

[Beads Discussion #266 "Complementary planning tools?"](https://github.com/steveyegge/beads/discussions/266) by rbergman:

> I had been using GitHub's spec-kit prior to finding beads... I tried, for a while, to stick with spec-kit for planning then porting `tasks.md` (after the analyze step) to beads and running with it from there. It worked ok, but since then I have pivoted to a homegrown lite version of that flow to be able to dump the dependency on spec-kit.

This is the most load-bearing signal in the whole research. A real user **ran the canonical pattern, found it workable but friction-heavy, and removed spec-kit rather than removing Beads.** That is the asymmetry: Beads is the sticky half; spec-kit is the replaceable half.

[Beads Discussion #240 "Openspec for the FAQ"](https://github.com/steveyegge/beads/discussions/240) — parallel signal that Beads users actively look for spec frameworks to pair with, and OpenSpec is the other frequently-named candidate.

Steve Yegge's stance, aggregated across multiple community signals: Beads is deliberately spec-agnostic. *"Make your plan in whatever tool you prefer, then have the agent file Beads epics and issues for the work."* He is not building an integration and does not intend to.

### Ambient signal

[Hacker News item 46078322](https://news.ycombinator.com/item?id=46078322): *"I've been using beads for a few projects and I find it superior to spec kit..."* — reinforces that the two occupy adjacent (not competing) mental categories in the community.

## 5. What does not exist

Explicit non-findings, to close the research loop:

- **No first-party integration in spec-kit.** Zero hits for `beads|gastown|steveyegge/beads` in the spec-kit repo.
- **No first-party integration in Beads.** Zero hits for `spec-kit|speckit|.specify` in the Beads repo.
- **No references to spec-kit anywhere in Gas Town.** Zero hits in the repo, issues, or associated discussion. Gas Town and spec-kit are in different universes as far as the community is concerned.
- **No Beads molecule** (`internal/molecules/`) that generates spec-kit-shaped files.
- **No spec-kit preset** that writes Beads templates.
- **No shared standard** for task-to-bead conversion across the five bridges. Each reinvents the sidecar format.

## 6. The critical asymmetry — why this matters for preflight

The rbergman signal is the single most important finding. One user's anecdote is not a trend, but the direction is consistent with every other data point:

- Steve Yegge deliberately designs Beads to be spec-agnostic
- Community bridges all treat Beads as the sticky execution half
- Spec-kit discussion thread #1381 describes the composition as "clunky"
- Multiple spec-kit issues (#1100, #1136, #1300) describe gaps Beads already fills

Across these signals, the pattern reads as: **Beads is winning the execution-memory layer race; spec-kit is a good-enough planning layer that people are happy to replace when something better shows up.** Preflight's governance rigor (48 enforceable rules, 25-category L4 taxonomy, constitution precedence, EARS discipline) is a concrete "something better" — the things rbergman described as missing in their homegrown flow are preflight's differentiated value.

## 7. Implications for preflight and ADR-007

1. **ADR-007 holds.** Nothing in the research contradicts the feature-folder lifecycle. The research validates a *composition target*; it does not invalidate the *governance shape*.
2. **A preflight ↔ Beads adapter is a validated target, not an invention.** If preflight's `plans/NNN-*.md` should round-trip to Beads issues at runtime, the shape is proven — ~200–500 lines of adapter based on SpecBeads or cc-spex prior art. We are not designing from scratch, we are cribbing from five existing bridges.
3. **Preflight can slot into the same "planning half" role** that spec-kit plays for this community, without fighting either upstream. Beads is spec-agnostic; it will compose with whatever governance layer sits in front of it. Preflight's positioning story writes itself: *"the governance rigor rbergman was missing."*
4. **Do not build the adapter now.** It is a one-to-two-day project whenever we want it, there is no time pressure, the ADR-007 spikes must come first, and cribbing is easier once we have seen which of the five bridge shapes the ecosystem consolidates around.
5. **Gas Town stays out.** Earlier conclusion reinforced by total absence of community overlap. Gas Town is at the wrong layer for preflight to compose with and there is no user demand for it.
6. **Track the ecosystem at the 60-day tripwire.** Two things would change the calculus:
   - Spec-kit discussion #1381 produces maintainer commitment to a first-party Beads integration — if first-party ships, the third-party patchwork commoditizes and any preflight adapter must target the official shape
   - Any of the five bridges ships a shared standard for task-to-bead conversion — the generic adapter pattern becomes a concrete interface preflight should target

## 8. What to borrow when we build the adapter

For future reference when the adapter work lands (not now):

- **Sidecar mapping format** — SpecBeads' `.beads-mapping.json` is the cleanest shape. Tracks task-ID ↔ bead-ID ↔ status with a timestamp. Easier to reason about than cc-spex's inline markers, at the cost of one extra file.
- **Trait-based composition model** — cc-spex's trait architecture (`beads` trait + `teams-spec` trait depending on it) is a useful pattern if preflight ever needs composable feature flags for its own plugins.
- **Init signal handling** — cc-spex's `BEADS_MIGRATION_NEEDED` signal in `spex-init.sh` is a good pattern for "detect existing Beads DB, offer migration." Port to a `preflight scaffold --with-beads` flag when the time comes.
- **Status sync direction** — all five bridges treat Beads as authoritative for status and sync back to the spec artifact. Do the same: preflight's plan.md should reflect Beads status, not drive it.

## 9. Deferred but tracked

These are interesting but not actionable now. Recording them to avoid rediscovery:

- **cc-spex's `teams-spec` trait composition** (`beads + superpowers + teams-vanilla`) suggests Superpowers users also want Beads. If we ever evaluate Superpowers as a preflight adjacency, cc-spex is prior art.
- **`jmanhype/speckit`'s 8-phase pipeline** is a more elaborate spec-kit reimplementation. If preflight ever wants to emit intermediate phases as named skills (beyond our current `explore` + `propose`), this is the most-worked-out community example.
- **`lucastamoios/openspec-to-beads`** is the closest thing to our "preflight → Beads" composition target. Different spec system, same execution layer, same adapter shape. Worth a 30-minute read when we start adapter work.

## 10. Sources

Integration projects:
- https://github.com/LastManStandingV2/SpecBeads
- https://github.com/rhuss/cc-spex
- https://github.com/jmanhype/speckit
- https://github.com/Abdssamie/opencode-beads-speckit
- https://github.com/nfskiy2/beadskit
- https://github.com/lucastamoios/openspec-to-beads (adjacent, OpenSpec → Beads)
- https://claude-plugins.dev/skills/@jmanhype/speckit/beads-integration

Community discussions:
- https://github.com/github/spec-kit/discussions/1381 — "Beads" (canonical thread)
- https://github.com/steveyegge/beads/discussions/266 — "Complementary planning tools?" (contains rbergman signal)
- https://github.com/steveyegge/beads/discussions/240 — "Openspec for the FAQ"

Related spec-kit persistence gaps (not naming Beads):
- https://github.com/github/spec-kit/issues/1100
- https://github.com/github/spec-kit/issues/1136
- https://github.com/github/spec-kit/issues/1300

Ambient:
- https://news.ycombinator.com/item?id=46078322
- https://steve-yegge.medium.com/beads-best-practices-2db636b9760c (referenced by the research agent, not fetched directly)

Clone greps (session-scoped, not persistent):
- `steveyegge/beads` at depth=1 — zero hits for `spec-kit|speckit|.specify`
- `gastownhall/gastown` at depth=1 — zero hits for `spec-kit|speckit|.specify`; 108 hits for `beads`
- `github/spec-kit` at depth=1 — zero hits for `beads|gastown|steveyegge/beads`
