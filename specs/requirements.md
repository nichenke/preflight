---
status: Active
version: 0.7.0
owner: nic
date: 2026-04-11
stakeholders: []
---

# Preflight — Requirements Specification

## 1. Problem Statement

AI coding agents produce better results with structured specifications, but adopting a
documentation framework today requires manual setup: copying templates, editing CLAUDE.md,
remembering governance rules. The PM Documentation Framework exists as a git repo with
templates, rules, and reference material, but installing it into a project means copying
files, hoping CLAUDE.md content stays current, and relying on agents to follow advisory
rules without enforcement. Existing SDD tools (Spec Kit, OpenSpec, BMAD) solve pieces of
this but require npm dependencies and don't integrate natively with Claude Code's plugin
system.

## 2. Users & Personas

**Project bootstrapper** — Engineer setting up the framework in a new or existing project.
Goals: get the directory structure, templates, and rules in place quickly. Pain point:
manual copying is error-prone and the "right" setup isn't obvious.

**Spec author** — Engineer creating requirements, ADRs, RFCs, or architecture docs during
development. Goals: produce well-structured docs that agents can consume. Pain point:
templates exist but the authoring workflow (what to fill in, what order, how to decompose
journeys into EARS requirements) isn't guided.

**Spec reviewer** — Engineer or agent checking documents against framework rules. Goals:
catch missing IDs, vague language, governance violations, cross-doc inconsistencies. Pain
point: reviewing means manually reading the rules file and checking each rule.

**Plugin author** — Engineer evolving the framework itself (templates, rules, skills).
Goals: modify framework content and ship updates. Pain point: changes must be versioned,
tested, and synced across the repo and any Notion upstream.

## 3. User Journeys / Jobs to Be Done

### Journey 1: Bootstrap a project

- Trigger: Engineer installs the preflight plugin and wants to set up a project
- Steps:
  1. Engineer runs `/preflight scaffold`
  2. Plugin creates `.preflight/` directory with templates, rules, and reference material
  3. Plugin creates skeleton `constitution.md` and `glossary.md`
  4. Plugin creates `decisions/adrs/` and `decisions/rfcs/` directories
  5. Plugin creates `adr-001-use-preflight.md` meta-ADR
- Success: `.preflight/` directory exists with all framework content, ready to use
- Failure: Directory already exists — plugin reports what's there, asks before overwriting
  framework files, never overwrites project-specific files

### Journey 2: Create a new spec document

- Trigger: Engineer needs a new requirements spec, ADR, RFC, or other doc type
- Steps:
  1. Engineer runs `/preflight new` (or `/preflight new adr`)
  2. Plugin asks which doc type if not specified
  3. Plugin walks through guided elicitation appropriate to that doc type:
     - Requirements: problem statement → personas → journeys → EARS decomposition → NFRs
     - ADR: context → decision drivers → options → pros/cons → decision → consequences
     - RFC: problem → proposed solution → alternatives → migration plan → risks
     - Architecture: requirements overview → context → strategy → building blocks
     - Interface contract: protocol → endpoints → SLA → error handling
     - Test strategy: pyramid levels → acceptance mapping → environments
     - Constitution: preamble → categories → principles (imperative, testable)
  4. Plugin creates the file in the correct location with filled frontmatter
- Success: Well-structured document created in the right location
- Failure: File already exists at target path — plugin reports and asks how to proceed
- Failure: Unrecognized doc type — plugin asks for clarification
- Failure: `.preflight/` directory missing — plugin directs user to run `/preflight scaffold` first
- Failure: Elicitation abandoned mid-flow — no file created, no partial artifacts left behind

### Journey 3: Review a document

- Trigger: Engineer has written or modified a spec and wants quality validation
- Steps:
  1. Engineer runs `/preflight review` (or `/preflight review specs/requirements.md`)
  2. Plugin identifies doc type from frontmatter or file location
  3. Plugin reads the applicable rules file from `.preflight/_rules/`
  4. Plugin reads universal rules and cross-doc rules
  5. Plugin checks each rule, reports findings grouped by severity (Error, Warning)
