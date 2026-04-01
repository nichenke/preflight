---
name: review
description: Validate a spec document against preflight framework rules and structural analysis — dispatches checklist (rule-based) and bogey (adversarial) reviewer agents, merges findings into a single report grouped by severity
---

# Review skill

Validate a spec document by dispatching two reviewer agents and merging their findings. Do not modify the document.

## 1. Resolve docs directory

Read `.preflight/config.yml` and extract the `docs_dir` value. If the file is missing or `docs_dir` is absent, default to `docs/`.

## 2. Determine which file to review

If the user provided a file path argument (e.g., `/preflight review path/to/file.md`):
- Use that path directly. If relative, resolve it from the project root.

If no argument was provided:
- Use Glob to list `{docs_dir}/**/*.md` files.
- Present the list to the user and ask which document to review.
- Wait for the user's selection before proceeding.

## 3. Identify document type

Read the target file. Check YAML frontmatter for a `type` field.

If `type` is present in frontmatter, use it.

If `type` is absent, infer from the file path:

| Path pattern | Doc type |
|---|---|
| `{docs_dir}/decisions/adrs/` | adr |
| `{docs_dir}/decisions/rfcs/` | rfc |
| `{docs_dir}/requirements.md` | requirements |
| `{docs_dir}/architecture.md` | architecture |
| `{docs_dir}/constitution.md` | constitution |
| `{docs_dir}/test-strategy.md` | test-strategy |
| `{docs_dir}/interfaces/` | interface-contract |

If no pattern matches and frontmatter has no `type`, ask the user what document type this is before proceeding.

## 4. Load rules

### 4.0 Verify .preflight/_rules/ exists

Use Bash to check:

```bash
test -d .preflight/_rules/ && echo "EXISTS" || echo "MISSING"
```

If the output is `MISSING`, stop and tell the user: "No `.preflight/_rules/` directory found. Run `/preflight scaffold` first to initialize the project."

### 4.1 Staleness note

The review always uses the project's committed copy of rules in `.preflight/_rules/`. If the plugin has been upgraded since the last scaffold run, the project copy may be out of date. Run `/preflight scaffold` to pull in the latest rules.

### 4.2 Determine rules files to load

**Always load:**
- `.preflight/_rules/universal-rules.md`

**Load type-specific rules if the file exists:**

| Doc type | Rules file |
|---|---|
| requirements | `requirements-rules.md` |
| adr | `adr-rules.md` |
| rfc | `rfc-rules.md` |
| architecture | `architecture-rules.md` |
| constitution | `constitution-rules.md` |
| interface-contract | (none — universal rules only) |
| test-strategy | (none — universal rules only) |

**Conditionally load cross-doc rules:**
- Use Grep to search the document for ID reference patterns: `FR-\d`, `NFR-\d`, `ADR-\d`, `CONST-[A-Z]`
- If any matches are found, also load `.preflight/_rules/cross-doc-rules.md`

Note the list of rules files to load — you will pass these paths to the reviewer agents.

## 5. Discover related documents

Build a list of related document paths for cross-doc analysis:

1. If `{docs_dir}/constitution.md` exists (and is not the doc being reviewed), add it.
2. Grep the document for references: `ADR-(\d+)`, `RFC-(\d+)`, `FR-(\d+)`, `NFR-(\d+)`.
3. For each ADR reference, check if `{docs_dir}/decisions/adrs/adr-{NNN}*.md` exists. Add the first match.
4. For each RFC reference, check if `{docs_dir}/decisions/rfcs/rfc-{NNN}*.md` exists. Add the first match.
5. If any FR or NFR references were found and `{docs_dir}/requirements.md` exists (and is not the doc being reviewed), add it.
6. Cap at 5 related documents total.

## 6. Dispatch checklist-reviewer

Use the Agent tool to dispatch a subagent with this prompt:

> You are the checklist-reviewer. Read the agent prompt at `{plugin_root}/agents/reviewers/checklist-reviewer.md` and follow it exactly.
>
> **Document to review:** {absolute_path_to_document}
> **Document type:** {doc_type}
> **Docs directory:** {docs_dir}
> **Rules directory:** .preflight/_rules/
> **Rules files to load:** {list of rules files from step 4}

Wait for the agent to complete. Save its output.

## 7. Dispatch bogey-reviewer

Use the Agent tool to dispatch a subagent with this prompt:

> You are the bogey-reviewer. Read the agent prompt at `{plugin_root}/agents/reviewers/bogey-reviewer.md` and follow it exactly.
>
> **Document to review:** {absolute_path_to_document}
> **Document type:** {doc_type}
> **Docs directory:** {docs_dir}
> **Rules directory:** .preflight/_rules/
> **Related documents for cross-doc analysis:** {list of paths from step 5}

Wait for the agent to complete. Save its output.

## 8. Merge and deduplicate

Read both agent outputs. Extract findings:
- From checklist-reviewer: all findings directly.
- From bogey-reviewer: only the **Layer 3 — Validated findings** section. Ignore Layer 1, Layer 2, and Suppressed sections for the merged report.

Deduplicate: if two findings describe the same underlying defect (same text quoted, same section targeted, same root cause), keep the one with higher confidence. Note the other source in parentheses.

Sort all findings by severity: Critical first, then Important, then Suggestion.

## 9. Format and report

Present the merged report:

```
## Review: {filename}
Document type: {doc_type} | Rules: {list of rules files loaded}

### Findings

**[Critical] {slug}** (confidence: {N}, {source})
{description with quoted evidence}
**Consequence:** {what breaks or misleads}
**Fix:** {one actionable step}

**[Important] {slug}** (confidence: {N}, {source})
...

**[Suggestion] {slug}** (confidence: {N}, {source})
...

### Strengths
- {from checklist-reviewer strengths section}

### Summary
{N} Critical, {M} Important, {P} Suggestions
Sources: {K} rule-based, {J} structural/cross-doc
```

Where `{source}` is the rule ID (e.g., UNIV-03, ADR-R02) for checklist findings or `structural` for bogey findings.

If no findings from either agent: report **PASS — no findings above confidence threshold**.

## 10. Constraints

- **Advisory only** — do not modify the document. Do not offer to auto-fix.
- Report findings and let the user decide what to act on.
- If either agent fails or times out, report findings from the agent that completed and note the failure.
