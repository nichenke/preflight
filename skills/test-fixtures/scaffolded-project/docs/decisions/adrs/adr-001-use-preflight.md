---
status: Accepted
date: 2026-03-01
deciders: [platform-team]
consulted: [all-engineers]
informed: [all-engineers]
type: adr
version: 1.0.0
owner: platform-team
---

# ADR-001: Use Preflight for Spec-Driven Development

## Context and Problem Statement

The engineering team lacks a consistent approach to capturing requirements, architecture decisions, and interface contracts before implementation begins. AI coding assistants operate without project context, leading to implementations that contradict implicit decisions or miss non-functional requirements.

## Decision Drivers

- Need structured requirements before AI-assisted implementation
- Decisions must be traceable across the project lifecycle
- Framework must work without proprietary tooling (git-native)
- Low adoption friction for engineering teams

## Considered Options

1. Preflight Claude Code plugin
2. Manual CLAUDE.md rules authoring per project
3. External specification tools (Notion, Confluence)

## Decision Outcome

Chosen option: **Preflight Claude Code plugin**, because it provides structured elicitation, rule-based validation, and git-native distribution with no proprietary dependencies.

### Consequences

- Good, because all spec documents follow consistent formats with validated IDs
- Good, because rules auto-load via `.claude/rules/` without per-project CLAUDE.md edits
- Bad, because requires initial scaffold step before first document creation
- Neutral, because teams must learn EARS notation for requirements

### Confirmation

Review at 90-day mark: are requirements docs being created before implementation tasks? Target: >80% of features have requirements before first PR.

## Pros and Cons of the Options

### Preflight Claude Code plugin

Structured elicitation + validation + git-native distribution.

- Good, because EARS-formatted requirements with ID validation
- Good, because no external service dependency
- Bad, because requires Claude Code with plugin support

### Manual CLAUDE.md authoring

Teams write their own rules in CLAUDE.md.

- Good, because maximum flexibility
- Bad, because no consistency across projects, no validation

### External specification tools

Notion, Confluence, or similar.

- Good, because rich collaboration features
- Bad, because not git-native, breaks offline workflows, proprietary lock-in

## More Information

See `docs/constitution.md` for principles this decision enforces.
