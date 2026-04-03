---
name: scaffold
description: Bootstrap or update a project's preflight directory structure — creates .preflight/ with templates/rules/reference, project docs directory with skeleton constitution/glossary/meta-ADR, and .claude/rules/preflight.md with concrete paths
---

# Scaffold skill

Bootstrap or update a project's spec-driven development structure.

## 0. Resolve plugin root

Run the following Bash command to verify the plugin content is reachable:

```bash
if [ -z "${CLAUDE_PLUGIN_ROOT}" ]; then echo "PLUGIN_ROOT_NOT_SET"; elif [ -d "${CLAUDE_PLUGIN_ROOT}/content" ]; then echo "OK"; else echo "CONTENT_PATH_MISSING"; fi
```

- `OK` → proceed.
- `PLUGIN_ROOT_NOT_SET` → stop and tell the user: "CLAUDE_PLUGIN_ROOT is not set. The preflight plugin may not be installed correctly — try restarting Claude Code."
- `CONTENT_PATH_MISSING` → stop and tell the user: "Plugin content directory not found at ${CLAUDE_PLUGIN_ROOT}/content. The preflight plugin may not be installed correctly."

## 1. Detect current state

Use Bash to check whether `.preflight/` exists in the current project root:

```
test -d .preflight && echo "EXISTS" || echo "FRESH"
```

