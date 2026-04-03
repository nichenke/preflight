---
status: Proposed
date: 2026-04-03
owner: nic
version: 0.1.0
deciders: [nic]
consulted: []
informed: []
---

# ADR-006: Add File and Line-Range Locations to Review Findings

## Context and Problem Statement

Preflight review findings include evidence quotes, severity, confidence, and fix
suggestions — but not the file path and line numbers where the violation occurs.
This means findings are human-readable in the conversation but cannot be
programmatically posted as GitHub PR review comments, which require `path` and
`line` fields.

The GitHub reviews API (`POST /repos/.../pulls/.../reviews`) accepts an array of
comments, each with `path`, `line`, and `body`. To bridge preflight review output
to this API, each finding needs a machine-parseable location reference that a
downstream tool can extract without re-analyzing the document.

This is not about building the GitHub posting flow — that is a separate concern.
This is about ensuring the review output carries enough structured data for any
downstream consumer (GitHub API, CI annotation, IDE integration) to place
findings at the right location.

## Decision Drivers

- Review findings currently lack location data, blocking GitHub PR comment integration
- Both reviewer agents (checklist, bogey) already read documents via the Read tool,
  which returns line numbers — the data is available but not captured
- The finding format is already structured (`**[severity] slug** (confidence, source)`)
  and can be extended without breaking consumers that parse the current format
- Location must be relative paths (not absolute) for portability across environments

## Considered Options

1. Extend the existing finding format line with `— \`path:L{start}-L{end}\``
2. Add a separate `Location:` line below the finding header
3. Emit a parallel JSON structure alongside the human-readable output

## Decision Outcome

Chosen option: "Extend the existing finding format line", because it keeps findings
as a single parseable line per header, avoids format bloat, and is trivially
extractable with a regex like `— \`([^:]+):L(\d+)-L(\d+)\``.

### Consequences

- Good, because findings become postable as GitHub PR review comments without
  re-analyzing the document
- Good, because the format extension is backward-compatible — existing consumers
  that don't parse the location suffix are unaffected
- Good, because line ranges (not just single lines) give reviewers enough context
  to understand the finding's scope
- Bad, because agents must now track line numbers during analysis, adding cognitive
  load to agent prompts — mitigated by the fact that Read tool output already
  includes line numbers
- Neutral, because this adds a new FR to requirements.md (FR-030) which must be
  tested

### Confirmation

- Review output includes `— \`path:L{start}-L{end}\`` on every finding line
- Line numbers match the actual location of quoted evidence in the document
- A downstream script can extract path, start line, and end line from each finding
  using a single regex

## Pros and Cons of the Options

### Extend the existing finding format line

Append `— \`{relative_path}:L{start}-L{end}\`` to the finding header line.

- Good, because one line per finding header — easy to scan and parse
- Good, because regex-extractable: `— \`([^:]+):L(\d+)-L(\d+)\``
- Good, because backward-compatible with consumers parsing severity/slug/confidence
- Bad, because long finding lines in narrow terminals

### Add a separate Location line

Add `**Location:** \`path:L{start}-L{end}\`` as a new line after the header.

- Good, because keeps the header line shorter
- Bad, because finding format grows from 4 lines to 5 lines per finding
- Bad, because multi-line extraction is harder than single-line regex

### Emit parallel JSON structure

Output findings in both human-readable and JSON formats.

- Good, because JSON is trivially machine-parseable
- Bad, because duplicates every finding in two formats — doubles output size
- Bad, because agents must maintain two parallel output streams
- Bad, because the human-readable and JSON versions could drift out of sync

## More Information

- FR-019 defines the current finding format (severity, rule ID, fix suggestion)
- The GitHub reviews API format: `{"path": "...", "line": N, "body": "..."}`
- Line numbers use the `L{N}` prefix to match GitHub's permalink convention
- For missing-element findings (e.g., absent section), agents use the line range
  of the nearest relevant context