- Success: Structured report with specific findings, rule IDs, and fix suggestions
- Failure: Doc type unrecognized — plugin asks for clarification

### Journey 4: Update framework content

- Trigger: New version of preflight plugin is installed, framework content has changed
- Steps:
  1. Engineer runs `/preflight scaffold` in existing project
  2. Plugin detects `.preflight/` already exists
  3. Plugin compares framework files (templates, rules, reference) against plugin source
  4. Plugin reports diffs and asks which to accept
  5. Plugin never touches project-specific files (constitution, requirements, ADRs, etc.)
- Success: Framework files updated, project files untouched
- Failure: Merge conflicts in customized templates — plugin shows diff, user resolves
- Failure: Plugin content directory missing — plugin reports installation issue and stops

### Journey 5: Evolve framework content

- Trigger: Plugin author needs to add or modify templates, rules, or reference material
- Steps:
  1. Author edits files in `content/` (single source of truth per CONST-CI-02)
  2. Author runs content integrity tests to verify structure and frontmatter
  3. Author bumps version in plugin.json (CONST-PROC-01)
  4. Author runs `/preflight scaffold` locally to verify copy behavior
  5. Author opens PR, passes plugin-dev validation and e2e tests
- Success: Updated plugin released, existing projects pick up changes via `/preflight scaffold`
- Failure: Content integrity tests fail — author fixes before proceeding
- Failure: Behavioral change without ADR — PR review catches governance violation (CONST-PROC-02)

### Journey 6: Maintain the plugin repo (Persona: plugin author)

- Trigger: Plugin author needs to triage issues, enforce workflow, or assess repo health
- Steps:
  1. Author triages open GitHub issues against current specs and constitution
  2. For each issue: verifies root cause against current code, maps to spec coverage (FR/NFR/CONST), classifies governance needs (ADR or not per REQ-R07)
  3. Author proposes fixes with dependency-ordered decomposition, each item tracing to a requirement ID
  4. Workflow invariants (worktrees, feature branches, PRs) are enforced by hooks — deterministic, not advisory
  5. Author commits work on feature branches via worktrees, never directly to main
- Success: Issues triaged with structured assessment, fixes traced to specs, workflow enforced deterministically
- Failure: Issue root cause no longer valid — author closes issue with disconfirming evidence
- Failure: Fix requires spec changes with no existing FR — author identifies the spec gap and creates an ADR before proceeding

## 4. Functional Requirements

### Scaffold

- FR-001: When the user runs `/preflight scaffold`, the plugin shall create the `.preflight/` directory structure with `_templates/`, `_rules/`, `_reference/`, and `interfaces/` subdirectories.
- FR-002: When the user runs `/preflight scaffold`, the plugin shall copy all template files from the plugin's `templates/` directory into `.preflight/_templates/`.
- FR-003: When the user runs `/preflight scaffold`, the plugin shall copy all rules files from the plugin's `rules-source/` directory into `.preflight/_rules/`.
- FR-004: When the user runs `/preflight scaffold`, the plugin shall copy all reference files from the plugin's `reference/` directory into `.preflight/_reference/`.
- FR-005: When the user runs `/preflight scaffold`, the plugin shall create skeleton `constitution.md` and `glossary.md` in the configured docs directory.
- FR-006: When the user runs `/preflight scaffold`, the plugin shall create `decisions/adrs/` and `decisions/rfcs/` directories.
- FR-007: When the user runs `/preflight scaffold`, the plugin shall create `decisions/adrs/adr-001-use-preflight.md` with the meta-ADR recording framework adoption.
- FR-008: While `.preflight/` already exists, when the user runs `/preflight scaffold`, the plugin shall compare framework files against plugin source and report differences without overwriting project-specific files.
- FR-009: The plugin shall never overwrite `constitution.md`, `glossary.md`, `requirements.md`, `architecture.md`, `test-strategy.md`, any file in `interfaces/`, or any file in `decisions/`.

