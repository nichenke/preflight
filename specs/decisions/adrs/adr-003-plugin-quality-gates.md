---
status: Accepted
date: 2026-03-28
deciders: [nic]
consulted: []
informed: []
---

# ADR-003: Require Automated Quality Gates Before Plugin Release

## Context and Problem Statement

The preflight plugin has quality requirements for skills (CONST-QA-01/02, NFR-004) but
no requirements for plugin-level quality: no automated tests for content integrity, no
functional testing that scaffold/new/review actually work, no plugin structure validation,
and no code review gate. Skills could pass evals individually while the plugin as a whole
ships broken content or a malformed manifest.

## Decision Drivers

- CONST-QA-01 requires skills be "measurably better than manual workflow before shipping"
  — but doesn't extend to the plugin structure or content files
- Content files (23 templates/rules/reference files) can drift — a missing file breaks
  scaffold silently
- The scaffold update flow (FR-008) must not clobber project files (FR-009) — this is only
  verifiable through functional testing
- ADR impact propagation (FR-023) is a complex multi-doc workflow that needs integration
  testing, not just skill evals

## Considered Options

1. Keep current quality gates (skill evals only)
2. Add automated content integrity tests and plugin validation
3. Add full quality gate suite: content tests, plugin validation, functional tests, code review

## Decision Outcome

Chosen option: "Full quality gate suite", because skill evals alone don't catch
plugin-level failures, and the cost of automated tests is low (bash scripts, no
dependencies) while the cost of shipping a broken plugin is high.

### Consequences

- Good, because content integrity is verified automatically — missing files caught before release
- Good, because functional tests verify scaffold/new/review work end-to-end
- Good, because plugin structure validation catches manifest and frontmatter issues early
- Good, because code review before shipping catches consistency issues across skills
- Bad, because adds testing overhead to every release — mitigated by automation
- Neutral, because functional tests require a Claude Code session (can't run in pure CI)

### Confirmation

All automated tests pass before merging the plugin conversion branch. Content integrity
tests run in CI on every push. Functional tests run manually before each release.

## Pros and Cons of the Options

### Keep current quality gates

Rely on NFR-004 skill evals only.

- Good, because no additional work
- Bad, because plugin-level failures (missing content, broken manifest) go undetected
- Bad, because FR-008/FR-009 (update flow, protected files) are untested

### Add content integrity tests and plugin validation

Automated bash tests + plugin-dev validator. No functional testing.

- Good, because catches structural issues automatically
- Bad, because doesn't verify skills actually work when invoked
- Bad, because complex flows like ADR impact propagation (FR-023) are untested

### Full quality gate suite

Content tests + plugin validation + functional tests + code review.

- Good, because comprehensive coverage from structure through behavior
- Good, because bash tests have no dependencies (NFR-001 compatible)
- Bad, because functional tests need manual Claude Code session
- Bad, because more to maintain

## More Information

- Constitution quality principles: CONST-QA-01, CONST-QA-02
- Skill eval requirement: NFR-004
- Protected files: FR-009
- Update flow: FR-008
- ADR impact propagation: FR-023
