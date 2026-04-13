---
status: complete
date: 2026-04-13
owner: nic
type: analysis
relates_to: adr-007-feature-folder-lifecycle
---

# Beads + Gas Town — comparison against preflight ADR-007

## Executive summary

**Neither Beads nor Gas Town should be adopted as a replacement for preflight ADR-007's feature-folder lifecycle.** Both fail the hard-requirement lens established in pass 4 on the same three counts (no enforceable document rules, direct violation of the PAI/ISC boundary, no main-cleanliness invariant). The category is wrong — they are *runtime memory layers for agent work*, not spec-driven-development frameworks. Preflight and Beads are **complementary, not competitive**: preflight governs specs, Beads (optionally) tracks the work items generated from them.

**However, the deep read turned up four small, directly-liftable borrowings** that improve ADR-007 without any structural change. The most valuable is a 10-line validator chain pattern from Beads that is the exact shape preflight's 48 rules want to be in. Full list in §5.

This doc shows the work behind that verdict.

---

## 1. What they actually are

### Beads (Steve Yegge, 20,660 stars, Go + Dolt)

A **graph-based issue tracker for AI coding agents**. Issues live as rows in an embedded Dolt database (`.beads/embeddeddolt/`), exported to JSONL for git collaboration. Schema at `internal/types/types.go:16-112`: Issue rows carry Description / Design / AcceptanceCriteria / Notes / SpecID / Dependencies / CompactionMetadata. The CLI (`bd ready`, `bd show`, `bd update`, `bd close`) is the executor's main interaction surface. Molecules (`internal/molecules/`) are reusable templates that spawn N child issues — explicit decomposition tooling. Positioning from `README.md:15`: *"persistent, structured memory for coding agents... replaces messy markdown plans with a dependency-aware graph."*

### Gas Town (Gas Town Hall org, 13,944 stars, Go)

A **multi-agent workspace orchestrator** that uses Beads as its underlying work ledger. Architecture: a "Mayor" coordinator hands "convoys" (bundles of beads) to "polecat" worker agents via git-worktree-backed "hooks." Plugins (`plugins/quality-review/`, `plugins/git-hygiene/`, `plugins/github-sheriff/`) run operational checks. Runtime binaries: `cmd/gt`, `cmd/gt-proxy-client`, `cmd/gt-proxy-server`. No spec layer at all — design notes live freely in `docs/design/`.

**Structural observation**: Gas Town is Beads + orchestration. Analyzing them separately is almost wasted effort; the interesting comparison is Beads, and Gas Town is "Beads at runtime with multi-agent coordination on top."

---

## 2. Hard-requirement lens

Applying the same three non-negotiables pass 4 used on OpenSpec:

| Requirement | Beads | Gas Town |
|---|---|---|
| **48 rules remain enforceable as document rules** | ❌ No. `internal/validation/*.go` has runtime preconditions (`IssueExists`, `NotPinned`, `NotClosed`) — not EARS/ID/constitution-precedence checks. The only gesture at doc-level rule governance is `docs/RULES_AUDIT_DESIGN.md` — a design doc, no shipped code. | ❌ No. `plugins/quality-review/` is an operational plugin that shells to an LLM. No document validator exists. |
| **PAI/ISC boundary respected** | ❌ **Direct violation.** Beads' whole purpose is task decomposition. Epics expand into child issues, `bd ready` surfaces unblocked leaves, molecules template-generate N children at once. The executor is handed atomic tasks, not prose intent. | ❌ **Direct violation via Beads.** Same decomposition model inherited wholesale. |
| **Main-cleanliness invariant tolerated** | ❌ No. `SpecID` is a free-text tag. No provisional/approved distinction. No mechanism to hold unvalidated FR changes outside main until UAT. | ❌ No. Design notes are edited freely in `docs/design/`, no delta model, no staging. |

**3/3 failures on both projects.** Pass 4's rejection logic applies unchanged.

---

## 3. Overlap with ADR-007 (paragraph-level)

