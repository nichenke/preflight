## Review: requirements.md
Document type: requirements | Rules: universal-rules.md, requirements-rules.md, cross-doc-rules.md

### Findings

**[Important] compound-frontmatter-requirement** (confidence: 88, quality)
FR-007 bundles many fields into a single requirement: "The handoff artifact frontmatter shall include: version, timestamp, session_type, agent_type, model, save_trigger, fidelity, project, cwd, branch, parent_commit, session_id (optional)." This is a compound requirement — twelve fields under one ID. Adding or removing a field changes the requirement's scope, but there is no granularity to track which fields are load-bearing vs. informational.
**Consequence:** An ADR that drops or adds a frontmatter field must reference FR-007 as a whole, obscuring the actual scope of the change. Traceability to architecture and test strategy degrades because one FR maps to twelve distinct behaviors.
**Fix:** Split FR-007 into a base requirement ("shall include YAML frontmatter") and either enumerate fields in a referenced table with individual traceability, or group fields by purpose (identity, context, git state) into separate FRs.

---

**[Suggestion] missing-handoff-brief-failure-mode** (confidence: 88, structural)
The failure modes table covers hook injection, malformed input, missing tools, and oversize artifacts, but has no entry for `/handoff-brief` invoked when no `<handoff-context>` exists in the session. FR-008 says the skill "shall read the `<handoff-context>` already in Claude's context" — if that context is absent, behavior is undefined.
**Consequence:** An agent or user invoking `/handoff-brief` in a session where the hook did not fire (no HANDOFF.md, hook error, or fresh session) gets undefined behavior. Implementations will handle this inconsistently.
**Fix:** Add a failure mode row: "No `<handoff-context>` in session when `/handoff-brief` invoked" with expected behavior (e.g., inform user no handoff context is available) and map to a new or existing requirement.

---

**[Suggestion] implicit-dependency-fr007-fr006** (confidence: 82, quality)
FR-007 uses ubiquitous EARS notation ("The handoff artifact frontmatter shall include...") but logically only applies when `/handoff` is invoked (FR-006). The implicit dependency between these two requirements is not stated — FR-007 reads as always-true rather than conditional on FR-006.
**Consequence:** A reader or agent evaluating FR-007 in isolation cannot determine when it applies. Test case generation may produce scenarios that test frontmatter structure outside the `/handoff` invocation context.
**Fix:** Rewrite FR-007 with an explicit trigger: "When the `/handoff` skill writes a `.dispatch/HANDOFF.md` artifact, the frontmatter shall include..."

---

**[Suggestion] vague-structured-briefing** (confidence: 82, structural)
FR-008 requires the skill to "deliver a structured session briefing: where we left off, next step, blockers." The word "structured" adds an undefined quality constraint beyond the three named items. An implementation that produces a single prose paragraph mentioning all three items could claim compliance.
**Consequence:** Different implementations of `/handoff-brief` will produce inconsistent output formats. Agents consuming the briefing downstream cannot rely on a predictable structure.
**Fix:** Either remove "structured" (the three named items already imply structure) or specify the expected output format (e.g., "deliver a session briefing with labeled sections: Where we left off, Next step, Blockers").

---

**[Suggestion] no-architecture-coverage-for-frs** (confidence: 80, XDOC-09)
No architecture document exists yet, so none of the FR/NFR IDs (FR-001 through FR-010, NFR-001 through NFR-005) are referenced by an architecture component, test strategy, or ADR. XDOC-09 requires every FR/NFR to be referenced by at least one downstream artifact.
**Consequence:** Requirements exist without traceability to design or test artifacts. As the project progresses, some requirements may be silently unimplemented.
**Fix:** When architecture.md is created, ensure every FR/NFR is mapped to at least one component or interface. This is expected for a Draft seed document but should be resolved before moving to Approved status.

### Strengths
- Failure modes table is thorough for the hook lifecycle — covers absent file, malformed YAML, missing tools, timeout, and oversize conditions, each mapped to a specific requirement
- All NFRs have quantitative acceptance criteria with concrete thresholds (10s, 20KB, zero writes, exit code 0 within 1s)
- Clear scope boundary in "Planned scope (not yet implemented)" section prevents scope creep into adjacent plugins

### Summary
0 Critical, 1 Important, 4 Suggestions
Sources: 1 rule-based (XDOC-09), 2 quality, 2 structural
