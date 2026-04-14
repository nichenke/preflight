---
status: complete
date: 2026-04-13
owner: nic
type: analysis
relates_to: adr-007-feature-folder-lifecycle, 2026-04-13-beads-gastown-comparison
---

# Validator chain combinatorics — design space for preflight's 48 rules

This analysis explores the design space for porting preflight's 48 review rules into a composable pattern borrowed from Beads (`internal/validation/issue.go:15-24, 140-174`). The borrow was identified in the Beads + Gas Town comparison (`docs/analysis/2026-04-13-beads-gastown-comparison.md` §5.1) as the single most valuable mechanical pattern across both projects. This doc works out which shape of composable chain is actually the right fit for preflight, given the constraints from ADR-007 and the goals from the workflow research arc.

## 1. The real design space is three axes, not ten

A naive enumeration of "every decision a validator framework could take" yields 10+ dimensions (rule atomicity, function signature, chain semantics, operators, configuration surface, integration point, discovery, testability, data model, locality). The combinatorial explosion is misleading — most of those dimensions are downstream of three load-bearing choices. Fix the three, and the rest collapses into implementation detail that can be changed later without restructuring.

The three load-bearing axes:

1. **Data model** — what unit of inspection does a rule receive?
   - Raw markdown string
   - Parsed AST (frontmatter + sections)
   - Typed domain models (`Requirement`, `ADR`, `ConstitutionClause`, `Project`)

2. **Composition mechanism** — how are chains assembled?
   - Explicit Python imports (`chain = [rule_a, rule_b, rule_c]`)
   - Tag-based dispatch (`@rule(ops=['drift'])` → auto-collected)
   - YAML config (`preflight-rules.yaml` declares chain assembly)

