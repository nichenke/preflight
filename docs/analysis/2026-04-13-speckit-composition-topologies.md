---
status: draft
date: 2026-04-13
owner: nic
type: analysis
---

# spec-kit community ecosystem survey + composition topologies for preflight

This doc answers two questions:

1. **What already exists in the spec-kit community that's close to preflight?**
   — surveyed presets (8), extensions (63), forks, and adjacent Claude Code
   plugins. None match preflight end-to-end, but several cover individual
   layers.
2. **Given what exists, what composition topologies are viable for preflight
   beyond "build standalone vs. fork spec-kit"?**
   — five topologies (A–E), each with pros/cons. No recommendation yet;
   topology choice is a pre-spike decision.

This doc feeds into SPIKE_PLAN.md's Phase 0 as a new open question (Question 5)
before the preset scaffold work in Phase 1 can proceed.

Related docs:

- [Composable architecture](./2026-04-13-composable-architecture.md) — introduced
  Path A-prime (preflight composes with spec-kit via preset). This doc expands
  the composition space to five topologies; Path A-prime as originally framed
  corresponds roughly to Topology A below.
- [Framework customization depth](./2026-04-13-framework-customization-depth.md)
  — prior surface analysis of spec-kit / OpenSpec customization surfaces. Did
  not survey the community extension catalog.
- [Meta evaluation methodology](./2026-04-12-meta-evaluation-methodology.md) —
  angles 2.10 (composition-first), 2.9 (load-bearing-criterion isolation), and
  2.8 (criteria-first re-scoring) all apply here.

---

## 1. What exists in the spec-kit community

spec-kit has two separate customization subsystems:

### 1.1 Presets — template + command overrides only

Source: `github/spec-kit/presets/catalog.community.json`.

8 community presets shipped. All are template + command overrides; the preset
system by design cannot add hooks, blocking validation, or lifecycle logic.
None match preflight's shape. The nearest conceptual neighbor is
`canon-core` (spec-first baseline for the Canon extension). The substantive
ones (`fiction-book-writing` with 21 templates + 17 commands, `aide-in-place`
migration workflow) prove the preset surface can carry weight but don't
address preflight's requirements.

**Finding**: presets are too thin to carry preflight's value. If preflight
composes with spec-kit, it must go through the extension system, not the preset
system. (A preset may still be useful as packaging for the preflight template
set — see Topology A.)

### 1.2 Extensions — commands + hooks + scripts

Source: `github/spec-kit/extensions/catalog.community.json`.

63 community extensions. This is where the real overlap lives. Preflight-adjacent
ones:

| Extension         | Repo                                        | Provides              | Overlap with preflight                                       |
| ----------------- | ------------------------------------------- | --------------------- | ------------------------------------------------------------ |
| `docguard`        | raccioly/docguard                           | 6 cmds, 3 hooks       | Closest philosophical match: "Canonical-Driven Development" validates, scores, and traces documentation via hooks. Not rule-based or typed-ID-aware. |
| `archive`         | stn1slv/spec-kit-archive                    | 1 cmd                 | Merge-into-main-memory for completed features. Closest to the archive half of feature-folder lifecycle. |
| `memorylint`      | RbBtSn0w/spec-kit-extensions                | 1 cmd, 1 hook         | Audits conflicts between `AGENTS.md` and constitution. Audit-only, no authoring. |
| `canon`           | maximiliamus/spec-kit-canon                 | 16 cmds               | Spec-first / code-first / drift detection as baseline-driven workflow. Requires `canon-core` preset. |
| `v-model`         | leocamello/spec-kit-v-model                 | 14 cmds, 1 hook       | Paired dev/test specs with traceability. Traceability is v-model, not FR/NFR/ADR IDs. |
| `ci-guard`        | Quratulain-bilal/spec-kit-ci-guard          | 5 cmds, 2 hooks       | Blocks merges in CI when spec gaps detected. CI-time gating, not author-time. |
| `plan-review-gate`| luno/spec-kit-plan-review-gate              | 1 cmd, 1 hook         | Requires `spec.md` + `plan.md` MR merge before task gen. PR-time gate. |
| `critique`        | arunt14/spec-kit-critique                   | 1 cmd, 1 hook         | Dual-lens spec+plan review (product strategy / engineering risk). LLM-narrative, not rule-based. |
| `verify`          | ismaelJimenez/spec-kit-verify                | 1 cmd, 1 hook         | Post-implementation quality gate comparing code to spec. |
| `sync`            | bgervin/spec-kit-sync                        | 5 cmds, 1 hook        | Detect + resolve spec/impl drift. Bidirectional, AI-assisted, human-gated. |
| `retrospective`   | emi-dm/spec-kit-retrospective                | 1 cmd, 1 hook         | Post-implementation retro with spec adherence scoring + drift analysis. |

