# Preflight delivery shape — options and recommendation

**Date:** 2026-04-27
**Status:** Analysis (decision lands as ADR after Phase 1.2 review)
**Tests against:** `specs/jtbd.md` J5 (Adopt and update preflight in a project)
**Surfaced in:** PR #45 review as a Phase 1.2 open decision

## TL;DR

Ship preflight as a **Claude Code plugin** providing the kernel (rules + reviewer agents + Explore/Review workflows + doc-type templates), with **project-level overlay** at `.claude/preflight-config.json` (or `.claude/skills/preflight/overrides/`) for per-project rule additions, skips, severity overrides, and custom doc-types. This is the hybrid Option C below.

The hybrid satisfies J5's three motions (install, update, customize) without forcing projects to fork the kernel. Pure skill bundle (Option A) makes updates manual; pure plugin (Option B) makes per-project customization awkward. The hybrid sits at the sweet spot.

The decision belongs to ADR-012 (after ADR-011 is closed per the one-ADR-at-a-time process throttle).

## J5 — what we're testing against

`specs/jtbd.md` v0.2:

> **When** I'm trying preflight on a new project, updating to a newer version across multiple projects, or adapting its defaults to a project's specific shape (extra rules, skipped rules, custom doc-types), **help me** install, update, and customize preflight without losing project-local adjustments and without forcing every contributor to re-tool, **so that** preflight's value compounds across projects and over time rather than being gated on a one-time install ceremony each project does in isolation.

Three motions to satisfy:

1. **Install** — new project, first time. Friction should be low (one or two commands).
2. **Update** — newer version drops; the user has N projects using preflight. Friction should not scale with N.
3. **Customize** — projects need per-project rule additions / skips / overrides. Customization must survive updates without manual merge.

J5's failure mode: *"installed once, forgotten, fork drift"* — projects pin an old preflight, accumulate unmerged local edits, lose access to upstream improvements.

## Options

### Option A — Skill bundle (in-project)

**Shape:** `.claude/skills/preflight/` directory checked into each target project. Contains SKILL.md + Workflows/ + agents/ + rules/ + templates/. This is the shape currently sketched in `docs/analysis/2026-04-26-preflight-strategic-reimagine.md` § "What preflight ships."

**Install:** `cp -r preflight-repo/.claude/skills/preflight target-project/.claude/skills/preflight` OR `git submodule add github.com/nichenke/preflight target-project/.claude/skills/preflight`.

**Update:** if submodule, `git submodule update --remote`. If direct copy, `cp -r` again (overwrites local edits).

**Customize:** edit `.claude/skills/preflight/rules/*.md` in place. Cleanly customizable but…

**J5 verdict:**
- Install: ✅ easy.
- Update: ⚠️ scales with N projects (each project pulls its submodule). Submodule conflicts on local rule edits are a real cost.
- Customize: ⚠️ per-project edits collide with updates unless the user is disciplined about which files are "kernel" vs "local." No mechanical separation.

**Failure mode:** the *fork drift* failure J5 names. Every project has its own copy; over time they diverge from upstream and from each other.

### Option B — Plugin (user-level)

**Shape:** preflight ships as a Claude Code plugin. User installs once globally via `/plugin marketplace add nichenke/preflight && /plugin install preflight@nichenke`. The plugin's skills, agents, and rules live at `${CLAUDE_PLUGIN_ROOT}/`. Skills become namespaced: `/preflight:explore`, `/preflight:review`.

**Install:** two commands first time; zero per-project commands afterward.

**Update:** auto-update at Claude Code startup (toggleable per marketplace; opt-in for third-party). Or `/plugin marketplace update nichenke`. Updates apply globally — the user updates once, all projects get the new version.

**Customize:** awkward by default. Plugin rules are read-only at `${CLAUDE_PLUGIN_ROOT}`. Per-project customization needs a config surface — either:
- `.claude/settings.json` with plugin-specific hooks (limited to what the plugin exposes)
- A project-level overlay file the plugin reads at runtime