| ADR-007 concept | Beads analog | Gas Town analog |
|---|---|---|
| `specs/features/NNN-slug/` folder | None. Work lives in Dolt rows. Hierarchical IDs (`bd-a3f8.1.1`) play a grouping role. | None. Beads row (bead) + convoy bundle. |
| `spec.md` vs `plans/*.md` split | None. Single Issue row carries Description + Design + AcceptanceCriteria + Notes in one record. | None. |
| Whole-file-copy vs delta for requirements | Neither. Row-level state with content-hash merge (`types.go:117-130`). | None. |
| 48 enforceable review rules | `internal/validation/issue.go:15-24, 140-174` — composable chains, ~466 LOC total. Different semantics (runtime, not doc-level) but **the pattern is a direct fit** — see §5.1. | None. |
| Drift detection | `ContentHash` over substantive fields — deterministic SHA256. | None for specs. Runtime health via `internal/doctor/`. |
| L4 coverage taxonomy | None. | None. |
| Archive-on-ship | Closest is `bd compact` — summarizes closed issues to save context tokens. Not spec archival. | Beads `closed` status. |

**Conceptual overlap is near-zero.** Mechanical overlap exists in the validator pattern and the content-hash trick — see next section.

---

## 4. Rate of change (evidence)

```
# Beads
git log --since='30 days ago' --oneline | wc -l    → 721
git log --since='90 days ago' --oneline | wc -l    → 3162
git log --oneline | wc -l                           → 8411 (total)
git tag --sort=-creatordate | head -20              → v1.0.0, v0.63.3...v0.53.0

# Gas Town
git log --since='30 days ago' --oneline | wc -l    → 670
git log --since='90 days ago' --oneline | wc -l    → 4275
git tag --sort=-creatordate | head -20              → v1.0.0, v0.13.0...v0.2.1 (22 total tags)
```

**~700 commits per month, each.** Beads' core Issue schema is still churning (new fields `WispType`, `MolType`, `WorkType`, `EventKind` in recent commits). Gas Town's bead/convoy/hook shapes are churning at similar rates. Both just tagged v1.0.0 (~2 weeks ago). **Vendoring either as a dependency is taking on a fast-moving upstream.** Pass 5's 55–70% six-month obsolescence estimate applies.

---

## 5. Ideas worth stealing (ranked by value/cost)

### 5.1 Composable validator chains — *high value, low cost*

**Source**: `internal/validation/issue.go:15-24` and `140-174` in Beads.

```go
type IssueValidator func(ctx context.Context, issue *types.Issue) error

func Chain(vs ...IssueValidator) IssueValidator {
    return func(ctx context.Context, issue *types.Issue) error {
        for _, v := range vs {
            if err := v(ctx, issue); err != nil { return err }
        }
        return nil
    }
}

// Operation-specific bundles:
var forUpdate = Chain(Exists(), NotTemplate(), NotPinned(force))
var forClose  = Chain(Exists(), NotTemplate(), HasStatus(Open, InProgress))
var forDelete = Chain(Exists(), NotPinned(force), NotHooked())
```

**Why this matters for preflight**: our 48 rules are currently expressed in review skill prose. Porting them to Python functions composed into operation-specific chains (`forReview`, `forDrift`, `forCoverage`, `forRatification`) gives us:
- Individual rules are unit-testable in isolation
- Operation bundles are explicit and readable
- Adding a rule is one function + one line in the relevant chain
- Review findings get structured output for free

**Port effort**: ~10 lines of Python to define the abstraction. Each of the 48 rules becomes a small function. One-day-per-rule-category port. Zero dependencies.

**This is the single most valuable borrowing in either project.** It directly improves ADR-007's `review --drift` and `review --coverage` implementations and makes the 48-rule maintenance story much better.

### 5.2 Content hash for drift detection — *medium value, low cost*

**Source**: `internal/types/types.go:117-130` in Beads (`ComputeContentHash`).

Deterministic SHA256 over "substantive fields only" (excludes IDs, timestamps, volatile metadata). Gives a cheap equality check for "did this thing actually change?"

**Why this matters**: ADR-007's two-tier FR lookup needs a way to answer "is this FR in the feature folder *actually different* from the one in main, or just reformatted?" Naive byte-diff over markdown fails on whitespace/formatting churn. A canonical-form hash over FR body + type + status gives a correct answer.

