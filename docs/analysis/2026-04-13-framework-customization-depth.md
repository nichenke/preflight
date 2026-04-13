---
status: complete
date: 2026-04-13
owner: nic
type: analysis
supersedes_details_of: 2026-04-12-pass4-build-vs-customize.md §2
---

# Framework customization depth — OpenSpec and spec-kit

Pass 4 concluded that building on preflight (Path A) beat customizing OpenSpec (Path B1) by 76 weighted points, but the dismissal of the customization paths rested on a single criterion — "OpenSpec's rules field is soft AI guidance" — without walking through the full customization surface. This doc does that walkthrough for both OpenSpec and spec-kit, rule-category by rule-category, and identifies two hybrid options pass 4 did not evaluate.

**Bottom line:** Path A still wins, but by a narrower margin than pass 4 computed. spec-kit is the more credible substrate candidate of the two, not OpenSpec. The gap has closed from ~76 weighted points to an estimated ~25–30. The day-60 tripwire should explicitly watch spec-kit's hook semantics — a small upstream change (advisory → blocking hooks) would meaningfully threaten Path A's lead.

---

## 1. Why this doc exists

Three reasons:

1. **Pass 4 under-showed its work on B1.** The claim "OpenSpec customization surface is narrow" was substantially correct at the command and validator layers but ignored a real extension surface (custom schemas) that ships today. The dismissal was right; the argument for it was incomplete.
2. **spec-kit wasn't analyzed at all as a customization target.** Pass 1 scored it as a content reference source, pass 2 walked through its artifact shape, but no pass asked "could preflight be built on spec-kit?" This doc closes that gap.
3. **The day-60 tripwire needs sharper conditions.** Pass 4's "check for OpenSpec rule-as-code in v1.4" was the only named trigger. With spec-kit's extensibility shipping faster, the tripwire should cover both ecosystems and should be framed in terms of *what would change the decision*, not *what we hope ships*.

---

## 2. OpenSpec customization surfaces as of 2026-04-13

### 2.1 The surface map

| Surface | Extensible? | What it holds | What it doesn't |
|---|---|---|---|
| Custom schemas (`openspec/schemas/<name>/`) | **Yes** — YAML + markdown, no TS fork | New artifact types, workflow dependency graph, AI prompt instructions, templates | Content validation rules, cross-doc assertions, severity gradients |
| `config.yaml` `rules:` field | Yes | Free-text strings injected into AI prompts | Any enforcement — literally prompt engineering |
| Per-schema templates | Yes | Per-artifact markdown | Behavior beyond what template text nudges |
| `/opsx:*` command names | No | — | — |
| Validator | No | — | — |
| Pre/post-validate hooks | **No** (none exist) | — | — |
| Plugin registry / user commands | No | — | — |

**Correction from pass 2/pass 4:** custom schemas are a real, documented extension surface. Since v1.0 a user can author a preflight-shaped workflow (doc types, templates, dependency graph) in `openspec/schemas/preflight/` without touching OpenSpec's TypeScript source. Pass 4 implied this required a fork. It does not.

**Correction from pass 5:** OpenSpec's release velocity has slowed. Pass 2 reported 12 releases per 90 days. As of 2026-04-13, OpenSpec has shipped 1 release (v1.3.0) in the past 49 days — the prior release was v1.2.0 on 2026-02-23. The obsolescence argument is weaker than pass 5 credited.

### 2.2 OpenSpec rule-category walkthrough

Preflight has 48 rules across five categories. For each category, we ask: **can a maximally-customized OpenSpec express this rule inside its own surfaces?**

| Category | Example | OpenSpec surface | Verdict | Approx count |
|---|---|---|---|---|
| Structural | "constitution.md must have Version + Categories + Amendments sections" | Custom schema + template structure | **Expressible** | ~8 |
| ID uniqueness and format | "FR IDs are FR-NNN, sequential, never reused" | Schema template nudge only — validator doesn't inspect IDs | **Not enforceable** | ~5 |
| Content-quality with severity | "EARS well-formedness: no 'should', no passive voice, Critical severity" | No rule DSL, no severity system | **Not expressible** | ~15 |
| Cross-doc traceability | "Every FR referenced in an ADR must exist in requirements.md" | Validator is single-artifact; no cross-doc query layer | **Not expressible** | ~12 |
| Governance procedural | CONST-PROC-01 version bump, CONST-PROC-02 ADR-on-requirement-change | Cross-commit invariants; no post-commit or post-PR hook exists | **Not expressible** | ~8 |

