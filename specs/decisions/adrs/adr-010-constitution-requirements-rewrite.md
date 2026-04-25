---
status: Proposed
date: 2026-04-25
deciders: Nic
consulted: ADR-007, ADR-009; .specify/memory/constitution.md (v1.2.0); specs/requirements.md (v0.2.0); FirstPrinciples + RedTeam adversarial review (2026-04-25)
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
| CONST-DIST-01 (`.claude/rules/` auto-load, no CLAUDE.md edits) | **REPHRASE** as **CONST-DIST-01 (rewritten)**: "Activation of preflight rules and templates shall not require manual edits to project-authored documents, and shall use only paths the host substrate documents as installable." | Article meaning changes substantively (auto-load semantics → substrate-neutral install). Wording per FirstPrinciples review — names the property (no manual edits, documented paths) without naming any tool. ID retained because the spirit (no manual wiring required) carries through. |
| CONST-DIST-02 (Plugin installation must not overwrite project-authored documents) | **REPHRASE** as **CONST-DIST-02 (rewritten)**: "Preset and extension installation must not overwrite project-authored documents." | Vocabulary update; spirit unchanged. |
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
| FR-023, FR-024 (ADR impact propagation) | **REPHRASE**: replace "plugin" with "`/speckit.preflight.review` command" — spirit unchanged. | Substrate-current vocabulary. |
| FR-026 (`.claude/skills/` triage skill) | **REMOVE in place** | Triage is now project-local skills (`.claude/skills/issue-triage`); not a preflight-shipped requirement. |
| FR-027 (requirement-ID traceability for behavioral fixes) | **REPHRASE**: drop the "enforced by an auto-loaded rule in `.claude/rules/`" clause; preserve the requirement. | Auto-load mechanism gone; requirement remains meaningful. |
| FR-028, FR-029 (already removed in PR #42) | (no-op) | Already struck through. |
| FR-031, FR-032 (added in PR #42) | **Preserve** | Current. |
| **NEW FR-033** | **ADD** (behavioral form per FirstPrinciples review): "When a finding is reported by `/speckit.preflight.review`, the finding shall cite a rule from one of the categories defined in the rule-design ADR (universal, type-specific, or cross-document)." | Observable from review output, not from inspecting preset directory. Citation is via rule-design ADR (currently `.claude/rules/rule-design.md`) so a future amendment can change categorization without breaking the FR. |
| **NEW FR-034** | **ADD** (behavioral form): "When the user requests a structured document scaffold for a doc-type the preset publishes, the scaffold shall match the template defined for that doc-type in `presets/preflight/templates/`." | Observable: scaffold output vs template. Avoids "supported doc-type" ambiguity (RT finding) by anchoring to the preset's published templates directly. |
| ~~FR-035~~ | **DROPPED** | Two-agent ensemble shape is ratified by ADR-004. ADR-004 vocabulary audit is part of this ADR's confirmation criteria (see §Confirmation). |
| NFR-001 (no external deps) | **REPHRASE**: "The preset and extension shall have no external runtime dependencies — content is markdown + YAML manifests within the preset/extension directories." | Same intent. |
| NFR-002 (`/preflight scaffold` <5s) | **REMOVE** | Mechanism doesn't exist. |
| NFR-003 (auto-loaded rules <80 lines) | **REMOVE** | Auto-load mechanism gone. |
| NFR-004 (skill evals ≥80%) | **Deferred to ADR-011** | Names "skills"; replacement vocabulary is shape-dependent on Spike 2 + companion CONST-QA-01/-02 rewrite. |
| NFR-005 (content integrity tests bash) | **REPHRASE** with vocabulary update: "preset + extension shall include automated content integrity tests..." | Same intent. |
| NFR-006 (plugin-dev validation) | **Deferred to ADR-011** | Replacement names spec-kit's `PresetManifest` / `ExtensionManifest` validators — shape-dependent on Spike 2 (workflow-engine mediation may change validator surface). |
| NFR-007 (functional e2e coverage) | **Deferred to ADR-011** | Same as NFR-006 — e2e scope cites direct-invocation paths that may change under Spike 2. |
| NFR-008 (skill files pass code review with /simplify) | **REMOVE** | Plugin-era skills don't exist. |

Frontmatter: version `0.2.0 → 1.0.0` (first substrate-current major); banner rewritten; `amendment_adrs: [..., ADR-010]`.

### Shipped-template cleanup (load-bearing scope addition)

`presets/preflight/templates/requirements-template.md` cites plugin-era FRs (FR-001..020 references). Because this template is shipped via the preset and scaffolds new project requirements docs, those citations propagate to every downstream project. The rewrite removes the stale citations (or replaces them with substrate-current FR-031..034 examples).

## Confirmation

ADR-010 moves from Proposed to Accepted when:

1. **Constitution rewrite PR merged** carrying the article-level deltas above; `.specify/memory/constitution.md` at v2.0.0; banner retired (or rewritten to point at ADR-011 for deferred items); amendment log updated.
2. **Requirements rewrite PR merged** carrying the FR/NFR-level deltas above; `specs/requirements.md` at v1.0.0; banner rewritten; amendment log entry added.
3. **`presets/preflight/templates/requirements-template.md` cleanup PR merged** removing stale FR citations.
4. **ADR-004 vocabulary audit complete**: either ADR-004 is verified to be substrate-current (preserve as-is) or ADR-004 is amended/superseded as part of this rewrite arc. Audit result documented in this ADR before flip to Accepted. Rationale: ADR-010 drops FR-035 because "ADR-004 covers two-agent ensemble"; the reference must be load-bearing in current vocabulary for that drop to hold.
5. **No new stale-article citations in shipped artifacts**, verified by:
   ```
   rg -n 'CONST-DIST-0[12]\b|CONST-PROC-01\b|FR-0(0[1-9]|1[0-9]|20|25|26|30)\b|NFR-00[238]\b' \
      presets/ extensions/ README.md CLAUDE.md
   ```
   returns zero matches outside historical/frozen contexts. (CONST-QA-01..05 / NFR-004/-006/-007 deliberately excluded — those remain stale until ADR-011.)

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
- Optional: ADR-004 amendment if vocabulary audit (Confirmation #4 above) finds it requires update

ADR-011 opens after Spike 2 exits (or at 2026-06-11 tripwire, whichever first).

### FirstPrinciples + RedTeam findings record

This ADR's narrow scope reflects adversarial review of an earlier one-shot draft. Key findings folded in:
- Hybrid splits the rewrite cleanly along Spike 2 dependence (FP #1, RT #5)
- CONST-QA-01..05 protect nothing currently in force; rephrasing would be theatrical (FP #2)
- CONST-DIST-01 wording must name the property, not the mechanism (FP #6, RT #2)
- New FRs must be observable behavior, not preset-contents documentation (FP #5, RT #3, RT #4)
- ADR-004 vocabulary audit is required because FR-035 is dropped on its authority (RT #7)
- Confirmation criteria must include a concrete grep test (FP #8, RT #9)
- Shipped `requirements-template.md` propagates stale FRs to downstream users (citation count check)
