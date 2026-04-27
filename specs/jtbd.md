# Preflight — jobs to be done

**Version:** v0.1 (2026-04-26) · expected to evolve.

## What this doc is for

Preflight helps you build, modify, review, and re-read the durable harness your projects — and your agents — execute against. This document names what preflight is hired to do, and what it isn't.

## Personas

Preflight serves four roles — often played by the same human at different times, sometimes split across different people on a team:

- **Builder** — producing or modifying the project's harness (goals, rules, architecture, JTBD, interface contracts).
- **Supervisor** — reviewing agent-drafted output before it merges; default action is *approve / iterate / reject*, not author from scratch.
- **Maintainer** — evolving the harness over time as project shape changes (adjusting rules, updating decisions, retiring artifacts).
- **Returning reader** — coming back to the harness after a break, or reading it cold as a new contributor or agent.

Each role has an **L3 mode** (more hands-on, human in-the-loop) and an **L4 mode** (more delegation, human on-the-loop). Preflight is most useful on the L3→L4 journey, where harness gaps are the friction that keeps agents from being trusted with more. The autonomy taxonomy is at `docs/reference/l4-autonomy-category-framework.md` (this is the one cross-doc reference where deeper reading is genuinely useful).

The drafting agent (Claude Code, Codex, etc.) is a *channel* through which these roles run, not a fifth persona — it shifts which role is doing what at the keyboard, but doesn't add a hireable user.

## Jobs

### J1 — Build or modify the project's durable harness

**When** I'm starting a project, adding a substantial feature, or modifying the harness as the project shape changes, **help me** produce the durable specs (goals, rules, architecture, JTBD, interface contracts) my agents will execute against, **so that** their work is anchored to intent that survives the session and matches what I actually wanted.

**Justifies:** the doc-type preset and the build/elicitation workflow. **Prevents:** the *"shipped against an under-specified intent"* failure mode where the agent guesses at scope and the guess is wrong in production.

J1 is the generative center — Builder mode at the start of a project, Maintainer mode when the harness has to bend to new reality. At L3 the human writes more of it; at L4 the agent drafts and the human reviews. Either way the artifact is the same shape.

### J2 — Catch defects in the harness before agents code against it

**When** I'm about to hand harness specs to an implementation agent, **help me** identify structural and epistemic defects (unverifiable requirements, EARS violations, dangling references, vague adjectives, implementation prescriptions, contradictions across docs), **so that** the agent doesn't generate code against gaps I'll later have to unwind.

**Justifies:** the rule pack and the bogey-reviewer (defect-finding agent). **Prevents:** the *"looks fine, ships broken"* failure mode where review felt thorough but missed a structural hole.

J2 is Supervisor mode — pre-merge gate at the L3/L4 checkpoint. At L3 it's a self-review pass before the human commits; at L4 it's the agent's self-check before requesting approval and the supervisor's spot-check after.

### J3 — Keep architecture-sized decisions traceable

**When** I'm making an architecture-sized choice — one whose downstream invariants are expensive to re-derive — **help me** record the decision and its rationale as an ADR, **so that** a future reader, contributor, or agent can retrace why the architecture is the way it is and won't silently revert it on the next "improvement."

**Justifies:** ADRs as a *scoped* artifact — kept for architecture-sized choices only, not for routine behavior changes. **Prevents:** the *"silent reversal"* failure mode where a later contributor or agent re-improves a prior decision because the rationale was never written down.

J3 is Maintainer mode (writing the ADR when the choice happens) and Returning-reader mode (reading the ADR when the choice has to be revisited). Routine behavior edits don't need an ADR — that accretes governance without adding traceability the project will actually use. The threshold is *"would re-deriving this from scratch cost real time?"*

### J4 — Keep the harness contributor-readable across time

**When** I'm returning to a project after time away, joining as a new contributor, or reading the harness without invoking any agent, **help me** read the project's current intent from versioned, diffable text files, **so that** the harness remains the source of truth even when no agent is running and a returning reader can answer *"what is this project for and how is it shaped?"* with `git log` and a text editor.

