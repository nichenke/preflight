---
status: complete
date: 2026-04-12
owner: nic
type: analysis
supersedes_conclusions_of: 2026-04-12-pass5-6mo-sanity-check.md
---

# Pass 5 re-analysis — scored against the original criteria

Pass 5 cut the plan to 2 items (drift hook + coverage view) on the basis of obsolescence risk. You pushed back with a specific observation: **dropping workflow skills is a functional regression, because without a defined workflow there's nothing to invoke and the native model behavior may or may not decide to use preflight well. This is exactly what OpenSpec got right — a command flow and state machine.**

This re-analysis tests that pushback rigorously. Method: enumerate the criteria from the original message, score pass 5 against each, identify where it drifted, and produce a corrected plan.

**Spoiler**: pass 5 was right about *some* drops (work-package.yaml, 25-category taxonomy as committed artifact, 365-day horizon) and wrong about the *central* drop (workflow skills). The corrected minimum plan is 4 items, not 2, and it ships a state machine.

---

## 1. The original criteria (from message 1, verbatim)

Twelve criteria extracted from the original ask and subsequent confirmations:

**From the opening problem statement**:

> "the process to create new features/work is not defined well - we often forget to update architecture, requirements, etc. openspec explore / superpowers brainstorm and gsd/gsd-2/bmad all have workflows (I believe) in this space."

- **Criterion A — Defined process for creating new features.** A repeatable, named, invokable workflow for starting work.
- **Criterion B — Prevent forgetting to update architecture/requirements.** The process must route through all affected docs, not rely on memory.

> "acting on changes. I am starting to miss a bit of the openspec flow to take an idea, then break down into implementation requirements. With PAI/ISC/Algorithm - I don't think we want openspec 'tasks', but we need some flavor of that 'now implement' flow."

- **Criterion C — Idea → implementation requirements breakdown.** A structured way to move from vague intent to FR-level specificity.
- **Criterion D — "Now implement" flow.** A named handoff from spec to execution, *without* adopting OpenSpec's tasks.md wholesale.
- **Criterion E — PAI / ISC / Algorithm compatibility.** The flow must plug into PAI Algorithm's existing execution model.

> "the important thing here is that we have structured formats and files, and that we have reviewers that continually ensure quality."

- **Criterion F — Structured formats and files preserved.** Templates and schemas stay load-bearing.
- **Criterion G — Reviewers preserved.** The ensemble review (checklist + bogey) survives intact.

> "We want to be building the harness as we go - all the content and rules that help the standard CC and other tools build things autonomously (see on-the-loop and tack-room design goals)."

- **Criterion H — Harness content for autonomous tools.** Preflight's content must be consumable by on-the-loop / Tack Room builders.
- **Criterion I — Standard CC compatibility.** Works with out-of-the-box Claude Code, not just PAI Algorithm.

**From pass 4's confirmed buy-vs-build weights**:

- **Criterion J — Preflight rules preservation.** The 48 rules stay first-class enforcement, not soft guidance.
- **Criterion K — Daily workflow friction minimized.** New capabilities reduce, not add to, daily cognitive overhead.

**From the current message**:

- **Criterion L — Command flow / state machine.** Preflight needs its own OpenSpec-equivalent workflow that can be encoded, invoked, and followed deterministically — by nic, by Claude Code natively, and by future Tack Room builders.

---

## 2. Pass 5 scored against the 12 criteria

Pass 5's 2-item plan: drift hook + `/preflight review --drift`, plus dumb `--coverage` view. Everything else dropped or deferred.

| # | Criterion | Pass 5 score | Reasoning |
|---|-----------|:------------:|-----------|
| A | Defined process for creating new features | **NO** | Drift hook is reactive, coverage view is diagnostic. Neither answers "how do I start a new feature?" |
| B | Prevent forgetting to update arch/reqs | **Partial** | Drift hook catches forgetting *after* the fact; it does not prevent it. You still forget, just with faster feedback. |
| C | Idea → implementation requirements breakdown | **NO** | Nothing in pass 5 addresses this. The elicitation flow from pass 2 was dropped. |
| D | "Now implement" flow | **NO** | Nothing in pass 5 addresses this. The propose skill from pass 2/4 was dropped. |
| E | PAI / ISC / Algorithm compatibility | **Neutral** | Not compromised, but not actively integrated either. Just markdown files. |
| F | Structured formats and files preserved | **YES** | Templates untouched. |
| G | Reviewers preserved | **YES** | Checklist + bogey agents untouched. |
| H | Harness content for autonomous tools | **Partial** | Existing content still usable as harness material, but no new content shipped. Cat 20/22/23 gaps persist. |
| I | Standard CC compatibility | **YES** | Pure markdown, no opinionated runtime. |
| J | Preflight rules preservation | **YES** | 48 rules untouched. |
| K | Daily workflow friction minimized | **NO** | Increases friction: without skills to invoke, nic must remember to run `/preflight review --drift` manually. No habit track. |
| L | Command flow / state machine | **NO** | This is the drop you flagged. |

