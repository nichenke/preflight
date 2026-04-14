---
description: Review the active feature's spec.md or plan.md against preflight's rule set
---

# /speckit.preflight.review — preflight extension

Perform a rule-based review of a spec or plan document. Report findings by severity with stable rule IDs.

## Target document

Determine the target document in this order:

1. **Argument** — if the user passed a path, use it
2. **Hook context (`after_specify`)** — the most recently modified `spec.md` under `.specify/features/`
3. **Hook context (`after_plan`)** — the most recently modified `plan.md` under `.specify/features/`
4. **Fallback** — prompt the user for a target

## Rules (loaded as context)

Load every `*.md` file in this extension's rules directory as prompt context. At install time the directory is `.specify/extensions/preflight/rules/`.

Each file groups rules by document type or concern (e.g., `universal-rules.md`, `requirements-rules.md`, `cross-doc-rules.md`). Within each file, rules appear as rows in a markdown table with columns: **Rule ID**, **Rule**, **Severity**. Rule IDs use stable prefixes by category (e.g., `UNIV-01`, `REQ-14`, `XDOC-09`, `ADR-03`) — never reused, never renumbered.

Severity values in the source tables are `Error` or `Warning`. Map them to the output grades as follows:
- `Error` → **Critical** (blocks acceptance)
- `Warning` → **High** (requires action) when the rule addresses traceability, consistency, or structural correctness; **Medium** (advisory) when it addresses style or clarity

Apply judgement when promoting `Warning` → High vs Medium: structural violations (missing IDs, broken cross-refs, superseded chain integrity) are High; prose quality issues (vague adjectives, missing quantification) are Medium.

If the rules directory is empty or missing, report that fact and exit without findings — do not fabricate rules.

## Review procedure

For each rule row across all loaded rule files, check the target document and record any violations. For each finding, capture:
- Rule ID (exact string from the source table — never invent IDs)
- Severity (mapped per the Error/Warning rules above)
- Section or line reference in the target document
- One-sentence explanation of the violation
- Optional suggested fix

Skip rules that don't apply to the target document type (e.g., skip `ADR-*` rules when reviewing a plan.md that isn't an ADR). Use the rule file's title and `applies_to` frontmatter to decide applicability.

Do **not** edit the target document. This command is read-only.

## Output format

```
# Preflight review — <document path>

## Critical (N findings)
- [RULE-ID] <section>: <explanation>
  Suggested fix: <optional>

## High (N findings)
- ...

## Medium (N findings)
- ...

## Low (N findings)
- ...

## Summary
- Critical: N, High: N, Medium: N, Low: N
- Overall: PASS | BLOCKED (blocked if any Critical or High)
```

A document passes review when it has zero Critical and zero High findings. Medium and Low findings are advisory.

## When invoked via hook

When this command fires via `after_specify` or `after_plan`, emit the review inline so the user sees it in-flow. Do not write a review file to disk unless the user explicitly asks — findings belong in the conversation, not a separate artifact that goes stale.

## Rules authoring

Rules live in `extensions/preflight/rules/*.md` in the preflight repo and are the single source of truth for review behavior. Each file is a markdown table grouped by document type or concern. Edit them there. New rules get new IDs (next number in the file's prefix series); existing IDs are never reused or renumbered. The rule files have YAML frontmatter with `applies_to` and a `version`; bump the file's version when adding or changing rules.
