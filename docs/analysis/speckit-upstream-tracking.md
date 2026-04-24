# spec-kit upstream tracking

**Status:** living doc — updated per upstream release, not batched.
**Baseline:** preflight was validated against spec-kit **v0.6.2** (pin: `">=0.6.2,<0.7.0"`).
**Current upstream HEAD:** v0.8.0 as of 2026-04-24 (B2-follow-up executed against v0.8.0, same day).
**Scope:** classify each release since v0.6.2 against preflight's 6 outcomes.

Preflight classifies each upstream release against preflight outcomes rather than deciding "bump vs pin" — the question per release is *how do we absorb each change, and is any of it a hard blocker?* The current install pin (`>=0.6.2,<0.7.0` in `presets/preflight/preset.yml` and `extensions/preflight/extension.yml`) is behind the v0.7.x classifications below; the pin widens in B4 as adaptation PRs land.

---

## Preflight outcomes to protect

These are what adaptation must preserve. A change is only a **(iii) hard blocker** if it breaks one of these in a way preflight cannot adapt to through implementation changes alone.

| ID | Outcome | One-liner |
|----|---------|-----------|
| (a) | Author-time review enforcement | Review runs when spec/plan is written, not in CI/post-hoc |
| (b) | Ensemble dispatch from spec-kit commands | `checklist` + `bogey` reviewers fire via spec-kit hook surface |
| (c) | Rules as first-class versioned artifacts with stable IDs | `CONST-*`, `UNIV-*`, etc. survive refactors; rule files are the source of truth |
| (d) | Severity-graded findings (Critical / High / Medium / Low) | Orchestrator output preserves severity tiers |
| (e) | Cross-doc traceability | An FR referenced in an ADR must exist in `requirements.md`; reviewer enforces |
| (f) | Composition with other spec-kit extensions | `archive`, community extensions, custom user extensions all coexist |

---

## Classification legend

| Tag | Meaning | Preflight response |
|-----|---------|--------------------|
| **(i) no-impact** | Cosmetic, internal CLI concern, or unrelated subsystem | Record; no action |
| **(ii) implementation-adjust** | Preflight code/config needs a change, but outcomes (a)–(f) preserved | B4 adaptation PR; B3 requirements/arch review if observable behavior shifts |
| **(iii) hard-blocker** | An outcome is broken and not recoverable through adaptation | Escalate to design-decision doc; may force ADR-007 revisit |

Every material change since v0.6.2 gets a row. Rows marked `needs-B2-confirmation` or `needs-B2-follow-up` have provisional classifications pending an install against the newer upstream.

### Affected-outcome notation

Each (ii) / (iii) row names the impacted outcome IDs in parentheses, e.g. `(ii: b, f)` = implementation-adjust affecting ensemble dispatch and composition.

---

## Stream B workstreams

This doc is part of preflight's Stream B work — spec-kit upstream tracking, adaptation, and hook-philosophy investigation. Stream A (core spike execution on issue #13, tack-room launcher, PAI brownfield) runs in parallel from the `workflow-research` worktree. Labels referenced throughout this doc:

| Label | Workstream |
|-------|-----------|
| **B1** | Living upstream tracking doc — this file |
| **B2** | Test adaptation: install preflight against current upstream; validate classifications |
| **B3** | Requirements / architecture review when a (ii) or (iii) alters preflight's observable behavior (per CONST-PROC-02) |
| **B4** | Adaptation PRs per (ii); escalation design docs per (iii); pin widening in `preset.yml` / `extension.yml` |
| **B5** | Hook philosophy investigation (subagent) — output at `./2026-04-22-speckit-hook-philosophy.md`, verdict β |

**Gate 2.5** (load-bearing): Spike 2 in the sibling worktree cannot proceed until B5's classification (done) plus integration-topology selection lands in writing. See ADR-007 "Integration topology" for the current state.

---

## Maintenance convention

