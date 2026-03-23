---
type: rules
applies_to: all
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Universal Rules — All Document Types

| Rule ID | Rule | Severity |
|---------|------|----------|
| UNIV-01 | Document SHALL have YAML frontmatter with status, date, and owner | Error |
| UNIV-02 | Document SHALL have a Meta section with version and status | Error |
| UNIV-03 | All cross-references SHALL use document/requirement IDs, not page numbers or prose | Warning |
| UNIV-04 | No section SHALL be entirely empty without a "TBD" marker and owner | Warning |
| UNIV-05 | Vague adjectives (fast, easy, simple, robust, scalable) SHALL be accompanied by quantification | Warning |
| UNIV-06 | Status SHALL be from the defined enum for that document type | Error |
| UNIV-07 | Dates SHALL use ISO 8601 format (YYYY-MM-DD) | Info |
| UNIV-08 | Document SHALL NOT contain TODO/FIXME/HACK without an assigned owner | Warning |
