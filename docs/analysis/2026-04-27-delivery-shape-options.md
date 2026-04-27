# Preflight delivery shape — options and recommendation

**Date:** 2026-04-27
**Status:** Analysis (decision lands as ADR after Phase 1.2 review)
**Tests against:** `specs/jtbd.md` J5 (Adopt and update preflight in a project)
**Surfaced in:** PR #45 review as a Phase 1.2 open decision

## TL;DR

Ship preflight as a **Claude Code plugin** providing the kernel (rules + reviewer agents + Explore/Review workflows + doc-type templates). Projects that want to add their own rules or doc-types drop them into `.preflight/rules/` (or `.preflight/templates/`) at the repo root — discovered alongside the kernel by the reviewer agents at runtime. No overlay-config file, no skip mechanism, no severity overrides — just additive rule discovery from two locations.

This is **Option B** below. Earlier framings of this analysis proposed an overlay-config file (`.claude/preflight-config.json`) layered on top — that's been dropped. There's no JTBD-evidenced demand for skip / override / config-format mechanisms; additive rule discovery is enough. Anything more is bureaucracy that hasn't earned its keep.

**Trade-off acknowledged honestly:** Option B's blast radius on a bad kernel update is *all of a user's projects at once*. Mitigations exist (auto-update opt-in, version pinning at install, canary on a low-stakes project) but per-project pinning is not a Claude Code plugin native feature. If a project domain has hard rollback requirements that exceed those mitigations, Option D (plugin-as-content-copier) becomes the right answer despite its update friction. For preflight's current usage profile (Nic + small set of projects), Option B's mitigations are sufficient.

The decision belongs to ADR-012 (after ADR-011 is closed per the one-ADR-at-a-time process throttle).

## J5 — what we're testing against

`specs/jtbd.md` v0.2:

> **When** I'm trying preflight on a new project, updating to a newer version across my projects, or adding project-specific rules or doc-types alongside the kernel defaults, **help me** install, update, and extend preflight without forcing every contributor to re-tool, **so that** preflight's value compounds across projects and over time rather than being gated on a one-time install ceremony each project does in isolation.

Three motions to satisfy:

1. **Install** — new project, first time. Friction should be low (one or two commands).
2. **Update** — newer version drops; the user has N projects using preflight. Friction should not scale with N.
3. **Extend** — projects need to *add* project-specific rules or doc-types. Additions must survive updates without manual merge.

J5's failure mode: *"installed once, forgotten, fork drift"* — projects pin an old preflight, accumulate divergent copies, lose access to upstream improvements.

J5 deliberately does not name *skipping* kernel rules, *overriding* severities, or any *config-format* concern. Those are not currently evidenced demands; absent demand, designing for them is bureaucracy.

## Options

### Option A — Skill bundle (in-project)

**Shape:** `.claude/skills/preflight/` directory checked into each target project. Contains SKILL.md + Workflows/ + agents/ + rules/ + templates/. This is the shape currently sketched in `docs/analysis/2026-04-26-preflight-strategic-reimagine.md` § "What preflight ships."

**Install:** `cp -r preflight-repo/.claude/skills/preflight target-project/.claude/skills/preflight` OR `git submodule add github.com/nichenke/preflight target-project/.claude/skills/preflight`.

**Update:** if submodule, `git submodule update --remote` per project. If direct copy, `cp -r` again (overwrites local edits).

**Extend:** edit `.claude/skills/preflight/rules/*.md` in place. Cleanly extensible but additions and edits collide with updates.

**J5 verdict:**
- Install: ✅ easy.
- Update: ⚠️ scales with N projects; submodule conflicts on local rule edits are real cost.
- Extend: ⚠️ additions and updates share the same directory tree; merge cost on every update.

**Failure mode:** the *fork drift* failure J5 names. Every project owns its copy; over time they diverge from upstream and from each other.

### Option B — Plugin (recommended)

**Shape:** preflight ships as a Claude Code plugin at `github.com/nichenke/preflight`. Users install once globally via `/plugin marketplace add nichenke/preflight && /plugin install preflight@nichenke`. The plugin's skills, agents, and rules live at `${CLAUDE_PLUGIN_ROOT}/`. Skills are namespaced: `/preflight:explore`, `/preflight:review`.