- **Living doc.** No date prefix on the filename. Update in-place as releases land.
- **One release per section** ordered most-recent first after the first pass below (ordered oldest-first for the initial population's narrative flow).
- **Do not batch.** When a release ships, add its section and classifications before other Stream B work continues.
- **Reclassify as evidence arrives.** B2 adaptation testing will validate or overturn (ii)/(iii) calls. Mark reclassifications with a `reclassified: YYYY-MM-DD` note inline.
- **Anchor per outcome.** The outcomes table above is stable; downstream references should link to `#preflight-outcomes-to-protect`.

---

## Baseline constraints (independent of release)

Some preflight-relevant properties of spec-kit are baseline — not introduced or changed by any specific release since v0.6.2 — and therefore do not belong in per-release classifications. Document them here so release rows only capture actual deltas.

- **`after_*` hooks are advisory by design.** `optional: false` renders an `EXECUTE_COMMAND:` marker but does not block host-agent completion. Established by spec-kit PR #1702 (2026-03-04, pre-v0.6.0); confirmed by upstream as intentional in issues [spec-kit#2104](https://github.com/github/spec-kit/issues/2104) (OPEN feature request for `auto_run: true`) and [spec-kit#2279](https://github.com/github/spec-kit/issues/2279) (closed "not a bug"). Full analysis: `./2026-04-22-speckit-hook-philosophy.md`. This is the structural reason the current hook-extension composition cannot enforce author-time review; it is *not* a v0.7.x regression.

---

## Release-by-release classifications — v0.6.2 → v0.8.0

Evidence sources below are all independently verifiable: upstream PR numbers (full URLs where relevant), spec-kit commit SHAs in `~/.cache/spec-kit`, and tag-to-tag `git log` (`git -C ~/.cache/spec-kit log <prev>..<curr>`). Initial pass populated 2026-04-22 (v0.6.2 → v0.7.4); B2 execution 2026-04-24 confirmed v0.7.4 classifications and added v0.7.5 / v0.8.0 sections.

### v0.6.3 (released 2026-04-08..2026-04-09, approximate)

**Headline:** maintenance release between v0.6.2 and v0.7.0 series. No material items captured in the survey.

| Change | Classification | Notes |
|--------|---------------|-------|
| — (no material items in survey) | (i) no-impact; reclassified: 2026-04-24 (B2) | Tag-to-tag `git log v0.6.2..v0.6.3` in `~/.cache/spec-kit` confirmed no preflight-impacting changes. |

### v0.6.4 (released 2026-04-09..2026-04-10, approximate)

**Headline:** maintenance release; survey did not flag specific items.

| Change | Classification | Notes |
|--------|---------------|-------|
| — (no material items in survey) | (i) no-impact; reclassified: 2026-04-24 (B2) | Tag-to-tag `git log v0.6.3..v0.6.4` confirmed no preflight-impacting changes. |

### v0.7.0 (released ~2026-04-11)

**Headline:** workflow engine + catalog introduction; `--ai` → `--integration` rename. This is the largest semantic jump in the window.

| Change | Classification | Notes |
|--------|---------------|-------|
| Workflow engine + catalog (#2158) | **(ii) implementation-adjust** (a, b); revised: 2026-04-22; B2-confirmed: 2026-04-24 | v0.7.0 introduces `src/specify_cli/workflows/` with Gate/CommandStep/`RunStatus.PAUSED` primitives — a new enforcement surface spec-kit did not have before. B2 install against v0.7.4 confirms the workflow engine coexists cleanly with preflight extension (`.specify/workflows/` is created during `specify init`; preflight's hook-extension composition dispatches independently). Workflow-gate migration remains the likely target for the advisory-hook baseline constraint; tracked as the integration-topology question in ADR-007. See `./2026-04-22-speckit-hook-philosophy.md` §Q3. |
| `--ai` → `--integration` CLI rename (#2218) | **(ii) implementation-adjust** (—); reclassified: 2026-04-24 (B2) | Confirmed: `specify init --ai claude` still works at v0.7.4 (deprecation alias preserved). `--integration` is the new canonical flag. Preflight install instructions in `CLAUDE.md` should adopt `--integration`; no outcome broken. |

### v0.7.1 (released between v0.7.0 and v0.7.2)

**Headline:** small bugfixes — unofficial-PyPI warning (#2027), legacy extension command name auto-correction (#2017), skill chain for hook execution (#2227).

| Change | Classification | Notes |
|--------|---------------|-------|
| Legacy extension command name auto-correction (#2017/#2027) | (i) no-impact; reclassified: 2026-04-24 (B2) | Rewrites old-style extension command names at load; preflight uses the post-rename `speckit.preflight.review` form already. |
| Allow Claude to chain skills for hook execution (#2227) | (i) no-impact; reclassified: 2026-04-24 (B2) | Claude-integration hook internals. Does not alter advisory-hook semantics (see Baseline constraints). Preflight's dispatch path unaffected. |

### v0.7.2 (released ~2026-04-16)

**Headline:** `pack_id` → `preset_id` manifest rename (#2243).

| Change | Classification | Notes |
|--------|---------------|-------|
| `pack_id` → `preset_id` rename (#2243) | **(i) no-impact**; reclassified: 2026-04-24 (B2) | Confirmed via `git show 8d2797d` and install test: #2243 renamed CLI `--help` parameter text from PACK_ID to PRESET_ID (user-facing flag help) and renamed internal variable names in `src/specify_cli/__init__.py`. The preset-manifest YAML field is `preset.id` (nested under `preset:` key) — not affected by the rename. `specify preset list` at v0.7.4 resolves our installed preflight preset correctly using the manifest's `preset.id` field. |

### v0.7.3 (released ~2026-04-19)

**Headline:** marker-based context upsert (#2259) replacing shell-based mechanism.

| Change | Classification | Notes |
|--------|---------------|-------|
| Marker-based context upsert (#2259) | **(i) no-impact**; reclassified: 2026-04-22 (post-B5) | B5 clarified: #2259 is not a hook-enforcement alternative. It solves a different problem (idempotent agent-context file mutation during `specify` CLI install/switch/uninstall). Not event-driven; no `after_*` equivalent. Preflight's review dispatch surface is unrelated to this mechanism. See `./2026-04-22-speckit-hook-philosophy.md` §Q4. |

### v0.7.4 (released ~2026-04-22)

**Headline:** Antigravity migration (#2276); `--skills` deprecation; UTF-8 BOM strip in agent-context reader (#2283).

| Change | Classification | Notes |
|--------|---------------|-------|
| Antigravity (agy) migration to `.agents/` + `--skills` deprecation (#2276) | **(i) no-impact**; reclassified: 2026-04-24 (B2) | Agent-integration internal. Preflight extension contract is unchanged; `.specify/extensions/preflight/` still composes cleanly. Verified: `specify extension add --dev` installs preflight on v0.7.4 with hooks `after_specify` + `after_plan` both registered in `.specify/extensions.yml`. |
| UTF-8 BOM strip in agent context reader (#2283) | (i) no-impact; reclassified: 2026-04-24 (B2) | Robustness fix for BOM-prefixed agent context files. Preflight rule files are plain UTF-8 (no BOM). |
| `--skills` deprecation (subset of #2276) | **(i) no-impact**; reclassified: 2026-04-24 (B2) | Preflight's `--dev` install sequence does not use `--skills`. Skill-based scaffolding is a spec-kit internal path; preflight composes via extension + preset. No references in preflight docs. |

### v0.7.5 (released ~2026-04-23)

**Headline:** preset wrap strategy (#2189); directory-traversal block (#2296); `specify self check/upgrade` stub (#2316).

| Change | Classification | Notes |
|--------|---------------|-------|
| Preset wrap strategy (#2189) | **(ii) implementation-adjust** (f) — opportunity, not required; B2-follow-up: 2026-04-24 | B2-follow-up against v0.8.0 (superset of v0.7.5) confirmed: `strategy` is a **per-template field** on preset entries in `presets.py` (`VALID_PRESET_STRATEGIES = {"replace", "prepend", "append", "wrap"}`), defaults to `"replace"`. Preflight's preset installs cleanly without declaring `strategy` — default `replace` preserves v0.7.x priority-based behavior. Opt-in to `strategy: "wrap"` on `speckit.tasks`/`speckit.implement` would let preflight compose with upstream defaults instead of fully replacing; opportunity flagged for ADR-007 topology evaluation. |
| Directory-traversal block in command write paths (#2296) | **(i) no-impact**; reclassified: 2026-04-24 (B2) | Security hardening — blocks extensions from writing outside their owned paths. Verified all preflight reviewer rule + agent + command files live under `extensions/preflight/` with no `..` path components. Previous placement of #2296 under v0.7.4 was incorrect; `git tag --contains 569d18a` confirms first release is v0.7.5. |
| `specify self check` / `self upgrade` stub (#2316) | (i) no-impact | CLI self-management subcommand. Does not affect preset/extension contract. |
| Skill placeholder resolution for all agents (#2313) | (i) no-impact | Agent-integration internal. Does not affect preflight extension dispatch surface. |

### v0.8.0 (released ~2026-04-24)

**Headline:** composition strategies for templates/commands/scripts (#2133); `--force` overwrites shared infra (#2320).

| Change | Classification | Notes |
|--------|---------------|-------|
| Composition strategies — prepend/append/wrap for templates, commands, scripts (#2133) | **(ii) implementation-adjust** (f) — opportunity, not required; B2-follow-up: 2026-04-24 | v0.8.0 supersets v0.7.5's `--wrap` with full prepend/append/wrap for templates + commands; scripts limited to `{replace, wrap}` (prepend/append don't make sense for executables). Default strategy is `"replace"` — preflight's existing preset (no `strategy` declared) behaves identically to v0.7.x. Opportunity: preflight's `speckit.tasks`/`speckit.implement` overrides could declare `strategy: "wrap"` to compose with upstream defaults. Resolver internals (`_reconcile_composed_commands`, `PresetResolver.resolve` with `skip_presets` flag) only activate when a non-replace strategy is in the stack. Topology-relevant — see ADR-007. |
| `--force` overwrites shared infra on init/upgrade (#2320) | **(i) no-impact**; B2-follow-up: 2026-04-24 | `_install_shared_infra(force=True)` is wired only to `specify init --here --force` and `specify integration upgrade --force` (per `git show 3970855`). It is **not** wired to `specify preset add` or `specify extension add`. Preflight's `--dev` install flow operates on preset/extension dirs exclusively and is unaffected by this change. Reclassified provisional `(ii)` → `(i) no-impact`. |
| Copilot `--integration-options="--skills"` (#2324) | (i) no-impact | Copilot-specific surface for skills-based scaffolding. Preflight targets Claude; does not use copilot integration. |

---

## Coupling table (what's linked to what)

| Entry | Coupled to | Why |
|-------|-----------|-----|
| v0.7.0 workflow engine (#2158) | ADR-007 integration-topology evaluation | v0.7.0 introduces the workflow engine as a candidate migration target for preflight (workflow-gate composition). Decision tracked in ADR-007 "Integration topology". Baseline advisory-hook constraint (separate, see above) is what motivates considering migration at all. B2 (2026-04-24) confirms the engine coexists with the current hook-extension composition. |
| v0.7.3 marker-based upsert (#2259) | B5 (RESOLVED β) | B5 resolved: #2259 is not an enforcement alternative. Entry reclassified (i). |
| v0.7.5 preset wrap strategy (#2189) | ADR-007 integration-topology evaluation | Preset composition strategies widen the design space for preflight's preset. B2-follow-up (2026-04-24) confirmed schema (`strategy: "wrap"` per-template, default `replace`). Opt-in only — existing preflight preset unaffected. |
| v0.8.0 composition strategies (#2133) | ADR-007 integration-topology evaluation | Finer-grained composition control for templates/commands/scripts. B2-follow-up (2026-04-24) confirmed default `replace` preserves current behavior; `wrap` opt-in could let preflight compose with upstream defaults on `speckit.tasks`/`speckit.implement`. |

---

## B2 adaptation test — v0.7.4 (executed 2026-04-24)

Answers to the original 6 outstanding questions. Each answer reflects an install against spec-kit v0.7.4 (`specify 0.7.4` installed via `pipx install --force "git+https://github.com/github/spec-kit.git@v0.7.4"`) in `/Users/Shared/sv-nic/src/tmp/test-preflight/`.

1. **Does `specify preset add --dev ./presets/preflight` succeed on v0.7.4?**
   **Answer: blocked by pin (as designed), succeeds under widened pin.** Current committed pin `>=0.6.2,<0.7.0` produces the expected `Compatibility Error: Preset requires spec-kit >=0.6.2,<0.7.0, but 0.7.4 is installed.` — exit 0, soft error, clean message. With a temp-widened pin (`<0.8.0`), install succeeds and `specify preset list` resolves the preset by ID. No adaptation required at preset-manifest level.

2. **Does `specify extension add --dev ./extensions/preflight` succeed, and do both hooks register?**
   **Answer: yes.** Extension installs cleanly under widened pin. Both `after_specify` and `after_plan` hooks appear in `.specify/extensions.yml` with `enabled: true, optional: false, command: speckit.preflight.review`. The registry also correctly records `Commands: 1 | Hooks: 2 | Priority: 10 | Status: Enabled` per `specify extension list`.

3. **Does `/speckit.preflight.review` still dispatch both reviewers from a v0.7.4 spec-kit command context?**
   **Answer: install wiring confirmed; end-to-end dispatch deferred.** The command file `speckit.preflight.review.md` is copied into `.specify/extensions/preflight/commands/` and registered. Interactive dispatch (does the host agent actually invoke the review when `/speckit.specify` completes?) is governed by the advisory-hook baseline constraint (B5) and requires a live Claude Code session in the test project — verified install wiring is necessary but not sufficient for end-to-end behavior. No v0.7.4 regression in the dispatch surface.

4. **Does `preset.id` in our preset manifest still bind correctly after the v0.7.2 `pack_id → preset_id` rename (#2243)?**
   **Answer: yes — rename does not affect the manifest field.** Confirmed via `git show 8d2797d`: #2243 renamed CLI `--help` parameter text and internal variable names in `src/specify_cli/__init__.py`; the YAML manifest still uses `preset.id` (nested under `preset:` key), unchanged. `specify preset list` at v0.7.4 resolves the preflight preset by manifest ID without any adaptation. Reclassified v0.7.2 row `(ii) provisional` → `(i) no-impact`.

5. **Does any v0.7.x release change the structure of `requires.speckit_version` expression evaluation?**
   **Answer: no.** Pin expressions evaluated at v0.7.4 use the same `>=X,<Y` syntax as v0.6.2. The `version_satisfies()` function in `src/specify_cli/extensions.py` at v0.7.4 handles standard version-specifier strings. The pin blocks correctly when violated and passes when satisfied.

6. **Are any preflight reviewer rule files tripping the v0.7.4 directory-traversal block?**
   **Answer: N/A at v0.7.4 — #2296 is v0.7.5, not v0.7.4.** `git tag --contains 569d18a` resolves to v0.7.5 and v0.8.0 only. The original doc row misplaced #2296 under v0.7.4; fixed. For v0.7.5+ readiness: all preflight reviewer files live under `extensions/preflight/{rules,agents,commands}` with no `..` path components, so the block should not trip. B2-follow-up will confirm against v0.7.5+ install.

## B2-follow-up — v0.7.5 + v0.8.0 (executed 2026-04-24)

Answers to the 4 follow-up questions. Tested against v0.8.0 (which supersets v0.7.5 for the questions at hand — dir-traversal block + preset wrap both ship in v0.7.5 and persist in v0.8.0). Install in `/Users/Shared/sv-nic/src/tmp/test-preflight/` against `specify 0.8.0` using temp-widened pin `<0.9.0`.

1. **Does the v0.7.5 directory-traversal block (#2296) allow preflight's reviewer dispatch paths without adjustment?**
   **Answer: yes.** Preflight's full `specify preset add --dev` + `specify extension add --dev` cycle succeeds on v0.8.0 without dir-traversal errors. All reviewer rule + agent + command file paths live under `extensions/preflight/{rules,agents,commands}` with no `..` components. Hooks register correctly (`after_specify` + `after_plan` both present in `.specify/extensions.yml`).

2. **Does the v0.7.5 preset wrap strategy (#2189) open a cleaner composition path for preflight's preset command overrides?**
   **Answer: yes, as an opt-in opportunity.** `VALID_PRESET_STRATEGIES = {"replace", "prepend", "append", "wrap"}` per `src/specify_cli/presets.py` at v0.8.0; `strategy` is a per-template field on preset entries, default `"replace"`. Preflight's `speckit.tasks`/`speckit.implement` overrides could declare `strategy: "wrap"` to compose with upstream defaults (PAI-redirect wrapping upstream invocation) instead of fully replacing. Not required for current behavior preservation. Decision belongs to ADR-007 integration-topology evaluation.

3. **Does the v0.8.0 composition strategies feature (#2133) change how preflight's command overrides resolve under priority-based conflict?**
   **Answer: no, not by default.** Default `strategy` is `"replace"` for all preset entries lacking an explicit field. `_reconcile_composed_commands` and `PresetResolver.resolve(skip_presets=...)` only activate when a non-replace strategy exists in the resolution stack. Preflight's existing preset (no strategy declared) resolves by priority exactly as in v0.7.x. Scripts are limited to `{replace, wrap}` — preflight does not ship scripts, so this limitation is unaffecting.

4. **Does the v0.8.0 `--force` shared-infra overwrite (#2320) affect `--dev` install flows?**
   **Answer: no.** `_install_shared_infra(force=True)` per `git show 3970855` is wired only to `specify init --here --force` and `specify integration upgrade --force`. The `--dev` paths on `preset add` and `extension add` do not call `_install_shared_infra`. Preflight's `--dev` install flow is unaffected. Reclassified the v0.8.0 `--force` row from provisional `(ii)` → `(i) no-impact`.

---

## Cross-references

- Hook philosophy classification (B5, verdict β): `./2026-04-22-speckit-hook-philosophy.md`
- ADR-007 — integration-topology reopened per B5: `../../specs/decisions/adrs/adr-007-feature-folder-lifecycle.md`
- Preset pin source: `../../presets/preflight/preset.yml` (`requires.speckit_version`)

---

## Change log (this doc only)

- 2026-04-22 — initial population from workflow-research handoff survey. All v0.7.x rows marked `needs-B2-confirmation`. Coupling to B5 noted on v0.7.0 and v0.7.3 entries.
- 2026-04-22 — post-B5 reclassification: v0.7.0 workflow engine upgraded to (iii) hard-blocker; v0.7.3 marker-based upsert downgraded to (i) no-impact (not a hook-enforcement alternative). Coupling table updated.
- 2026-04-22 — structural revision (Codex PR review): added "Baseline constraints" section separating release-independent properties (advisory `after_*` hooks) from per-release deltas. v0.7.0 workflow engine revised (iii) → (ii) — v0.7.0 introduces a new enforcement surface (opportunity), while the advisory-hook limitation that motivates migration is a baseline constraint (pre-v0.6.0). Source citation replaced sibling-worktree HANDOFF pointer with durable in-repo references (upstream PR numbers, spec-kit SHAs, tag-to-tag `git log`).
- 2026-04-23 — removed dead HANDOFF cross-references (`.dispatch/` is untracked, session-scoped). Added "Stream B workstreams" section defining B1–B5 labels and Stream A/B context in-file, so the doc stands on its own without relying on external dispatch artifacts.
- 2026-04-24 — B2 adaptation test executed against spec-kit v0.7.4. All 6 original outstanding questions answered with evidence (install run, `.specify/extensions.yml` inspection, `git show` for #2243). Reclassifications: v0.6.3/v0.6.4/v0.7.1/v0.7.2/v0.7.4 rows moved from `needs-B2-confirmation` to `(i)/(ii)` with 2026-04-24 markers. Fixed misplaced #2296 dir-traversal row: moved from v0.7.4 section to new v0.7.5 section (`git tag --contains 569d18a` = v0.7.5+). Added v0.7.5 and v0.8.0 sections per "no batching" maintenance rule, with provisional classifications flagged `needs-B2-follow-up`. "Current upstream HEAD" updated v0.7.4 → v0.8.0. Committed `requires.speckit_version` pin in `presets/preflight/preset.yml` and `extensions/preflight/extension.yml` deliberately unchanged — pin widening stays gated on topology selection (B4).
- 2026-04-24 — B2-follow-up executed against spec-kit v0.8.0 (superset of v0.7.5). All 4 follow-up questions answered with evidence (install run + code inspection of `src/specify_cli/presets.py` + `git show` on #2133/#2189/#2320). Reclassifications: v0.7.5 preset-wrap and v0.8.0 composition-strategies rows confirmed `(ii)` as **opt-in opportunities, not required adjustments** (default `strategy: "replace"` preserves v0.7.x behavior); v0.8.0 `--force` shared-infra overwrite reclassified provisional `(ii)` → `(i) no-impact` (force semantics wired only to init/integration-upgrade paths, not `--dev` preset/extension adds). Committed pin still unchanged.
