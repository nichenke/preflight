---
name: review
description: Validate a spec document against preflight framework rules — checks type-specific, universal, and cross-doc rules from .preflight/_rules/, reports findings grouped by severity (Error/Warning) with rule IDs and fix suggestions
---

# Review skill

Validate a spec document against the project's preflight rules. Report findings grouped by severity. Do not modify the document.

## 0. Resolve plugin root

Run the following Bash command to verify `${CLAUDE_PLUGIN_ROOT}` is set:

```bash
echo "$CLAUDE_PLUGIN_ROOT"
```

If the output is empty or the variable is unset, stop and tell the user: "CLAUDE_PLUGIN_ROOT is not set. This skill requires the preflight plugin to be installed in Claude Code."

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

### 4.1 Staleness check

Before loading rules, compare the project copy against the plugin source to detect divergence. For each file in `.preflight/_rules/`, check whether the corresponding file in `${CLAUDE_PLUGIN_ROOT}/content/rules-source/` differs:

```bash
diff -rq .preflight/_rules/ ${CLAUDE_PLUGIN_ROOT}/content/rules-source/ || true
```

If any files differ or are missing from `.preflight/_rules/`, warn the user:

> "Warning: `.preflight/_rules/` is out of date with the installed plugin version. The review will use the project's current copy. Run `/preflight scaffold` to pull in the latest rules."

Continue with the review using the project copy — do not block on staleness.

### 4.2 Load rules files

Read rules from `.preflight/_rules/` (the project's committed copy, NOT from `${CLAUDE_PLUGIN_ROOT}`).

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
- If any matches are found, also read `.preflight/_rules/cross-doc-rules.md`

## 5. Evaluate each rule

Read the full document content. For each rule in every loaded rules file:

1. Parse the rule table rows — each row has a Rule ID, Rule text, and Severity.
2. Evaluate whether the document satisfies the rule.
3. If the rule is violated, record a finding with:
   - **Rule ID** — from the table (e.g., UNIV-03, REQ-R07)
   - **Severity** — Error or Warning, as specified in the rules table
   - **What's wrong** — a specific description referencing the actual content that violates the rule (quote or cite the section/line)
   - **Fix suggestion** — one concrete, actionable step to resolve the violation

Be thorough but precise. Do not flag rules that the document satisfies. Do not invent violations — each finding must trace to a specific rule ID and a specific deficiency in the document.

## 6. Report findings

Format the report as follows:

### Header

```
## Review: {filename}
Document type: {doc_type}
Rules checked: {list of rules files loaded}
```

### Findings — grouped by severity

List **Errors** first, then **Warnings**. For each finding:

```
### {Severity}: {Rule ID}
**Violation:** {what's wrong — specific}
**Fix:** {actionable suggestion}
```

### Summary line

Always end with a summary:

```
**Result: N Errors, M Warnings**
```

If zero Errors, report the document as **passing**:

```
**Result: PASS — 0 Errors, M Warnings**
```

## 7. Constraints

- **Advisory only** — do not modify the document. Do not offer to auto-fix.
- Report findings and let the user decide what to act on.
