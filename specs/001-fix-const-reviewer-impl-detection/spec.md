# Feature Specification: Constitution reviewer catches implementation-detail leaks consistently

**Feature Branch**: `001-fix-const-reviewer-impl-detection`
**Created**: 2026-04-22
**Status**: Draft
**Input**: User description: "fix constitution reviewer implementation-detail detection — issue #13"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Spec author gets every implementation leak flagged in a constitution principle (Priority: P1)

A spec author drafts or updates a constitution and runs the preflight review. The review flags every principle whose behavior is bound to a specific implementation shape — not just CLI commands — so the author can rewrite those principles as implementation-agnostic outcome statements before the constitution is ratified.

**Why this priority**: This is the core defect. Today, principles embedding function names, file paths, environment variable patterns, or inline code expressions pass review silently, which defeats the purpose of the constitution being an implementation-agnostic authority. Closing this gap is the single change that makes the fix valuable.

**Independent Test**: Construct a principle pair — one binding behavior to a specific implementation shape, one expressing the same intent implementation-agnostically. Confirm the reviewer flags the first under CONST-R04 and passes the second.

**Acceptance Scenarios**:

1. **Given** a principle bound to a specific implementation shape (e.g., naming a function, file, env var, CLI invocation, version pin, or vendor), **When** the reviewer runs, **Then** the principle is flagged under CONST-R04.
2. **Given** a principle with two distinct implementation-shape references, **When** the reviewer runs, **Then** both references produce a CONST-R04 finding.

---

### User Story 2 - Legitimate abstract principles continue to pass (Priority: P2)

Principles that state outcomes or boundaries without binding to a specific implementation shape are not flagged. Broadening CONST-R04 must not introduce false positives that would train authors to ignore the rule.

**Why this priority**: Over-flagging is the main risk of reframing the rule. If principles that merely name a concept get flagged, authors dismiss findings wholesale — worse than the original bug. P2 because false-positive control matters for trust, but the system is still valuable with some noise as long as real leaks are caught.

**Independent Test**: Run the reviewer over a control constitution of implementation-agnostic outcome statements drawn from accepted constitutions. Confirm zero CONST-R04 flags.

**Acceptance Scenarios**:

1. **Given** a principle stating "All code must have automated tests," **When** the reviewer runs, **Then** the principle is not flagged under CONST-R04.
2. **Given** a principle naming a published standard (EARS, MADR, SemVer) without pinning a version or embedding the standard's template tokens, **When** the reviewer runs, **Then** the principle is not flagged merely for naming the standard.

---

### Edge Cases

- **Version-pinned standards** ("All ADRs SHALL use MADR 4.0"): the property test resolves this — substituting MADR 4.0 with "a structured ADR format" changes the principle's meaning, so it is flagged. Naming the standard without a version is fine; pinning the version is not.
- **Multiple implementation-shape references in one principle**: each reference is flagged independently.
- **Plain prose outcome statements with no implementation-shape references**: not flagged.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001 (property test)**: CONST-R04's rule text MUST instruct the reviewer to flag any principle whose stated behavior is bound to a specific implementation shape rather than an implementation-agnostic outcome. The governing test is: *would the principle still hold, unchanged in meaning, if the underlying implementation were replaced with a different language, tool, filesystem layout, or module structure?* If the answer is no, the principle embeds an implementation detail and is flagged.
- **FR-002 (illustrative scaffolding)**: The rules file MUST include a non-exhaustive list of common implementation-detail shapes — function or method names, file paths, directory paths, environment variable expressions, CLI invocations, inline code tokens, tool and vendor names, version pins — paired with good/bad exemplars that calibrate reviewer judgment. The list is scaffolding, not the normative rule; shapes absent from the list are still flagged when they fail the FR-001 property test.
- **FR-003 (standards exemption)**: CONST-R04 MUST exempt named references to published specifications and standards (e.g., EARS, MADR, SemVer, RFC 2119). The property test resolves the boundary: naming the standard passes; pinning a version or embedding the standard's template tokens does not.
- **FR-004 (rule-ID stability)**: The rule identifier `CONST-R04` MUST remain stable so existing constitutions, prior review outputs, and external references continue to resolve.

### Key Entities *(include if feature involves data)*

- **Constitution principle**: a numbered outcome or boundary statement in the constitution. The reviewer evaluates each principle independently against CONST-R04.
- **CONST-R04 finding**: a reviewer output entry tied to a principle, citing the offending phrase verbatim.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Over the pai-source constitution v1.0.0 examples cited in issue #13 (`getPaiDir()`, `process.env.PAI_DIR || fallback`, `bootstrap.sh --target <dir>`, `settings.json`, `MEMORY/`), the reviewer flags every concrete instance.
- **SC-002**: Over a control constitution composed entirely of implementation-agnostic outcome statements, the reviewer produces zero CONST-R04 flags.
- **SC-003**: Over a scaffolding-shapes fixture that exercises the three scaffolding shapes NOT covered by issue #13 (tool/vendor, inline code token, version-pinned standard), the reviewer flags every principle. This closes the coverage gap between the issue #13 examples (5 shapes) and the rule's full 8-shape claim.

## Assumptions

- The fix is a rule-text change in `extensions/preflight/rules/constitution-rules.md` (source of truth). Install-copy propagation into `.specify/extensions/preflight/` is a planning-phase concern, not a spec-level assumption.
- The reviewer agent is not rewritten by this spec — it reads the rule file and applies whatever text is there. Exact prompt phrasing, exemplar set size, and detection approach (LLM reasoning vs. heuristic surrogates) are decided during `/speckit.plan`.
- This change modifies the *shape* of a preflight review rule — not just its wording. Per CONST-PROC-02, an ADR is required. The ADR should establish "**property-test + illustrative scaffolding**" as the preflight rule shape going forward, with CONST-R04 as the first application. The ADR is a prerequisite for implementation and is authored before `/speckit.plan` completes.
- The research backing this shape (spec-kit, BMAD, GSD, Superpowers, OpenSpec, Gas Town converging on substitution-test + illustrative-list patterns) is summarized in the forthcoming ADR; raw research artifacts live in `cache/repos/` per `.claude/rules/rule-design.md`.
- The spike context of ADR-007 applies: this feature lives under `specs/001-fix-const-reviewer-impl-detection/`, not on main.
- Other document types (requirements, ADRs, architecture, interfaces) retain their existing rules — this change is scoped to constitution review only.
