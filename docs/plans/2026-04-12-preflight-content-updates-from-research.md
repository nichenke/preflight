---
status: proposal
date: 2026-04-12
owner: nic
type: plan
---

# Proposed preflight content updates — from workflow research arc

## Context

The 5-pass research arc on workflow integration produced methodology that could feed back into preflight's own content. This doc proposes specific additions to `content/` (reference material, templates, rules) that would let future preflight users reuse the methodology instead of rediscovering it.

**This is a proposal, not an implementation.** None of the items below have been added to preflight yet. Each one would need to follow normal governance:
- Behavioral changes require a version bump (CONST-PROC-01)
- Requirements/behavioral changes require an ADR (CONST-PROC-02)
- Content changes are additive and can ship as a minor version bump

Proposals are grouped by directory so nic can cherry-pick what to land.

---

## 1. Proposed additions to `content/reference/`

Reference material is the safest category — it's documentation that projects copy via scaffold, not code that runs. Reference additions don't require behavioral change governance.

### 1.1 `evaluation-methodology.md` — the seven angles pattern

**What**: a reference doc describing the 7-angle multi-pass analysis pattern (FirstPrinciples, IterativeDepth, Council, RedTeam, rate-of-change, buy-vs-build, backward-walking, criteria-first re-scoring) and when to use each.

**Why**: preflight users facing non-trivial decisions (which framework to adopt, whether to refactor, whether to change scope) need a reusable analytical pattern. Without a reference, each decision reinvents the method. The 7-angle pattern was validated by this arc and is portable.

**Source material**: `docs/analysis/2026-04-12-meta-evaluation-methodology.md` in this worktree. Would be distilled and generalized (strip preflight-specific examples, keep the pattern).

**Scaffold impact**: copied into target projects as `.preflight/_reference/evaluation-methodology.md`. Projects can reference it from their own ADRs and RFCs when choosing among alternatives.

**Risk**: low. It's a reference doc. Worst case it sits unused.

**Recommendation**: **ship it.** Highest-leverage reference doc we can add right now.

### 1.2 `rate-of-change-awareness.md` — obsolescence risk for fast-moving spaces

**What**: a reference doc describing how to assess obsolescence risk when picking tools, features, or formats in a fast-moving space. Includes the five-question decision framework ("does it address an original criterion / is it a commodity / will it obsolete in 6 months / does it create daily habits / can it ship in <1 week").

**Why**: preflight is positioned for spec-driven development, which is currently in a fast-moving phase. Projects adopting preflight need explicit guidance on when to rent vs build vs wait. This was the single most load-bearing lesson from pass 5.

**Source material**: §4 and §5 of the meta-report. Plus the rate-of-change research data from pass 5 as appendix (version numbers, ship dates, release cadence of the frameworks we track).

**Scaffold impact**: copied as `.preflight/_reference/rate-of-change-awareness.md`. Referenced from ADR guidance when choosing among alternatives.

**Risk**: medium. The data appendix will age — frameworks named today may be dead in 18 months, new ones will appear. Mitigation: version the doc, timestamp the data, and note the 60-day refresh cadence as part of the methodology.

**Recommendation**: **ship the principles, skip the data snapshot**. Include the framework for assessing obsolescence, but keep the specific framework comparisons in `docs/analysis/` rather than calcifying them into `content/`.

### 1.3 `short-horizon-planning.md` — governance for 6-month-max plans

**What**: a reference doc describing the "60-day tripwire" governance model. Explains why annual planning fails in fast-moving spaces, how to size plans to 4-6 week delivery windows, and how to structure "stop and re-evaluate" checkpoints.

**Why**: traditional engineering guidance assumes multi-quarter roadmaps. In spaces where the underlying tooling ships breaking releases weekly, that guidance is actively harmful. Preflight users need explicit permission to plan short.