**Port effort**: ~15 lines of Python. Specific to preflight's FR/NFR/ADR/CONST ID formats. Feeds directly into the drift hook.

### 5.3 Notes/status convention for post-compaction recovery — *medium value, trivial cost*

**Source**: `claude-plugin/skills/beads/SKILL.md:65-75` and `resources/WORKFLOWS.md:47-80` in Beads.

A structured Notes format: `COMPLETED / IN PROGRESS / BLOCKERS / KEY DECISIONS / NEXT`. Agents write notes in this shape explicitly for context recovery after compaction events.

**Why this matters**: ADR-007's plan files (`plans/NNN-*.md`) need a status section. This is a battle-tested shape — the Beads community has been using it in practice. Adopt it as our plan-template's status section, no reinvention needed.

**Port effort**: zero code. One paragraph in the plan template.

### 5.4 Event log as append-only artifact — *medium value, low cost*

**Source**: `.beads/backup/events.jsonl` in Gas Town (schema inherited from Beads).

Append-only event log of state transitions. In Beads' case: issue-level events. For preflight: an `events.jsonl` inside each feature folder recording `drafted | proposed | reviewed | approved | shipping | shipped` transitions with timestamps and responsible actor.

**Why this matters**: gives replay, audit, and post-hoc drift forensics without changing the main spec shape. When a feature ratifies, the events log goes into the archive with the folder.

**Port effort**: ~20 lines of bash/python to write events. Requires deciding the event schema (5–8 event types plus freeform fields). Not urgent for ADR-007 acceptance but good for L4 when the loop is running unattended.

### 5.5 SKILL.md structure pattern — *low value, trivial cost*

**Source**: `claude-plugin/skills/beads/SKILL.md:1-110` in Beads.

A tight SKILL.md format: `allowed-tools` + `version` + decision table + session protocol + resource index. Worth mirroring for the new `/preflight:explore` and `/preflight:propose` skills rather than reinventing.

**Port effort**: zero code. One template worth copying.

---

## 6. Ideas deliberately *not* stealing

- **The Beads schema (`types.go:16-112`)**. Rich, battle-tested, but it bakes in task decomposition as a first-class concept — directly violates PAI/ISC boundary. Taking the schema means taking the philosophy.
- **Gas Town's convoy/hook/polecat runtime model**. Interesting as a *target* for executing preflight plans (PAI could run inside a polecat), but not as a replacement for ADR-007's governance shape.
- **Molecules** (`internal/molecules/`, 357 LOC). Reusable issue templates that spawn child issues. Attractive but decomposition-first, wrong side of the boundary.
- **Dolt / SQL storage**. Adds CGO dependency, Go runtime, and a database. Preflight is Python/bash; importing Dolt means importing half of Beads. Git + markdown is enough for preflight's scale.
- **`bd rules audit` design doc** (`docs/RULES_AUDIT_DESIGN.md`). Jaccard-similarity rule-deduplication. Interesting but unshipped, and our 48-rule corpus is hand-curated — deduplication is not our actual problem.

---

## 7. Adopt-instead verdict

### Beads as replacement for ADR-007: NO

**Gain**: 20k-star community, mature Claude Code plugin, persistent DB-backed issue memory, compaction survival, rich typed-edge graph, inter-agent messaging.

**Lose**: the 48-rule enforcement framework, the 25-category L4 taxonomy, spec-as-source-of-truth, main cleanliness, the PAI/ISC boundary, markdown-native diffing, Python/bash simplicity. At that point we have rewritten preflight and taken on a Go + Dolt + CGO dependency whose schema is still churning at 700 commits/month.

**Rebuild cost to make Beads carry preflight's value**: implement the 48 rules inside `bd rules audit` (currently a design doc, zero code), add provisional/approved state to `SpecID`, gate `bd close` on UAT, fork the molecule decomposition model to respect a PAI handoff layer. **Effectively a rewrite.**

### Gas Town as replacement for ADR-007: NO

Even larger category mismatch. Gas Town is an orchestration runtime that assumes Beads beneath it — no spec layer at all. Adopting Gas Town means adopting Beads by transitivity plus a Go runtime plus the multi-agent coordination logic we do not need.