**Aggregate**: ~8 of 48 rules could live inside a maximally-customized OpenSpec. The other ~40 — including every deterministic content check, every cross-doc rule, and every procedural governance rule — must live outside in a separate tool.

### 2.3 OpenSpec verdict

The decisive problem is not that OpenSpec is rigid. It is flexible enough at the authoring layer. The problem is that **OpenSpec's lifecycle commands cannot be gated on an external validator**. `openspec validate` → `openspec apply` is a closed loop inside OpenSpec. A hypothetical `preflight-review` running alongside it has no way to block `apply` on a failed review. The user must remember to run both tools in sequence, manually. When they forget, governance leaks.

This is exactly the failure mode preflight exists to prevent. Building on OpenSpec would reproduce the original pain (forgetting to enforce) in a slightly different shape.

---

## 3. spec-kit customization surfaces as of 2026-04-13

### 3.1 The surface map

| Surface | Extensible? | What it holds | What it doesn't |
|---|---|---|---|
| Presets (`.specify/presets/<id>/templates/`) | **Yes** — 4-tier override stack (overrides → presets → extensions → core) | Templates for spec/plan/tasks, command overrides | — |
| Extensions (`.specify/extensions/<id>/`) | **Yes** — declared in `extension.yml` | Namespaced commands (`speckit.<ext>.<cmd>`), hooks, config schemas | — |
| Custom commands | **Yes** — via preset or extension | Full replacement of a command prompt file | Step injection into an existing command |
| Hooks | **Yes** | `before_specify`, `after_specify`, `before_plan`, `after_plan`, `after_tasks`, `after_implement`, `before_analyze` | **Blocking semantics** — hooks fire LLM prompts, advisory only |
| Config schema (`extension.yml` `config_schema`) | Yes | JSON-schema validation of extension config files | Content validation of specs |
| Content validator | **No** — doesn't exist | — | — |
| Constitution check | **Partial** — prompt-level only | LLM self-evaluates against constitution section | Structural enforcement |
| Multi-agent registration | **Yes** — 17+ agents (Claude, Gemini, Cursor, Copilot, Windsurf, etc.) | Commands written to all detected agent dirs | — |

**Key finding pass 2 missed:** spec-kit has a real extension system, implemented (not just proposed), shipping since v0.3.0. The 4-tier template override stack + namespaced commands + hooks + multi-agent registration is substantially more mature than OpenSpec's equivalent.

**The critical caveat on hooks:** they fire registered spec-kit commands (LLM prompts), not subprocesses or external validators. `optional: true` shows a prompt to the user; there is no documented way for a hook to block the workflow on a non-zero exit from an external tool. They are advisory, not enforcing. This is the one detail that keeps spec-kit from being a credible substrate — and it is a small upstream API change away from being one.

**Release velocity**: 13 releases in the last 30 days (v0.3.0 through v0.6.1). Still pre-1.0, so the preset and extension APIs are not yet stable under semver.

### 3.2 spec-kit rule-category walkthrough

| Category | spec-kit surface | Verdict | Approx count |
|---|---|---|---|
| Structural | Preset templates (`spec-template.md`, `plan-template.md`, `tasks-template.md`) with required sections | **Expressible** | ~8 |
| ID uniqueness and format | Template nudge + prompt-level via command override; no structural enforcement | **Nudgeable, not enforceable** | ~5 |
| Content-quality with severity | Command override prompts the LLM to enforce; no rule DSL | **Nudgeable, not enforceable** | ~15 |
| Cross-doc traceability | No cross-artifact query layer; prompt-level only via command override | **Nudgeable, not enforceable** | ~12 |
| Governance procedural | No post-PR hook; advisory `after_implement` hook only | **Not enforceable** | ~8 |

**Aggregate**: ~8 of 48 rules are structurally expressible (same as OpenSpec). The difference is that spec-kit can *nudge* an additional ~32 rules via command-override prompts and advisory hooks — which is more than OpenSpec's ~0 at that layer. Nudging is not enforcement, but it is closer to enforcement than OpenSpec's current position.

**Approximate coverage at different trust levels**:
- Deterministic enforcement: ~8 of 48 (same as OpenSpec)
- LLM-trusted prompt enforcement: ~40 of 48
- Blocking structural gate: 0 of 48 until spec-kit ships blocking hook semantics

### 3.3 spec-kit verdict

spec-kit is *closer* to being a viable preflight substrate than OpenSpec — but it is not there yet. The two structural gaps are:

