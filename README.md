# Preflight

A [spec-kit](https://github.com/github/spec-kit) preset and extension for spec-driven development. Ships curated doc-type templates, a 48-rule review rule set, and a two-agent review ensemble that hooks into spec-kit's lifecycle.

> **Note.** Preflight is currently in a validation spike (ADR-007, Topology A). It was previously distributed as a Claude Code plugin — the conversion to a spec-kit extension is in progress. See `docs/spikes/SPIKE_PLAN.md` for status.

## What you get

- **Preset** (`presets/preflight/`) — 7 doc-type templates (ADR, RFC, architecture, constitution, interface contract, requirements, test strategy) plus command overrides for `/speckit.tasks` and `/speckit.implement` that delegate task decomposition and execution to PAI Algorithm.
- **Extension** (`extensions/preflight/`) — a `speckit.preflight.review` command that runs a two-agent review ensemble (checklist + bogey) on your `spec.md` or `plan.md` via `after_specify` and `after_plan` hooks. Findings report in severity-graded format with stable rule IDs.

## Why two reviewers

- **Checklist reviewer** — rule-based pass over 48 curated rules (universal + type-specific + cross-doc) with confidence scoring. Catches rule violations with direct textual evidence.
- **Bogey reviewer** — adversarial pass using pre-committed hypotheses and Layer 1/2/3 validation gates. Catches structural and epistemic defects the rule set can't reach (unverifiable requirements, false hard constraints, silent cross-doc conflicts).

Merged findings are deduplicated and sorted by severity (Critical / Important / Suggestion).

## Install

Spec-kit's PyPI package (`specify-cli` on PyPI) is stale and has no preset/extension subcommands. Install from the git source:

```bash
pipx install "git+https://github.com/github/spec-kit.git@v0.6.2"
```

Then in your target project:

```bash
specify preset add /path/to/preflight
specify extension add /path/to/preflight
```

The preset and extension install into `.specify/presets/preflight/` and `.specify/extensions/preflight/` respectively. Command registration propagates through spec-kit's `CommandRegistrar` to all supported agent directories.

## Workflow

```
/speckit.specify <feature>          # scaffolds spec.md in preflight format
                                    # → after_specify hook fires preflight.review
/speckit.plan                       # scaffolds plan.md
                                    # → after_plan hook fires preflight.review
# (Task decomposition delegated to PAI Algorithm reading plan.md directly)
# (Implementation delegated to PAI Algorithm)
/speckit.archive <feature>          # ratify the feature folder (via archive extension)
```

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