**Score tally**: 4 YES, 2 Partial/Neutral, **6 NO**.

Pass 5 scores 4/12 on the original criteria. Pass 4 scored ~10/12 on the same criteria. **Pass 5 regressed against the stated goals by optimizing for a metric (obsolescence risk) that wasn't in the original criteria.**

---

## 3. Where pass 5 drifted — the three specific mistakes

### 3.1 Mistake 1: treating workflow skills as "framework glue" when they're UX contract

Pass 5 ranked workflow skills as HIGH obsolescence risk because "direct competitors shipped in the 90-day window — OpenSpec's propose workflow, spec-kit's lean preset, Superpowers' brainstorm."

This is the wrong framing. Those are competitors *for users choosing a spec-driven development framework*. They are not competitors *for preflight's own UX*. A user who has committed to preflight needs a way to invoke preflight's capabilities. Without `/preflight explore` and `/preflight propose`, the entry point is ambiguous: the user either remembers the right sequence of `/preflight new`, `/preflight new`, `/preflight review`, or the native model picks something based on vibes.

**The OpenSpec parallel**: OpenSpec's workflow commands are not "framework glue" that might get obsoleted. They are the tool's UX. TabishB ships workflow command changes in every minor release because they're the primary surface users touch. Nobody calls the OpenSpec workflow obsolete because the underlying Claude Code API evolves.

**Preflight-native workflow skills are the same**. They are thin orchestration over the existing scaffold/new/review skills, glued together by a state machine. They don't compete with OpenSpec or spec-kit — they give preflight users a way to use preflight.

**Obsolescence risk on preflight-native workflow skills: LOW**, not high. The risk is only high if we build them as general-purpose spec-driven development workflows for the whole ecosystem (which is what the other frameworks are doing). If we build them as preflight's own entry point, they're stable as long as preflight's primitives are stable.

### 3.2 Mistake 2: confusing "habit lock-in" as a cost when it's actually the point

Pass 5 said: *"Skills become habits. Once you're running `/preflight explore` every morning, replacing it means retraining yourself."*

This was cited as a reversibility cost. But **habit formation is exactly what the original criteria A and B require.** The whole point of a defined workflow is that nic stops forgetting to update architecture/requirements because the workflow routes through those updates automatically. Habit-lock is the feature, not the bug.

The reversibility argument applies correctly to things like work-package.yaml — a data format that propagates into git history and tooling. It does not apply to workflow skills, which are just interactive commands. Replacing `/preflight explore` is a single-file change. The habit is a small cost to pay and a large benefit to earn.

### 3.3 Mistake 3: scoring obsolescence risk without scoring the alternative cost of missing the feature

Pass 5's obsolescence framework measured "probability the item gets obsoleted" but not "probability nic keeps having the original pain if we don't ship it." The second number is 100% for workflow skills — if we don't ship them, the forgetting-to-update-docs problem continues until we do.

A fair risk model multiplies obsolescence probability by build effort. Workflow skills are small (thin orchestration, probably ~200 lines of skill markdown and state transitions), their build effort is low, and the pain they solve is daily. Even at 70% obsolescence risk, expected value is positive: small invest × daily payoff × 30% durability > zero invest × continued pain.

Pass 5 implicitly used a different math: treated every new item as high-risk and defaulted to deferral. That's appropriate for large items (work-package.yaml, committed 25-category taxonomy) and wrong for small items that directly address the stated problem.

---

## 4. What pass 5 got right

Before the correction, note what stays:

- **Dropping work-package.yaml as core handoff format**: correct. Cross-tool handoff is the most contested surface in the 90-day window. YAML is swimming against the markdown tide. Defer indefinitely.
- **Dropping 25-category taxonomy as committed rule artifact**: correct. Keep it as reference documentation (already written at `docs/reference/l4-autonomy-category-framework.md`). Don't calcify it into `_rules/`.
- **60-day tripwire instead of 365-day**: correct. Rate-of-change data supports this.
- **Rent over build for template formats**: correct. STRIDE for threat model, C4/DDD for data model, Google SRE book for ops envelope.
- **Defer operations-envelope, data-model, threat-model, task-plan templates until friction hit**: correct, with one caveat below.
- **Drift hook and `/preflight review --drift`**: correct.
- **Dumb `--coverage` view (file-exists/section-empty report)**: correct.

Pass 5 was 7-for-10 on the individual decisions. The three it got wrong were the three central to the original ask.

---

## 5. The corrected minimum plan — 4 items