3. **Rule locality** — what scope does a rule see?
   - Per-doc (one file at a time)
   - Per-ID (one FR, one ADR, one clause)
   - Cross-doc (project-wide — e.g., "every FR has a test in test-strategy.md")
   - Staged (main + feature folder simultaneously — ADR-007's two-tier drift check)

Every other design decision (short-circuit vs collect-all, sync vs async, decorator vs registry function, golden tests vs property tests) is downstream of these three and reversible without touching the rule set.

## 2. Seven coherent points in the space

Not every combination is sensible; most are dominated by neighbors. The coherent design points:

| # | Option | Data model | Composition | Locality | One-line shape |
|---|---|---|---|---|---|
| 1 | **Minimal flat** | Raw string | Explicit list | Per-doc only | `chain = [r1, r2]; run(chain, doc)` |
| 2 | **Typed models** | Parsed typed models | Explicit typed chains | All scopes | `run(forReview, Project(docs=...))` |
| 3 | **Hybrid YAML** | Parsed AST | YAML assembles code primitives | All scopes | Python rules, YAML chain config |
| 4 | **Streaming** | Token/section stream | Explicit pipeline | Per-doc, early-exit on critical | `async for finding in stream(doc)` |
| 5 | **Full DSL** | Rules as data | YAML/JSON only | All scopes | Evaluator reads declarative rules |
| 6 | **Tag-dispatch flat** | Raw string | `@rule(ops=...)` auto-collected | Per-doc | `run(ops='drift', doc)` |
| 7 | **Tag-dispatch typed** | Typed models | `@rule(ops=..., scope=..., types=...)` | All scopes | `run(ops='drift', project)` |

**Eliminated immediately**:

- **Option 5 (Full DSL)** — the OpenSpec rule-as-code dream. Logic-heavy rules escape the DSL, producing a mix of code and data that is harder to maintain than either alone. Dead until OpenSpec (or equivalent) ships a mature rule-as-code layer upstream. Tripwire at 2026-06-13 to re-check.
- **Option 4 (Streaming)** — solves a problem preflight does not have. Our docs are markdown files under a few hundred lines each; there is no latency pressure that would justify a streaming parser and async chain semantics. Premature.

Five live candidates: 1, 2, 3, 6, 7.

## 3. Weighted outcome scoring

Weights derived from the workflow research arc and ADR-007:

| Outcome | Weight | Source |
|---|:-:|---|
| Rules remain enforceable | ×3 | Pass 4 hard requirement |
| Single-maintainer load | ×3 | Pass 4 decision driver |
| PAI/ISC boundary respected | ×3 | ADR-007 decision driver |
| Two-tier FR lookup supported | ×2 | ADR-007 drift mechanism |
| Rate-of-change tolerance | ×2 | Pass 5 rate-of-change research |
| Testable in isolation | ×2 | Standard engineering practice |
| New-rule addition cost | ×2 | Daily-use affordance |
| Multi-operation reuse | ×2 | Review, drift, coverage, ratification all need chains |
| User-configurable | ×1 | Nice-to-have, not core |
| Habit-compatible | ×2 | Pass 5 re-analysis finding |

Max weighted score = (3+3+3+2+2+2+2+2+1+2) × 5 = **220**.

Per-option scores (5 = best fit, 1 = worst):

| # | Option | Enforce ×3 | Maint ×3 | PAI ×3 | 2-tier ×2 | Rate ×2 | Test ×2 | New rule ×2 | Reuse ×2 | Config ×1 | Habit ×2 | **Total** |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | Minimal flat | 5 | 5 | 5 | 3 | 5 | 5 | 5 | 2 | 1 | 4 | **181** |
| 2 | Typed models | 5 | 4 | 5 | 5 | 4 | 5 | 4 | 5 | 2 | 4 | **195** |
| 3 | Hybrid YAML | 5 | 3 | 5 | 4 | 3 | 4 | 3 | 5 | 5 | 4 | **175** |
| 6 | Tag-dispatch flat | 5 | 4 | 5 | 3 | 4 | 4 | 5 | 5 | 3 | 4 | **183** |
| 7 | Tag-dispatch typed | 5 | 4 | 5 | 5 | 4 | 5 | 5 | 5 | 3 | 4 | **200** |

**Top three**: Option 7 (200), Option 2 (195), Option 6 (183). Options 1 and 3 are dominated.

## 4. The load-bearing decisions

### 4.1 Data model — flat vs typed

The score gap between flat (Options 1, 6) and typed (Options 2, 7) is driven entirely by two capabilities:

1. **Cross-doc rules** — roughly 15 of the 48 rules touch multiple docs:
   - "Every FR has at least one acceptance test in `test-strategy.md`"
   - "ADR referenced by an RFC must exist"
   - "Constitution precedence over ADR on conflict"
   - "FR orphan detection (requirement not referenced by any code or test)"
   - "Architecture section referenced by FR must exist"
   - etc.

   Flat models force these rules into primary/secondary-doc plumbing — a rule that takes one doc but needs another must load the second doc itself, breaking the pure-function model and duplicating file-system access across every cross-doc rule.

2. **Two-tier FR lookup** (ADR-007 requirement) — the drift hook resolves an FR ID against main's `requirements.md` first, then against any in-flight `specs/features/*/requirements.md`. A typed `Project` model carries both (`Project(main_requirements, in_flight_features=[...])`) and drift rules query it through a single interface. Flat models require a fallthrough helper threaded through every call site.

**Verdict on axis 1**: **typed**. The one-time cost of a parser layer plus typed models (Requirement, ADR, Constitution, RFC, Architecture, Interface, TestStrategy, Project) buys cross-doc rules and ADR-007's drift semantics as natural consequences. Flat models are dominated for preflight's rule set.

### 4.2 Composition mechanism — explicit vs tag-dispatch

Between Options 2 and 7 (both typed), the question is whether chain assembly is *hand-written* or *derived from tags*.

**Option 2 — explicit chains**:
```python
forReview = [ears_shall, id_uniqueness, fr_has_test, constitution_precedence, ...]
forDrift = [id_exists_somewhere, fr_orphan, adr_reference_resolves, ...]
forCoverage = [category_coverage, missing_category_sections, ...]
forRatification = [no_provisional_fr, all_plans_merged, archive_marker, ...]
```
- Visible at a glance. A reader can trace exactly which rules run for a given operation.
- Adding a rule requires touching both the rule file and each chain that should include it.
- For 48 rules × ~4 operations over the project's lifetime, ~150–200 touch points of maintenance.

**Option 7 — tag dispatch**:
```python
@rule(id='EARS-01', severity='high', ops=['review', 'ratification'], ...)
def ears_shall_keyword(project): ...
```
- Adding a rule is one file, one decorator line.
- Chain assembly is a registry query: `chain_for(op='drift')`.
- The dependency from rule to chain is invisible unless you grep tags.
- **Failure mode**: a rule with a missing or wrong tag silently drops from an operation without any error.

**Mitigation for the silent-drop failure mode**: a golden-file test per operation that pins the expected list of rule IDs contributing. If someone adds a rule and forgets the `ops=['drift']` tag, the golden test fails and the CI blocks the merge. Roughly 20 lines of test code for the whole system.

With the mitigation, Option 7 wins on:
- New-rule addition cost (one file, one decorator)
- Multi-operation reuse (a rule contributes to every operation it declares, for free)
- Rate-of-change tolerance (churn in the rule set is amortized across a simple uniform addition pattern)

Without the mitigation, Option 7 degrades toward "rules silently drop from operations" — a failure mode that is hard to detect and worse than the equivalent in Option 2. **The golden test is load-bearing, not optional.**

**Verdict on axis 2**: **tag-dispatch, with golden membership tests mandatory**.

### 4.3 Rule locality — per-doc, per-ID, cross-doc, staged

With typed models and tag dispatch, locality becomes a rule-level declaration rather than a framework concern:

```python
@rule(id='EARS-01', severity='high', ops=['review'], scope='per-id', types=['requirement'])
def ears_shall_keyword(project): ...

@rule(id='FR-TEST-01', severity='critical', ops=['review', 'ratification'], scope='cross-doc', types=['requirement', 'test-strategy'])
def every_fr_has_a_test(project): ...

@rule(id='DRIFT-01', severity='high', ops=['drift'], scope='staged', types=['requirement'])
def fr_id_resolves_anywhere(project): ...
```

The framework uses the `scope` tag to inform callers what the rule needs (framework can warn if a `scope='cross-doc'` rule is invoked without the secondary doc present, etc.), but does not special-case the rule bodies. All rules receive the same `Project` argument; they query what they need from it.

This is the payoff of the typed data model: locality is expressed declaratively and enforced by convention, not by forking the rule signature per scope.

## 5. Recommended shape — concrete starting code

### 5.1 Framework primitives (~80 lines)

```python
# preflight/rules/base.py
from dataclasses import dataclass
from typing import Callable

Severity = str  # 'critical' | 'high' | 'medium' | 'low'
Operation = str  # 'review' | 'drift' | 'coverage' | 'ratification'
Scope = str      # 'per-doc' | 'per-id' | 'cross-doc' | 'staged'

@dataclass
class Finding:
    rule_id: str
    severity: Severity
    location: str  # file:line-range per ADR-006
    message: str

Rule = Callable[['Project'], list[Finding]]

_registry: list[tuple[Rule, dict]] = []

def rule(*, id: str, severity: Severity, ops: list[Operation],
         scope: Scope = 'per-doc', types: list[str] | None = None):
    def decorator(fn: Rule) -> Rule:
        _registry.append((fn, {
            'id': id, 'severity': severity, 'ops': ops,
            'scope': scope, 'types': types or [],
        }))
        return fn
    return decorator

def chain_for(op: Operation) -> list[Rule]:
    return [r for r, meta in _registry if op in meta['ops']]

def run(op: Operation, project: 'Project') -> list[Finding]:
    findings = []
    for r in chain_for(op):
        findings.extend(r(project))
    return findings

def rule_ids_for(op: Operation) -> list[str]:
    return sorted(meta['id'] for r, meta in _registry if op in meta['ops'])
```

### 5.2 Example rule

```python
# preflight/rules/ears.py
from preflight.rules.base import rule, Finding

@rule(id='EARS-01', severity='high', ops=['review', 'ratification'],
      scope='per-id', types=['requirement'])
def ears_shall_keyword(project):
    findings = []
    for fr in project.requirements.functional:
        if ' shall ' not in fr.body.lower():
            findings.append(Finding(
                rule_id='EARS-01',
                severity='high',
                location=fr.location,
                message=f"{fr.id}: missing 'shall' keyword",
            ))
    return findings
```

### 5.3 Golden test (prevents silent drops)

```python
# tests/golden/test_chain_membership.py
from preflight.rules.base import rule_ids_for

DRIFT_CHAIN_EXPECTED = [
    'DRIFT-01', 'DRIFT-02', 'DRIFT-03',
    'FR-ORPHAN-01', 'ID-RESOLVE-01',
    # ... pinned list
]

def test_drift_chain_membership():
    assert rule_ids_for('drift') == DRIFT_CHAIN_EXPECTED

# Repeat for 'review', 'coverage', 'ratification'.
```

**Total new framework code**: ~80 lines base + ~20 lines per golden test × 4 operations = ~160 lines. Each of the 48 rules becomes a 15–40 line function. Full port is ~2500 lines of rule code + framework, almost all of it trivially unit-testable in isolation.

## 6. Complex pay-offs worth deferring

Things that are tempting to add immediately but should wait for empirical friction signal:

| # | Deferred idea | Trigger to revisit | Risk if added early |
|---|---|---|---|
| 1 | **Hybrid YAML enable/disable** (Option 3's contribution) — `preflight.local.yaml` lets projects opt out of individual rules | First spike reveals a rule is too prescriptive for a specific project context | Premature generality; two config surfaces to maintain |
| 2 | **Severity-gated short-circuit** — stop running medium/low rules once a critical fails | Review latency becomes noticeable on real runs | Harder to reason about — a rule's failure hides other rules' findings |
| 3 | **Rule dependencies** (rule B only runs if rule A passes) | Noise cascade from a structural rule failure makes review output unreadable | Classic trap: dependency DAG compounds complexity disproportionate to value |
| 4 | **Content-hash cache** (Beads `types.go:117-130` pattern) — skip rules on unchanged docs | Review latency measurable on full-project runs at L4 scale | Cache invalidation is the classic hard problem; premature |
| 5 | **Full rules-as-data DSL** (Option 5) | OpenSpec v1.4+ ships first-class rule-as-code and we want interop | Logic-heavy rules escape any DSL; mixed code+data surface is worst-of-both |
| 6 | **Cross-project rule sharing** — preflight as a library for other projects' rule sets | Second project adopts preflight with its own rule set | Trivially supported by Option 7's registry; no design cost to defer |
| 7 | **Parallel rule execution** | Review wall-clock becomes painful | Complicates test isolation for marginal gain at preflight's scale |

Each deferred idea has a clear empirical trigger. The tripwire at 2026-06-13 reviews all seven against actual friction observed in the spike period.

## 7. Recommendation summary

**Ship Option 7 (tag-dispatch with typed models) as the validator framework for ADR-007's spike work.**

Rationale:

- Scored highest (200/220) on the weighted outcomes from the research arc.
- Typed models are required by ADR-007's two-tier FR lookup and by ~30% of the rule set being cross-doc.
- Tag dispatch minimizes per-rule touch points, which matters because the rule set itself will churn as L4 categories evolve.
- The framework is ~80 lines; the 48-rule port is ~2500 lines of trivially unit-testable code.
- The golden-membership-test mitigation for tag dispatch's silent-drop failure mode is ~20 lines per operation and must be mandatory.

**Ordering**:

1. Write the 80-line framework plus base `Project` + typed models.
2. Port the 48 rules (can parallelize across rule categories: EARS, ID discipline, constitution, governance, traceability).
3. Pin golden-membership tests per operation before the first spike runs.
4. Run the first spike (small preflight bug, per ADR-007) with the new framework in place.
5. Harvest friction signal; revisit deferred ideas #1–#7 at the 60-day tripwire.

**What would change this recommendation**:

- If the spike reveals that typed models are over-designed for the actual rule set (e.g., <5% of rules use cross-doc scope in practice), fall back to Option 6 (tag-dispatch flat). This is a one-day refactor and touches only the framework, not rule bodies.
- If OpenSpec or spec-kit ships a rule-as-code DSL before the 60-day tripwire, re-score against Option 5.
- If a second maintainer joins preflight, Option 3's YAML config becomes more attractive because the user-configurable surface has an audience.

## 8. Relationship to ADR-007 and the spikes

This analysis directly feeds the spike work ADR-007 schedules. The small-bug spike needs `chain_for('review')` and `chain_for('drift')` to exist and produce findings in a format the review skill can render. The large tack-room-launcher spike will exercise `chain_for('coverage')` (for the L4 category contract at feature-spec level) and `chain_for('ratification')` (for the atomic feature-folder-to-main merge).

All four chains can be populated with subset of the 48 rules before the small spike starts. The framework is a blocking dependency for the spike; the full 48-rule port is not.

**Minimum viable rule set for the small-bug spike**: the ~8 rules touching a single FR's structure (EARS keyword, ID format, severity field, status field, trace-back to source, uniqueness, location format, language precision). Port those first, pin their golden test, run the spike. Port the remaining 40 in parallel streams after the spike validates the framework shape.

## Appendix — eliminated options detail

### Option 5 (Full DSL) — dead without upstream

A rules-as-data design where every rule is a YAML record and the framework evaluates them. Fails on:

- **Logic-heavy rules escape the DSL.** "Every FR has a test in test-strategy.md" requires cross-doc traversal that is either too much to encode in YAML (resulting in a rule engine bigger than the rules themselves) or forces a Python escape hatch per rule, producing a worse code/data mix than Option 3's hybrid.
- **Rate-of-change risk**: any DSL design we own will itself need to evolve as the rule set grows; we take on a language design problem on top of the rule problem.
- **Interop value is hypothetical**: the DSL's main payoff is cross-tool portability, and pass 4 explicitly deprioritized cross-tool portability as a non-goal.

**Trigger to revisit**: OpenSpec or spec-kit ships a rule-as-code layer we could target instead of inventing. Tracked in the day-60 tripwire.

### Option 4 (Streaming) — solves a nonexistent problem

An async streaming parser that yields findings as sections arrive. Fails on:

- **Preflight's docs are small.** Requirements files run 500–2000 lines; constitution files run 200–500 lines. There is no latency pressure that would justify streaming.
- **Complicates testing.** Async fixtures, section-order assumptions, and early-exit semantics compound test complexity for zero runtime benefit.
- **Complicates rule authoring.** A streaming rule is harder to write than a batch rule because the author must reason about section arrival order.

**Trigger to revisit**: never, unless preflight's scope expands to documents multiple orders of magnitude larger than today. No such signal exists.

### Option 1 (Minimal flat) — dominated by Option 6

Simpler than Option 6 only by lacking the tag dispatch layer. Still requires manual chain assembly with every rule touched per chain change. Strictly dominated by Option 6 once tag dispatch is on the table, and by Option 7 once typed models are on the table. No scenario where Option 1 wins.

### Option 3 (Hybrid YAML) — dominated until user demand materializes

Adds a YAML configuration layer on top of a Python rule set. Loses to Option 7 on maintainability (two config surfaces) and rate-of-change (YAML schema drifts alongside rule churn), but wins on user-configurability. The win is worth nothing until a user wants to configure, which is not preflight's current situation. Dominated at present; re-evaluate when a second project adopts preflight.