- If `EXISTS` → go to [Update existing project](#3-update-existing-project)
- If `FRESH` → go to [Fresh project setup](#2-fresh-project-setup)

## 2. Fresh project setup

### 2.1 Ask for docs directory

Ask the user: "Where should project specs live? (default: docs/)"

If the user accepts the default or gives no answer, use `docs/`. Store the chosen path as `{docs_dir}` (no trailing slash in config, but use trailing slash in mkdir commands).

### 2.2 Create .preflight/ framework content

Use Bash to copy framework content from the plugin into `.preflight/`:

```bash
mkdir -p .preflight/_templates .preflight/_rules .preflight/_reference
cp ${CLAUDE_PLUGIN_ROOT}/content/templates/* .preflight/_templates/
cp ${CLAUDE_PLUGIN_ROOT}/content/rules-source/* .preflight/_rules/
cp ${CLAUDE_PLUGIN_ROOT}/content/reference/* .preflight/_reference/
```

Note: `.preflight/_templates/`, `_rules/`, and `_reference/` are read-only reference copies for humans to browse (CONST-CI-02). The single source of truth is `content/` in the plugin. Never edit files in `.preflight/` directly — run `/preflight scaffold` to update them from the plugin.

### 2.3 Create project docs

Create skeleton documents in `{docs_dir}`:

1. Read `${CLAUDE_PLUGIN_ROOT}/content/scaffolds/constitution-skeleton.md` → Write to `{docs_dir}/constitution.md`
2. Read `${CLAUDE_PLUGIN_ROOT}/content/scaffolds/glossary-skeleton.md` → Write to `{docs_dir}/glossary.md`
3. Use Bash: `mkdir -p {docs_dir}/interfaces` then write an empty file `{docs_dir}/interfaces/.gitkeep`
4. Read `${CLAUDE_PLUGIN_ROOT}/content/scaffolds/adr-001-use-preflight.md` → Write to `{docs_dir}/decisions/adrs/adr-001-use-preflight.md` (create dirs with `mkdir -p` first)
5. Use Bash: `mkdir -p {docs_dir}/decisions/rfcs` then write an empty file `{docs_dir}/decisions/rfcs/.gitkeep`
6. Read `${CLAUDE_PLUGIN_ROOT}/content/scaffolds/agents-md-skeleton.md` → replace every `{docs_dir}` with the actual chosen path → Write to `AGENTS.md` at the project root. This file configures OpenAI Codex auto-review to use the project's governing documents.

### 2.4 Write .preflight/config.yml

Write `.preflight/config.yml` with contents:

```yaml
docs_dir: {docs_dir}
```

Replace `{docs_dir}` with the actual chosen directory path.

### 2.5 Generate .claude/rules/preflight.md

Create `.claude/rules/` with `mkdir -p` if it does not exist.

Write `.claude/rules/preflight.md` with the following content, replacing every `{docs_dir}` with the actual chosen path:

```markdown
# Preflight — project spec rules

## Before writing code

Read these files in order — skip any that don't exist:

1. `{docs_dir}/constitution.md` — overrides everything
2. `{docs_dir}/requirements.md` — EARS requirements with FR/NFR IDs
3. `{docs_dir}/architecture.md` — system structure, patterns, components
4. `{docs_dir}/interfaces/` — contracts at boundaries you're touching

Check `{docs_dir}/decisions/adrs/` only when modifying requirements or architecture
— ADR decisions should already be reflected in those docs.

## Requirements change governance

No behavioral requirement change without an ADR. If a change to requirements.md
would cause an agent to generate different code, it needs an ADR first.
Clarifications, typo fixes, and added failure modes do not.

## EARS quick reference

| Pattern | Keyword | Template |
|---------|---------|----------|
| Ubiquitous | (none) | The <system> shall <response>. |
| Event-driven | **When** | When <trigger>, the <system> shall <response>. |
| State-driven | **While** | While <precondition>, the <system> shall <response>. |
| Optional | **Where** | Where <feature>, the <system> shall <response>. |
| Unwanted | **If/then** | If <condition>, then the <system> shall <response>. |
| Complex | Combined | While <pre>, when <trigger>, the <system> shall <response>. |

## Document IDs

Assign unique IDs: FR-NNN, NFR-NNN, ADR-NNN, RFC-NNN, CONST-{CAT}-NN.
IDs are sequential and never reused.
```

### 2.6 Report results

Print a summary of everything created. Group by category:

- `.preflight/` framework files (count of templates, rules, reference files)
- Project docs in `{docs_dir}/`
- `.claude/rules/preflight.md`
- `AGENTS.md` (Codex auto-review configuration)

Remind the user to commit these files and that they can run `/preflight new` to create their first spec document.

## 3. Update existing project

### 3.1 Read current config

Read `.preflight/config.yml` and extract `docs_dir`.

### 3.2 Compare framework files

For each content category (templates, rules, reference):

1. Glob `${CLAUDE_PLUGIN_ROOT}/content/{category}/*` to get the source file list
2. For each source file, Read the source and Read the corresponding `.preflight/` copy
3. If the local copy does not exist → report it as a new file to add
4. If the local copy differs from the source → show the diff to the user using Bash: `diff -u .preflight/{subdir}/{file} ${CLAUDE_PLUGIN_ROOT}/content/{category}/{file} || true`
5. If identical → skip silently

The category-to-directory mapping:
- `templates/` → `.preflight/_templates/`
- `rules-source/` → `.preflight/_rules/`
- `reference/` → `.preflight/_reference/`

### 3.3 Ask user which changes to accept

Present all new and changed files as a list. Ask the user which changes to apply. Options:
- Accept all
- Accept individually (list each file)
- Skip all

For accepted changes: use Bash `cp ${CLAUDE_PLUGIN_ROOT}/content/{category}/{file} .preflight/{subdir}/{file}` to copy each accepted file.

### 3.4 Update .claude/rules/preflight.md

Re-generate `.claude/rules/preflight.md` using the template from section 2.5 with the `docs_dir` from config. This ensures the rules file stays current with the plugin version.

### 3.5 Protected files — NEVER overwrite

The update flow MUST NOT touch any of these files, regardless of what the user requests:

- `{docs_dir}/constitution.md`
- `{docs_dir}/glossary.md`
- `{docs_dir}/requirements.md`
- `{docs_dir}/architecture.md`
- `{docs_dir}/test-strategy.md`
- Anything in `{docs_dir}/interfaces/`
- Anything in `{docs_dir}/decisions/`
- `AGENTS.md` (user customizes review guidelines after scaffolding)

These are user-authored project documents. The scaffold skill only manages framework content in `.preflight/` and the rules file in `.claude/rules/preflight.md`. Project documents and AGENTS.md are created once during fresh setup and never modified by this skill afterward.

### 3.6 Report results

Print a summary of what was updated, what was skipped, and any new files that were added.
