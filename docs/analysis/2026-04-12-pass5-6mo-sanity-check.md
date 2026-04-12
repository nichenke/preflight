---
status: complete
date: 2026-04-12
owner: nic
type: analysis
supersedes_conclusions_of: 2026-04-12-pass4-build-vs-customize.md
---

# Pass 5 — 6-month sanity check

Pass 4 framed the decision as *"build the substrate you'll own for a decade vs duct-tape two tools for the next quarter"* and chose Path A (build on preflight) with a 5-phase plan over 45 days plus a 365-day tripwire.

The user pushed back: **6 months is the farthest horizon worth planning for. The space is moving too fast. Don't over-select for "own it for decades" mindset.**

Pass 5 tests that pushback empirically and analytically. Two streams: a hard-numbers rate-of-change survey, and a strict 6-month re-examination of pass 4's phases. Both converge on the same answer: **pass 4 over-built.** The recommendation collapses to roughly 2 items, not 16.

---

## 1. The rate-of-change evidence

Web research on the last 90 days (2026-01-12 to 2026-04-12) of the agentic coding space produced concrete version numbers, ship dates, and breaking changes across every framework preflight overlaps with.

### 1.1 What shipped in 90 days

| Date | Item | Impact |
|------|------|--------|
| 2026-01-15 | Superpowers admitted to Anthropic marketplace | Legitimizes subagent-driven dev + two-stage review |
| 2026-01-26 | **OpenSpec v1.0.0** | **Breaking**: removed `/openspec:proposal\|apply\|archive`, action-based workflow |
| 2026-01-29 | METR Time Horizon 1.1 (228 tasks, Inspect infra) | Tighter CIs, re-estimates 14 models |
| 2026-02-02 | Google Conductor (Gemini CLI, markdown-as-knowledge) | Markdown-spec substrate goes multi-vendor |
| 2026-02-05 | **Claude Opus 4.6** | 1M ctx, 128k output |
| 2026-02-17 | **Claude Sonnet 4.6** | Same price as 4.5 |
| 2026-02-19 | **Gemini 3.1 Pro** | 2× reasoning over 3 Pro, ARC-AGI-2 77.1% |
| 2026-02-23 | OpenSpec v1.2.0 | Profiles, propose workflow, Kiro/Pi support |
| 2026-Feb | **BMAD v6.0.0 stable** (after 23 alphas + 8 betas) | `.bmad` → `_bmad` directory migration |
| 2026-03-01 | Claude `advisor-tool` public beta | New orchestration primitive |
| 2026-03-05 | **GPT-5.4** | Merges 5.3-Codex coding with broader reasoning |
| 2026-Mar | SlopCodeBench paper (arXiv 2603.24755) | Erosion in 80% of trajectories |
| 2026-03-23 | spec-kit v0.4.0 | Embedded core pack, offline support |
| 2026-03-24 | Claude Message Batches 300k output beta | Single-turn outputs 10× |
| 2026-Mar | Claude Code hooks: `defer` decision + `PermissionDenied` | Hook API still expanding |
| **2026-04-02** | **spec-kit v0.4.5 — Claude Code as native skills** | Migration off legacy scaffold |
| **2026-04-10** | **BMAD v6.3.0** | **4 breaking changes**, 4 agents merged into "Amelia" |
| 2026-04-10 | METR adds GPT-5.4 to time horizons | Frontier keeps moving monthly |
| 2026-04-11 | OpenSpec v1.3.0 | 4 new tool integrations |

That's **3 frontier models, 2 framework major versions, 4 breaking releases, and 2 new research benchmarks** in 90 days. SWE-bench Verified top score moved from ~65% (early 2025) to ~81% (March 2026) to "Claude Mythos Preview" reportedly at 93.9% (April 2026).

### 1.2 What's stable vs moving

