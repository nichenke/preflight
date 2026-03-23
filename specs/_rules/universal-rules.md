---
type: rules
applies_to: all
version: 2.0.0
source: PM Documentation Framework (Notion)
---

# Universal Rules — All Document Types

| Rule ID | Rule | Severity |
|---------|------|----------|
| UNIV-01 | Document SHALL have YAML frontmatter with: status (from defined enum for that doc type), date (ISO 8601), owner, and version | Error |
| UNIV-02 | All cross-references SHALL use document/requirement IDs, not page numbers or prose | Warning |
| UNIV-03 | No section SHALL be entirely empty without a "TBD" marker and owner | Warning |
| UNIV-04 | Vague adjectives (fast, easy, simple, robust, scalable) SHALL be accompanied by quantification | Warning |
| UNIV-05 | Document SHALL NOT contain TODO/FIXME/HACK without an assigned owner | Warning |