**Source material**: §5.3 of the meta-report. Also the "cost of being wrong" asymmetry from pass 5 (30 days lost if you're too conservative is recoverable; 45 days lost to building the wrong thing is not).

**Scaffold impact**: copied as `.preflight/_reference/short-horizon-planning.md`. Referenced from RFC guidance about rollout horizons.

**Risk**: low. Principles-based, not data-based.

**Recommendation**: **ship it, but merge with `adoption-order.md` if that doc exists and addresses related topics**. Don't create two reference docs saying adjacent things.

### 1.4 Update to `adoption-order.md`

**What**: if preflight already has `content/reference/adoption-order.md`, add a section on "when to shrink a roadmap" that points at the 60-day tripwire pattern.

**Why**: consistency. Adoption order advice and roadmap sizing are related.

**Risk**: low. Additive update.

**Recommendation**: **defer until the other reference docs ship**, then update in a single pass.

---

## 2. Proposed additions to `content/templates/`

Template additions require more careful governance because they become project-copied artifacts. Each new template is a commitment to maintain.

### 2.1 `analysis-template.md` — multi-pass decision analysis doc type

**What**: a new doc type template for multi-pass decision analyses (like this research arc). Sections: original brief, criteria enumeration, pass-by-pass summaries, criteria-first re-scoring table, final recommendation with confidence.

**Why**: the five-pass structure of this arc was ad-hoc. Future non-trivial decisions would benefit from a repeatable template. Having a template makes "run a proper analysis" a one-command thing instead of a ~5-day workflow.

**Risk**: medium. New templates add governance surface area. Also: the pass structure might become obsolete if better analytical patterns emerge (see rate-of-change concerns from pass 5).

**Recommendation**: **wait until we've run 2-3 more multi-pass analyses and see if the pattern holds**. Creating a template after one instance is premature. If the next analysis reuses the same shape, the template is justified. If it doesn't, we'd have committed too early.

### 2.2 Do NOT add: task-plan template, operations-envelope template, data-model template, threat-model template

These were proposed across passes 2-4 but explicitly deferred by pass 5 and the re-analysis. They should stay deferred until nic hits a friction that one of them would have fixed. This proposal does not revive them.

---

## 3. Proposed additions to `content/rules-source/`

Rule additions are the highest-governance category. Every new rule runs against every document and affects every review.

### 3.1 Do NOT add: 25-category L4 taxonomy as enforcement rules

This was considered and explicitly rejected by pass 5 for good reasons:
- The taxonomy is an opinionated snapshot likely to be replaced by benchmark-derived or model-derived category lists within 6 months
- Committing it to `_rules/` would calcify it and make updates require ADRs
- Its value is as reference material, not as enforcement

**Stay**: `docs/reference/l4-autonomy-category-framework.md` (the 764-line research reference) remains in `docs/reference/`, not `content/rules-source/`. It's research output, not product content.

### 3.2 Possible future addition: `analysis-rules.md`

If the `analysis-template.md` doc type ships later, it would need rules:
- Must cite the original brief criteria
- Must show criteria-first re-scoring when passes disagree
- Must include explicit confidence level on final recommendation
- Must include "what would flip the recommendation" section

**Recommendation**: **defer until the template ships**. Rules without a template are abstractions.

---

## 4. Proposed additions to `content/scaffolds/`

### 4.1 Do NOT add new scaffolds

The scaffold skill copies starter files into new projects. No scaffold additions are justified by this research. The existing scaffold for `constitution-skeleton.md` and `glossary-skeleton.md` covers what's needed.

---

## 5. Summary — what to actually land

If nic wanted to act on this proposal with minimum risk, here's the ship list:

### Ship now (~2 hours total work, additive, low risk)

1. `content/reference/evaluation-methodology.md` — the 7-angle pattern, distilled from the meta-report. Principles only, no preflight-specific examples.
2. `content/reference/rate-of-change-awareness.md` — the 5-question decision framework plus the "cost of being wrong" asymmetry. No data snapshots.
3. `content/reference/short-horizon-planning.md` — the 60-day tripwire governance model. Principles only.

These three are pure reference material. They don't affect any existing rule, template, or skill. They ship as a minor version bump (v0.7.0 → v0.8.0) with no ADR required because they add reference, not behavior.

### Defer until proven

4. `analysis-template.md` — wait for 2-3 more multi-pass analyses to confirm the pattern.
5. `analysis-rules.md` — depends on template.
6. 25-category L4 framework as rules — not recommended, keep as reference.

### Do not add

7. Any new workflow surface area (skills, hooks, scaffolds) — the workflow decision is tracked separately in the pass 5 re-analysis plan and should ship as code (skills in `skills/`), not as content.

---

## 6. The important distinction

There's a clean line between:
- **Content that captures methodology** (reference docs, templates, rules) — goes in `content/`, gets copied into target projects
- **Code that implements behavior** (skills, hooks, reviewers) — goes in `skills/`, `agents/`, etc., runs at plugin invocation time

The research arc produced both. The meta-report and evaluation methodology go in `content/reference/`. The `/preflight explore` and `/preflight propose` skills go in `skills/`. They're on different governance paths and should not be bundled in a single commit.

This proposal covers only the `content/` side. The `skills/` side is covered by the pass 5 re-analysis recommendation (4-item minimum plan).

---

## 7. Recommendation

**Ship items 1-3 from §5 (the three reference docs) as a minor version bump.** Skip everything else on this proposal for now.

The reference docs are:
- Additive (no existing content changes)
- Low risk (principles, not calcified data)
- High leverage (reusable on every future non-trivial decision)
- Fast (~2 hours of work to distill from the meta-report)

They encode the methodology without committing preflight to specific positions on frameworks, tools, or taxonomies that might shift in 6 months. That's the right tradeoff.

Any of the deferred items can revisit on the 60-day tripwire alongside the workflow skills and drift infrastructure.