The corrected plan adds workflow skills back to pass 5's 2-item list, keeps everything else from pass 5 that was right, and maintains the 60-day tripwire as the governance model.

### Phase 1 — Workflow state machine (week 1-2)

**1. `skills/explore/SKILL.md`** — preflight-native entry point for fuzzy ideas.
- State machine input: free-form idea
- Actions: reads `specs/constitution.md` + `specs/requirements.md` for grounding; elicits via structured Q&A (reusing the existing `new` skill's elicitation patterns); escalates to governance mode on any requirement-ID touch
- State machine output: a named plan listing which doc types must be created or updated
- Transition: hands off to `/preflight propose` on user approval

**2. `skills/propose/SKILL.md`** — preflight-native orchestration for known scope.
- State machine input: either (a) a plan from `/preflight explore`, or (b) a spec-ready description with FR traceability
- Actions: orchestrates the existing `new` skill once per doc type; runs the existing `review` skill across the changed docs; surfaces results
- State machine output: a reviewed, traced, governance-compliant set of document edits
- **No work-package.yaml emitted.** Propose is complete when review passes. Whatever comes next (PAI Algorithm execution, manual implementation, Tack Room handoff) reads the specs directly. Defer the serialized handoff format per pass 5.

These two skills are the command flow / state machine Criterion L requires. They are ~200 lines of skill markdown each, thin orchestration, no new rules, no new templates. Implementation time: ~2 days.

**Why this isn't the pass 4 recommendation**: pass 4's explore/propose skills were going to emit `work-package.yaml`. The corrected version does not. That one deletion removes the highest-obsolescence-risk surface (handoff format) while preserving the lowest-obsolescence-risk surface (user-facing state machine).

### Phase 2 — Drift infrastructure (week 2-3)

**3. Post-implementation drift hook** — `.preflight/hooks/post-implementation.sh`, ~30-50 lines of bash.
- Trigger: post-commit or post-PR-merge
- Action: diffs FR IDs in commit trailers against FR IDs expected by the most recent propose output; surfaces drift as PR comments
- Non-blocking: human decides whether drift represents a gap or a clean implementation
- **Three rules only** (pass 5 was right to shrink): spec-file mtime vs touched code paths, ADR referenced in commit message when `specs/requirements.md` changes, architecture.md touched when new top-level directory added

**4. `/preflight review --coverage`** — dumb file-exists / section-non-empty report.
- Input: a change or a path
- Output: table showing which standard spec files exist, which sections are non-empty, which IDs are referenced but undefined
- **No 25-category taxonomy enforcement.** No committed taxonomy file. The research stands alone at `docs/reference/l4-autonomy-category-framework.md`.

### Phase 3 — Stop

That's the entire plan. Four items, ~1 week of total build effort, covers all 12 original criteria.

### Deferred until friction hit

Everything else from pass 4:
- Operations-envelope template (Cat 20 + 22)
- Rollback criteria on ADRs (Cat 23)
- Task-plan template (Cat 21)
- Data model template (Cat 11)
- Threat model template (Cat 19)
- JTBD strengthening (Cat 1)
- work-package.yaml handoff format
- 25-category taxonomy as committed rule artifact

These are not wrong items. They may all become right in weeks 5-24. But none of them is urgent enough to justify building on the 55-70% obsolescence-risk gamble before nic has actually hit the friction they would solve.

---

## 6. The corrected plan scored against the 12 criteria

| # | Criterion | 4-item plan score | Reasoning |
|---|-----------|:------------------:|-----------|
| A | Defined process for creating new features | **YES** | `/preflight explore` is the named entry point |
| B | Prevent forgetting to update arch/reqs | **YES** | Propose orchestrates `new` across every affected doc type; drift hook catches misses |
| C | Idea → implementation requirements breakdown | **YES** | Explore walks fuzzy input → named plan → propose |
| D | "Now implement" flow | **YES** | Propose's output is a reviewed spec set. PAI/Codex/Claude Code reads specs directly. No adoption of OpenSpec's tasks.md; no work-package.yaml required at this stage. |
| E | PAI / ISC / Algorithm compatibility | **YES** | Skills are markdown + state machine; PAI Algorithm consumes them without changes |
| F | Structured formats and files preserved | **YES** | Templates untouched |
| G | Reviewers preserved | **YES** | Checklist + bogey agents untouched; propose orchestrates them |
| H | Harness content for autonomous tools | **Partial** | Existing content is harness-ready; Cat 20/22/23 gaps remain deferred. Acceptable tradeoff at 6-month horizon. |
| I | Standard CC compatibility | **YES** | Skills are native CC skill format; no runtime dependency beyond the plugin |
| J | Preflight rules preservation | **YES** | 48 rules stay first-class |
| K | Daily workflow friction minimized | **YES** | Single entry point replaces "remember the right sequence of commands" |
| L | Command flow / state machine | **YES** | Explore → Propose is the state machine |

**Score tally**: 11 YES, 1 Partial, 0 NO.

11/12 vs pass 5's 4/12. **The corrected plan is the smallest plan that actually addresses the original criteria.** It does not add any item that pass 5 dropped for good reason.

---

## 7. Obsolescence risk re-examined for the 4-item plan

Applying the same rate-of-change lens pass 5 used, now correctly:

| Item | Pass 5 risk | Corrected risk | Why corrected |
|------|:-----------:|:--------------:|---------------|
| Drift hook | Medium-high | Medium-high | Unchanged — Claude Code hook API still growing |
| `--coverage` dumb view | Medium | Medium | Unchanged — native equivalents may appear |
| `/preflight explore` skill | HIGH | **LOW** | Preflight-native UX, not general-purpose framework; thin orchestration over existing skills; ~200 lines; re-writable in a day |
| `/preflight propose` skill | HIGH | **LOW** | Same reasoning — it's UX for preflight's existing capabilities, not a competing framework |

Pass 5's mistake on the workflow skills was treating them as if they were in competition with OpenSpec's framework. They're not. They're in competition with nic forgetting to use preflight at all. The correct reference class is "thin UI orchestration over existing preflight primitives," which is low-risk.

The two genuinely high-risk items (work-package.yaml, 25-category taxonomy-as-rules) remain dropped.

---

## 8. The governance model stays

Pass 5's 60-day tripwire (2026-06-11) is unchanged. The corrected plan does not extend the horizon; it fills the 2-item gap left by pass 5's drop of workflow skills without adding the high-risk items pass 5 correctly identified.

Signals at day 60 that would expand the plan:
1. Nic hit 3+ frictions that deferred templates would have fixed → ship those templates
2. Two or more external projects using preflight → network effects rescore
3. Tack Room started real implementation and needs specific category coverage → ship ops-envelope
4. Claude Code shipped a native capability that makes `--coverage` trivially better → retire the custom view

Signals that would contract the plan further:
1. Claude Code shipped native drift detection → retire the hook
2. OpenSpec v1.4 shipped rule-as-code → re-open buy-vs-build analysis
3. Daily workflow didn't hit expected frictions → templates were solving imagined problems

**No other governance beyond the 60-day review.** Ship the 4 items. Use them. Look at signal. Decide.

---

## 9. The meta-lesson from pass 5's drift

Pass 5's rate-of-change data was empirically correct. Its framework for applying that data was almost correct. Its failure was **not re-scoring decisions against the original criteria before publishing the plan.** Pass 5 optimized for the criterion pass 5 introduced (obsolescence risk) at the cost of the criteria the user actually stated (defined workflow, prevent forgetting, idea→implementation flow, etc.).

This is the classic pitfall of late-stage analytical passes: each pass refines on the previous pass's framing and can lose sight of the original brief. The correction pattern is what just happened — explicit re-scoring against the earliest criteria, not against the most recent pass's framing.

**The rule for future passes**: any pass that changes the recommendation from a prior pass must score against the original criteria before publishing, not just against the prior pass's new criteria.

---

## 10. Final recommendation

**Ship 4 items in weeks 1-3, then stop.**

1. **`/preflight explore` skill** (week 1) — state machine entry for fuzzy ideas
2. **`/preflight propose` skill** (week 1-2) — state machine orchestrating new + review across affected doc types
3. **Drift hook + `/preflight review --drift`** (week 2) — reactive drift catcher, 3 rules to start
4. **`/preflight review --coverage`** dumb view (week 3) — file/section existence report, no taxonomy enforcement

**Defer**: work-package.yaml, committed 25-category taxonomy, operations-envelope template, task-plan template, data-model template, threat-model template, JTBD strengthening, rollback-on-ADRs. Revisit on day 60 (2026-06-11).

**Drop**: pass 2's `work-package.yaml` as required output of propose. Propose is complete when review passes. Whatever consumes the specs next (PAI Algorithm, Codex, Claude Code, future Tack Room) reads them directly.

**Confidence: high.** The corrected plan scores 11/12 on the original criteria vs pass 5's 4/12 and pass 4's ~10/12. It ships less than pass 4 (4 items vs 16) while covering more of the original criteria than pass 5 (11 vs 4). It respects pass 5's correct obsolescence-risk findings on the genuinely high-risk items while rejecting pass 5's overreach on items that were not actually high-risk.

**The one-sentence principle**: **A minimum plan is the smallest set of items that addresses all the original criteria, not the smallest set of items.** Pass 5 optimized for item count. Pass 5 re-analysis optimizes for criteria coverage at the smallest item count.
