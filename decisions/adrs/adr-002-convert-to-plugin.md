---
status: Accepted
date: 2026-03-28
deciders: [nic]
consulted: []
informed: []
---

# ADR-002: Convert from CLAUDE.md-based to Plugin-based Distribution

## Context and Problem Statement

The PM Documentation Framework is currently distributed as a git repo that users copy into their projects. This requires editing CLAUDE.md to inject agent instructions, manually copying templates and rules, and hoping the content stays current across projects. The framework's rules are advisory — loaded via CLAUDE.md but not enforced. Updating the framework in existing projects means re-running a bootstrap prompt or manually diffing files.

Claude Code's plugin system offers native integration: auto-loaded rules via `.claude/rules/`, skills for guided workflows, and a versioned install/update path. Converting to a plugin would eliminate CLAUDE.md edits in target projects (CONST-DIST-01) and enable guided elicitation workflows that manual template copying can't provide.

## Decision Drivers

- CONST-DIST-01 requires rules auto-load via `.claude/rules/`, never requiring CLAUDE.md edits
- CONST-CI-01 requires the repo to be standalone without Notion access
- Existing SDD tools (Spec Kit, OpenSpec, BMAD) all require npm dependencies — a pure plugin avoids this
- Guided elicitation for spec authoring is the highest-value gap in the current manual workflow
- Plugin versioning (CONST-PROC-01) gives a cleaner update story than ad-hoc file copying

## Considered Options

1. Keep CLAUDE.md-based distribution (status quo)
2. Convert to Claude Code plugin with `.preflight/` project directory
3. Build an npm package (like OpenSpec/BMAD)

## Decision Outcome

Chosen option: "Convert to Claude Code plugin with `.preflight/` project directory", because it satisfies CONST-DIST-01 (auto-loaded rules), requires no external dependencies (NFR-001), enables guided elicitation skills, and provides a native update path through the plugin system.

### Consequences

- Good, because rules auto-load without CLAUDE.md edits in target projects
- Good, because skills provide guided elicitation (requirements EARS walkthrough, ADR options analysis, RFC problem-first exploration) that manual template copying can't
- Good, because plugin versioning gives a clean update story — `preflight scaffold` in existing projects reports diffs without overwriting project-specific files (FR-008, FR-009)
- Good, because no npm/pip/binary dependencies — everything is markdown and shell scripts
- Bad, because existing users of the git-copy approach need to migrate to the plugin
- Bad, because the plugin is Claude Code-only — doesn't help Cursor, Copilot, or other agents
- Neutral, because templates are copied into `.preflight/` on scaffold — users can customize but updates require manual diff review

### Confirmation

Validate with /skill-creator evals after building the three core skills (scaffold, new, review). Success: >90% activation accuracy, >85% rule-following on generated docs. Revisit if Claude Code plugin system changes in ways that affect distribution.

## Pros and Cons of the Options

### Keep CLAUDE.md-based distribution

Continue shipping as a git repo that users copy into projects.

- Good, because it works today with zero setup beyond git clone
- Good, because it's agent-agnostic — any AI tool can read CLAUDE.md
- Bad, because CLAUDE.md in target projects must be manually edited and kept current
- Bad, because no guided elicitation — users must read templates and figure out the workflow
- Bad, because updates mean re-running bootstrap prompt and manually resolving diffs

### Convert to Claude Code plugin

Ship as a plugin with auto-loaded rules, skills for scaffold/new/review, and `.preflight/` project directory.

- Good, because rules auto-load natively (CONST-DIST-01)
- Good, because skills guide authoring workflows
- Good, because no external dependencies
- Bad, because limited to Claude Code users
- Bad, because migration effort for existing git-copy users

### Build an npm package

Ship as an npm package like OpenSpec or BMAD, with a CLI for init/update.

- Good, because cross-tool support (any agent can use the scaffolded files)
- Good, because npm versioning and update is a solved problem
- Bad, because adds an npm dependency (violates NFR-001)
- Bad, because requires Node.js installed
- Bad, because duplicates what the plugin system already provides for Claude Code

## More Information

- Research on existing frameworks: docs/reviews/ in repo (session from 2026-03-23)
- Requirements spec: specs/requirements.md (FR-001 through FR-022, NFR-001 through NFR-004)
- Constitution: specs/constitution.md (CONST-DIST-01, CONST-CI-01, CONST-PROC-01)
- Plugin name: "preflight" — the checks before you fly; specs before you code
- Project directory: `.preflight/` in target repos
