---
status: Draft
version: 0.7.0
owner: nic
date: 2026-04-11
---

# Preflight — Architecture & Design

## 1. Introduction & Goals

### 1.1 Requirements overview

Preflight is a Claude Code plugin for spec-driven development. It provides three skills
(scaffold, new, review) backed by content files (templates, rules, reference material)
and enforced by hooks and auto-loaded rules. See `specs/requirements.md` for the full
specification.

### 1.2 Quality goals

| Priority | Quality attribute | Scenario |
|----------|------------------|----------|
| 1 | Zero dependencies | Plugin installs and runs with no npm, pip, or binary prerequisites (NFR-001) |
| 2 | Content integrity | Single source of truth in `content/` — scaffold copies to projects, never the reverse (CONST-CI-02) |
| 3 | Context efficiency | Auto-loaded rules stay under 80 lines to minimize agent context cost (NFR-003) |
| 4 | Governance traceability | Every behavioral change traces to a requirement ID and ADR (CONST-PROC-01, CONST-PROC-02) |

### 1.3 Stakeholders

| Role | Expectations |
|------|-------------|
| Project bootstrapper | Fast setup, correct directory structure, no surprises |
| Spec author | Guided elicitation that produces well-structured docs |
| Spec reviewer | Accurate findings with rule IDs and locations |
| Plugin author | Clear content editing workflow, version governance |

## 2. Constraints

### 2.1 Technical constraints

- **Platform:** Claude Code plugin system only — skills, agents, rules, and hooks
- **Content access:** All plugin content accessed via `${CLAUDE_PLUGIN_ROOT}` paths
- **File formats:** Templates, rules, and reference material are markdown with YAML frontmatter
- **No runtime dependencies:** No npm, pip, or binaries — content is markdown and shell scripts (NFR-001)

### 2.2 Organizational constraints

- Single maintainer (plugin author persona)
- Constitution governance: version bumps on behavioral changes (CONST-PROC-01), ADRs on requirement changes (CONST-PROC-02)

## 3. Context & Scope

### 3.1 System context

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
│                                                      │
│  ┌──────────────┐    ┌───────────────────────────┐  │
│  │  User/Agent  │───▶│   Preflight Plugin         │  │
│  │              │    │                             │  │
│  │  /preflight  │    │  Skills: scaffold,new,review│  │
│  │  scaffold    │    │  Agents: checklist, bogey   │  │
│  │  new         │    │  Rules: auto-loaded         │  │
│  │  review      │    │  Hooks: protect-main        │  │
│  └──────────────┘    └───────────┬───────────────┘  │
│                                  │                   │
│                      ┌───────────▼───────────────┐  │
│                      │   Target Project           │  │
│                      │                             │  │
│                      │  .preflight/                │  │
│                      │    _templates/ _rules/      │  │
│                      │    _reference/              │  │
│                      │  specs/ (project docs)      │  │
│                      │  .claude/rules/preflight.md │  │
│                      └───────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

External interfaces: none. Preflight is fully self-contained within Claude Code.

## 4. Solution Strategy

- **Content-as-code:** All framework content (templates, rules, reference) lives in `content/` as markdown files. The scaffold skill copies them into target projects. This means the plugin has zero runtime dependencies — it's just files.
- **Ensemble review:** Document review dispatches two independent agents (checklist + bogey) with different strategies, then merges findings. This catches both rule violations and structural defects (ADR-004).
- **Auto-loaded rules:** Framework rules inject into agent context via `.claude/rules/` — no CLAUDE.md edits needed in target projects (FR-021, CONST-DIST-01).
- **Deterministic workflow enforcement:** Git workflow invariants (worktrees, feature branches, no direct commits to main) are enforced by PreToolUse hooks in the plugin repo, not by advisory rules (FR-028, ADR-005).

## 5. Building Block View

### 5.1 Plugin components

| Component | Location | Responsibility | Implements |
|-----------|----------|---------------|------------|
| **Scaffold skill** | `skills/scaffold/SKILL.md` | Create/update `.preflight/` directory structure | FR-001–FR-009 |
| **New skill** | `skills/new/SKILL.md` | Guided document creation with elicitation | FR-010–FR-016, FR-023, FR-024 |
| **Review skill** | `skills/review/SKILL.md` | Dispatch reviewers, merge findings, report | FR-017–FR-020, FR-025, FR-030 |
| **Checklist reviewer** | `agents/reviewers/checklist-reviewer.md` | Rule-based review with confidence scoring | ADR-004 |
| **Bogey reviewer** | `agents/reviewers/bogey-reviewer.md` | Adversarial structural review with validation gates | ADR-004 |
| **Content: templates** | `content/templates/` | Document type templates (7 types) | CONST-CI-02 |
| **Content: rules** | `content/rules-source/` | Review rules (7 files: universal, cross-doc, 5 type-specific) | CONST-CI-02 |
| **Content: reference** | `content/reference/` | Framework reference material (6 files) | CONST-CI-02 |
| **Content: scaffolds** | `content/scaffolds/` | Starter files for new projects (constitution, glossary, meta-ADR, AGENTS.md) | FR-005, FR-007 |
| **Auto-loaded rules** | `.claude/rules/preflight.md` | Inject read-before-coding sequence and governance rules into agent context | FR-021, FR-022 |
| **Protect-main hook** | `.claude/hooks/protect-main.sh` | PreToolUse hook blocking direct commits/pushes to main | FR-028, FR-029 |
| **Issue-triage skill** | `.claude/skills/issue-triage/` | Local skill for structured issue assessment | FR-026 |
| **Traceability rule** | `.claude/rules/preflight.md` | Auto-loaded rule requiring spec traceability on behavioral fixes | FR-027 |

