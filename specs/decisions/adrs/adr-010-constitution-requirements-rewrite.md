---
status: Proposed
date: 2026-04-25
deciders: Nic
consulted: ADR-007, ADR-009; .specify/memory/constitution.md (v1.2.0); specs/requirements.md (v0.2.0); FirstPrinciples + RedTeam + Council adversarial review (2026-04-25); Codex bot review on PR #44
informed: Stream A Spike 2; future orchestration ADR; pai-source #102; planned ADR-011 (Spike 2-shape-dependent governance)
---

# ADR-010: Narrow rewrite of constitution + requirements (substrate-vocabulary cleanup)

## Context and Problem Statement

`.specify/memory/constitution.md` (v1.2.0) and `specs/requirements.md` (v0.2.0) carry plugin-era articles and FRs that no longer describe preflight. Both files have self-aware staleness banners flagging the rot. ADR-009's criterion #4 cascade (PR #42) added what was needed for the on-demand-review stance but left the rest untouched, deferring full rewrite to a future amendment "after the ADR-007 spike outcome is known."

This ADR splits that deferred rewrite into two stages:

- **ADR-010 (this ADR)** — narrow rewrite covering only articles/FRs that are unambiguously dead independent of Spike 2's outcome (plugin-era mechanisms removed by ADR-007 + ADR-009).
- **ADR-011 (planned, post-Spike 2)** — covers articles/FRs whose substrate-current vocabulary is shape-dependent on Spike 2's exit (workflow-engine mediation vs direct command invocation): CONST-QA-01..05, NFR-004, NFR-006, NFR-007.

