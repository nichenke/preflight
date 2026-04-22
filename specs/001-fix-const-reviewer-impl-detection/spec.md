# Feature Specification: Broaden constitution reviewer's implementation-detail detection

**Feature Branch**: `001-fix-const-reviewer-impl-detection`
**Created**: 2026-04-22
**Status**: Draft
**Input**: User description: "fix constitution reviewer implementation-detail detection — issue #13"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Spec author gets every implementation leak flagged in a constitution principle (Priority: P1)

A spec author drafts or updates a constitution and runs the preflight review. The review flags every principle that embeds an implementation detail — not just CLI commands — so the author can rewrite those principles as tool-agnostic outcome statements before the constitution is ratified.

**Why this priority**: This is the core defect. Today, principles with function names, file paths, environment variable patterns, or inline code expressions pass review silently, which defeats the purpose of the constitution being a tool-agnostic authority. Closing this gap is the single change that makes the fix valuable; everything else is secondary.

**Independent Test**: Run the preflight review over a constitution that intentionally embeds one principle per implementation-detail category (function name, file path, directory path, env var pattern, CLI invocation, inline code expression). Confirm the review flags every principle at least once under the implementation-detail rule.

**Acceptance Scenarios**:

1. **Given** a constitution principle containing a function name such as `getPaiDir()`, **When** the reviewer runs, **Then** that principle is flagged under the implementation-detail rule.
2. **Given** a principle containing a file name such as `settings.json` or a directory path such as `MEMORY/`, **When** the reviewer runs, **Then** the principle is flagged under the implementation-detail rule.
3. **Given** a principle containing an environment variable expression such as `process.env.PAI_DIR || fallback`, **When** the reviewer runs, **Then** the principle is flagged under the implementation-detail rule.
4. **Given** a principle containing a CLI invocation such as `bootstrap.sh --target <dir>` or `git fetch upstream && git merge upstream/main`, **When** the reviewer runs, **Then** the principle is flagged under the implementation-detail rule.
5. **Given** a principle containing an inline code expression (backtick-wrapped symbol or call) that is not a standards name, **When** the reviewer runs, **Then** the principle is flagged under the implementation-detail rule.

---

### User Story 2 - Each flag points to a specific offending phrase (Priority: P2)

When the reviewer flags a principle, the reviewer's finding names the specific phrase that triggered the flag and the implementation-detail category it belongs to. The author can act on the finding without guessing which words to change.

**Why this priority**: Without phrase-level specificity, the author faces a vague "this principle is too specific" note and may rewrite the wrong part or dismiss the flag. Specificity turns a flagged defect into actionable rework. It is P2 because the flag itself (P1) is the minimum viable fix; specificity is what makes the fix usable at scale.

**Independent Test**: Run the reviewer over a constitution with one principle per category. For each finding, verify the output names the exact phrase (e.g., `getPaiDir()`, `settings.json`) and identifies the category (e.g., function name, file path).

**Acceptance Scenarios**:

1. **Given** a flagged principle, **When** the author reads the reviewer's finding, **Then** the finding cites the offending phrase verbatim from the principle.
2. **Given** a principle with two distinct implementation details, **When** the reviewer runs, **Then** both phrases are cited in the finding for that principle.

---

### User Story 3 - Legitimate abstract principles continue to pass (Priority: P2)

Principles that state outcomes or boundaries without embedding implementation details are not flagged by the broadened detection. Expanding detection must not introduce false positives that would train authors to ignore the rule.

**Why this priority**: Over-flagging is the main risk of broadening the rule. If the fix turns every principle with a noun into a false positive, authors will start dismissing findings wholesale, which is worse than the original bug. This is P2 because false-positive control matters for trust, but the system is still valuable with some noise as long as real leaks are caught.

**Independent Test**: Run the reviewer over a control constitution composed of tool-agnostic outcome statements drawn from existing accepted constitutions. Confirm zero flags under the implementation-detail rule.

**Acceptance Scenarios**:

1. **Given** a principle stating "All code must have automated tests," **When** the reviewer runs, **Then** the principle is not flagged.
2. **Given** a principle stating "The system must be installable via a single documented command," **When** the reviewer runs, **Then** the principle is not flagged merely because it contains the word "command."

---

### Edge Cases