### 5.2 Content flow

```
content/                          Target project
  templates/ ──── scaffold ────▶ .preflight/_templates/
  rules-source/ ─ scaffold ────▶ .preflight/_rules/
  reference/ ──── scaffold ────▶ .preflight/_reference/
  scaffolds/ ──── scaffold ────▶ specs/ (constitution, glossary, meta-ADR)
```

Content flows one direction only: plugin → project. Edits happen in `content/` (the source of truth per CONST-CI-02), never in a target project's `.preflight/` directory.

### 5.3 Enforcement mechanisms

| Mechanism | Type | Scope | Implementation |
|-----------|------|-------|---------------|
| Git workflow invariants | PreToolUse hook | Plugin repo only | `.claude/hooks/protect-main.sh` via `.claude/settings.json` |
| Spec traceability | Auto-loaded rule | Plugin repo only | `.claude/rules/preflight.md` — advisory, enforced by agent compliance |
| Review rules | Review skill dispatch | Target projects | `.preflight/_rules/` — advisory, checked by checklist + bogey agents |

Hook-based enforcement is deterministic: the hook blocks the tool use and reports the violation (FR-028, FR-029). Rule-based enforcement is advisory: agents are expected to follow rules but are not mechanically prevented from violating them. Review-rule enforcement via hooks remains out of scope (Section 9 of requirements).

## 6. Runtime View

### 6.1 Scaffold (Journey 1 & 4)

1. User invokes `/preflight scaffold`
2. Skill checks if `.preflight/` exists
3. If new: creates directory structure, copies all content, creates skeleton docs
4. If existing: compares framework files against plugin source, reports differences
5. Never overwrites project-specific files (FR-009, CONST-DIST-02)

### 6.2 New document (Journey 2)

1. User invokes `/preflight new [type]`
2. Skill resolves doc type (prompt if not specified)
3. Skill reads template from `.preflight/_templates/`
4. Skill walks through guided elicitation for each template section
5. Skill writes document with populated frontmatter in the correct location
6. For ADRs: identifies downstream docs needing updates (FR-023)

### 6.3 Review (Journey 3)

1. User invokes `/preflight review [path]`
2. Skill resolves target file and doc type
3. Skill loads applicable rules (universal + cross-doc + type-specific)
4. Skill dispatches checklist-reviewer and bogey-reviewer agents in parallel
5. Skill merges findings: checklist findings directly, bogey Layer 3 validated findings only
6. Skill deduplicates by root cause, sorts by severity, reports with file:line locations (FR-030)

### 6.4 Protect-main hook (Journey 6)

1. Agent attempts Bash tool use with git commit/push/merge targeting main
2. PreToolUse hook (`protect-main.sh`) intercepts the tool input
3. Hook checks if the command targets main branch
4. If violation: blocks tool use, reports which invariant was violated and correct workflow (FR-029)
5. If clean: allows tool use to proceed

## 7. Deployment View

Not applicable — Preflight is a Claude Code plugin distributed as a directory of files. No servers, no containers, no infrastructure.

- **Installation:** Clone or install via Claude Code plugin management
- **Updates:** User runs `/preflight scaffold` to pull updated framework content into their project

## 8. Crosscutting Concepts

### 8.1 Version governance

Every behavioral change bumps the version in `plugin.json` (CONST-PROC-01). The plugin follows semver:
- Patch: bug fixes, typo corrections, clarifications
- Minor: new rules, new template sections, new reference material
- Major: breaking changes to scaffold output structure or skill behavior

### 8.2 Content integrity

The `content/` directory is the single source of truth (CONST-CI-02). Rule IDs are stable — renumbering or removing requires an ADR (CONST-CI-03). Content integrity is verified by automated tests before each release (CONST-QA-03).

### 8.3 Error handling

Skills report failures to the user with specific guidance:
- Missing `.preflight/`: directs to run `/preflight scaffold`
- Unrecognized doc type: asks for clarification
- File already exists: reports and asks how to proceed
- Elicitation abandoned: no file created, no partial artifacts

## 9. Architecture Decisions

| ADR | Title | Status |
|-----|-------|--------|
| ADR-002 | Convert to Claude Code plugin | Accepted |
| ADR-003 | Plugin quality gates | Accepted |
| ADR-004 | Reviewer agent architecture (ensemble: checklist + bogey) | Accepted |
| ADR-005 | Maintainer workflow requirements | Accepted |
| ADR-006 | Review finding locations (file:line-range) | Proposed |

## 10. Risks & Technical Debt

| Risk | Impact | Mitigation |
|------|--------|------------|
| Claude Code plugin API changes | Skills/hooks may break | Pin to documented API surface, test against each CC release |
| Rule file growth exceeds context budget | Agent performance degrades | NFR-003 caps auto-loaded rules at 80 lines; review rules are loaded on-demand |
| Template drift from upstream (Notion) | Scaffolded content becomes stale | Manual sync; Notion tooling remains out of scope for v1 |
| FR-009 enumerated file list vs CONST-DIST-02 open set | Custom project files could be overwritten | FR-008 provides broad protection; FR-009 enumerates known cases |
