---
name: issue-triage
description: Triage open GitHub issues against the current codebase and specs — validates claims, maps spec gaps, classifies governance needs, and produces structured assessment. Use when processing issues, reviewing backlog health, doing repo maintenance, or when the user mentions issues, bugs, or backlog in the context of this project.
---

# Issue triage

Assess open GitHub issues against the current state of the codebase and spec artifacts. The goal is a triage report that a maintainer can act on without re-reading the issues — every claim verified, every fix traced to a spec.

## What good output looks like

For each issue, the report delivers four things:

**Validity verdict** — Is the described behavior still present? Back this up with evidence from the current code: file paths with line numbers, command output, or a commit SHA that changed things. The issue's original description is a claim, not a fact — verify it.

**Spec gap map** — Which spec artifacts cover the behavior described in the issue? Check requirements (FR/NFR IDs), constitution (CONST clauses), and rules files. If nothing covers it, that's the most important finding — name the missing artifact and where it belongs. A bug with no spec coverage isn't a code bug, it's a spec gap.

**Governance classification** — Would fixing this issue change what an agent generates? That's the REQ-R07 test. If yes, an ADR is required before the fix. State the reasoning, not just the verdict — the maintainer needs to understand why so they can challenge it.

**Fix decomposition** — Concrete artifacts to create or modify, ordered by dependency. Spec changes before implementation. ADR before requirement changes. Every item traces to an existing or proposed requirement ID.

## Decision framework

### Validity

An issue is **valid** if its root cause claim holds against current code. Check the specific files, rules, and skill content it references — these may have changed since filing. Look at git log for commits or PRs that addressed it. If partially fixed, note what remains.

An issue is **invalid** if the described behavior no longer exists or was addressed by a subsequent change. Cite the evidence.

### ADR or not

The test is behavioral: would the change cause an agent to generate different code?

- New or changed FR/NFR → ADR required
- New rule that alters review output → ADR required (changes behavioral expectations)
- New reference or template content → no ADR (additive, existing behavior unchanged)
- Clarification of existing intent → no ADR

### Bug vs missing requirement

When an issue describes behavior the specs don't address, resist calling it a code bug. It's a gap in the specs. Name the gap explicitly — "no FR covers structural completeness checking" is more useful than "the review skill doesn't check templates."

## Validation criteria

These are quality gates for the triage output. A report that fails any of these needs rework:

- Every validity verdict cites current evidence (file path + line, command output, or commit SHA) — not the issue's original claim restated
- Every spec gap names specific IDs (FR-NNN, CONST-XX-NN, rule ID) or explicitly states "no coverage exists" with a proposal for where coverage should live
- Every governance classification states the REQ-R07 reasoning, not just "needs ADR"
- Fix decomposition is dependency-ordered (spec before implementation, ADR before requirement changes)
- No fix item lacks traceability — each traces to an existing or proposed requirement ID
- Issues classified as invalid include the disconfirming evidence

## Output format

```
## Issue triage: {repo}

### #{number}: {title}

**Valid:** {yes | no | partial} — {evidence summary with file:line or SHA}

**Spec coverage:**
- {ID}: {brief description} — {covers | partially covers}
- Gap: {what's missing} → proposed {artifact type} in {file path}

**Governance:** {ADR required | No ADR} — {reasoning against REQ-R07 test}

**Fix decomposition:**
1. {file path} — {what changes} (traces to {ID})
2. ...

---
```

Repeat per issue, then close with:

```
## Summary

| # | Title | Valid | ADR needed | Spec gaps |
|---|-------|-------|------------|-----------|
| {n} | {title} | {yes/no/partial} | {yes/no} | {count} |
```
