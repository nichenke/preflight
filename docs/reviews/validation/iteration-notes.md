# Validation iteration notes

Notes from manual review of validation run outputs. Inform agent prompt calibration.

## Fix suggestion scope inversion

**Pattern observed:** The checklist-reviewer (and occasionally bogey-reviewer) suggests fixes that pull implementation detail into higher-authority documents. Findings are valid but fix suggestions sometimes invert the authority chain.

**Examples from preflight validation:**
- Constitution `unverifiable-qa-effectiveness-gate`: suggested adding "≥80%" threshold to CONST-QA-01. Correct fix: make the principle structurally testable ("Skills must pass a defined eval suite") without embedding a number. Thresholds belong in requirements (NFR-004).
- Constitution `const-ci-01-dual-statement`: suggested rewriting with both clauses. User direction: drop Notion entirely, make git canonical. Simpler principle, not a more detailed one.
- Requirements `const-dist02-incomplete-vs-fr009`: suggested amending CONST-DIST-02 to match FR-009's file list. Correct fix: CONST-DIST-02 should stay generic ("don't overwrite project-authored documents"); FR-009 owns the specific file list.
- Requirements `nfr-004-misses-const-qa01-baseline`: suggested adding baseline comparison to NFR-004. The manual baseline is a one-time proof (established by the spike), not a recurring gate. NFR-004's absolute threshold is the ongoing gate.

**Root cause:** The fix suggestion logic doesn't account for document authority hierarchy. When a finding spans two doc levels (constitution + requirements, or requirements + architecture), the fix should push detail DOWN the hierarchy, not pull it UP.

**Calibration action:** Add guidance to the checklist-reviewer's fix generation:
- Constitution fixes should make principles more structurally testable, not more specific. Push thresholds and enumerations down to requirements.
- Requirements fixes should not suggest amending the constitution. If there's a gap between constitution and requirements, the requirements should implement the constitutional principle — not the other way around.
- Fix suggestions should respect the authority chain: constitution (principles) → requirements (thresholds, enumerations) → architecture (mechanisms).

## Approved findings and directions

From preflight constitution review:
- `missing-adr-001`: Approved. Migrate or replace with bootstrapping note.
- `unverifiable-qa-effectiveness-gate`: Finding valid, fix wrong-scoped. Rewrite CONST-QA-01 to be structurally testable: "Skills must pass a defined eval suite before shipping."
- `const-ci-01-dual-statement`: Rewrite. Drop Notion. Make git canonical source.

From preflight requirements review:
- `compound-fr-023`: Approved. Split into two FRs.
- `nfr-004-misses-const-qa01-baseline`: Finding valid. Manual baseline is a one-time proof (spike), not a recurring gate. Note in NFR-004 that baseline was established; ongoing gate is absolute threshold.
- `unverifiable-appropriate-elicitation`: General rule preferred: "walk through all sections defined in the doc type's template." No per-type FRs needed.
- `fr-022-passive-missing-actor`: Approved. Rewrite with EARS trigger.
- `const-dist02-incomplete-vs-fr009`: Finding valid, fix wrong-scoped. CONST-DIST-02 should stay generic (principle-level); FR-009 owns the specific file list.