1. **No content validator.** Every deterministic rule preflight enforces would still run as a separate tool. The 48-rule engine has no home.
2. **Hooks are advisory.** Even if preflight ran as `after_plan` and `after_specify` hooks, spec-kit cannot be instructed to halt on a failed review. The gate is honor-system.

Both gaps are closable with a single upstream change: a `blocking: true` field on hook declarations plus exit-code propagation. This is a small API addition — smaller than the custom schemas OpenSpec shipped in v1.0. Whether spec-kit's maintainers are inclined to add it is the open question.

---

## 4. Side-by-side — authoring and enforcement surfaces

| Dimension | OpenSpec | spec-kit | Path A (preflight native) |
|---|---|---|---|
| Custom doc types without fork | Custom schemas (YAML + templates) | Presets (4-tier templates) + extensions | Native doc type templates |
| Custom commands | **Not possible** | Namespaced commands via preset or extension | Native skill definitions |
| Hook system | **None** | Advisory LLM-prompt hooks | Bash hooks (post-implementation, pre-commit, etc.) |
| Blocking gate on external validator | No | **No (advisory hooks only)** | Yes — native review engine |
| Rule DSL | No — `rules:` is prompt injection | No — command overrides are prompt injection | 48-rule engine with severity |
| Cross-doc validation | No | No | Native |
| Governance procedural enforcement | No | No | Native (CONST-PROC-01/02) |
| Multi-agent auto-registration | Adapter system (~10 targets) | 17+ agents via `CommandRegistrar` | Claude Code plugin only |
| Release velocity (30d) | 0 | 13 | (not applicable) |
| Extension API stability | v1.x, semver | Pre-1.0, unstable | Internal |

**What this means**: if the goal were purely "author specs across many AI agents," spec-kit wins on the multi-agent registration alone — its preset system writes to 17+ agent directories automatically. Path A locks into Claude Code. But the decisive criterion is not multi-agent reach; it is **rule enforcement**, and on that dimension all three options look the same: preflight enforces, OpenSpec and spec-kit do not.

---

## 5. Hybrid options pass 4 did not evaluate

### 5.1 Option B3 — OpenSpec authoring + preflight review

**Mechanism**: ship `openspec/schemas/preflight/` as a custom schema covering the 7 preflight doc types with preflight's templates and instruction strings. Keep preflight's review engine as a separate Claude Code plugin. User workflow: `openspec new requirements` → `preflight review` → `openspec apply`. Three steps, manual gating.

**What it buys**:
- OpenSpec's adapter ecosystem (~10 AI tool adapters maintained by others)
- Familiar authoring commands for anyone already using OpenSpec
- Less template code to maintain in preflight

**What it costs**:
- Two tools installed, two CLIs to learn
- OpenSpec's `apply` cannot gate on preflight review — manual discipline required
- The 40 content rules still live in preflight; no reduction in preflight's rule-engine scope
- If OpenSpec's schema format evolves (v1.4, v2.0), the custom schema may need updates
- Cognitive coherence loss — two mental models for one workflow

**Weighted estimate**: ~120/175 against pass 4's 15-criterion matrix. Rules preservation still scores 1/5 (enforcement lives outside). Control/customization rises from 2/5 to 3/5 (custom schemas help). Tack Room fit rises slightly. The gap to Path A narrows from 76 points to ~41.

**Verdict**: still loses to A, but closer than pass 4 implied.

### 5.2 Option B4 — spec-kit preset + preflight review (advisory hook)

**Mechanism**: ship `.specify/presets/preflight/` as a preset with preflight's spec/plan/tasks templates + constitution check. Register `speckit.preflight.review` as an extension command that shells out to preflight's review engine. Wire it to `after_specify` and `after_plan` hooks. The hook is advisory (cannot block), but it runs automatically and surfaces findings to the user.

**What it buys**:
- Multi-agent registration — preflight reaches 17+ agents through spec-kit's `CommandRegistrar`, not just Claude Code
- Hook-based automation of review — user doesn't have to remember to run it
- Spec-kit's preset system is more mature than OpenSpec's schema system (4-tier override, clear precedence rules)
- Extension API is real and documented

**What it costs**:
- Spec-kit's APIs are pre-1.0 and unstable; breaking changes are likely
- Hooks are advisory — the user can ignore review findings and proceed to `speckit.implement`
- The 40 content rules still live in preflight (same as B3)
- Spec-kit's template resolution is replace-based, not merge-based — if another preset installs at higher priority, preflight's templates get silently overridden

