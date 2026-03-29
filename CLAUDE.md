# Preflight — Claude Code Plugin

Plugin for spec-driven development. Provides three skills:
- `/preflight scaffold` — bootstrap or update project structure
- `/preflight new` — guided doc creation with elicitation
- `/preflight review` — rule-based document validation

## Repo structure

```
.claude-plugin/plugin.json   # Plugin manifest
skills/                       # Skill definitions (SKILL.md per skill)
content/
  templates/                  # Doc type templates (copied to .preflight/_templates/)
  rules-source/               # Review rules (copied to .preflight/_rules/)
  reference/                  # Framework reference material (copied to .preflight/_reference/)
  scaffolds/                  # Starter files for new projects
specs/                        # This plugin's own specs (requirements, constitution)
decisions/                    # This plugin's own ADRs and RFCs
docs/                         # Design docs and plans for this plugin
tests/                        # Automated content integrity tests
```

## Before modifying plugin behavior

1. Read `specs/constitution.md` — overrides everything
2. Read `specs/requirements.md` — EARS requirements with FR/NFR IDs
3. Read `decisions/adrs/` — accepted ADRs constrain choices
4. Any behavioral change requires a version bump in plugin.json (CONST-PROC-01)
5. Any behavioral requirement change requires an ADR (CONST-PROC-02)

## Content files

Templates, rules, and reference material in `content/` are the single source of truth
(CONST-CI-02). The scaffold skill copies these into target projects. Edit them here,
not in a target project's `.preflight/` directory.