### New document creation

- FR-010: When the user runs `/preflight new`, the plugin shall prompt for doc type if not specified.
- FR-011: When the user runs `/preflight new <type>`, the plugin shall walk through all sections defined in the doc type's template before creating the file.
- FR-012: When creating a requirements spec, the plugin shall guide the user through: problem statement, personas, user journeys with failure modes, EARS functional requirements, non-functional requirements with quantitative criteria, constraints, assumptions, success measures, and out-of-scope items.
- FR-013: When creating an ADR, the plugin shall guide the user through: context, decision drivers, at least two options with pros and cons, decision outcome with consequences, and confirmation criteria.
- FR-014: When creating an RFC, the plugin shall guide the user through: executive summary, problem statement with measurable evidence, scope, proposed solution, at least one alternative, migration/rollout plan with rollback, risks, and success criteria.
- FR-015: When the plugin creates a new document, the plugin shall populate YAML frontmatter with status, date, owner, and version.
- FR-016: When the plugin creates a new document, the plugin shall assign the next sequential ID for that doc type.
- FR-023: When creating an ADR, after the document is written, the plugin shall identify downstream docs (requirements, architecture, constitution, interfaces) that need updates to reflect the decision, propose specific changes, and apply approved changes.
- FR-024: When creating an ADR, the plugin shall flag any ADR consequences that cannot be traced to a downstream doc.

### Review

- FR-017: When the user runs `/preflight review`, the plugin shall identify the doc type and check all applicable rules from `.preflight/_rules/`.
- FR-018: When reviewing a document, the plugin shall check all universal rules and all cross-doc rules in addition to type-specific rules.
- FR-019: When reviewing a document, the plugin shall report findings grouped by severity (Error, Warning) with rule IDs and specific fix suggestions.
- FR-020: If a reviewed document has zero Error findings, the plugin shall report it as passing review.
- FR-025: When the user runs `/preflight review` on a document inside a sub-project that lacks its own `.preflight/_rules/`, the plugin shall walk up the directory tree to find the nearest ancestor `.preflight/_rules/` and use those rules — without requiring the sub-project to be independently scaffolded.
- FR-030: When reviewing a document, each finding shall include the file path (relative to project root) and line range (`L{start}-L{end}`) where the evidence appears, formatted as `— \`{path}:L{start}-L{end}\`` on the finding header line (ADR-006).

### Rules auto-loading

- FR-021: The plugin shall auto-load framework rules into agent context via `.claude/rules/` without requiring CLAUDE.md edits in the target project.
- FR-022: When the plugin installs rules via `/preflight scaffold`, the plugin shall include in the auto-loaded rules file: the read-before-coding sequence (constitution, requirements, architecture, interfaces — ADRs excluded, referenced only when modifying requirements or architecture), requirements change governance (REQ-R07), and EARS quick reference.

### Maintainer workflow (Persona: plugin author) — ADR-005

- FR-026: The plugin repo shall provide a local issue-triage skill (`.claude/skills/`) that produces structured assessments with evidence-backed validity verdicts, spec gap maps, governance classifications, and dependency-ordered fix decompositions.
- FR-027: Every proposed behavioral fix shall trace to a requirement ID (FR/NFR/CONST) or explicitly identify a missing requirement — enforced by an auto-loaded rule in `.claude/rules/`.
- FR-028: The plugin repo shall enforce git workflow invariants (worktrees, feature branches, PRs — no direct commits to main) via PreToolUse hooks that block violations deterministically.
- FR-029: While a git workflow hook blocks a tool use, the hook shall report which invariant was violated and what the correct workflow is.

## 5. Non-Functional Requirements