The split is the result of FirstPrinciples + RedTeam adversarial review of an earlier one-shot draft. The QA-* / NFR-006/-007 articles cite specific install/invocation paths (`PresetManifest`, `specify preset add`, `/speckit.preflight.review`) that would become wrong under workflow-engine mediation. Holding them costs almost nothing (they're already flagged stale in the v1.2.0 banner), and avoids shipping known-conditionally-stale governance.

A real cost was also surfaced: `presets/preflight/templates/requirements-template.md` is a SHIPPED artifact that teaches end-user citation of plugin-era FR-001..020. That template scaffolds new requirements docs in downstream projects. The rewrite has to clean it.

## Decision Drivers

- **Governance compliance** — CONST-PROC-02: "All behavioral requirement changes require an ADR." Removing/rephrasing FRs and constitution articles is a behavioral requirement change.
- **Anti-rot, scoped** — `presets/preflight/templates/requirements-template.md` is a shipped template citing dead FRs. Every new project bootstrapped from this template inherits stale citations. That's a concrete propagation cost the rewrite eliminates.
- **Don't pre-decide spike outcomes** — articles whose vocabulary is shape-dependent on Spike 2's outcome (QA-* / NFR-006/-007) are deferred to ADR-011 to avoid known-conditionally-stale governance.
- **Preserve substrate-independent principles** — anything still meaningful (rule IDs stable, ADR governance, MADR format, ID sequentiality) carries through unchanged.

## Considered Options

1. **Wait for ADR-007 spike outcome** — defer all rewrite until Spike 2 exits or 2026-06-11 tripwire.
2. **One-shot ADR (rejected, was v1 of this ADR)** — full rewrite including QA-* and NFR-006/-007. Adversarial review surfaced known-conditionally-stale risk on QA-04/-05 and NFR-007 under plausible Spike 2 exit shapes.
3. **Hybrid — narrow ADR-010 now, ADR-011 post-spike (chosen)** — purge unambiguously-dead articles; defer shape-dependent articles.

## Decision Outcome

**Option 3.** Narrow rewrite covering articles/FRs whose substrate-current target is stable under any plausible Spike 2 outcome.

### Constitution deltas — `.specify/memory/constitution.md`

| Article | Target | Rationale |
|---|---|---|
| CONST-CI-01 (canonical source = git repo) | **Preserve** | Substrate-independent. |
| CONST-CI-02 (templates in `presets/preflight/templates/`) | **Preserve** | Path is current; banner flag retired. |
| CONST-CI-03 (rule IDs stable) | **Preserve** | Substrate-independent; load-bearing for reviewer continuity. |
| CONST-DIST-01 (`.claude/rules/` auto-load, no CLAUDE.md edits) | **REPHRASE** as **CONST-DIST-01 (rewritten)**: "Preflight shall be activatable through host-substrate installation alone; preflight authors shall not require project authors to manually wire preflight into project-authored configuration." | Article meaning changes substantively. Wording per Council synthesis: substrate-neutral (no tool/file/path names) and binds to author behavior rather than installer behavior. ID retained because the spirit (no manual wiring required) carries through. |
| CONST-DIST-02 (Plugin installation must not overwrite project-authored documents) | **REPHRASE** as **CONST-DIST-02 (rewritten)**: "Preflight shall not declare installable destinations outside its own published namespace; preflight-shipped paths must remain within preflight-owned scope." | Council synthesis: re-targeted to constrain author behavior (manifest declarations) rather than installer behavior (which is substrate-owned). Substrate-neutral wording (no specific paths or tool names). The concrete mapping from "preflight-owned scope" to current substrate paths is implemented by tests, not by the article. |
| CONST-QA-01..05 | **Deferred to ADR-011** | RedTeam: shape-dependent on Spike 2 exit (QA-04/-05 cite manifest validators and direct-invocation paths that would change under workflow-engine mediation). Banner v1.2.0 already flags as stale-pending-rewrite. |
| CONST-PROC-01 (any plugin change bumps version) | **REPHRASE** as **CONST-PROC-01 (rewritten)**: "Any preset or extension change that alters behavior bumps the version in `presets/preflight/preset.yml` and `extensions/preflight/extension.yml` lock-step (PEP 440)." | Already cascaded through commits; codify in the article. |
| CONST-PROC-02 (ADR on behavioral requirement change) | **Preserve** | Substrate-independent. |
| CONST-PROC-03 (ADRs use MADR 4.0) | **Preserve** | Substrate-independent. |
| CONST-REV-01, CONST-REV-02 (added in PR #42 per ADR-009) | **Preserve** | Already current. |

Banner is rewritten: drop the v1.2.0 partial-rewrite framing, reference ADR-010 for what it amends and ADR-011 for what's still deferred.

Frontmatter: version `1.2.0 → 2.0.0` (major bump because CONST-DIST-01's article meaning changes — citations written under v1.2.0 vocabulary resolve to a different principle under v2.0.0); `last_amended: <merge date>`; `amendment_adrs: [ADR-003, ADR-009, ADR-010]`. Amendment log gets a `2.0.0` row.

### Requirements deltas — `specs/requirements.md`

| FR / NFR | Target | Rationale |
|---|---|---|
| FR-001..009 (plugin scaffold journey via `/preflight scaffold`) | **REMOVE in place** (strikethrough + note); IDs retained | Mechanism doesn't exist in spec-kit extension form. |
| FR-010..016 (plugin `/preflight new` elicitation) | **REMOVE in place** | `/preflight new` doesn't exist; templates are scaffolded by spec-kit's own commands. |
| FR-017..020, FR-025, FR-030 (plugin `/preflight review`) | **REMOVE in place** | Replaced by `/speckit.preflight.review` (FR-031); old FR-030 finding-location format absorbed into FR-031c. |
| FR-021, FR-022 (already removed in PR #42) | (no-op) | Already struck through. |
| FR-023, FR-024 (ADR impact propagation) | **REPHRASE**: replace "the plugin shall" with "the user or orchestrator shall" — preserve the ADR-authoring trigger; only update vocabulary. | Codex P2 finding: retargeting to `/speckit.preflight.review` would gate downstream-impact propagation on review invocation (on-demand per ADR-009), which is a behavioral regression vs the original ADR-creation-time trigger. Preserve the trigger; modernize the actor reference. |
| FR-026 (`.claude/skills/` triage skill) | **REMOVE in place** | Triage is now project-local skills (`.claude/skills/issue-triage`); not a preflight-shipped requirement. |
| FR-027 (requirement-ID traceability for behavioral fixes) | **REPHRASE**: drop the "enforced by an auto-loaded rule in `.claude/rules/`" clause; preserve the requirement. | Auto-load mechanism gone; requirement remains meaningful. |
| FR-028, FR-029 (already removed in PR #42) | (no-op) | Already struck through. |
| FR-031, FR-032 (added in PR #42) | **Preserve** | Current. |
| **NEW FR-033** | **ADD** (behavioral, substrate-neutral): "Findings produced by preflight review shall cite a rule whose category is defined by preflight's rule-design framework." | Council synthesis: drops the bracketed enumeration and the "ADR" referent (current rule-design lives in a rule file, not an ADR). The framework itself is the durable referent; categorization is implementation that the framework owns. |
| **NEW FR-034** | **ADD** (behavioral, substrate-neutral): "When the user requests a structured document scaffold for a published doc-type, the scaffold shall match the template defined for that doc-type by preflight." | Council synthesis: drops the path reference. Verifiability: covered by NFR-005's content-integrity test obligation. |
| ~~FR-035~~ | **NOT AUTHORED** | Council synthesis (Codex P3): ADR-010 explicitly chose **not** to author a new FR for the two-agent ensemble shape, deferring instead to ADR-004's existing ratification. Phrased as "not authored" rather than "dropped" because FR-035 never existed in `requirements.md`. |
| NFR-001 (no external deps) | **REPHRASE**: "The preset and extension shall have no external runtime dependencies — content is markdown + YAML manifests within the preset/extension directories." | Same intent. |
| NFR-002 (`/preflight scaffold` <5s) | **REMOVE** | Mechanism doesn't exist. |
| NFR-003 (auto-loaded rules <80 lines) | **REPHRASE**: "Rules loaded as prompt context for preflight review shall stay within an agent-context budget (target: <80 lines per file)." | Council synthesis + Codex P2 (v3): the auto-load mechanism is dead but the underlying budget rationale (rules must be agent-context-friendly, scannable) survives. Wording is substrate-neutral — drops `/speckit.preflight.review` to avoid Spike 2 shape-dependence; "preflight review" is a behavior phrase that survives both direct-invocation and workflow-engine-mediation futures. |
| NFR-004 (skill evals ≥80%) | **Deferred to ADR-011** | Names "skills"; replacement vocabulary is shape-dependent on Spike 2 + companion CONST-QA-01/-02 rewrite. |
| NFR-005 (content integrity tests bash) | **REPHRASE** with vocabulary update: "preset + extension shall include automated content integrity tests..." | Same intent. |
| NFR-006 (plugin-dev validation) | **Deferred to ADR-011** | Replacement names spec-kit's `PresetManifest` / `ExtensionManifest` validators — shape-dependent on Spike 2 (workflow-engine mediation may change validator surface). |
| NFR-007 (functional e2e coverage) | **Deferred to ADR-011** | Same as NFR-006 — e2e scope cites direct-invocation paths that may change under Spike 2. |
| NFR-008 (skill files pass code review with /simplify) | **REPHRASE**: "Preset templates and extension content shall pass code review (`/simplify` or equivalent) before shipping." | Council synthesis: quality discipline survives substrate change — `/simplify` runs on markdown the same as on code. Removing this conflates artifact type with quality discipline. |

Frontmatter: version `0.2.0 → 1.0.0` (first substrate-current major); banner rewritten; `amendment_adrs: [..., ADR-010]`.

### Shipped-template cleanup (load-bearing scope addition)

`presets/preflight/templates/requirements-template.md` cites plugin-era FRs (FR-001..020 references). Because this template is shipped via the preset and scaffolds new project requirements docs, those citations propagate to every downstream project. The rewrite removes the stale citations (or replaces them with substrate-current FR-031..034 examples).

## Confirmation

ADR-010 moves from Proposed to Accepted when:

1. **Constitution rewrite PR merged** carrying the article-level deltas above; `.specify/memory/constitution.md` at v2.0.0; banner retired (or rewritten to point at ADR-011 for deferred items); amendment log updated.
2. **Requirements rewrite PR merged** carrying the FR/NFR-level deltas above; `specs/requirements.md` at v1.0.0; banner rewritten; amendment log entry added.
3. **`presets/preflight/templates/requirements-template.md` cleanup PR merged** removing stale FR citations.
4. **ADR-004 vocabulary audit complete.** ADR-010 chose **not** to author a new FR for the two-agent ensemble shape, deferring instead to ADR-004's existing ratification. The audit verifies that the deferral is load-bearing rather than implicit. Methodology:
   ```
   rg -n 'skill\b|plugin\b|\.claude/skills' \
      specs/decisions/adrs/adr-004-reviewer-agent-architecture.md
   ```
   Any matches are audit findings. If the file uses plugin-era vocabulary, ADR-004 must be amended (separately, not in this ADR) before ADR-010 can flip to Accepted.
5. **CONST-PROC-01 lock-step verification mechanism in place.** A pre-commit hook, CI step, or equivalent shall fail when `presets/preflight/preset.yml` and `extensions/preflight/extension.yml` versions drift apart. Without this, CONST-PROC-01's lock-step claim is unenforced. (Implementation can be a separate small PR; criterion blocks ADR-010 acceptance, not the rewrite cascade itself.)
6. **No new stale-article citations in shipped artifacts**, verified by:
   ```
   rg -n 'FR-0(0[1-9]|1[0-9]|20|25|26|30)\b|NFR-002\b' \
      presets/ extensions/ README.md CLAUDE.md
   ```
   returns zero matches outside historical/frozen contexts. (Notes: CONST-DIST-01/-02 + CONST-PROC-01 IDs are reused with new wording — citations under v2.0.0 reference the new principles. CONST-QA-01..05 / NFR-004/-006/-007 deliberately excluded — those remain stale until ADR-011. NFR-003/-008 are now rephrased rather than removed, so their IDs persist.)

## Pros and Cons of the Options

### Option 1 — Wait for ADR-007 spike outcome

- Good: zero risk of any conditional staleness
- Good: matches deferral framing in current banners
- Bad: stale citations keep accumulating until 2026-06-11 (or later) tripwire
- Bad: shipped template (`requirements-template.md`) keeps teaching plugin-era FR citations to downstream users
- Bad: governance drift compounds

### Option 2 — One-shot ADR (rejected, was v1)

- Good: single amendment, single cascade
- Bad: ships known-conditionally-stale CONST-QA-04/-05, NFR-006/-007 under live Spike 2
- Bad: contradictory — the §Successor ADR risk acknowledgment concedes shape-dependence, then proceeds anyway

### Option 3 — Narrow ADR-010 + planned ADR-011 (chosen)

- Good: governance-compliant (CONST-PROC-02 satisfied for the in-scope changes)
- Good: stops citation rot for unambiguously-dead articles immediately
- Good: addresses the load-bearing shipped-template propagation issue
- Good: defers shape-dependent articles to ADR-011 — zero conditionally-stale governance shipped
- Good: enumerated deltas + concrete confirmation grep make the rewrite reviewable
- Bad: requires two amendment ADRs eventually (one now, one post-spike)
- Bad: leaves QA-* / NFR-006/-007 visibly stale in the v2.0.0 constitution banner until ADR-011

## More Information

- **Predecessor ADRs:** ADR-004 (reviewer-agent-architecture, vocabulary audit pending), ADR-007 (feature-folder lifecycle, Proposed), ADR-009 (integration topology, Accepted)
- **Predecessor PRs:** #40 (criterion #1, hooks), #41 (criterion #3, PAI redirects), #42 (criterion #4, governance cascade), #43 (ADR-009 status flip)
- **Cross-repo:** `pai-source#102` (PAI-side wiring follow-up to criterion #3)
- **Spike 2 unblock:** ADR-009's Accepted state. ADR-010 does not gate Spike 2.
- **Day-60 tripwire:** 2026-06-11 — orchestration-ADR research deadline.

### Planned ADR-011 scope (deferred from this ADR)

- CONST-QA-01..05: rewrite or REMOVE depending on whether eval-suite + release-process mechanisms exist post-Spike 2
- NFR-004 (eval thresholds): same dependency
- NFR-006, NFR-007: substrate-current install + e2e scope, dependent on Spike 2's invocation choice (direct command vs workflow-engine)
- **FR-031, FR-032** (added in PR #42 under ADR-009): both name `/speckit.preflight.review` directly. By the same Codex P2 (v3) logic that pulled NFR-003's slash-command name out of this ADR, FR-031/-032 are conditionally-stale under Spike 2. Out of scope for ADR-010 (would mean editing FRs authored under a different ADR's authority); revisit under ADR-011 alongside the other shape-dependent items.
- Optional: ADR-004 amendment if vocabulary audit (Confirmation #4 above) finds it requires update

ADR-011 opens after Spike 2 exits (or at 2026-06-11 tripwire, whichever first).

### Adversarial review record (FirstPrinciples + RedTeam + Council + Codex)

This ADR's narrow scope and v3 wording reflect three adversarial review passes plus Codex bot review.

**Pass 1 — FirstPrinciples + RedTeam (informed v2 → v3 narrowing):**
- Hybrid splits the rewrite cleanly along Spike 2 dependence → narrow scope chosen (FP #1, RT #5)
- CONST-QA-01..05 protect nothing currently in force; deferred to ADR-011 (FP #2)
- New FRs must be observable behavior, not preset-contents documentation (FP #5, RT #3, RT #4)
- ADR-004 vocabulary audit is required because FR-035 is dropped on its authority (RT #7)
- Confirmation criteria must include concrete grep tests (FP #8, RT #9)
- Shipped `requirements-template.md` propagates stale FRs to downstream users (citation count check)

**Pass 2 — Council on CONST-DIST-02 (informed v3 re-targeting of DIST articles):**
- Substrate-Skeptic position won synthesis: bind principles to author behavior (manifest declarations) rather than installer behavior (substrate-owned)
- Belt-and-Suspenders argument restored NFR-003 + NFR-008 from REMOVE → REPHRASE (budget rationale and quality discipline survive substrate change)
- Final wording hoisted to substrate-neutral abstraction: principle stays abstract; tests stay concrete (no implementation details in DIST-01/-02 wording)

**Pass 3 — Codex bot (informed v3 corrections):**
- P2: FR-023/-024 retarget would gate ADR-impact propagation on review invocation — behavioral regression. Reverted; preserved authoring trigger, only updated actor reference.
- P3: Confirmation criterion #4 referenced non-existent FR-035. Reworded to "ADR-010 chose not to author FR-035" framing.