**Justifies:** keeping the harness as checked-in markdown (not agent-mediated state); requiring reviewer rules to cite line-anchored evidence. **Prevents:** the *"truth-in-the-agent"* failure mode where the agent becomes the only thing that knows what the project is supposed to do.

J4 is about the *durable bits* — goals, rules, architecture, JTBD, ADRs. State (current implementation status, in-flight work, what's deployed) is fluid and lives in git history, code, and changelogs; the harness does not try to re-encode it.

## Anti-jobs

- **Not for replacing PAI / agent ISC task decomposition, spec-kit, OpenSpec, or similar SDD frameworks.** Preflight evaluates and produces *this* project harness shape; it does not generate the implementation task graph (the agent does that against the harness), and it does not try to be a drop-in alternative to adjacent spec-driven-dev frameworks (each has its own opinions on lifecycle, artifact shapes, and gates). *Preflight does:* serve projects that adopt this harness shape and review approach; the agent does ISC against the harness; users who want a different SDD shape pick a different tool.
- **Not a CI gate, pre-commit hook, or runtime enforcer.** Preflight runs on demand. Making it block commits or merges turns review trust into review obligation, and false-positive cost compounds. *Preflight does:* return findings when invoked; the user (or a higher-level gate the user explicitly wires up) decides what to do.
- **Not for behavior-change governance.** ADRs are for architecture-sized choices, not every behavioral edit. Forcing an ADR on routine behavior changes accretes process without adding traceability the project will actually use. *Preflight does:* ADR for architecture; commits, code, and spec edits trace everything else.
- **Not a constitution-checker for arbitrary projects.** The rule pack is calibrated for projects that adopt this harness shape. Lifting rules into projects that haven't adopted it surfaces false positives at scale. *Preflight does:* serve projects that have adopted the practice.

## User stories

One concrete narrative per Job. Each acceptance hint is specific enough to drive a real test.

### S1 — Builder, J1
*As a builder starting a new feature, I want the build workflow to ask back the questions I would have skipped (failure modes, rollback plan, observability story) and produce drafts of the right doc types, so that the resulting harness is L4-ready instead of L3-with-gaps.*
- Acceptance: the workflow produces both questions and provisional answers; each provisional answer carries one of {confirmed, inferred, guessed}; overriding a {guessed} answer re-runs only the dependent question subtree; output is the set of doc-type drafts (RFC / requirements delta / architecture entry / interface contract) appropriate to the intent.

### S2 — Supervisor, J2
*As a supervisor reviewing an agent-drafted RFC, I want a defect list with severity and file-anchored quotes, so that I spend attention on calls I have to make — not on issues the rule pack already defines as defects.*
- Acceptance: review output groups findings by severity using FR-031's taxonomy ({Critical, Important, Suggestion}); each finding cites a quote and a rule ID; findings without rule traceability surface as *"judgment call, not rule violation."*

### S3 — Maintainer, J3
*As a maintainer making an architecture-sized change, I want the system to flag my edit as needing an ADR — and to stay silent on routine behavior changes — so that traceability is recorded where it matters and isn't accreted where it doesn't.*
- Acceptance: edits touching `specs/architecture.md` or `specs/interfaces/` are flagged for an ADR; edits touching only `specs/requirements.md` behavioral clauses pass without prompting; the ADR draft includes the change, the alternatives considered, and the rationale.

### S4 — Returning reader, J4
*As a contributor returning to a project (or joining cold), I want `specs/requirements.md`, the relevant ADRs under `specs/decisions/adrs/`, and (when present) `specs/architecture.md` to fully answer "what is this project for and how is it shaped?" without invoking any tool.*
- Acceptance: opening that set of files in a text editor is sufficient on this project to answer the question; no read path requires running preflight, an agent, or any external tool. Each project's harness declares its own file set in `specs/requirements.md` (or wherever the project's index lives) — S4 is satisfied per-project against that declared set.