**Weighted estimate**: ~130–135/175. Rules preservation scores 2/5 (advisory gate is slightly better than no gate). Multi-agent reach adds value we didn't weight before. The gap to Path A narrows to ~25–30.

**Verdict**: the strongest alternative to Path A. Closer than B3. Still loses because the review gate is advisory, not blocking.

### 5.3 Why both still lose

The decisive criterion remains the same: **enforcement**. Preflight's entire value proposition is that the 48 rules cannot be skipped. Both B3 and B4 leak at the enforcement layer — OpenSpec by having no hook at all, spec-kit by having hooks that cannot block. In both cases, the failure mode is "user ignores the advisory and proceeds," which is exactly the failure mode preflight exists to prevent.

A rule engine whose gate is honor-system is not a governance tool; it is a linting suggestion. Preflight must be able to fail hard.

---

## 6. Revised tripwire conditions for day-60 (2026-06-13)

Pass 4 named one condition: OpenSpec ships rule-as-code in v1.4. This doc adds two more, in order of likelihood:

1. **spec-kit ships blocking hook semantics.** A single `blocking: true` field on hook declarations, plus exit-code propagation, would make B4 viable. This is a small API change compatible with spec-kit's current extension system. It is the most plausible near-term change that would invalidate Path A's lead. **Watch: `extensions/RFC-EXTENSION-SYSTEM.md` hook schema, release notes for "blocking hooks" or "halt on fail" language.**
2. **OpenSpec ships pre-apply validator hooks.** Less likely — OpenSpec has historically kept its lifecycle closed. But if it ships, B3 becomes viable. **Watch: `docs/hooks.md` appearing in the OpenSpec repo, release notes for "hook" or "extensibility".**
3. **OpenSpec ships a rule DSL** (pass 4's original condition). Least likely — major design commitment. **Watch: any reference to rule enforcement beyond prompt injection.**

If any of the three ship, re-run the scoring matrix from pass 4 with updated evidence. If none ship by day 60, continue Path A and check again at day 120.

---

## 7. Does this change ADR-007?

No. ADR-007 is a *shape* decision (feature folder lifecycle), not a *substrate* decision. The feature folder pattern works on Path A; it would also work on a hypothetical future B4 where spec-kit's preset system holds the authoring layer and preflight holds review. The shape is substrate-independent by design.

What this analysis does change: ADR-007's "Considered Options" should include B3 and B4 as alternatives explicitly considered, with the enforcement-gate argument as the decisive factor. ADR-007 will be amended to reference this doc.

---

## 8. Meta — what the rework caught

Pass 4 correctly identified the decisive criterion (rules preservation) but stated it as "OpenSpec is rigid" when the accurate framing is "OpenSpec and spec-kit are extensible in the *authoring* layer but closed at the *enforcement* layer." The difference matters because:

- "Rigid" implies Path A wins by ceiling effect — there's no room in the alternatives. Pass 4's 85-point B1 score fed this reading.
- "Closed enforcement layer" implies Path A wins by *single-criterion lock* — the alternatives have room everywhere except the one place that matters. A B4 at 130/175 captures this more honestly than B1 at 85/175.

The methodology lesson: when a single criterion drives a decision, the honest framing is to name it and rate the competitors highly on everything else. Pass 4's matrix suppressed this by spreading the score across 15 criteria, which hid that 14 of them are close and 1 is binary.

This is the same class of error pass 5 caught when the original criteria check revealed drift. Criteria-first analysis catches it. Methodology angle 2.8 (criteria-first re-scoring) should include a companion check: **when one criterion is load-bearing, score competitors honestly on the rest and explain the gap with the one criterion, not with the average.** Proposal for `docs/analysis/2026-04-12-meta-evaluation-methodology.md`: add this as angle 2.9, "load-bearing-criterion isolation," on the next revision.

---

## 9. Recommendation

- **Keep Path A**. The enforcement-layer gap in both OpenSpec and spec-kit is real and decisive.
- **Amend ADR-007** to include B3 and B4 as considered options, with pointers to this doc.
- **Revise the day-60 tripwire** to explicitly watch spec-kit's hook semantics. This is the most likely upstream change to threaten Path A in the next quarter.
- **Do not re-open pass 4's scoring matrix** for the full 15-criterion recomputation. The decisive criterion has not changed; only the spread around it has. The conclusion holds.
- **Do consider sharing this analysis upstream** to spec-kit's extension RFC discussion if blocking hooks are in scope. A concrete use case (preflight's 48 rules) is more useful than an abstract feature request. This is cheap, and advances the ecosystem whether or not preflight ever adopts it.