**Stable for ~6 months:**
- **Markdown-as-spec substrate.** Every framework (OpenSpec, spec-kit, BMAD, Superpowers, CLAUDE.md/AGENTS.md, Cursor `.cursor/rules/`, Google Conductor) is converging *on* markdown, not away from it. GitHub published an explicit "markdown as a programming language" post.
- **Fresh-context-per-task / subagent isolation.** Chroma's context-rot research remains the dominant framing. Claude Code's JIT retrieval and Superpowers' subagent dispatch are doubling down, not retreating.
- **Two-stage (spec-compliance then code-quality) subagent review.** Referenced as the current Superpowers pattern in April 2026.
- **~60-70% context-fill compaction guidance.** Still the field-reported threshold. Anthropic made it user-configurable via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` — validating, not replacing.
- **SWE-bench Verified as headline benchmark** (even while being criticized as contaminated).

**Moving fast:**
- **Plugin/Skills/Hooks API surface.** New hook decisions (`defer`), new `--bare` flag, `--channels`, `advisor-tool` beta, 500k MCP size limit, 300k output beta — all within one 90-day window.
- **Framework internals.** OpenSpec shipped v1.0 breaking changes, BMAD did a full v5→v6 migration *and* then v6.0→v6.3 with 4 more breaking changes, spec-kit migrated its entire scaffold to Claude Code native skills.
- **Frontier model capability.** Opus 4.6, Sonnet 4.6, Haiku 4.5, GPT-5.3-Codex, GPT-5.4, Gemini 3.1 Pro — all in 90 days.
- **Orchestration patterns.** "Agent teams" (cross-session git-coordinated) is a new primitive alongside subagents.
- **Benchmarks themselves.** FeatureBench and SlopCodeBench exposed that strong SWE-bench scores collapse to 11% on end-to-end features — expect methodology churn.

### 1.3 The honest probability estimate

**Probability that significant chunks of a spec-driven dev tool built in April 2026 get materially obsoleted by October 2026: 55-70%.**

Evidence: within the last 90 days alone, every major peer framework shipped breaking changes, Claude Code's hook and plugin API added new decision types, three new frontier models landed that each shift what "minimum viable scaffolding" looks like, and SlopCodeBench demonstrated that the problem spec-driven tools are solving is still an open research question.

**Where the thesis is durable**: the substrate choice (markdown files), the core loops (fresh context per subtask, two-stage review, ~60% compaction), and the spec-before-code philosophy are all reinforced, not threatened, by the last 90 days. A tool whose value lives in *methodology and content* is relatively safe. A tool whose value lives in *API integration, framework glue, or scaffold mechanics* is much more exposed.

---

## 2. Obsolescence risk per pass 4 item

Mapping the rate-of-change evidence onto pass 4's concrete roadmap:

| Item (from pass 4) | Risk | Reason |
|--------------------|------|--------|
| 25-category taxonomy as committed artifact | **Low** | Taxonomies are content; content survives framework churn |
| Operations-envelope template | **Low** | Templates are markdown; maps onto any framework's skill substrate |
| Task decomposition template | **Low** | Templates are portable; decomposition reinforced by METR/SlopCodeBench |
| Data model template (Phase 5) | **Low** | Entity modeling is a decision artifact, not a derivation artifact |
| Threat model template (Phase 5) | **Low** | STRIDE/LINDDUN is 25 years old and stable |
| Coverage view (reports which spec sections exist) | **Medium** | Read-only over filesystem; risk is mainly that spec-kit/OpenSpec offer equivalents natively |
| Drift detection hook (git-level) | **Medium-high** | Git hook API is stable, but Claude Code's own hook surface is still growing — a first-party equivalent could appear |
| Workflow skills (explore/propose) | **HIGH** | Directly competes with OpenSpec's "propose workflow" (Feb 2026), spec-kit's lean preset (v0.6.1 Apr 10), and Superpowers' `/brainstorm` + `/write-plan` — all shipped inside the window |
| Work-package.yaml handoff format | **HIGH** | Cross-tool handoff is the hottest contested surface: BMAD v6.3's marketplace, spec-kit-as-native-skills, and Claude Code agent-teams are all converging here, and YAML is swimming against the markdown tide |

**This directly contradicts pass 4's phase ordering.** Pass 4 put workflow skills in Phase 4 ("Days 31-45") and work-package.yaml in the same phase. These are the two highest-obsolescence-risk items. Meanwhile the lowest-risk items — the taxonomy, templates for ops-envelope, task-plan, data model, threat model — were scattered across Phases 2, 3, and 5.

**The phases are upside down.** Pass 5 corrects this.

---

## 3. The 6-month phase-by-phase re-examination

Independent analysis of each pass 4 phase through a strict 6-month lens. For each phase: value at 6 months, obsolescence risk, reversibility, and a one-word verdict (keep / shrink / defer / drop).

### Phase 1 — Drift loop (pass 4 Days 1-10)

**Value at 6 months**: High. Drift between code and specs is the single failure mode that breaks spec-driven development every day regardless of which model or IDE is in use. A hook that flags "you touched `auth.py` but `specs/architecture.md` hasn't been updated in 40 commits" delivers value on day 1 and every subsequent day.

**Obsolescence risk**: Low for the hook, medium-high if we over-build the rule catalog. Claude Code's hook API is growing but git hooks are stable ground.

**Reversibility**: High. Hook + review mode + rule files. `git revert` erases cleanly. No schema, no persisted state, no user-authored artifacts that get orphaned.

**Verdict**: **KEEP, but shrink.** Ship the hook + `--drift` flag. Defer the full drift rule catalog — start with 3-5 rules, not 20.

### Phase 2 — Completeness contract (pass 4 Days 11-18)

**Value at 6 months**: Medium. The L4 category taxonomy is genuinely useful for answering "what am I missing." The `--coverage` view is valuable. But the specific 25-category taxonomy is an opinionated artifact that might not match where the ecosystem lands.

**Obsolescence risk**: Medium-high for the committed taxonomy file, low for a dumb coverage view. Taxonomies are exactly the kind of thing that gets replaced by benchmark-derived or model-derived category lists in the next 6 months. A research paper or OpenSpec release will publish something better.

**Reversibility**: Medium. A taxonomy file is easy to delete, but if reviews start citing category IDs in findings, those citations propagate into user docs and become sticky.

**Verdict**: **SHRINK.** Ship `--coverage` as a dumb "which standard spec files exist, which sections are non-empty" view. **Do NOT ship the 25-category taxonomy as a committed artifact.** Keep it as internal reference material only (which we just wrote as `docs/reference/l4-autonomy-category-framework.md`). The research stands alone; committing it to preflight's `_rules/` calcifies it.

### Phase 3 — Operations envelope (pass 4 Days 19-30)

**Value at 6 months**: High for nic specifically, lower as a default for other users. Operational concerns don't get obsoleted by better models — they get *more* important as agents ship more code.

**Obsolescence risk**: Low. Ops templates are markdown; they map onto any framework's skill substrate.

**Reversibility**: Low-medium. Once `ops-envelope.md` is a template, it shows up in every new project and becomes load-bearing. Removing it later means breaking existing projects.

**Verdict**: **KEEP as optional template, not a default.** Add it to `content/templates/` and let scaffold offer it. Don't force it into every project.

### Phase 4 — Workflow skills (pass 4 Days 31-45)

**Value at 6 months**: **Low**. Explore/propose skills are workflow wrappers over capabilities nic already has with plain Claude Code. work-package.yaml is the highest-obsolescence-risk item in the entire plan — it's a context-marshalling format, and context marshalling is exactly what model providers are racing to make unnecessary.

**Obsolescence risk**: **HIGH**. Native context handling, memory features, and sub-agent infrastructure are all moving monthly. Direct competitors (OpenSpec's propose workflow, spec-kit's lean preset, Superpowers' `/brainstorm` + `/write-plan`) all shipped in the last 90 days. Anything built here is very likely to be redundant by October.

**Reversibility**: Low. Skills become habits. Once nic is running `/preflight explore` every morning, replacing it means retraining.

**Verdict**: **DROP.** This is the phase most optimized for "own it for a decade" and least justified at 6 months.

### Phase 5 — Substantive gaps (pass 4 backlog)

**Value at 6 months**: **High** specifically for data model and threat model templates. These are evergreen artifacts — every system needs them, and no model update will obsolete the concept of "write down your entities and your attack surface."

**Obsolescence risk**: Low. Templates for data model and threat model are boring in the best way.

**Reversibility**: High. Just template files.

**Verdict**: **PROMOTE.** Move data-model and threat-model templates *forward* from backlog. They're the lowest-risk, highest-durability items in the whole plan.

---

## 4. The minimum viable 180-day plan

Merging the empirical rate-of-change data with the phase-by-phase re-examination, five items make the cut — ordered by pain-relief per day of effort:

1. **Drift hook + `/preflight review --drift`** (week 1) — three rules only: spec-file mtime vs touched code paths, ADR referenced in commit message when `specs/requirements.md` changes, architecture.md touched when new top-level directory added.
2. **Data-model and threat-model templates** (week 2) — two new template files in `content/templates/`, scaffold offers them, `/preflight new data-model` works. No rules yet — templates alone are valuable.
3. **`--coverage` dumb view** (week 3) — lists which standard spec files exist, which sections are non-empty, which IDs are referenced but undefined. No committed taxonomy. No 25-category framework as enforcement.
4. **Optional ops-envelope template** (week 4) — added to scaffold as opt-in, not a default. One template file, no rules.
5. **Stop there. Reserve months 2-6 for responding to ecosystem changes.**

That's it. **No workflow skills, no taxonomy-as-rules, no work-package.yaml, no explore/propose commands, no 25-category enforcement.**

### 4.1 What's rented vs built

| Item | Decision | Rationale |
|------|----------|-----------|
| Drift hook | **Build** | Git-hook-specific to preflight's layout. Nothing rents cleanly. Keep under 200 lines. |
| Drift rules | **Rent partially** | Borrow patterns from OpenSpec's change validation; write only 3-5 minimal rules. |
| Data-model template | **Rent** | C4 model, DDD aggregates, or OpenSpec's data-model pattern if it exists. Do not invent. |
| Threat-model template | **Rent** | STRIDE or LINDDUN, lightly adapted. 20+ years old and stable. |
| `--coverage` view | **Build** | Trivial. ~100 lines of filesystem traversal and section parsing. |
| Ops-envelope template | **Rent** | Google SRE book has the canonical operational readiness checklist. Adapt it. |
| Task decomposition (Cat 21) | **Rent if shipped** | Pass 4 planned to borrow OpenSpec's task.md. Pass 5 says defer the whole item — don't ship task-plan template yet. |
| 25-category taxonomy as committed artifact | **Neither** | Don't build, don't rent, don't ship. Keep as internal reference material only. |

**Pattern**: build only plumbing (hooks, views) and rent every artifact format (templates, taxonomies, rules). Artifacts are where ecosystem convergence happens; plumbing is where repo specifics matter.

### 4.2 Obsolescence bets

For each kept item, the explicit bet:

- **Drift hook**: In 6 months, spec-code drift will still be a daily pain point because even if models get better at updating specs, commits will still happen without spec updates, and git hooks are still how to catch things at commit time. **Confidence: high.**
- **Data-model template**: In 6 months, writing down "here are the entities and their relationships" is still something humans do before agents generate code, because entity modeling is a *decision* artifact, not a *derivation* artifact. **Confidence: high.**
- **Threat-model template**: STRIDE-style threat modeling has been the standard for 25 years. **Confidence: very high.**
- **`--coverage` view**: "Which spec files are empty" is a question nic will still ask in 6 months regardless of what else changes. **Confidence: high.**
- **Ops-envelope template**: Rollback, observability, and on-call are *organizational* contracts, not technical ones. They don't get obsoleted. **Confidence: high.**

Every bet is on durability of the *concept*, not durability of the *format*. Every artifact in the minimum plan could be rewritten in a weekend if a better standard emerges.

---

## 5. The contrarian "ship nothing" position

A legitimate argument exists for going even further — ship nothing, use preflight as-is for 8 weeks, and decide later.

**The strongest version of the argument**:

1. **Expansion creates surface area.** Every new template, rule, skill, and hook is code to maintain against a shifting substrate (Claude Code, plugin API, skill semantics). Zero new surface area means zero new maintenance tax.
2. **You don't know what's missing until you use what you have.** Preflight has been in production for less than three months. Most "gaps" identified in pass 1-4 are theoretical gaps from comparing against other frameworks, not empirical gaps from hitting walls in actual work.
3. **The ecosystem is in a discovery phase.** OpenSpec, Spec Kit, BMAD, Superpowers, and half a dozen others are each exploring a different point in the design space. In 6 months, one or two will have clearly won on specific axes. Building in April based on April's understanding means rebuilding in October.
4. **Attention is the scarce resource.** Any hour spent on preflight features is an hour not spent on the projects preflight is supposed to serve. At 6 months, the meta-work ROI is bad unless the feature pays back within weeks.

**What would make this wrong**: if nic can name a specific friction point he hit *last week* that would be fixed by one of the proposed items. Drift detection probably passes this test — spec-code drift is a live pain. Data-model templates probably don't — nic hasn't hit a wall from not having one.

**Applied strictly**: the contrarian position cuts the minimum plan from 5 items to 2: **drift hook, and `--coverage` view, and nothing else until a wall is hit.**

This is defensible. It is also maximally reversible. It does not preclude shipping more later.

---

## 6. The revised recommendation

**Ship drift hook and `--coverage` view in weeks 1-2. Then stop and use preflight for 8 weeks without adding anything.** Revisit in mid-June with a list of frictions nic actually hit. If data-model, threat-model, or ops-envelope templates are on that list, ship the one that appears most.

**Drop entirely** (from pass 4):
- Workflow skills (explore/propose)
- work-package.yaml handoff format
- 25-category taxonomy as a committed rule artifact
- Ensemble reviewers as new concept (existing ones are fine)
- 365-day tripwire — **replace with 60-day tripwire**

**Defer** (until friction hit):
- Operations-envelope template
- Task-plan template (Cat 21)
- Data-model template (Cat 11)
- Threat-model template (Cat 19)
- JTBD strengthening (Cat 1)

**Keep** (only two items):
1. Drift hook + `/preflight review --drift` — because spec-code drift is a named live pain
2. `/preflight review --coverage` as dumb file/section-exists view — because "what am I missing" is asked daily

### 6.1 The meta-principle pass 5 corrects

Pass 4 optimized for this assumption: **the cost of not building the right thing dominates the cost of building the wrong thing.**

Pass 5 corrects it: **at a 6-month horizon, the cost of building the wrong thing dominates the cost of not building the right thing, because you can build the right thing in week 20 once you see it, but you cannot unbuild the wrong thing once users depend on it.**

This single reframing flips most of pass 4's output. Pass 4's "build the substrate you'll own for a decade" framing was a mistake for this space at this moment.

### 6.2 The 60-day tripwire

Instead of pass 4's 365-day tripwire, pass 5 recommends a **60-day checkpoint** (2026-06-11) with these specific signals:

**Signals that would expand the plan**:
1. Nic hit 3+ frictions that one of the deferred templates would have fixed
2. Two or more external projects are actively using preflight
3. Tack Room started real implementation and needs specific category coverage
4. Claude Code shipped a native capability that makes `--coverage` or drift detection trivially better

**Signals that would contract the plan further**:
1. Claude Code shipped native drift detection (retire the hook)
2. OpenSpec v1.4 shipped rule-as-code (re-open the buy-vs-build analysis)
3. Nic's daily workflow didn't hit any of the expected frictions (the templates were solving imagined problems)

**The 60-day review is the entire governance model.** No further pre-planning. Ship two things, use them, look at signal, decide.

---

## 7. What this means for Tack Room

Pass 4 framed preflight as Tack Room's L4 substrate and built an entire phase stack to prepare for that future. Pass 5 says: **Tack Room will evolve in parallel, and preflight's role in Tack Room will be determined by what Tack Room actually needs, not by what we guessed Tack Room would need.**

The right relationship is *cooperative*, not *preparatory*:
- Preflight stays good at what it's already good at (23/25 category coverage, enforced rules, ensemble review)
- Tack Room, when it ships, will consume preflight content as harness material if that's the right fit, or design its own contract if something better emerges
- The two systems evolve with a short feedback loop, not a 365-day plan

**This does not retract the pass 3 finding** that preflight's defensible core is a coverage taxonomy with precedence and traceability. That's still true. But the defensible core doesn't need new features to prove it out — it needs *use*, and feedback from that use, and patience.

---

## 8. Confidence and what would flip the recommendation

**Confidence: high** on the core claim that pass 4 over-built.

The rate-of-change evidence is empirical (3 frontier models, 4 breaking framework releases, 2 new research benchmarks in 90 days). The 55-70% obsolescence estimate is grounded in concrete version history, not vibes.

**What would flip the recommendation back toward pass 4's fuller scope**:

1. **Tack Room starts real implementation this week** — if the autonomous builder is imminent, the operations-envelope templates become urgent, not speculative. But pass 5's estimate is that Tack Room is still in design, not implementation.
2. **A clear ecosystem winner emerges** — if by week 4 it's obvious which framework has won on spec-driven development (e.g., spec-kit's native-skills migration becomes the standard), the decision shifts toward interop rather than independence.
3. **SWE-bench Verified score tops 95%** — if frontier models get good enough that underspecification stops being the dominant failure mode, the whole 25-category framework becomes less load-bearing. Current trajectory says this is possible but not confirmed.
4. **Nic discovers that two tools is fine** — if pass 2's dismissal of "two-tool friction" was wrong, the config-customize OpenSpec path (pass 2's B1) re-opens. Worth revisiting if daily workflow shows OpenSpec features that preflight users would benefit from.

**The commitment**: ship the two items in weeks 1-2, review on day 60 (2026-06-11), make the next decision then.

---

## 9. What pass 4 got right and what pass 5 corrects

**Pass 4 got right**:
- Path A (build on preflight) over Path B (customize OpenSpec) — the buy-vs-build scoring still holds
- Rules preservation as decisive criterion
- Preflight rules > OpenSpec's soft-guidance model for L4
- The taxonomy as preflight's defensible core (the *concept*, not necessarily as a committed artifact)
- Drift detection as active infrastructure (before or alongside the builder)

**Pass 5 corrects**:
- **Scope**: 16 items across 5 phases → 2 items, stop, reassess
- **Horizon**: 365-day tripwire → 60-day tripwire
- **Framing**: "substrate for a decade" → "improvements that pay back in weeks"
- **Taxonomy treatment**: committed artifact in `_rules/` → internal reference material only
- **Workflow skills**: Phase 4 priority → dropped entirely
- **work-package.yaml**: core hand-off format → dropped entirely (too contested, too likely to be replaced)
- **Ordering assumption**: "drift before builder because L4 autonomy is dangerous with stale specs" → still right, but the "builder" is hypothetical on a 6-month horizon, so drift is valuable for its own sake, not as builder preparation

**What survives from pass 4**:
- Drift loop concept
- Coverage view concept
- Rejection of Path B1 and B2 (OpenSpec customization paths)

**What changes**:
- Everything else. Pass 4's plan was 90% "prepare for a future that might not arrive." Pass 5 replaces it with 10% "fix the daily pain" and 90% "wait and see."

---

## 10. Final summary

**Pass 5 recommendation in one paragraph**:

Ship the drift hook and `--coverage` view in weeks 1-2, stop, and use preflight for 8 weeks. Reassess on day 60 with a list of actual frictions hit. Drop the explore/propose skills, work-package.yaml, and 25-category taxonomy-as-rules entirely. Defer data-model, threat-model, ops-envelope, and task-plan templates until friction justifies them. Replace pass 4's 365-day tripwire with a 60-day checkpoint. Keep the pass 3 L4 category framework as a standalone reference document — it's valuable research, but not a committed preflight artifact. **Confidence: high.**

### The one-sentence principle

**At a 6-month horizon in a space shipping 3 frontier models and 4 breaking framework releases per quarter, the cost of building the wrong thing dominates the cost of not building the right thing.**

### The cost of being wrong

If pass 5 is wrong and pass 4 was right: we lose 30 days of building foundation work, and ship in mid-May instead of mid-April. Recoverable.

If pass 4 is wrong and pass 5 was right: we lose 45 days building features that get obsoleted by October, plus the maintenance cost of tearing them out, plus the habit-lock from users who started relying on them. Not recoverable.

The asymmetry is real. Ship less, ship later, ship with better information.
