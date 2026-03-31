---
status: Proposed
date: 2026-03-31
owner: nic
version: 0.1.0
deciders: [nic]
consulted: []
informed: []
---

# ADR-004: Reviewer Agent Architecture — Ensemble with Adversarial Complement

## Context and Problem Statement

RFC-001 proposes replacing the monolithic review skill with specialized reviewer agents
(Phase 2). The RFC left the agent architecture open pending spike results: should the
review skill dispatch one agent per doc type, use a universal agent, or combine approaches?

A spike evaluated four reviewer implementations across 16 documents in 3 repos:
- **Baseline**: monolithic rule evaluation (current skill behavior)
- **Impl-B**: doc-type-specialized agents (one per type, rule-focused)
- **Impl-C**: universal rule-based agent (one agent, all types)
- **Impl-D**: adversarial layered agent (cross-doc analysis, hypothesis investigation, steelman gates)

The spike extension (v2 rubric) measured severity-weighted recall and precision to
determine which architecture the review skill should adopt.

## Decision Drivers

- FR-017 requires the review skill to produce actionable findings with confidence signals
- FR-018 requires both universal and doc-type-specific rule checking
- NFR-004 requires >=85% rule-following accuracy with <=15% false positive rate
- CONST-QA-01 requires skills to be measurably better than the manual workflow
- The spike demonstrated that rule-based and adversarial approaches find orthogonal
  defect classes with near-zero overlap — neither subsumes the other

## Considered Options

1. Universal rule-based agent only (impl-c)
2. Doc-type-specialized agents only (impl-b, as originally proposed in RFC-001)
3. Ensemble: universal rule-based (impl-c) + adversarial complement (impl-d)

## Decision Outcome

Chosen option: "Ensemble: universal rule-based + adversarial complement", because the
spike shows that rule-based and adversarial review find fundamentally different defect
classes, and combining them achieves higher recall than either alone without sacrificing
precision.

### Consequences

- Good, because ensemble covers both compliance/formatting defects (impl-c) and
  structural/epistemic defects (impl-d) — the two categories have near-zero overlap
- Good, because impl-d adds unique findings on 16/16 tested documents, always expanding
  the finding union
- Good, because both agents have high precision (impl-c 0.94, impl-d 0.97), so merging
  outputs does not introduce significant noise
- Bad, because running two agents per review doubles the inference cost — mitigated by
  running them in parallel (no serial dependency)
- Bad, because impl-d's adversarial architecture requires calibration before production
  use (suppression rate 58.4% vs 10-30% target) — mitigated by the ensemble context where
  rule-compliance suppressions are benign since impl-c catches them
- Neutral, because impl-b (doc-type-specialized) is retired as a separate implementation;
  if ADR-specific review improvements are needed, they should be a variant of impl-c with
  rule emphasis adjustments, not a separate agent architecture

### Spike evidence

| Metric | Baseline | Impl-B | Impl-C | Impl-D |
|---|---|---|---|---|
| Avg severity-weighted recall | 35.3% | 40.6% | 45.2% | 45.0% |
| Avg precision | 0.73 | 0.88 | 0.94 | 0.97 |
| Docs won | 2 | 3 | 5 (+1 tie) | 5 |

- Impl-d beats max(B,C) on 5/16 docs (fails standalone replacement at 10/16 threshold)
- Impl-d adds unique findings on 16/16 docs (passes complementary value condition)
- Impl-d's unique findings: cross-doc governance gaps, unverifiable requirements, false
  hard constraints, internal contradictions — categories rule-based review cannot reach

Full results: `docs/spike/results/aggregate-v2-opus.md` (branch: feature/reviewer-agents-spike)

### Confirmation

- Phase 2 implementation uses the ensemble architecture: `skills/review/SKILL.md`
  dispatches impl-c first, then impl-d, merges findings
- Review skill evals meet NFR-004 targets (>=85% accuracy, <=15% false positive rate)
  on the 16-document spike corpus
- Impl-d suppression calibration is addressed before or during Phase 2 implementation
  (target: structural/epistemic finding recall, not global suppression rate)

## Pros and Cons of the Options

### Universal rule-based agent only (impl-c)

Single agent handling all doc types with universal + doc-type-specific rules.

- Good, because highest single-impl per-doc average recall (45.2%)
- Good, because strong precision (0.94) with consistent quality across doc types
- Good, because simplest to maintain — one agent file
- Bad, because misses all structural/epistemic defects that only adversarial review finds
  (37 unique findings across 16 docs)
- Bad, because no cross-doc analysis capability

### Doc-type-specialized agents only (impl-b)

Seven agents, one per doc type, each with tailored rules and quality heuristics.

- Good, because RFC-001 originally proposed this — no design change needed
- Good, because catches some findings impl-c misses (won 3/16 docs)
- Bad, because aggregate performance is strictly worse than impl-c (40.6% vs 45.2%
  recall, 0.88 vs 0.94 precision)
- Bad, because 7 agent files to maintain vs 1 for impl-c
- Bad, because still no cross-doc analysis capability

### Ensemble: universal rule-based + adversarial complement

Impl-c as primary reviewer, impl-d running in parallel as complement.

- Good, because highest combined recall on most documents
- Good, because finding profiles are orthogonal — merging adds signal without duplication
- Good, because both agents have high precision — merged output stays clean
- Good, because impl-d surfaces defect classes (governance gaps, false hard constraints,
  internal contradictions) that are invisible to rule-based review
- Bad, because doubles inference cost per review
- Bad, because impl-d requires calibration work before production

## More Information

- RFC-001: `specs/decisions/rfcs/rfc-001-reviewer-agents.md`
- Spike extension design: `docs/plans/2026-03-31-reviewer-agents-spike-extension.md`
- Adversarial reviewer agent: `agents/reviewers/adversarial-reviewer.md`
- Aggregate results (Opus): `docs/spike/results/aggregate-v2-opus.md`
- Aggregate results (Sonnet): `docs/spike/results/aggregate-v2.md`
- Post-review notes: `docs/spike/results/aggregate-v2-review-notes.md`
