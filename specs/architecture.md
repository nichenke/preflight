---
status: Draft
version: 0.7.0
owner: nic
date: 2026-04-11
---

# Preflight — Architecture & Design

## 1. Introduction & Goals

Preflight is a Claude Code plugin for spec-driven development — scaffold, guided
elicitation, and rule-based review. It runs entirely within Claude Code with no
external dependencies.

### Quality goals

| Priority | Quality attribute | How it's achieved |
|----------|------------------|-------------------|
| 1 | Zero dependencies | Everything is markdown and shell scripts — no package managers, no binaries (NFR-001) |
| 2 | Content integrity | Single source of truth with one-way flow — plugin owns content, projects get copies (CONST-CI-02) |
| 3 | Context efficiency | Auto-loaded rules stay lean to minimize agent context cost (NFR-003) |
| 4 | Governance traceability | Behavioral changes require version bumps; requirement changes require ADRs (CONST-PROC-01/02) |

## 2. Constraints

- **Platform:** Claude Code plugin system — skills, agents, rules, and hooks are the only extension points
- **Content format:** Markdown with YAML frontmatter — this is what the plugin system natively understands
- **No runtime:** No servers, no databases, no network calls — the plugin is a directory of files

## 3. System Context

Preflight exists entirely within Claude Code. The user invokes skills (`/preflight scaffold`, `new`, `review`), which operate on the plugin's content files and the target project's specs directory. There are no external systems or integrations.

The plugin interacts with two scopes:
- **Plugin repo** — where content is authored and maintained, with hook-based workflow enforcement
- **Target projects** — where content is scaffolded and specs are written and reviewed

## 4. Key Architectural Decisions

### Content-as-code with one-way flow

All framework content (templates, rules, reference material) lives in the plugin as plain files. The scaffold skill copies them into target projects. Content flows one direction only: plugin → project.

This means:
- The plugin has zero runtime dependencies — it's just files being copied
- Projects get a snapshot of the framework at scaffold time, not a live reference
- Updates require re-running scaffold, which compares and reports differences
- Edits to content happen in the plugin, never in a target project's copy

**Why not live references?** Claude Code plugins access content via `${CLAUDE_PLUGIN_ROOT}` paths, but the review skill needs rules to exist in the project for portability — a project should be reviewable even without the plugin installed. One-way copy solves this.

### Ensemble review (ADR-004)

Document review dispatches two independent agents with different strategies, then merges their findings:

- **Checklist reviewer** — rule-based, systematic. Loads applicable rules, checks each one, scores confidence. Catches violations of known rules.
- **Bogey reviewer** — adversarial, structural. Forms hypotheses about what could be wrong, investigates each with validation gates (verify, YAGNI, steelman). Catches cross-doc conflicts and structural defects that rules don't cover.

**Why two agents instead of one?** A single agent trying to be both systematic and creative tends to be mediocre at both. Separating the strategies lets each agent specialize. The merge step deduplicates by root cause — if both agents find the same defect, only the higher-confidence finding survives.

### Three enforcement tiers

