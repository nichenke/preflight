# Preflight

A [spec-kit](https://github.com/github/spec-kit) preset and extension for spec-driven development. Ships curated doc-type templates, a 48-rule review rule set, and a two-agent review ensemble invokable on-demand via `/speckit.preflight.review`.

> **Note.** Preflight is currently in a validation spike for ADR-007 (feature-folder lifecycle). It was previously distributed as a Claude Code plugin — the conversion to a spec-kit extension is in progress. The integration-topology question (how preflight composes with spec-kit) is resolved in writing by ADR-009 (preset + extension as the distribution topology; enforcement-orchestration choice deferred to a follow-on ADR). See `docs/spikes/SPIKE_PLAN.md` for spike status and `specs/decisions/adrs/adr-009-integration-topology.md` for the topology decision.

## What you get

- **Preset** (`presets/preflight/`) — 7 doc-type templates (ADR, RFC, architecture, constitution, interface contract, requirements, test strategy) plus command overrides for `/speckit.tasks` and `/speckit.implement` that delegate task decomposition and execution to PAI Algorithm.
- **Extension** (`extensions/preflight/`) — a `speckit.preflight.review` command that runs a two-agent review ensemble (checklist + bogey) on your `spec.md` or `plan.md` on demand. Findings report in severity-graded format with stable rule IDs.

## Why two reviewers

- **Checklist reviewer** — rule-based pass over 48 curated rules (universal + type-specific + cross-doc) with confidence scoring. Catches rule violations with direct textual evidence.
- **Bogey reviewer** — adversarial pass using pre-committed hypotheses and Layer 1/2/3 validation gates. Catches structural and epistemic defects the rule set can't reach (unverifiable requirements, false hard constraints, silent cross-doc conflicts).

Merged findings are deduplicated and sorted by severity (Critical / Important / Suggestion).

## Install

Spec-kit's PyPI package (`specify-cli` on PyPI) is stale and has no preset/extension subcommands. Install from the git source:

```bash
pipx install "git+https://github.com/github/spec-kit.git@v0.6.2"
```

Then in your target project, install the preset and extension in local dev mode. Spec-kit's `preset add` / `extension add` commands read `preset.yml` / `extension.yml` directly from the directory you point them at, so the paths must target the manifest subdirectories (`presets/preflight/` and `extensions/preflight/`) — not the repo root:

```bash
specify preset add --dev /path/to/preflight/presets/preflight
specify extension add --dev /path/to/preflight/extensions/preflight
```

The preset and extension install into `.specify/presets/preflight/` and `.specify/extensions/preflight/` respectively. Command registration propagates through spec-kit's `CommandRegistrar` to all supported agent directories. `--dev` performs a one-shot copy (not a symlink), so edits to the source repo require re-running the install commands to propagate.

## Workflow

```
/speckit.specify <feature>          # scaffolds spec.md in preflight format
/speckit.preflight.review           # on-demand review of spec.md
/speckit.plan                       # scaffolds plan.md
/speckit.preflight.review           # on-demand review of plan.md
# (Task decomposition delegated to PAI Algorithm reading plan.md directly)
# (Implementation delegated to PAI Algorithm)
/speckit.archive <feature>          # ratify the feature folder (via archive extension)
```

> **Note on invocation.** Preflight review runs **on demand** via `/speckit.preflight.review` — it is not auto-triggered by spec-kit hooks. Per ADR-009 (integration topology), preflight ratifies the preset + extension distribution topology and defers enforcement orchestration (whether and how to automate review firing) to a follow-on ADR. Until that decision lands, **manually invoke `/speckit.preflight.review` after each `/speckit.specify` and `/speckit.plan`** to review the generated artifacts. Background on why `after_*` hooks don't enforce: `docs/analysis/2026-04-22-speckit-hook-philosophy.md`.

## Doc types

Requirements, Architecture, ADR, RFC, Interface Contract, Test Strategy, Constitution.

## Standards

- [EARS](https://alistairmavin.com/ears/) — Easy Approach to Requirements Syntax
- [MADR 4.0](https://github.com/adr/madr) — Markdown Any Decision Records
- [arc42](https://arc42.org) — Architecture documentation template

## Development

```bash
uv sync --group dev
uv run python -c "import yaml; yaml.safe_load(open('presets/preflight/preset.yml'))"
```

See `CLAUDE.md` for repo structure and development workflow.

## License

[MIT](LICENSE)