For project-specific additions: a project drops rule files into `.preflight/rules/` and template files into `.preflight/templates/` at the repo root. The plugin's reviewer agents discover rules from both `${CLAUDE_PLUGIN_ROOT}/skills/preflight/rules/` (kernel) and `<repo>/.preflight/rules/` (project additions) at invocation time. Same shape, additive.

**Install:** two commands first time per user; zero per-project commands afterward (default kernel works).

**Update:** auto-update at Claude Code startup (toggleable per marketplace; opt-in for third-party). Or `/plugin marketplace update nichenke`. Updates apply globally — the user updates once, all projects get the new kernel.

**Extend:** project drops markdown rule files into `.preflight/rules/`; reviewer picks them up alongside the kernel. No config format, no schema, no skip mechanism. The same rule format used by the kernel works for project additions.

**J5 verdict:**
- Install: ✅ trivially easy.
- Update: ✅ auto-update handles N projects for free.
- Extend: ✅ additive discovery; project additions live in `.preflight/`, kernel lives in plugin — no collision possible.

**Failure modes:**
1. *Kernel hostility* — if the kernel ships a rule that's wrong for a specific project, the project can't disable it; they live with the finding or open an issue against the kernel. Mitigation: severity grading ({Critical, Important, Suggestion}) lets projects ignore lower-severity findings; a Critical-severity rule that's wrong for a project is a kernel-design conversation, not a per-project fix.
2. *Update blast radius* — a bad kernel update propagates to all of a user's projects at once with no per-project pin. Claude Code plugins do not have native per-project version pinning. **Mitigations to wire in at adoption time:** (a) keep auto-update OFF by default for the preflight marketplace (opt-in per the user's risk tolerance); (b) pin to a specific version on install (`/plugin install preflight@nichenke@<version>` — PEP 440 versions); (c) test new versions on a single canary project before rolling forward; (d) `/plugin uninstall && /plugin install <prior-version>` is the rollback path if a bad version ships. Mitigations are real but not perfect — they require user discipline.
3. *Dual-source confusion* — projects that have additions in `.preflight/rules/` plus the plugin kernel could see findings come from either source. Mitigation: every finding cites a rule ID; the rule ID's namespace (kernel vs project) makes the source visible.

### Option C — Hybrid (plugin kernel + overlay config) — REJECTED

Earlier framing of this doc proposed a hybrid: plugin kernel + project-level overlay config (`.claude/preflight-config.json`) with addRules / skipRules / overrideSeverity / customDocTypes fields.

**Why rejected:** no JTBD-evidenced demand for skip / override / config-format. J5 names install + update + extend; the *extend* motion is fully covered by additive rule discovery (Option B). Adding an overlay format introduces:
- A schema to design and version
- A precedence model (kernel vs overlay, which wins?)
- A new artifact type for projects to maintain
- Documentation overhead

…all to solve problems that haven't surfaced. If a real demand emerges (a project repeatedly needs to skip or override a kernel rule), revisit. Until then, the kernel ships with severity, and projects ignore findings they don't want to act on.

This is the right cut per the project rule "Don't add features, error handling, or abstractions beyond the task scope." Overlay config is a hypothetical-future-requirement design.

### Option D — Plugin-as-content-copier (the original preflight plugin shape)

**Shape:** preflight ships as a Claude Code plugin, but on installation the plugin *copies* its rule and template content into the target project's `.preflight/` directory. After install, the project owns the copy; the kernel content in the plugin is a source-of-truth template, but each project has its own snapshot. This was the v0.6.x preflight plugin shape, before the spec-kit conversion.

**Install:** `/plugin install`, then run a "bootstrap" command that copies content into the project. Two-step.

**Update:** `/plugin update` updates the plugin globally — but the *copies* in each project don't update. To get new rules into a project, the user has to re-run a "sync" or "re-bootstrap" command in each project, which either overwrites local edits or creates merge conflicts.

**Extend:** edit the copied content in `.preflight/`. Project owns its copy after install.

**J5 verdict:**
- Install: ⚠️ two steps.
- Update: ❌ kernel updates don't propagate to projects automatically; the user has to manually sync each project, accepting overwrite or doing a merge. Same N-projects friction as Option A, plus the version-confusion of "which version did this project copy?"
- Extend: ✅ project owns its copy.