- A principle that legitimately references a standard by name (e.g., EARS, MADR, SemVer) should not be flagged, because the name refers to a published specification rather than a tool or implementation.
- A principle that includes an inline example of the form "(e.g., `tool X`)" should be flagged, because the example inside the principle embeds the same implementation detail the rule forbids.
- A principle written entirely in plain prose with no backticks, no capitalized function-style identifiers, and no path-like tokens must not be flagged.
- When a single principle contains multiple implementation-detail categories, the reviewer must not stop at the first one; it must flag all of them so the author sees the full scope of rework.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The constitution review MUST flag principles that embed function names (identifier tokens written in a callable form such as `name()`).
- **FR-002**: The constitution review MUST flag principles that embed file names or file paths (tokens containing a recognizable file extension or a path separator that points at a file).
- **FR-003**: The constitution review MUST flag principles that embed directory paths (tokens that end in a path separator or that name a filesystem directory referenced as a location).
- **FR-004**: The constitution review MUST flag principles that embed environment variable expressions (tokens that read or compose an environment variable, including fallback expressions).
- **FR-005**: The constitution review MUST flag principles that embed CLI invocations (tokens that name an executable followed by arguments, flags, or shell operators).
- **FR-006**: The constitution review MUST flag principles that embed inline code expressions (backtick-wrapped symbols, calls, or operator expressions) that are not standards names.
- **FR-007**: When a principle embeds more than one implementation detail, the review MUST flag every distinct offending phrase within that principle, not only the first one encountered.
- **FR-008**: Each finding under the implementation-detail rule MUST cite the offending phrase verbatim and identify which implementation-detail category the phrase belongs to.
- **FR-009**: The review MUST NOT flag principles whose only concrete nouns are names of published specifications or standards referenced as such (e.g., EARS, MADR, SemVer).
- **FR-010**: The review MUST NOT flag principles that express outcomes or boundaries in plain prose without embedded code, paths, or tool-specific identifiers.
- **FR-011**: The broadened detection MUST apply only to principles in the constitution document; other document types (requirements, ADRs, architecture) MUST retain their existing rules without side effects from this change.
- **FR-012**: The governing rule identifier for constitution implementation-detail detection MUST remain stable so that existing constitutions, prior review outputs, and external references continue to resolve.

### Key Entities *(include if feature involves data)*

- **Constitution principle**: A numbered outcome or boundary statement in the constitution. Attributes relevant here: the principle's prose, any embedded code spans, and the principle's identifier.
- **Implementation-detail finding**: A reviewer output entry tied to a principle. Attributes: the principle identifier, the offending phrase, the implementation-detail category, and a pointer back to the governing rule.
- **Implementation-detail category**: One of: function name, file path, directory path, environment variable expression, CLI invocation, inline code expression. Used to label findings and to support false-positive control.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Over a benchmark constitution that embeds one principle per implementation-detail category (six categories total), the reviewer flags all six principles under the implementation-detail rule in a single pass.
- **SC-002**: Over the specific pai-source constitution v1.0.0 examples from issue #13 (`getPaiDir()`, `process.env.PAI_DIR || fallback`, `bootstrap.sh --target <dir>`, `settings.json`, `MEMORY/`), the reviewer flags every one of those five concrete instances.
- **SC-003**: Over a control constitution composed only of tool-agnostic outcome statements, the reviewer produces zero implementation-detail flags.
- **SC-004**: Over a mixed constitution containing both categories (benchmark plus control, combined into one document), the count of principles flagged under the implementation-detail rule equals the count of principles that actually embed an implementation detail — no more, no less.
- **SC-005**: Every implementation-detail finding produced by the reviewer includes both the offending phrase verbatim and the category label, verified by inspection of the review output.

## Assumptions

- The constitution reviewer is the checklist reviewer in `extensions/preflight/agents/reviewers/checklist-reviewer.md` operating under `extensions/preflight/rules/constitution-rules.md`; this fix targets that pair and does not introduce a new reviewer.
- The governing rule today is CONST-R04 (principles shall not prescribe specific tools or versions). This fix broadens the interpretation of CONST-R04 rather than introducing a new rule ID, preserving rule-ID stability per FR-012.
- The expected input to the reviewer is the constitution file as-authored, not a pre-processed or stripped version; detection works on the same prose the author wrote.
- "Standards names" that should pass (EARS, MADR, SemVer, etc.) are a small and stable set; a short, explicit allow-list is acceptable rather than a general inference.
- The spike context of ADR-007 applies: this fix lives on a feature spec under `specs/001-…`, not on main, and follows the preflight extension's existing review pipeline.
- Downstream behavior in other reviewers (requirements, ADR, architecture) is out of scope; those reviewers keep their current rules.
