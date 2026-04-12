---
status: Draft
version: 0.7.0
owner: nic
date: 2026-04-11
---

# Preflight — Test Strategy

## Testing pyramid

### Content integrity tests (unit-level)

Shell scripts that verify the plugin's structural correctness without requiring Claude Code or any external dependencies.

**Implementation:** Bash scripts using standard POSIX tools. The current implementation uses bash for structured text validation, but the test runner technology is an implementation choice — the requirement is that tests run without Claude Code or external dependencies (NFR-005).

**Test files:**
- `tests/test-plugin.sh` — content integrity and plugin structure validation (99 assertions)
- `tests/test-hooks.sh` — hook behavior unit tests

**What they cover:**
- Plugin manifest exists and has required fields (name, description, version as semver)
- All content directories exist (`content/templates/`, `content/rules-source/`, `content/reference/`, `content/scaffolds/`)
- All template files exist and have valid YAML frontmatter with required fields (`type`, `doc_type`, `version`, `source`)
- All rules files exist and have valid frontmatter
- All reference files exist
- All scaffold files exist
- Skill files exist with valid frontmatter
- File references in skills resolve to actual files
- Test fixtures match source content (`.preflight/_rules/` mirrors `content/rules-source/`)
- Project docs exist and have valid frontmatter
- Hook scripts exist, are executable, and behave correctly

**Run:** `bash tests/test-plugin.sh && bash tests/test-hooks.sh`

### Skill eval tests (integration-level)

Each skill is validated with `/skill-creator` evals before shipping (NFR-004). Evals measure:
- Rule following: does the skill follow its SKILL.md instructions? (target: ≥85%)
- Activation ordering: does the skill execute steps in the correct order?
- Triggering accuracy: does the skill activate on the right inputs?

**Run:** `/skill-creator eval` per skill

### Plugin structure validation (integration-level)

The plugin structure passes `plugin-dev` validation with zero blocking findings before each release (NFR-006). This checks:
- Manifest completeness and correctness
- Skill frontmatter validity
- File reference resolution
- Agent definition validity

### Functional end-to-end tests (system-level)

Each release must pass 6 e2e test scenarios (NFR-009–NFR-014):

| NFR | Scenario | What it verifies |
|-----|----------|-----------------|
| NFR-009 | Fresh scaffold | `.preflight/` created with all framework content in a new project |
| NFR-010 | Custom docs dir | Scaffold respects configured docs directory |
| NFR-011 | Scaffold update without clobbering | Framework files updated, project files untouched (FR-008/FR-009) |
| NFR-012 | `/preflight new` for ADR and requirements | Guided elicitation produces well-structured docs |
| NFR-013 | `/preflight review` on valid and invalid docs | Findings reported correctly, clean docs pass |
| NFR-014 | ADR impact propagation | Downstream docs identified and updated (FR-023) |

**Current status:** E2e tests are manual — run via Claude Code in a test project. Automation is a future goal.

## Acceptance criteria mapping

| Requirement | Test type | Test location | Status |
|-------------|-----------|---------------|--------|
| FR-001–FR-007 | Content integrity | `tests/test-plugin.sh` | Automated |
| FR-008–FR-009 | E2e | Manual (NFR-011) | Manual |
| FR-010–FR-016 | E2e | Manual (NFR-012) | Manual |
| FR-017–FR-020 | E2e | Manual (NFR-013) | Manual |
| FR-021–FR-022 | Content integrity | `tests/test-plugin.sh` (rules file checks) | Automated |
| FR-023–FR-024 | E2e | Manual (NFR-014) | Manual |
| FR-025 | E2e | Manual | Manual |
| FR-026 | Content integrity | `tests/test-plugin.sh` (skill existence) | Automated |
| FR-027 | Content integrity | `tests/test-plugin.sh` (rules file checks) | Automated |
| FR-028–FR-029 | Unit | `tests/test-hooks.sh` | Automated |
| FR-030 | E2e | Manual (NFR-013) | Manual |
| NFR-001 | Content integrity | `tests/test-plugin.sh` (no external deps) | Automated |
| NFR-002 | E2e | Manual timing | Manual |
| NFR-003 | Content integrity | `tests/test-plugin.sh` (line count) | Automated |
| NFR-004 | Skill eval | `/skill-creator eval` | Semi-automated |
| NFR-005 | Content integrity | `tests/test-plugin.sh` | Automated |
| NFR-006 | Plugin validation | `plugin-dev` validation | Semi-automated |
| NFR-008 | Code review | `/simplify` or equivalent | Semi-automated |

## Environment strategy

Tests run in two environments:
- **Plugin repo:** `tests/test-plugin.sh` and `tests/test-hooks.sh` run directly against the repo
- **Test fixture:** `tests/fixtures/scaffolded-project/` provides a pre-scaffolded project for content mirror verification

No staging or production environments — the plugin is a file bundle, not a service.

## CI/CD integration

- **Pre-commit:** `tests/test-plugin.sh` and `tests/test-hooks.sh` must pass before merge
- **Pre-release:** All NFR-009–NFR-014 e2e scenarios must pass (currently manual)
- **Release gate:** Plugin version in `plugin.json` must be bumped for behavioral changes (CONST-PROC-01)

## Test fixture maintenance

The test fixture at `tests/fixtures/scaffolded-project/` mirrors the scaffold output. When content files change:
1. Update the source in `content/`
2. Update the fixture mirror in `tests/fixtures/scaffolded-project/.preflight/_rules/` (or `_templates/`, `_reference/`)
3. `test-plugin.sh` verifies the mirror matches the source — failures indicate a missed fixture update