**Honest assessment:** this combines the *worst* of A and B. It has the in-project copy fork-drift problem of A (each project is a snapshot that diverges) AND the install ceremony of B (two-step plugin + bootstrap), AND it loses B's auto-update benefit (copies don't auto-update). The only thing it adds over A is a marginally nicer install (`/plugin install` vs `cp -r`).

The historical reason this shape existed (in preflight v0.6.x) was that Claude Code plugins did not yet have first-class skill discovery — copying content into the project was the only way to make it discoverable. That constraint no longer applies; plugins now have `${CLAUDE_PLUGIN_ROOT}` and namespaced skill invocation. Option D is a relic of an earlier Claude Code era.

**Verdict:** overkill, as you predicted. Strictly dominated by Option B for J5's three motions. Including it for completeness; not recommending it.

## Trade-off matrix

| Concern | A: Skill bundle | B: Plugin (recommended) | C: Hybrid (rejected) | D: Plugin-as-copier |
|---|---|---|---|---|
| First-time install | 1 command | 2 commands (per user) | 2 commands | 2 commands |
| Per-project install | 1 command | 0 commands | 0 commands | 1 command (re-bootstrap) |
| Update across N projects | N submodule pulls | 1 auto-update | 1 auto-update | N manual syncs |
| Project rule additions | edit in place | drop into `.preflight/rules/` | overlay config + addRules | edit copy in `.preflight/` |
| Additions survive updates | ❌ manual merge | ✅ separate dirs | ✅ overlay isolated | ❌ manual merge |
| Skip / override kernel rules | edit in place | not supported (live with severity) | overlay supports it | edit copy |
| **Per-project version pinning** | ✅ submodule SHA | ❌ not native (user-level only) | ❌ kernel is global | ✅ snapshot is frozen |
| **Rollback path on bad update** | ✅ git revert submodule | ⚠️ uninstall + reinstall older version | ⚠️ same as B for kernel | ✅ keep old snapshot |
| **Blast radius of bad update** | per-project (isolated) | global (all user's projects) | global (all user's projects) | per-project (isolated) |
| New artifact required | none | `.preflight/rules/` (just markdown) | `.preflight/preflight-config.json` (schema) | `.preflight/` snapshot of kernel |
| Versioning model | per-project pin | global single | global kernel + per-project overlay | per-project snapshot |
| Composability with hooks/commands | manual | auto-discover | auto-discover | manual |
| Maintainer cost (1+ project) | high | lowest | low-medium | high |
| Failure mode | fork drift | kernel hostility + update blast radius (mitigated, not eliminated) | overlay-API stability | fork drift + version confusion |

## Recommendation

**Option B — Plugin.** Kernel ships in the plugin; project additions land at `.preflight/rules/` and `.preflight/templates/` and are discovered by the reviewer agents alongside the kernel.

Rationale:
1. **J5's three motions are all satisfied** without any new artifact type beyond a directory convention.
2. **Pure plugin auto-update is the cheapest update story** in any pattern Claude Code currently supports.
3. **Additive rule discovery is the simplest extension surface** — same rule shape used by the kernel works for projects. No schema, no precedence model, no skip mechanism.
4. **Severity grading mitigates kernel hostility** — kernel rules ship as Critical / Important / Suggestion; a bad-fit Suggestion is ignored, a bad-fit Critical is a kernel-design conversation (not a per-project workaround).
5. **`.preflight/` keeps project state out of `.claude/`**, which keeps the project's Claude Code config surface clean and gives preflight a clearly named home.

