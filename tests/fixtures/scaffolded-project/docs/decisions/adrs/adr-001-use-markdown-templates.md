---
type: adr
status: accepted
date: 2026-02-15
decision_makers:
  - Jane Smith
  - Bob Chen
---

# ADR-001: Use Markdown Templates for Document Generation

## Context and Problem Statement

The team needs a consistent way to create specification documents. Currently, each team member uses their own format, leading to inconsistency and missing sections. How should we standardize document creation?

## Decision Drivers

- Team members have varying levels of experience with spec writing
- Documents must be reviewable by automated tooling
- Templates should be easy to update as standards evolve

## Considered Options

1. Markdown templates with YAML frontmatter
2. Google Docs templates shared via Drive
3. Custom web application with form-based input

## Decision Outcome

Chosen option: "Markdown templates with YAML frontmatter", because it integrates with version control, supports automated validation, and has zero external dependencies.

### Consequences

- Good, because documents are version-controlled alongside code
- Good, because automated review tooling can parse structured frontmatter
- Bad, because team members unfamiliar with Markdown need onboarding
- Neutral, because template updates require a scaffold re-run

## More Information

- Related to FR-001 (scaffold skill) and FR-002 (template management)
- Templates stored in `content/templates/` as single source of truth
