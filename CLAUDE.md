# Preflight — spec-kit preset + extension

Preflight is a [spec-kit](https://github.com/github/spec-kit) preset and extension for spec-driven development. It ships curated doc-type templates, a 48-rule review rule set, and a two-agent review ensemble (checklist + bogey) that hooks into spec-kit's `after_specify` / `after_plan` stages.

Preflight was previously distributed as a Claude Code plugin (v0.6.x). See `git log` for the conversion from plugin to spec-kit extension (Topology A, 2026-04-14).

## Repo structure

```
preflight/
├── presets/preflight/               # spec-kit preset (template + command overrides)
│   ├── preset.yml                   # preset manifest
│   ├── templates/                   # 7 doc-type templates (ADR, RFC, architecture, etc.)
│   └── commands/                    # speckit.tasks, speckit.implement (PAI redirects)
├── extensions/preflight/            # spec-kit extension (review + hooks)
│   ├── extension.yml                # extension manifest with after_specify / after_plan hooks
│   ├── commands/
│   │   └── speckit.preflight.review.md   # orchestrator (two-agent ensemble)
│   ├── agents/reviewers/            # checklist-reviewer + bogey-reviewer prompts
│   ├── rules/                       # 7 rule files (universal + type-specific + cross-doc)
│   └── scaffolds/                   # starter files (adr-001, constitution skeleton, etc.)
├── docs/                            # design docs, analysis, spikes, reference material
│   ├── analysis/                    # research passes + composable architecture work
│   ├── spikes/SPIKE_PLAN.md         # ADR-007 validation spike tracker
│   └── reference/                   # EARS, MADR, cross-doc relationships, etc.
├── specs/                           # preflight's own specs (requirements, decisions) — constitution moved to .specify/memory/ per ADR-007 Amendment 1
├── pyproject.toml                   # uv dev env (requires-python >=3.11, pyyaml, pytest)
└── uv.lock                          # reproducible dev env lockfile
```

## Before modifying behavior

- Any behavioral change requires a version bump in `presets/preflight/preset.yml` and `extensions/preflight/extension.yml` (both track `0.7.0-dev`)
- Any behavioral requirement change requires an ADR (CONST-PROC-02)
- `.specify/memory/constitution.md` (formerly `specs/constitution.md`, moved 2026-04-15 per ADR-007 Amendment 1) is currently being rewritten — CONST-CI-02 formerly required content to live in `content/` which no longer exists; do not cite CONST-CI-02 in new work until the rewrite lands

## Dev workflow

```bash
# one-time setup
uv sync --group dev

# lint YAML manifests
uv run python -c "import yaml; yaml.safe_load(open('presets/preflight/preset.yml')); yaml.safe_load(open('extensions/preflight/extension.yml'))"

# install spec-kit from git source (PyPI's specify-cli is stale)
pipx install "git+https://github.com/github/spec-kit.git@v0.6.2"

# install preflight preset + extension into a target project (dev mode, points at the manifest subdirs)
cd /path/to/target-project
specify preset add --dev /path/to/preflight/presets/preflight
specify extension add --dev /path/to/preflight/extensions/preflight
```

`--dev` does a one-shot copy from the source paths — re-run both commands after edits to propagate changes into the target project.

## Content source of truth

Templates, rules, agent prompts, and scaffolds live **inside** `presets/preflight/` and `extensions/preflight/`. Edit them there. There is no separate `content/` dir — the plugin-era layout was retired during conversion.

## Spike status

Preflight is currently in Phase 1 of the ADR-007 validation spike (Topology A — preflight as a spec-kit extension). See `docs/spikes/SPIKE_PLAN.md` for phase status and open questions. Until the spike promotes ADR-007, the layout should be considered provisional.

## Active Technologies
- Markdown edits only — no code changes in this feature + preflight checklist reviewer agent (reads `extensions/preflight/rules/constitution-rules.md`) (001-fix-const-reviewer-impl-detection)
- Git-tracked markdown files under `extensions/preflight/rules/` and `specs/001-fix-const-reviewer-impl-detection/fixtures/` (001-fix-const-reviewer-impl-detection)

## Recent Changes
- 001-fix-const-reviewer-impl-detection: Added Markdown edits only — no code changes in this feature + preflight checklist reviewer agent (reads `extensions/preflight/rules/constitution-rules.md`)
