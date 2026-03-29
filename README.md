# Preflight

A Claude Code plugin for spec-driven development. Scaffolds a structured doc directory into your project and provides guided elicitation and rule-based review for requirements, ADRs, RFCs, architecture docs, and more.

## Skills

| Skill | Invoke | What it does |
|-------|--------|--------------|
| **scaffold** | `/preflight scaffold` | Bootstrap or update `.preflight/` framework content, project doc skeleton, and `.claude/rules/preflight.md` |
| **new** | `/preflight new` | Guided elicitation for 7 doc types — walks through structured questions, writes the doc, runs automated review |
| **review** | `/preflight review <file>` | Rule-based review against doc-type-specific rules — reports Errors and Warnings with rule IDs |

## Installation

Install via the Claude Code marketplace or manually:

```bash
claude plugin install nichenke/preflight
```

Then in your project:

```
/preflight scaffold
```

## Doc types

Requirements, Architecture, ADR, RFC, Interface Contract, Test Strategy, Constitution.

## Standards

- [EARS](https://alistairmavin.com/ears/) — Easy Approach to Requirements Syntax
- [MADR 4.0](https://github.com/adr/madr) — Markdown Any Decision Records
- [arc42](https://arc42.org) — Architecture documentation template

## License

[MIT](LICENSE)