**Trade-off accepted honestly: Option B has the largest blast radius on a bad kernel update (all of a user's projects, no per-project pin).** This is the cost of B's auto-update value. The user-level mitigations (auto-update opt-in, install-time version pin, canary project, uninstall-and-reinstall-old as rollback) reduce but do not eliminate the risk. If preflight's user base later includes contexts where blast radius would be catastrophic — multi-team org, regulatory environment, projects whose specs the org cannot afford to break simultaneously — Option D's per-project snapshot becomes the right answer despite its update friction. For the current usage profile (single maintainer, small project set, where any breakage is recoverable in minutes), Option B's mitigations are sufficient and the simplicity wins. ADR-012 should record this trade-off explicitly so the decision is revisitable as the user base changes.

## What this changes for the reshape (PR #45)

### Roadmap Phase 3.2 (restructure to skill bundle) → restructure to **plugin**

Current Phase 3.2 task says:

> Create `.claude/skills/preflight/` skill bundle structure ... `git mv` operations: extensions/preflight/rules/* → .claude/skills/preflight/rules/

Under Option B, the structure is:

```
preflight-plugin-repo/
  plugin.json                           # plugin manifest
  skills/
    preflight/
      SKILL.md                          # Explore + Review entry
      Workflows/
        Explore.md
        Review.md
      rules/                            # 48-rule kernel
      templates/                        # 6 doc-type templates
      agents/
        checklist-reviewer.md
        bogey-reviewer.md
        gap-reviewer.md
```

Skill invocation: `/preflight:explore` and `/preflight:review`.

Project repos (optional, only if they need additions):
```
target-project/
  .preflight/
    rules/                              # project-specific rule files (markdown, kernel format)
    templates/                          # project-specific doc-type templates
```

Reviewer agent discovery walks both `${CLAUDE_PLUGIN_ROOT}/skills/preflight/rules/` and the project's `.preflight/rules/` if it exists. Both are markdown files in the same shape; no precedence rules, no override semantics — just additive.

### Roadmap Phase 4.5 (ship v0.7.0) — install instructions change

Current:
> `cp -r preflight/.claude/skills/preflight <target>/.claude/skills/preflight`

New (per user, one time):
> `/plugin marketplace add nichenke/preflight`
> `/plugin install preflight@nichenke`

Per project (optional, only if additions are needed):
> Create `.preflight/rules/<your-rule>.md` with the same frontmatter shape kernel rules use.

### Roadmap Phase 1.2 confirm-list

Update from:
> Open: delivery shape — skill bundle vs plugin. ... Add J5 (or sibling specs/delivery-jtbd.md) before locking the delivery shape.

To:
> Resolved (this analysis): plugin (Option B) per `docs/analysis/2026-04-27-delivery-shape-options.md`; ratified by ADR-012 after ADR-011 closes.

## What this DOESN'T change

- **The four "in-use" Jobs (J1–J4).** Plugin shape is invisible to Builders, Supervisors, Maintainers, and Returning readers. They use `/preflight:explore` and `/preflight:review`; nothing about the harness Jobs depends on which delivery shape ships them.
- **The harness shape itself.** `specs/requirements.md`, ADRs under `specs/decisions/adrs/`, etc. — all stay markdown-on-disk in the target project. J4 (contributor-readable) is unaffected.
- **The reshape direction.** ADR-011 (drop spec-kit, ship as a Claude Code workflow tool) still holds.

## Open questions for ADR-012

1. **Marketplace.** Use Anthropic's official marketplace or self-hosted? Self-hosted gives faster iteration; official gives reach. Probably self-hosted initially.
2. **`.preflight/` discovery scope.** Reviewer agents walk the project's `.preflight/rules/` recursively or only top-level? Recursive is more flexible; top-level is more predictable. Lean top-level.
3. **Plugin manifest.** Versioning policy (PEP 440), author/repository fields, plugin description — boilerplate but worth deciding once.
4. **Naming.** Plugin name = `preflight`; skill name = `preflight`; namespace becomes `/preflight:explore`. Confirm this collision is fine (it is — they're distinct surfaces in Claude Code's model).

## Bottom line

Plugin (Option B). `.preflight/` for project additions. No overlay config, no skip mechanism, no schema. The simplest thing that satisfies J5's three motions.

If real demand emerges later for skip / override / config (a real project repeatedly needs to disable a kernel rule), revisit. Until then, the kernel rules + severity grading + project-additive rules cover the field.

## References

- [Claude Code plugins (official docs)](https://code.claude.com/docs/en/plugins.md)
- [Plugin reference — manifest, components, CLAUDE_PLUGIN_ROOT](https://code.claude.com/docs/en/plugins-reference.md)
- [Discovering plugins (official + third-party marketplaces)](https://code.claude.com/docs/en/discover-plugins.md)
- [Skill discovery and namespacing](https://code.claude.com/docs/en/skills.md)
- [`specs/jtbd.md` v0.2](../specs/jtbd.md) — J5 (this analysis's test)
- [`docs/analysis/2026-04-26-preflight-strategic-reimagine.md`](2026-04-26-preflight-strategic-reimagine.md) — the reshape proposal this refines
- [`docs/plans/2026-04-26-preflight-roadmap.md`](../plans/2026-04-26-preflight-roadmap.md) Phase 3 — the tasks affected
