---
type: rules
applies_to: constitution
version: 2.1.0
source: PM Documentation Framework (Notion)
---

# Constitution / Engineering Principles — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| CONST-R01 | Every principle SHALL have a unique ID in the format CONST-{CATEGORY}-NN | Error |
| CONST-R02 | Status SHALL be one of: Draft, Ratified, Amended | Error |
| CONST-R03 | Each principle SHALL be a single, testable imperative statement ("All services MUST..."), not a paragraph of guidance or aspiration | Warning |
| CONST-R04 | Principles SHALL pass the implementation-detail property test (see CONST-R04 detail below) | Warning |
| CONST-R05 | The constitution SHALL NOT exceed 30 principles — if it's longer, it's not a constitution, it's a standards doc | Warning |
| CONST-R06 | Every amendment SHALL be recorded in the Amendment Log with ADR reference | Error |
| CONST-R07 | Principles SHALL NOT cross-reference requirement IDs (FR-NNN, NFR-NNN) — principles are self-contained outcome statements; implementation details and requirement mappings belong in ADRs and requirements docs | Warning |

## CONST-R04: Implementation-detail property test

Principles must express implementation-agnostic outcomes, not implementation specifics. The rule has three parts: the normative property test, a non-normative scaffolding list, and an exemption for standards.

### Property test (normative)

Flag any principle whose stated behavior is bound to a specific implementation shape rather than an implementation-agnostic outcome.

**The test**: would the principle still hold, unchanged in meaning, if the underlying implementation were replaced with a different language, tool, filesystem layout, or module structure?

If the answer is no, the principle embeds an implementation detail and is flagged under CONST-R04. If yes, the principle passes.

### Scaffolding (non-normative, illustrative)

Common shapes that typically fail the property test. This list calibrates reviewer judgment — it is not exhaustive, and a principle may fail the property test via a shape not listed here:

- Function or method names (`getConfig()`, `load_profile`)
- File paths and filenames (`settings.json`, `/etc/foo.conf`)
- Directory paths (`MEMORY/`, `.cache/`)
- Environment variable expressions (`process.env.PAI_DIR`, `$HOME/.foo`)
- CLI invocations (`bootstrap.sh --target`, `git fetch upstream`)
- Inline code tokens (backtick-wrapped identifiers or expressions)
- Tool and vendor names (Jest, PostgreSQL, AWS Lambda)
- Version pins (Node 20, Python 3.11, MADR 4.0)

### Exemption (normative)

Named references to published specifications and standards (for example: EARS, MADR, SemVer, RFC 2119) are not implementation details. Naming the standard passes. Pinning a version of the standard or embedding the standard's template tokens does not — the property test resolves the boundary.

### Examples

One paired before/after per shape. The "bad" column embeds an implementation-shape; the "good" column preserves the intent without the shape.

| Shape | Bad — fails property test | Good — passes property test |
|---|---|---|
| Function name | The `getPaiDir()` helper SHALL be the canonical way to locate the install root. | The system SHALL expose a documented accessor for the install root. |
| File path | Per-user overrides SHALL live in `settings.json`. | Per-user overrides SHALL live in a single documented configuration file. |
| Directory path | Agent memory SHALL be written under `MEMORY/`. | Agent memory SHALL be written under a single documented root, separated from source code. |
| Env var | The system SHALL resolve the install root via `process.env.PAI_DIR`. | The system SHALL resolve the install root via a documented environment override. |
| CLI invocation | New installs SHALL be initialized by running `bootstrap.sh --target <dir>`. | New installs SHALL have a single documented initialization entry point. |
| Inline code token | Configuration SHALL be read via `fs.readFileSync`. | Configuration SHALL be read synchronously at startup before any request is served. |
| Tool / vendor | All services SHALL use PostgreSQL for durable state. | All services SHALL use a relational store for durable state. |
| Version pin | All ADRs SHALL use MADR 4.0 templates. | All ADRs SHALL use the MADR format. |

### When multiple shapes appear in one principle

Each offending phrase is flagged independently. The reviewer does not stop at the first shape — findings list every phrase that fails the property test, so the author sees the full scope of rework.

## Change Governance

**The constitution is the only document that governs its own change process.**
Requirements need ADRs to change (REQ-R07). The constitution — being higher authority —
needs ADRs AND ratification.

### Amendment Process
1. **Write an ADR** proposing the change (title: "ADR-NNN: Amend Constitution CONST-{ID}")
2. **Ratification**: Explicitly approved by designated ratifiers
3. **Update the constitution**: Increment version, add to Amendment Log
4. **Cascade check**: Review downstream documents for conflicts

### What Requires an Amendment
- Adding, removing, or changing a principle
- Changing the scope or authority statement in the Preamble

### What Does NOT Require an Amendment
- Fixing typos or grammar
- Adding examples or clarifications that don't change meaning
- Reorganizing categories

## Anti-Patterns to Flag

- **Constitution as wish list**: Principles nobody follows or enforces. Every principle should be checkable by an agent or reviewer.
- **Too many principles**: More than 30 means it's a standards manual, not a constitution. Constitutions should be memorizable.
- **Implementation-specific principles**: Principles that name a specific tool, version, file, path, function, or other implementation shape ("Use PostgreSQL 16+", "`getConfig()` must return a Promise") belong in an ADR, not a constitution. Apply CONST-R04's property test: would the principle still hold if the implementation were replaced?
- **Unenforced amendments**: Changing the constitution without an ADR.
- **No ratifiers named**: A constitution without designated ratifiers has no authority.
- **Agent-invisible principles**: Principles only a human could verify ("code should feel elegant"). Every principle should be mechanically checkable.
- **Requirement leaking into principles**: Principles that reference FR-NNN or NFR-NNN IDs are coupling the constitution to implementation. The ADR maps principle to requirements; the principle itself should stand alone.
