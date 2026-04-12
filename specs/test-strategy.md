---
status: Draft
version: 0.7.0
owner: nic
date: 2026-04-11
---

# Preflight — Test Strategy

## Philosophy

Preflight is a file-based plugin with no runtime — testing focuses on structural
correctness (do the right files exist with the right content?) and behavioral
correctness (do the skills produce the right output?). There are no APIs to mock,
no databases to seed, no services to deploy.

The constraint shaping everything: tests must run without Claude Code or external
dependencies (NFR-005). This rules out test frameworks, package managers, and anything
that requires installation. Shell scripts with standard POSIX tools are the current
implementation choice.

## Testing levels

### Content integrity (automated, pre-commit)

Shell scripts verify the plugin's structural invariants: every expected file exists,
has valid YAML frontmatter with required fields, and content mirrors stay in sync with
their sources. These tests are fast, deterministic, and catch the most common class of
breakage — forgetting to update a fixture after changing a source file.

This level covers CONST-QA-03 (automated content integrity tests) and validates the
structural aspects of most FRs (file existence, frontmatter validity, reference resolution).

### Skill evals (semi-automated, pre-release)

Each skill is validated with `/skill-creator` evals measuring rule following (≥85%),
activation ordering, and triggering accuracy (NFR-004, CONST-QA-01/02). Evals run
against the skill's SKILL.md instructions — they test whether the agent follows the
skill definition, not whether the skill definition is correct.

### Plugin structure validation (semi-automated, pre-release)

Plugin-dev validation checks manifest completeness, skill frontmatter, file references,
and agent definitions (NFR-006, CONST-QA-04). This catches structural issues at the
plugin packaging level that content integrity tests don't cover.

### Functional end-to-end (manual, pre-release)

Six scenarios exercised manually in a test project (NFR-009–NFR-014, CONST-QA-05):
fresh scaffold, custom docs dir, scaffold update without clobbering, `/preflight new`
for multiple doc types, `/preflight review` on valid and invalid documents, and ADR
impact propagation. These test the full skill behavior including agent interaction.

E2e automation is a future goal — the current constraint is that these tests require
Claude Code running interactively.

## Quality gates

| Gate | What blocks | When |
|------|------------|------|
| Content integrity tests | Merge to main | Every PR (pre-commit) |
| Skill evals | Release | Before version bump |
| Plugin-dev validation | Release | Before version bump |
| E2e scenarios (all 6) | Release | Before version bump (manual) |
| Code review (`/simplify` or equivalent) | Release | Before shipping skill changes (NFR-008) |

## Coverage philosophy

**Automated tests verify structure, not behavior.** Content integrity tests confirm
files exist and have valid frontmatter — they don't test what the scaffold skill
actually does when invoked. Behavioral testing requires Claude Code running the
skills, which is why e2e tests are manual.

**Test fixtures are mirrors, not mocks.** The test fixture directory contains an exact
copy of what scaffold would produce. Tests verify the fixture matches the source. When
source content changes, the fixture must be updated — test failures indicate a missed
update, not a broken feature.

**Every FR traces to a test level.** Content-level FRs (file existence, structure) are
automated. Behavioral FRs (elicitation flow, review output, scaffold decisions) are
covered by e2e scenarios. The gap is automation of behavioral tests — currently manual,
tracked as technical debt.