| Tier | Mechanism | Strength | Scope |
|------|-----------|----------|-------|
| Deterministic | PreToolUse hooks | Blocks the action before it happens | Plugin repo only (ADR-005) |
| Advisory | Auto-loaded rules | Agent reads and follows (or doesn't) | Plugin repo + scaffolded projects (FR-021/FR-022) |
| On-demand | Review skill | Agent checks when asked | Target projects |

**Why not enforce review rules via hooks?** Hooks block tool use — appropriate for git workflow invariants (don't commit to main) but too blunt for spec quality rules. A spec with one missing ID shouldn't block all file writes. Review rules are advisory, checked when the user explicitly requests review. This remains out of scope for v1.

### Skill decomposition

Three user-facing skills map to three user journeys:
- **Scaffold** — project setup and framework updates (Journeys 1 & 4)
- **New** — guided document creation with type-specific elicitation (Journey 2)
- **Review** — ensemble validation dispatching two reviewer agents (Journey 3)

A fourth skill — **Issue Triage** — lives in `.claude/skills/` rather than the public `skills/` directory. It supports the maintainer workflow (Journey 6, FR-026) and is intentionally local to the plugin repo: it isn't shipped to scaffolded projects.

Each skill is a self-contained SKILL.md with its own instructions. Skills don't call each other — they're independent entry points.

## 5. Content Architecture

The plugin organizes content into four categories, each serving a different purpose:

- **Templates** — document type skeletons (7 types: requirements, ADR, RFC, architecture, constitution, interface contract, test strategy). Define what sections each doc type should have.
- **Rules** — review rules organized as universal (apply to all docs), cross-doc (traceability between docs), and type-specific (per doc type). Each rule has an ID, description, and severity.
- **Reference** — guidance material scaffolded into projects for agent context (EARS notation, doc taxonomy, cross-doc relationships).
- **Scaffolds** — starter files for new projects (constitution skeleton, glossary, meta-ADR).

Rule IDs are stable — renumbering or removing requires an ADR (CONST-CI-03). This ensures review findings remain traceable across plugin versions.

## 6. Runtime Behavior

### Scaffold flow

Scaffold checks whether the target project already has a `.preflight/` directory. Fresh projects get the full directory structure with all content. Existing projects get a comparison — the skill reports what's different and asks before updating framework files. Project-specific files (constitution, requirements, ADRs, etc.) are never overwritten.

**Failure:** If the plugin's content directory is missing or corrupt, scaffold stops and reports the issue rather than creating an incomplete `.preflight/` directory.

### Review flow

Review resolves the doc type, loads applicable rules, and dispatches both reviewer agents in parallel. When both complete, the skill merges findings: checklist findings come through directly, bogey findings only from the validated layer (Layer 3). Deduplication keeps the higher-confidence finding when both agents flag the same defect. Output is sorted by severity with file:line locations (ADR-006).

**Failure:** If either reviewer agent fails or times out, the skill reports findings from the agent that completed and notes the partial coverage.

### Elicitation flow

New resolves the doc type (prompting if not specified), reads the template, and walks through each section with guided questions. Requirements elicitation follows a specific sequence: problem → personas → journeys → EARS decomposition → NFRs → constraints/assumptions/out-of-scope → success measures with baselines and targets. For ADRs, the skill also identifies downstream docs needing updates after the decision is written.

**Failure:** If elicitation is abandoned mid-flow, no file is created — no partial artifacts are left behind.

### Error handling approach

All skills follow the same pattern: fail loud with actionable messages. When something goes wrong, the skill tells the user what happened and what to do about it (e.g., "No `.preflight/` directory found — run `/preflight scaffold` first"). Skills never silently skip steps or create partial output.

## 7. Architecture Decisions

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-002 | Convert from standalone repo to Claude Code plugin | Accepted |
| ADR-003 | Add automated quality gates (content integrity, plugin validation, e2e) | Accepted |
| ADR-004 | Ensemble reviewer architecture (checklist + bogey, merge findings) | Accepted |
| ADR-005 | Add maintainer workflow requirements (hooks, triage skill, traceability) | Accepted |
| ADR-006 | Include file:line-range locations in review findings | Accepted |

## 8. Risks & Technical Debt

| Risk | Impact | Mitigation |
|------|--------|------------|
| Claude Code plugin API changes | Skills or hooks may break on CC updates | Pin to documented API surface; test against each CC release |
| Rule file growth exceeds context budget | Agent performance degrades as rules consume more context | NFR-003 caps auto-loaded rules at 80 lines; review rules load on-demand, not at startup |
| Template drift from upstream (Notion) | Scaffolded content becomes stale vs. source framework | Manual sync; Notion tooling remains out of scope for v1 |
| Enumerated protection list (FR-009) vs. open set (CONST-DIST-02) | Custom project files outside the list could be overwritten | FR-008 provides broad protection; FR-009 enumerates the known cases as a safety net |