Without a designed customization surface, Option B forces every project to use the same kernel — which doesn't survive contact with reality (projects do have different needs).

**J5 verdict:**
- Install: ✅ trivially easy.
- Update: ✅ auto-updates handle the N-projects motion for free.
- Customize: ❌ unless a customization surface is designed alongside the plugin shape. Otherwise projects can't extend.

**Failure mode:** projects either (a) don't customize and live with kernel mismatches, or (b) bypass the plugin and roll their own — which loses the update mechanic.

### Option C — Hybrid (plugin + project overlay)

**Shape:** the kernel ships as a plugin (Option B). Each project that wants customization adds a small overlay at `.claude/preflight-config.json` (or `.claude/skills/preflight/overrides/`) that the plugin's workflows read at runtime. Overlay shape:

```jsonc
// .claude/preflight-config.json
{
  "extends": "preflight",
  "addRules": [
    "./rules/project-issue-traceability.md"
  ],
  "skipRules": ["UNIV-04"],
  "overrideSeverity": {
    "UNIV-07": "Suggestion"
  },
  "customDocTypes": [
    {
      "name": "gameplay-design",
      "template": "./templates/gameplay-design.md",
      "rules": ["./rules/gameplay-design.md"]
    }
  ]
}
```

Plugin's Explore + Review workflows look at the kernel rules + the overlay, in that order. Overlay can add, skip, override, or extend.

**Install:** plugin install (two commands, first-time only). Project sets up an overlay file when/if it needs to (optional; default kernel works without it).

**Update:** plugin auto-updates the kernel. Project overlay doesn't get touched (it lives outside the plugin). No merge conflicts.

**Customize:** project owns its overlay. Versioned in the project's git history. Survives kernel updates by construction.

**J5 verdict:**
- Install: ✅ as easy as Option B.
- Update: ✅ as cheap as Option B; overlay isolation prevents the merge-cost of Option A.
- Customize: ✅ explicit overlay surface; per-project versioning; no fork.

**Failure mode:** the overlay shape becomes an API. Breaking changes to the overlay format ripple through every project. Mitigation: version the overlay schema (`"schemaVersion": 1`); publish migrations alongside kernel updates that change the schema.

## Trade-off matrix

| Concern | A: Skill bundle | B: Plugin | C: Hybrid |
|---|---|---|---|
| First-time install | 1 command (cp/submodule) | 2 commands (marketplace + install) | 2 commands (same as B) |
| Update across N projects | N submodule pulls | 1 auto-update | 1 auto-update |
| Per-project rule customization | edit in place (collides w/ updates) | requires plugin-exposed config | overlay file (clean) |
| Customization survives updates | ❌ manual merge required | n/a (no surface) | ✅ overlay isolated |
| Versioning model | per-project pin | global single | global kernel + per-project overlay |
| Composability with hooks/commands | manual integration | auto-discover | auto-discover (kernel) + project hooks coexist |
| Bootstrapping new contributor in project | clone repo, get bundle | install plugin once | install plugin once + read overlay |
| Maintainer cost (1+ project) | high | lowest | low |
| Failure mode | fork drift | one-size-fits-all | overlay-API stability |

## Recommendation

**Option C — Hybrid.** Plugin kernel + project overlay.

Rationale:
1. **J5's update motion is the deciding factor.** Option A's manual update path is the *fork drift* failure mode J5 names. Hybrid eliminates it.
2. **J5's customize motion forces an overlay regardless.** Even if we shipped pure skill bundle (A), every project would need a way to manage local edits separately from kernel content. The overlay is needed; it might as well be designed.
3. **Plugin distribution is the dominant idiom for Claude Code add-ons.** Adopting it puts preflight where users will look, with the install/update mechanic users already know.
4. **The overlay schema is small to design** — addRules / skipRules / overrideSeverity / customDocTypes covers the customization needs we've actually seen in the rule-design history.

## What this changes for the reshape (PR #45)