- NFR-001: The plugin shall have no external dependencies — no npm, no pip, no binaries. All content is markdown files and shell scripts within the plugin directory.
- NFR-002: The `/preflight scaffold` skill shall complete in under 5 seconds for a new project.
- NFR-003: The auto-loaded rules file shall not exceed 80 lines — context budget must be managed.
- NFR-004: Each skill shall be validated with /skill-creator evals before shipping, scoring ≥85% for rule following, activation ordering, and triggering accuracy.
- NFR-005: The plugin shall include automated content integrity tests that verify all expected files exist, have valid frontmatter, and contain required structural elements. Tests shall run without Claude Code or external dependencies.
- NFR-006: The plugin structure shall pass plugin-dev validation with zero blocking findings (manifest, skill frontmatter, file references) before each release.
- NFR-009: Each release shall pass a functional end-to-end test for fresh scaffold into a new project.
- NFR-010: Each release shall pass a functional end-to-end test for scaffold with a custom docs directory.
- NFR-011: Each release shall pass a functional end-to-end test for scaffold update without clobbering project files (FR-008/FR-009).
- NFR-012: Each release shall pass functional end-to-end tests for `/preflight new` on at least ADR and requirements doc types.
- NFR-013: Each release shall pass functional end-to-end tests for `/preflight review` on valid and invalid documents.
- NFR-014: Each release shall pass a functional end-to-end test for ADR impact propagation (FR-023).
- NFR-008: All skill files shall pass code review with zero blocking findings (/simplify or equivalent) before shipping — checking for consistency across skills, edge case coverage, and frontmatter triggering quality.

## 6. Constraints

- Technical: Claude Code plugin system only — no CLI, no npm package, no external tooling
- Technical: Plugin content accessed via `${CLAUDE_PLUGIN_ROOT}` paths
- Technical: Templates, rules, and reference files are markdown with YAML frontmatter
- Process: Constitution (CONST-PROC-01) requires version bump on any behavioral change

## 7. Assumptions

- Claude Code plugin system supports skills, rules, and hooks as documented
  - Validation: test with a minimal plugin before building full feature set
- Users will install the plugin via Claude Code's plugin management
  - Validation: confirm installation path works for both local and published plugins
- `.preflight/` will not conflict with existing project directories
  - Validation: search GitHub for `.preflight/` usage

## 8. Success Measures

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| Context cost of rules | 135 lines (current CLAUDE.md) | <80 lines (auto-loaded rules file) | Line count of `.claude/rules/preflight.md` |
| Skill activation accuracy | N/A (no skills today) | >90% correct triggering | /skill-creator eval suite |
| Rule-following accuracy | N/A | >85% of rules followed without reminder | /skill-creator eval on generated docs |
| Content integrity tests | N/A | 0 failures | `tests/test-content-integrity.sh` exit code |
| Functional test coverage | N/A | All 6 e2e tests pass (NFR-009–NFR-014) | Automated e2e test suite exit code |

## 9. Out of Scope

- Mechanical review-rule enforcement via hooks — review rules are advisory, enforced by the review skill, not by hooks (git workflow hooks per FR-028 are in scope)
- Integration with Spec Kit, OpenSpec, or BMAD workflows
- Notion sync tooling (stays manual, separate from the plugin)
- Task/story decomposition templates (identified gap, not addressed in v1)
- UX specification templates (identified gap, not addressed in v1)
- Multi-agent support beyond Claude Code

## 10. Open Questions

- What is the best file layout within `.preflight/` — flat or nested?
  Owner: nic. Target: before ADR-002.
- Should the meta-ADR (adr-001) go in `.preflight/decisions/adrs/` or `decisions/adrs/`?
  Owner: nic. Target: before scaffold implementation.
- How should `/preflight new` handle doc types that need a filename (e.g., `rfc-003-auth-approach.md`)?
  Owner: nic. Target: before new skill implementation.
