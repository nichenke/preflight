---
description: Review a spec document against preflight rules using a two-agent ensemble (checklist + bogey) with confidence scoring and Layer 3 validation gates
---

# /speckit.preflight.review — preflight extension

Validate a spec document by dispatching two reviewer subagents and merging their findings. Do **not** modify the document.

This command is a faithful port of the preflight plugin's `skills/review/` skill into native spec-kit form. The two reviewer prompts live at `.specify/extensions/preflight/agents/reviewers/checklist-reviewer.md` and `.../bogey-reviewer.md` and are dispatched via the host agent's subagent/Task mechanism.

## 1. Determine the target document

The target is determined in this order:

1. **Explicit argument** — if the user passed a path, use it. Resolve relative paths from the project root.
2. **Hook context (`after_specify`)** — the most recently modified `spec.md` under `.specify/features/<current>/`
3. **Hook context (`after_plan`)** — the most recently modified `plan.md` under the same directory
4. **Interactive fallback** — if none of the above, Glob `{project_docs_dir}/**/*.md` (default `docs/` if no `{project_docs_dir}` is configured), present the list, and ask the user to pick one. Wait for their selection before proceeding.

## 2. Identify document type

Read the target file. Check YAML frontmatter for a `type` field.

If `type` is present in frontmatter, use it.

If `type` is absent, infer from the file path:

| Path pattern | Doc type |
|---|---|
| `**/decisions/adrs/` | adr |
| `**/decisions/rfcs/` | rfc |
| `**/requirements.md` | requirements |
| `**/architecture.md` | architecture |
| `**/constitution.md` | constitution |
| `**/test-strategy.md` | test-strategy |
| `**/interfaces/` | interface-contract |
| `**/spec.md` | spec (generic feature spec) |
| `**/plan.md` | plan (generic feature plan) |

If no pattern matches and frontmatter has no `type`, ask the user what document type this is before proceeding.

## 3. Determine which rules files to load

The preflight rules live at `.specify/extensions/preflight/rules/`.

**Always load:**
- `universal-rules.md`

**Load type-specific rules when the file exists:**

| Doc type | Rules file |
|---|---|
| requirements | `requirements-rules.md` |
| adr | `adr-rules.md` |
| rfc | `rfc-rules.md` |
| architecture | `architecture-rules.md` |
| constitution | `constitution-rules.md` |
| interface-contract | (none — universal only) |
| test-strategy | (none — universal only) |
| spec | (universal only; generic feature spec) |
| plan | (universal only; generic feature plan) |

**Conditionally load cross-doc rules:**
Grep the document for ID references: `FR-\d`, `NFR-\d`, `ADR-\d`, `RFC-\d`, `CONST-[A-Z]`. If any match, also load `cross-doc-rules.md`.

Record the list of rules files — you'll pass these paths to the checklist reviewer.

## 4. Discover related documents

Build a list of related document paths for the bogey reviewer's cross-doc analysis:

1. If `{project_docs_dir}/constitution.md` exists and is not the doc being reviewed, add it.
2. Grep the target document for references: `ADR-(\d+)`, `RFC-(\d+)`, `FR-(\d+)`, `NFR-(\d+)`.
3. For each ADR reference, check if a matching ADR file exists at `{project_docs_dir}/decisions/adrs/adr-{NNN}*.md`. Add the first match.
4. For each RFC reference, check if a matching RFC file exists at `{project_docs_dir}/decisions/rfcs/rfc-{NNN}*.md`. Add the first match.
5. If FR/NFR references exist and `{project_docs_dir}/requirements.md` exists (and is not the doc being reviewed), add it.
6. Cap at 5 related documents.

## 5. Dispatch the checklist reviewer

Use your subagent/Task mechanism to dispatch a reviewer with this prompt:

> You are the checklist-reviewer. Read the agent prompt at `.specify/extensions/preflight/agents/reviewers/checklist-reviewer.md` and follow it exactly.
>
> - **Document to review:** {absolute_path_to_document}
> - **Relative path (for findings output):** {path_relative_to_project_root}
> - **Document type:** {doc_type}
> - **Project docs directory:** {project_docs_dir}
> - **Rules directory:** `.specify/extensions/preflight/rules/`
> - **Rules files to load:** {list from step 3}