### Roadmap Phase 3.2 (restructure to skill bundle) → restructure to **plugin**

Current Phase 3.2 task says:

> Create `.claude/skills/preflight/` skill bundle structure ... `git mv` operations: extensions/preflight/rules/* → .claude/skills/preflight/rules/

Under hybrid, the structure is:

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
  scripts/
    new-overlay.sh                      # bootstraps .claude/preflight-config.json in a target project
```

Skill invocation becomes `/preflight:explore` and `/preflight:review` (namespaced).

Project repos add (optional):
```
target-project/
  .claude/
    preflight-config.json               # overlay file
    rules/                              # project-local rules referenced from overlay
```

### Roadmap Phase 3.3 / 3.4 / 3.5

No changes — Explore workflow, gap-reviewer agent, SKILL.md orchestration all live inside the plugin.

### Roadmap Phase 4.5 (ship v0.7.0) — install instructions change

Current:
> `cp -r preflight/.claude/skills/preflight <target>/.claude/skills/preflight`

New:
> `/plugin marketplace add nichenke/preflight && /plugin install preflight@nichenke` (one-time per user)
> Optionally: create `.claude/preflight-config.json` in any project that needs custom rules.

## What this DOESN'T change

- **The four "in-use" Jobs (J1–J4).** Hybrid is invisible to Builders, Supervisors, Maintainers, and Returning readers. They use `/preflight:explore` and `/preflight:review` (or whatever the user-facing entry is); nothing about the harness Jobs depends on which delivery shape ships them.
- **The harness shape itself.** `specs/requirements.md`, ADRs under `specs/decisions/adrs/`, etc. — all stay markdown-on-disk in the target project. J4 (contributor-readable) is unaffected.
- **The reshape direction.** ADR-011 (drop spec-kit, ship as a Claude Code workflow tool) still holds. This refines what the workflow tool's *delivery* looks like.

## Open questions for the ADR

1. **Overlay format.** JSON, YAML, or markdown with frontmatter? Project rule rule-design suggests markdown frontmatter is more legible; JSON is more programmable. Lean markdown for J4 (contributor-readable).
2. **Overlay location.** `.claude/preflight-config.json` is conventional; `.claude/skills/preflight/overrides/` is more discoverable. Pick after surveying peer plugins.
3. **Schema versioning.** Embed `"schemaVersion": 1` from day one; otherwise migrations get expensive.
4. **Marketplace.** Use Anthropic's official marketplace or a self-hosted one? Self-hosted gives faster iteration; official gives reach. Probably self-hosted initially, migrate later.
5. **Kernel customization surface scope.** The minimum viable overlay surface is addRules + skipRules. overrideSeverity and customDocTypes are nice-to-have. Start narrow; expand on real demand.

## Bottom line

Hybrid is the right shape. The roadmap's Phase 3 tasks need a small structural update (skill-bundle directory → plugin directory + plugin.json). Phase 1.2's Confirm-list updates: the delivery decision is *resolved* (hybrid plugin + overlay), pending an ADR to ratify it.

J5 is the test the hybrid passes that A and B individually don't.

## References

- [Claude Code plugins (official docs)](https://code.claude.com/docs/en/plugins.md)
- [Plugin reference — manifest, components, CLAUDE_PLUGIN_ROOT](https://code.claude.com/docs/en/plugins-reference.md)
- [Discovering plugins (official + third-party marketplaces)](https://code.claude.com/docs/en/discover-plugins.md)
- [Skill discovery and namespacing](https://code.claude.com/docs/en/skills.md)
- [`specs/jtbd.md` v0.2](../specs/jtbd.md) — J5 (this analysis's test)
- [`docs/analysis/2026-04-26-preflight-strategic-reimagine.md`](2026-04-26-preflight-strategic-reimagine.md) — the reshape proposal this refines
- [`docs/plans/2026-04-26-preflight-roadmap.md`](../plans/2026-04-26-preflight-roadmap.md) Phase 3 — the tasks affected