### Beads or Gas Town as runtime target for preflight: PLAUSIBLE, OUT OF SCOPE

PAI (or any other executor) could consume a preflight plan and run inside a Gas Town polecat, with the polecat's bead rows referencing the plan's FR IDs via `SpecID`. This is an interesting future composition — *preflight governs the specs, Beads tracks the work items spawned from them* — but nothing about it needs to happen now, and nothing about it changes ADR-007.

### Keep ADR-007 and borrow: YES

The four small borrowings in §5 (validator chains + content hash + notes convention + event log) improve ADR-007's implementation without changing its shape. Validator chains alone justify the research time: they reshape how the 48 rules are expressed and tested for essentially zero cost.

---

## 8. Recommended next moves

1. **ADR-007 stands as written.** No revision needed. Beads/Gas Town do not invalidate any assumption.
2. **Port validator chains into preflight's review skill as part of the `/preflight:review --drift` spike.** This is a prerequisite for the feature-folder spikes ADR-007 schedules — having `forDrift`, `forCoverage`, `forRatification` chains ready makes the small-bug spike cleaner.
3. **Adopt Beads' Notes format as preflight's plan-template status section.** Zero-cost borrow, lands in the plan template before the first spike.
4. **Add content-hash helper to the drift hook scaffold.** Part of the drift hook work item from the pass 5 re-analysis 4-item plan. Use the Beads pattern.
5. **Defer event log** until the first spike reveals whether a feature folder needs replay/audit tooling. Not required for v0.7.0.
6. **Note Beads as a potential runtime composition target** in a short reference doc, without committing to integration. Preflight and Beads are complementary; recording this relationship lets future-us compose them cleanly if the need arises.

## 9. Reasoning and methodology notes

Applied pass 4's buy-vs-build framing (hard requirements first, then weighted criteria, then backward-walk) to both projects. Applied pass 5's rate-of-change lens (both projects >600 commits/month, both v1.0.0 within two weeks of analysis — high obsolescence risk for any vendoring decision). Applied criteria-first re-scoring (from pass 5 re-analysis): checked each borrowable idea against the original brief (forgotten updates, L4 readiness, habit formation) rather than the research arc's generated criteria.

**What would change this verdict**: if Beads shipped an EARS validator, a constitution precedence engine, or a document-level rule framework as first-class features — then the hard-requirement lens would pass and a deeper integration analysis would be warranted. `bd rules audit` is the closest signal and it is currently unshipped. Re-check at the day-60 tripwire (2026-06-13).

**Research artifacts** (not committed): clones at `$TMPDIR/preflight-research-clones/beads/` and `$TMPDIR/preflight-research-clones/gastown/`. Safe to delete. Key files examined listed inline in §1–5 citations.

---

## Appendix — citation index

Beads:
- `internal/types/types.go:16-112` — Issue schema
- `internal/types/types.go:117-130` — ComputeContentHash
- `internal/validation/issue.go:1-175` — validator chain pattern
- `internal/validation/issue.go:140-174` — operation-specific chains
- `internal/molecules/` + `resources/MOLECULES.md` — decomposition templates (357 LOC, not adopting)
- `claude-plugin/skills/beads/SKILL.md:1-110` — SKILL.md template
- `claude-plugin/skills/beads/SKILL.md:65-75` — Notes convention
- `claude-plugin/skills/beads/resources/WORKFLOWS.md:47-80` — session protocol
- `docs/RULES_AUDIT_DESIGN.md:1-60` — unshipped rules audit design
- `README.md:15, 40, 53-58` — positioning and concepts

Gas Town:
- `.beads/PRIME.md:1-60` — worker primer
- `.beads/PRIME.md:5-13` — Propulsion Principle
- `.beads/PRIME.md:15-20, 29, 38-48` — session protocol
- `.beads/backup/*.jsonl` — JSONL snapshot format
- `plugins/quality-review/` — advisory runtime checks (not document rules)
- `docs/concepts/convoy.md` — bundle concept
- `internal/doctor/`, `internal/health/` — runtime health (not spec drift)