**Layer ownership** — which extension covers which layer of the problem space:

| Layer                                                    | Already covered by                      | Preflight plans to build   |
| -------------------------------------------------------- | ---------------------------------------- | -------------------------- |
| Authoring UX (`/specify` `/plan` `/tasks`)               | spec-kit core                            | duplicates                 |
| Multi-agent distribution (17+ AI tools)                  | spec-kit `CommandRegistrar`              | ignores (Claude-only)      |
| Catalog / distribution infra                             | spec-kit presets + extensions subsystems | duplicates via `content/`  |
| Archive / merge lifecycle primitives                     | `archive` extension                      | duplicates                 |
| CI-time drift / gap detection                            | `sync`, `ci-guard`, `retrospective`       | duplicates                 |
| Constitution ↔ AGENTS.md conflict audit                  | `memorylint`                             | duplicates                 |
| Doc validation / scoring / traceability plumbing         | `docguard`                               | duplicates                 |
| Dev-test paired generation with traceability             | `v-model`                                | duplicates (different shape) |
| **Author-time blocking rules against typed spec grammar** | **nobody**                               | **preflight's differentiator** |
| **EARS as enforced grammar**                             | **nobody** (one shipped conversion skill in `wcpaxx/spec-kit-brownfield-extensions`) | **preflight's differentiator** |
| **MADR 4.0 ADRs as first-class doc type**                | **nobody**                               | **preflight's differentiator** |
| **Constitution precedence rules with CONST-IDs**         | **nobody** (memorylint audits, doesn't enforce) | **preflight's differentiator** |

**Load-bearing criterion isolation** (angle 2.9): the only layer nobody owns is
*author-time blocking enforcement against typed spec grammar with ID traceability*.
Every other layer is commodity or near-commodity across the extension catalog.
**Preflight's defensible wedge is one layer thick**, not five.

### 1.3 Forks worth noting (for study, not forking)

- **`tikalk/agentic-sdlc-spec-kit`** — 1,287 commits, very active. Architect
  extension uses **Rozanski & Woods for architecture description**; ADRs are
  **MADR** (correction from prior note). Quality gates enforced as
  LLM-advisory, not blocking. Feature directories but no archive lifecycle.
  No EARS, no FR/NFR IDs. Closest overall fork. **Worth borrowing patterns
  from — see code analysis in SPIKE_PLAN Q1 follow-up.**
- **`panaversity/spec-kit-plus`** — 201 stars, most adoption. PHR/ADR Curator
  subagent treats specs + ADRs + prompts as first-class artifacts. No EARS,
  no blocking. **Worth borrowing patterns from — see code analysis in
  SPIKE_PLAN Q1 follow-up.**
- **`danwashusen/spec-kit-ext`** — governance-leaning. Loads PRDs/ADRs/runbooks
  as grounding context (consumes, doesn't produce). No blocking.
- **`galando/piv-speckit`** — distributed as Claude Code plugin (closest
  format match). PIV + TDD discipline. No EARS/ADR/lifecycle.

### 1.4 Claude Code plugin ecosystem

Adjacent but not overlapping:

- **`gotalab/cc-sdd`** — 3,092 stars. Kiro-style requirements→design→tasks.
  Not EARS; no ADR/RFC/constitution doc types.
- **`rhuss/cc-spex`** — closest structural match. Composes traits over spec-kit;
  review commands; drift detection. Reviews are narrative, not rule-based.
- **`MartyBonacci/SpecSwarm`** — 5 workflows over spec-kit. No spec grammar
  enforcement.
- **`usmc0341/spec-driven-dev-sop`** — 29 skills, broadest SDLC SOP plugin.
  No EARS, no MADR, no blocking rules.

None implement EARS + MADR + blocking rules + feature-folder lifecycle as a
combined product.

### 1.5 Community demand signal

- Issue [github/spec-kit#1356](https://github.com/github/spec-kit/issues/1356)
  — "Feature Request: EARS Integration" — open, zero comments, zero maintainer
  engagement since 2025-12-20.
- Issue [#1644](https://github.com/github/spec-kit/issues/1644) — "RFC:
  Specification domains" — proposes domain-resolver + extension model for
  template structure variation. Structurally adjacent to what preflight wants,
  still open.
- Issue [#2142](https://github.com/github/spec-kit/issues/2142) / PR
  [#2158](https://github.com/github/spec-kit/pull/2158) — "Workflow Engine with
  Catalog System" — adjacent to feature-folder lifecycle. Open.
- PR [#2010](https://github.com/github/spec-kit/pull/2010) — "approval gates" —
  blocking-rules analog. Open.

Pattern: spec-kit is evolving toward "minimal core + opinionated extensions"
(merged PRs #1787, #1855, #2167, #2168). Over 60–90 days the extension surface
will likely mature enough that most of preflight's layers become reachable as
extensions. The window where preflight's differentiation is structural (not
just content) is narrowing. **EARS remains the clearest unambiguous gap** —
zero shipped code, zero maintainer engagement.

---

## 2. Five composition topologies

Composition-first check (angle 2.10): the trigger conditions hold. spec-kit is
extensible by design; preflight's planned surface duplicates layers the
extension ecosystem already owns. Substitution framing ("build preflight vs.
fork spec-kit") asks the wrong question. The right framing is: which layers
should preflight own, and which should it rent?

The topologies below are the viable composition shapes. They are listed in
order of increasing decoupling from a single substrate. **No preferred
topology is named — this section is for review before picking.**

Common criteria to evaluate each topology (drawn from the original preflight
brief):

- **Claude Code plugin form factor** — primary distribution surface today
- **Author-time blocking enforcement** — via PreToolUse hook (Claude Code)
  or equivalent
- **EARS / MADR / constitution as first-class**
- **Feature-folder lifecycle** (apply/archive model from ADR-007)
- **Multi-agent reach** (nice-to-have, not originally in brief)
- **Rate-of-change resilience** — tolerance for substrate churn
- **Maintenance cost**
- **Reversibility** — how hard to back out if the topology fails

### Topology A — Preflight becomes a spec-kit extension

**Selected 2026-04-14** per Notion discussion: nic chose this topology to test life in the spec-kit ecosystem directly rather than build a parallel surface and risk missing something.

**Initial spike scope**:
- ✅ **Include**: preset + templates + extension manifest + `after_specify`/`after_plan` hooks + preflight review command + **`archive` extension composition** for ADR-007's ratification step. Archive is 1 command, isolated, composes as a peer without asking preflight to change shape.
- ❌ **Exclude**: `docguard` — it's a substrate, not a composition partner. Using it would mean preflight's rules live as docguard rule packs (proprietary format) and enforcement shifts to docguard's hook timing. Preflight becomes a docguard client, not a peer. Too invasive for an initial spike.
- ❌ **Exclude**: `ci-guard` — CI-time gating is not a current concern (no LLM-in-CI subscription), and author-time review is a different enforcement phase. Post-spike follow-up at most.

**Shape**: register preflight in `extensions/catalog.community.json` as
`speckit-preflight`. Ship preflight rules as prompt context loaded into a
`speckit.preflight.review` command, MADR templates, and template overrides
(via a bundled preset). Wire `after_specify`/`after_plan` hooks to the
review command. Compose with `archive` extension at ratification. Abandon
the Claude Code plugin form factor as primary (or keep as a thin secondary
wrapper post-spike).

**Pros**:

- Rents the most substrate: multi-agent reach (17+ AI targets free via
  `CommandRegistrar`), catalog distribution, lifecycle primitives, authoring
  UX, command registration.
- Joins an active community. Preflight's ideas get exposure to thousands of
  spec-kit users. Community adoption path is legible.
- Lowest duplication — owns only the differentiating layer (grammar +
  blocking rules + typed IDs).
- Forces preflight into a minimal, substrate-neutral rule engine, which is
  structurally cleaner.

**Cons**:

- **Drops the Claude Code plugin form factor** as the primary surface —
  violates the original brief unless we redefine it.
- Spec-kit's hook model is not yet proven to support **blocking** enforcement;
  PR #2010 ("approval gates") is still open. If hooks remain advisory, the
  author-time blocking guarantee may not be reachable without upstream
  contribution.
- Couples preflight's release cadence and breaking-change exposure to
  spec-kit. Rate-of-change: extension system shipped PR #1787 (March 2026),
  still churning. A 1.0 cut is imminent, which may force another migration.
- Loses Claude Code's PreToolUse hook power (skill/tool-level blocking) —
  spec-kit hooks fire at spec-kit lifecycle events, which is a coarser grain.
- Existing preflight users (if any) would need a migration path.
- The preset+extension authoring surface is non-trivial to master (Python
  cli, YAML manifests, three-language template resolver).

**Reversibility**: medium. Extensions are standalone repos; preflight could
be de-listed and repackaged, but its users would need to migrate.

**Rate-of-change risk**: medium-high. Tied to spec-kit release train.

### Topology B — Preflight stays a CC plugin + composes with docguard

**Shape**: preserve the Claude Code plugin as the primary distribution
surface. Adopt `docguard`'s hook architecture as the blocking-rules substrate
— preflight's EARS + MADR rule packs become docguard rule packs. Preflight
still scaffolds doc types and runs its own authoring; docguard provides the
validation plumbing.

**Pros**:

- Preserves the CC plugin form factor.
- Rents the rule-engine plumbing instead of building it from scratch.
- docguard's "Canonical-Driven Development" philosophy is philosophically
  aligned with preflight's "docs as contract" stance.
- Stays independent from spec-kit's release cadence.
- Can still ship as a CC plugin; users don't have to know about docguard.

**Cons**:

- Couples to a single community extension (`raccioly/docguard`) — much
  smaller project than spec-kit itself; bus factor and maintenance risk are
  real.
- docguard is a spec-kit extension — to run docguard's hook pack, the target
  project must have spec-kit installed. That drags the whole spec-kit
  substrate in whether preflight wants it or not.
- Rule-pack interchange format is docguard-proprietary; preflight's rules
  become only valuable in a docguard environment.
- Duplicates the authoring and lifecycle layers (no composition with
  `archive`, no multi-agent reach).
- Author-time blocking via docguard runs at docguard's hook timing, not
  Claude Code's PreToolUse — so the enforcement point shifts.

**Reversibility**: medium. Rules are re-extractable but the packaging and
docguard-specific conventions would need to be reworked.

**Rate-of-change risk**: medium. docguard is one community maintainer; could
go dormant.

### Topology C — Dual distribution (CC plugin primary + spec-kit extension twin)

**Shape**: extract preflight's rule engine, EARS parser, MADR validator, and
ID traceability logic into a substrate-neutral core library. Ship two thin
adapters: one as the existing CC plugin, one as a `speckit-preflight`
extension. Both invoke the same core; only the packaging, command surface,
and hook wiring differ.

**Pros**:

- Preserves CC plugin form factor (primary) AND gains multi-agent reach
  through the spec-kit extension twin.
- The forced extraction of a substrate-neutral core is structurally cleaner
  — fights leakage of CC-runtime assumptions into preflight's logic.
- Neither substrate is a blocking dependency. If spec-kit's extension system
  stalls, the CC plugin keeps shipping. If CC plugin APIs change, the
  spec-kit side keeps shipping.
- Enables upstream contribution of the substrate-neutral core to other
  communities later (OpenSpec, BMAD, etc.) without forking.

**Cons**:

- **Highest maintenance cost** of the five topologies. Two distribution
  surfaces, two install flows, two test matrices, two docs paths.
- The "substrate-neutral core" claim needs to be proven. Today's preflight
  review skill may leak CC-specific assumptions (file I/O patterns, skill
  frontmatter, hook wiring). A spike is required to check.
- Doubles the cognitive load on contributors — changes to the rule engine
  need to be tested against both adapters.
- Governance risk: when the CC plugin and spec-kit extension diverge
  (because one substrate ships a feature the other doesn't), which is
  canonical?
- Users get confused about which to install, especially if they use Claude
  Code *with* spec-kit.

**Reversibility**: high. Either adapter can be deprecated without killing
the core.

**Rate-of-change risk**: low. Two substrates provide redundancy — preflight
survives either one going stale.

### Topology D — Substrate-agnostic rulepack + thin adapters (3+)

**Shape**: like Topology C but with 3+ adapters from day one. Package
preflight as a language-neutral rulepack (EARS grammar, MADR validator,
constitution precedence, FR/NFR/ADR ID traceability) with adapters for
Claude Code plugin, spec-kit extension, and standalone CLI. Potentially a
4th adapter for OpenSpec if that surface matures.

**Pros**:

- Maximum reach. Preflight becomes a format + rulepack spec that any agent
  environment can consume.
- Strongest composition-first story. The rule engine is the product; form
  factors are commodity adapters.
- Upstream contribution path becomes obvious — "here's the rulepack, here's
  the adapter API, add another adapter."
- Zero lock-in to any substrate.

**Cons**:

- **Highest cost of all topologies**. 3+ adapters to maintain at the start,
  tests for each, docs for each, release coordination across all of them.
- Violates the "ship in <1 week" rate-of-change principle from the meta doc.
- Over-engineered for today's one-user situation. The value of reach is
  hypothetical; the cost of maintenance is real.
- Substrate-neutrality claim is even harder to validate with 3 adapters than
  with 2.
- Rulepack interchange format is not yet a standard; preflight would have
  to invent one, which is a parallel product.

**Reversibility**: high on paper, low in practice — the rulepack format
becomes load-bearing infrastructure that's hard to redesign once adapters
depend on it.

**Rate-of-change risk**: low per-substrate, high for the rulepack format
itself (which preflight would own and therefore also ossify).

### Topology E — Borrow patterns, keep standalone (study, don't compose)

**Shape**: keep preflight as a standalone CC plugin (Path A from the
original composable architecture doc). Do not integrate with spec-kit or
any community extension. But **read docguard, archive, and ci-guard as
prior art** before implementing preflight's blocking rules, archive
lifecycle, and CI gates. Borrow architectural patterns without composing
with the artifacts themselves.

**Pros**:

- Lowest maintenance cost — one distribution surface, one install flow,
  one test matrix.
- Full control over the CC plugin runtime — PreToolUse hook, skill
  frontmatter, everything.
- No coupling to spec-kit, docguard, or any community extension's release
  cadence. Preflight ships on its own schedule.
- Preserves the original brief exactly.
- Fastest path to shipping — no substrate learning curve.
- Still benefits from community prior art through study, not runtime
  coupling.

**Cons**:

- Duplicates work that already exists. docguard's rule engine, archive's
  merge logic, and ci-guard's drift detection all need to be reimplemented
  in preflight's own terms.
- No multi-agent reach. Preflight remains Claude-Code-only unless it
  re-ships under another form factor later.
- Over 60–90 days, spec-kit's extension ecosystem may mature to the point
  where "preflight doesn't interop with the ecosystem" becomes a legible
  disadvantage. The window is narrowing.
- Community-adoption path is murky. A standalone Claude Code plugin has
  less discoverability than a spec-kit extension in a catalog.
- If the user wants multi-agent reach later, the migration cost is high
  because the CC runtime assumptions will have leaked into the codebase.

**Reversibility**: high. Nothing to back out of.

**Rate-of-change risk**: low in the short term (no external dependencies),
medium in the long term (risk of ecosystem isolation).

---

## 3. Topology comparison at a glance

| Criterion                                     | A (spec-kit ext) | B (docguard compose) | C (dual dist)  | D (rulepack + 3 adapters) | E (standalone + study) |
| ---------------------------------------------- | ---------------- | -------------------- | -------------- | ------------------------- | ---------------------- |
| CC plugin form factor preserved                | no (or thin)     | yes                  | yes            | yes                       | yes                    |
| Author-time PreToolUse blocking                | no (spec-kit hooks) | partial            | yes (via CC)   | yes (via CC adapter)       | yes                    |
| EARS / MADR / constitution first-class         | yes              | yes                  | yes            | yes                       | yes                    |
| Feature-folder lifecycle                        | rents from `archive` | duplicates        | rents + owns   | rents via adapters         | duplicates             |
| Multi-agent reach                              | free (17+ targets) | no                 | yes (via twin) | yes (via rulepack)         | no                     |
| Duplication of community work                  | lowest           | low                  | low            | lowest                     | highest                |
| Maintenance cost                               | medium           | medium               | high           | highest                    | lowest                 |
| Rate-of-change risk (substrate churn)          | medium-high      | medium               | low            | medium                     | low (short) / medium (long) |
| Reversibility                                  | medium           | medium               | high           | medium                     | high                   |
| Time to first ship                             | medium           | medium               | medium-high    | high                       | low                    |
| Preserves original brief exactly               | no               | mostly               | yes            | yes                        | yes                    |
| Community adoption path                        | clear            | unclear              | clear (both)   | clear                      | murky                  |
| Requires proving substrate-neutral core        | no               | no                   | yes            | yes                        | no                     |

---

## 4. What this changes about SPIKE_PLAN.md

The current SPIKE_PLAN is built around a two-way choice: Path A (preflight-native
skills) vs Path A-prime (spec-kit preset composition). The five-topology
decomposition shows that Path A-prime was actually ambiguous — it could mean
Topology A (preflight *becomes* a spec-kit extension, abandoning the CC plugin
form factor) or Topology C (preflight *also* ships as a spec-kit extension,
keeping the CC plugin as primary). The original spike design assumed Topology A
implicitly; that assumption should now be surfaced and reviewed.

**Proposed change**: add Open Question 5 to Phase 0 of SPIKE_PLAN.md — "which
composition topology is the spike testing?" — and block Phase 1 scaffold work
until answered. The answer will determine:

- What `presets/preflight/` looks like (full preset+extension for Topology A,
  minimal wrapper for Topology C, nothing for Topology E)
- Whether Phase 1's tasks include extracting a substrate-neutral core
  (required for C and D, not for A/B/E)
- Whether Spike 2's multi-agent verification is load-bearing (required for
  A/C/D, cosmetic for B/E)
- Whether ADR-007 needs to change its form-factor assumption (currently
  assumes CC plugin)

**This doc is input to that decision, not the decision itself.** Review topologies;
pick one (or a hybrid); update SPIKE_PLAN Phase 0 accordingly.

---

## 5. Decision input — what to review

When choosing between topologies, these are the questions that drive the
answer:

1. **Is the Claude Code plugin form factor load-bearing?** If yes, Topology A
   is out. If it's negotiable, A becomes viable.
2. **Is multi-agent reach worth paying for?** If yes, A/C/D; if no, B/E.
3. **How much churn tolerance does preflight have for upstream substrates?**
   High tolerance → A; low tolerance → C/E.
4. **Is the preflight rule engine already substrate-neutral, or would
   extraction require real work?** Unknown — requires a 1-day code audit of
   `skills/review/` to answer. This is a cheap unblocker for C/D viability.
5. **What's the cost of ecosystem isolation in 90 days?** If spec-kit's
   extension system matures as expected, standalone preflight (E) looks
   increasingly orphaned. If spec-kit stalls or breaks in 1.0, A/C look
   increasingly risky.
6. **Does preflight want a single deliverable or a rulepack + adapters
   architecture?** Shapes whether D is even worth considering. D assumes
   preflight's value is the rulepack; if the value is the integrated UX,
   D over-invests in neutrality.

None of these questions can be answered from this doc alone. All of them are
cheaper to answer than to commit to the wrong topology blind.

---

## 6. What's explicitly not in this doc

- **No topology recommendation.** The research surfaces the options; the
  decision is for the owner (nic) to make during Phase 0.
- **No deep dive into docguard's hook architecture** — that's a read-source
  task for whichever topology wins.
- **No community signal on preflight-adjacent proposals.** Issue #1356 (EARS)
  has zero traction; issue #1644 (spec domains) has structural adjacency.
  These matter for Topology A (join the conversation upstream) but not for
  the topology choice itself.
- **No prototype code.** The point of this doc is to prevent premature
  prototyping on the wrong topology.