Wait for the subagent to complete. Save its output verbatim.

## 6. Dispatch the bogey reviewer

Use your subagent/Task mechanism to dispatch a second reviewer with this prompt:

> You are the bogey-reviewer. Read the agent prompt at `.specify/extensions/preflight/agents/reviewers/bogey-reviewer.md` and follow it exactly.
>
> - **Document to review:** {absolute_path_to_document}
> - **Relative path (for findings output):** {path_relative_to_project_root}
> - **Document type:** {doc_type}
> - **Project docs directory:** {project_docs_dir}
> - **Rules directory:** `.specify/extensions/preflight/rules/`
> - **Related documents for cross-doc analysis:** {list from step 4}

Wait for the subagent to complete. Save its output verbatim.

**Parallelism note:** Steps 5 and 6 are independent — dispatch both subagents in parallel if your host agent's tool supports it. On Claude Code, this means a single message with two Task tool calls. On Codex or other hosts, use the equivalent parallel-dispatch mechanism.

## 7. Merge and deduplicate

Read both agent outputs. Extract findings:

- **Checklist reviewer output** — all findings directly (rule-based + quality anti-patterns).
- **Bogey reviewer output** — only the **Section 3: Layer 3 — Validated findings** section. Ignore Layer 1, Layer 2, and Suppressed sections for the merged report (they're useful for debugging but not for user-facing output).

**Deduplicate**: if two findings describe the same underlying defect (same quoted evidence, same section, same root cause), keep the one with higher confidence. If the bogey reviewer noted convergence (same issue flagged by both Layer 1 and Layer 2), mention that.

**Sort** by severity: Critical first, then Important, then Suggestion.

## 8. Format and report

Present the merged report inline — do NOT write a review file to disk unless the user explicitly asks. Findings belong in the conversation, not a separate artifact that goes stale.

```
## Review: {filename}
Document type: {doc_type} | Rules: {list of rules files loaded}

### Findings

**[Critical] {slug}** (confidence: {N}, {source}) — `{relative_path}:L{start}-L{end}`
{description with quoted evidence}
**Consequence:** {what breaks or misleads}
**Fix:** {one actionable step}

**[Important] {slug}** (confidence: {N}, {source}) — `{relative_path}:L{start}-L{end}`
...

**[Suggestion] {slug}** (confidence: {N}, {source}) — `{relative_path}:L{start}-L{end}`
...

### Strengths
- {1-3 items from checklist reviewer's Strengths section}

### Summary
{N} Critical, {M} Important, {P} Suggestions
Sources: {K} rule-based, {J} structural/cross-doc
```

Where `{source}` is:
- A rule ID (e.g., `UNIV-03`, `ADR-R02`) for rule-based checklist findings
- `quality` for checklist anti-pattern findings
- `structural` for bogey findings

The `{relative_path}:L{start}-L{end}` location reference comes directly from the subagent output — preserve it exactly.

**If no findings from either subagent**, report: `**PASS — no findings above confidence threshold.**`

**If either subagent failed or timed out**, report the findings from the one that completed and note the failure.

## 9. Constraints

- **Advisory only** — do not modify the document. Do not offer to auto-fix.
- Report findings and let the user decide what to act on.
- Never invent rule IDs. If a finding's source is unclear, mark it `quality` or `structural`, not a fabricated rule ID.
- Critical findings require author action before the feature advances; Important findings require action before the feature ships; Suggestions are advisory.

## Why this command has two reviewers

Preflight's differentiator is **curated rules + ensemble review + confidence scoring + Layer 3 validation** — not a single-pass rule check. The checklist reviewer catches rule violations with direct textual evidence; the bogey reviewer catches structural and epistemic defects that rule-based review cannot reach (unverifiable requirements, false hard constraints, silent cross-doc conflicts). Merging both with deduplication gives higher recall with lower false-positive rate than either alone.

See the two reviewer prompts in `.specify/extensions/preflight/agents/reviewers/` for full methodology.
