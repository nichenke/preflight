# spec-kit after-hook philosophy — classification

**Date:** 2026-04-22
**Author:** B5 subagent investigation (Stream B, Gate 2.5)
**Upstream ref:** spec-kit @ `c52ea23` (origin/main, 2026-04-22; local HEAD `c0152e4` slightly stale but asymmetry identical)
**Cross-reference:** `docs/analysis/2026-04-14-speckit-after-hook-execution-bug.md` (prior "it's a bug" framing)

## Classification

**Verdict: (β) intentional advisory design.**

The before/after "Wait for the result" asymmetry is not a defect; it reflects a design in which `optional: false` means "not promptable; fire the notification automatically" and *not* "the host agent must block until completion." The very same commit (`d0a112c`, PR #1702) introduced *both* halves of the asymmetry together, by the same author, with distinct structural framing — the pre-hook block sits inside a "Pre-Execution Checks" section with an explicit "before proceeding to the Outline" sequencing directive, while the after-hook block is positioned *after* a "Stop and report: Command ends…" step. Upstream source code confirms this: `src/specify_cli/extensions.py:2509` is explicit — *"The actual execution is delegated to the AI agent."* Spec-kit does no enforcement itself; it emits a `EXECUTE_COMMAND:` marker and hopes the agent picks it up. Most decisively, open issue #2104 is a community *feature request* asking for a new `auto_run: true` field because `optional: false` empirically does not auto-execute — meaning the community already reads `optional: false` as advisory, and upstream has not treated that reading as a bug. The asymmetry has persisted unchanged across ten months and multiple releases up through v0.7.4/0.7.5.dev on origin/main as of 2026-04-22. If it were a bug, it would have been patched by now.

## Evidence by question

### Q1 — Is the before/after asymmetry intentional?

**Yes, intentional.** The asymmetry was introduced in a single commit, by a single author, in the same diff that wired the hook system into any template for the first time.

- Commit `d0a112c` (PR #1702, 2026-03-04, Manfred Riem): *"fix: wire after_tasks and after_implement hook events into command templates"*. In this single commit, **both** the before-hook block (with "Wait for the result of the hook command before proceeding to the Outline.") **and** the after-hook block (without any wait directive) were added side-by-side to `templates/commands/tasks.md` and `templates/commands/implement.md`. See the diff hunks introducing both `Pre-Execution Checks` sections and `Check for extension hooks` trailing steps.
- The template's structural framing of each block is qualitatively different:
  - Before-hook: lives under `## Pre-Execution Checks`, **above** the main `## Outline` — structurally a gate.
  - After-hook: lives as the final numbered step in the Outline, **after** an explicit "Stop and report: Command ends…" step (see `templates/commands/plan.md` step 4→5 on origin/main). Structurally a post-completion notification.
- The naming is also deliberately asymmetric: `**Automatic Pre-Hook**` (pre) vs `**Automatic Hook**` (post) and `**Optional Pre-Hook**` (pre) vs `**Optional Hook**` (post). If the author had intended symmetry, they would have used `**Automatic Post-Hook**` / `**Optional Post-Hook**`. They did not.
- Commit `333a765` (PR #1886, 2026-03-19) *"feat(commands): wire before/after hook events into specify and plan templates"* explicitly says it is "replicating the hook evaluation pattern from tasks.md and implement.md (introduced in PR #1702) into the specify and plan command templates." The asymmetry was copy-propagated verbatim across all 9 core templates. A copy-paste of a 25-line block that "accidentally" drops one specific line, uniformly across all nine templates, by two different authors, over several PRs, is not a copy-paste error — it's a faithful replication of the intended shape.
- The asymmetry persists unchanged on origin/main as of `c52ea23` (2026-04-22), which is after release v0.7.4. Ten months and multiple releases have not prompted anyone upstream to add the "Wait for the result" line to after-hook blocks.

### Q2 — What does `optional: false` guarantee?

**In the *contract*: only that the hook will be *rendered* as an `EXECUTE_COMMAND:` directive instead of a prompt-for-confirmation. No code path guarantees fire, completion, or blocking. Enforcement is delegated entirely to the host AI agent's interpretation of the rendered marker.**

Authoritative definitions:

- **`src/specify_cli/extensions.py:2418-2461`, `format_hook_message()`** — the only code path that handles `optional`:

  ```python
  optional = hook.get("optional", True)
  ...
  if optional:
      lines.append(f"\n**Optional Hook**: {extension}")
      lines.append(f"Command: `{display_invocation}`")
      ...
      lines.append(f"\nPrompt: {prompt}")
      lines.append(f"To execute: `{display_invocation}`")
  else:
      lines.append(f"\n**Automatic Hook**: {extension}")
      lines.append(f"Executing: `{display_invocation}`")
      lines.append(f"EXECUTE_COMMAND: {command_text}")
      lines.append(f"EXECUTE_COMMAND_INVOCATION: {display_invocation}")
  ```

  That is the entirety of what the code does with `optional`. It picks between two text templates. There is no scheduling, no waiting, no status tracking, no retry, no success-check.

- **`src/specify_cli/extensions.py:2505-2527`, `execute_hook()`** — the most on-the-nose piece of evidence. The docstring:

  ```
  """Execute a single hook command.

  Note: This returns information about how to execute the hook.
  The actual execution is delegated to the AI agent.
  ```

  The method returns a dict. It does not execute anything. Upstream has explicitly and normatively written down that host-agent interpretation is the enforcement layer, not spec-kit's runtime.

- **`src/specify_cli/extensions.py:2463-2503`, `check_hooks_for_event()`** — returns `{has_hooks, hooks, message}`. The `message` field is a rendered string for display. No completion tracking, no blocking return, no callback.

- **`extensions/EXTENSION-DEVELOPMENT-GUIDE.md:212`** — "`optional`: If true, prompt user before executing." The inverse logic for `optional: false` is "don't prompt; just execute" — but "execute" here refers to the *agent* executing when it sees the marker, not spec-kit executing.

- **`extensions/EXTENSION-DEVELOPMENT-GUIDE.md:656`** — `optional: false  # Always run`. Normative documentation: the *intent* is "always run" (i.e. no prompt), but there is nothing anywhere in the code that *enforces* "run" — only that the message marker is emitted.

- **`extensions/EXTENSION-API-REFERENCE.md:589-608`** — the normative on-the-wire hook message format for mandatory hooks is just three lines:

  ```markdown
  **Automatic Hook**: {extension}
  Executing: `/{command}`
  EXECUTE_COMMAND: {command}
  ```

  No wait directive. The API reference *defines* the protocol and the protocol does not include "block until complete."

**Summary:** `optional: false` guarantees (a) the hook will be rendered with an `EXECUTE_COMMAND:` marker and (b) the user will not be prompted for confirmation. It does **not** guarantee the host agent actually runs the command, completes it before returning, or succeeds. All three are "best-effort on the agent's part, interpreted from a free-text marker."

### Q3 — v0.7.0 workflow engine impact

**Yes, it changes the enforcement story decisively: spec-kit is building a proper step-based workflow engine with explicit `Gate` / `CommandStep` / `PAUSED` / `FAILED` / `ABORTED` semantics — that is the real enforcement surface going forward. Hooks were the v1 mechanism; workflows are the v2 mechanism. The prompt-embedded hook system is legacy and will likely not get enforcement retrofitted.**

PR #2158 (commit `a00e679`, "Add workflow engine with catalog system", merged into 0.7.x line) introduces:

- `src/specify_cli/workflows/engine.py` (778 lines) — a proper state machine
- `src/specify_cli/workflows/steps/gate/` — Gate steps that "prompt `[1] approve [2] reject` in TTY / Fall back to `PAUSED` in non-interactive environments" and support `on_reject: retry`
- `src/specify_cli/workflows/steps/command/` — CommandStep which "returns FAILED when CLI not installed (was silent COMPLETED)" and which actually invokes dispatched commands via the integration's CLI (not via prompt markers)
- `RunStatus.PAUSED`, `RunStatus.FAILED`, `RunStatus.ABORTED` as first-class state machine outcomes
- `Ctrl+C saves state as PAUSED for clean resume`
- Explicit fan-out/fan-in, while-loops, if-then, and switch steps

This is structurally different from the hook dispatch layer. Hook dispatch relies on a single free-text marker and the host agent's prompt-obedience to execute it. The workflow engine relies on a Python state machine that:

1. Dispatches commands via `integration.build_exec_args()` + `integration.dispatch_command()` (real subprocess, not prompt marker)
2. Tracks per-step completion status
3. Persists run state on disk for resume across sessions
4. Treats gates as first-class interruption points with explicit approve/reject semantics

**There is no `blocking: true` field on the hook surface on any version up to and including origin/main v0.7.5.dev (2026-04-22).** What there is instead is `Gate` steps inside workflows. That's spec-kit's designated mechanism for what the hook system was never meant to do.

Implication for preflight: if preflight wants hard author-time enforcement of review before `/speckit.plan` completes, the correct upstream primitive is a workflow with a Gate step that calls the review command before dispatching `/speckit.plan` — not an `after_specify` hook with `optional: false`.

### Q4 — v0.7.3 marker-based upsert as alternative

**No, PR #2259 is not a hook-enforcement alternative. It solves a different problem (idempotent agent-context file mutation), though it does surface a related design insight: spec-kit's preferred mutation surface is file markers, not prompt execution.**

PR #2259 (commit `fc3d124`, *"fix: replace shell-based context updates with marker-based upsert"*) replaces ~3500 lines of bash/PowerShell context-update scripts with a Python-based marker system: `<!-- SPECKIT START/END -->` markers in the host agent's context file (CLAUDE.md, AGENTS.md, etc.) are maintained directly by the Python CLI at `integration_install` / `integration_switch` / `integration_uninstall` time. The LLM is then instructed (via the plan template) to update the plan reference *between the markers*.

Relevance to preflight's use-case:

- **This is not a hook API.** It is a one-shot installer-time mutation of a specific file with a specific marker convention, executed by Python code during `specify` CLI operations, not by the host agent post-command.
- **It is not event-driven.** There is no `after_plan` equivalent. The upsert runs when the user runs `specify` CLI commands (install/switch/uninstall), not when the host agent completes a speckit skill.
- **However**, the pattern does suggest spec-kit is converging on "Python code owns idempotent mutations of specific files with markers" as the safe/deterministic alternative to "prompt the LLM and hope it edits correctly." That's structurally similar to what a review extension might want for, say, updating a review log.

If preflight wanted to use this style, it would need to:
1. Run review as a workflow Gate step (per Q3), OR
2. Ship a post-run file mutation via Python code triggered by some installer-time hook we haven't found evidence of.

Neither of these is "after-hook with blocking." So this PR does not offer an enforcement surface for preflight's specific need.

### Q5 — Intended enforcement mechanism

**For hard enforcement, upstream's intended mechanism is (a) **pre-hooks** with `optional: false` and the explicit "Wait for the result" directive, relying on host-agent compliance, or (b) **workflow Gate steps** (the newer, proper primitive). There is no `blocking: true` field anywhere in the hook surface, and no roadmap signal that one is coming.**

Evidence:

- **Pre-hooks *are* treated as enforcement**: the "Wait for the result of the hook command before proceeding to the Outline" directive exists only on before-hook blocks. Issue #2149 (user reported Cursor not executing `optional: false` pre-hooks) was treated by maintainers as a *per-agent bug* ("Feel free to create a PR to migrate Cursor from commands to skills" — mnriem, collaborator). Issue #2178 (Claude Code not executing pre-hooks) was *actually fixed* by PR #2227, which flipped `disable-model-invocation: false` and added a dot-to-hyphen naming note so Claude could execute the skill. Upstream treats pre-hook non-execution as a bug to fix. They do not treat after-hook non-execution the same way.
- **No `blocking:` field in any YAML schema**: Grepped every YAML example in RFC, API reference, user guide, and development guide. Zero occurrences of a `blocking` field. The `optional` field is the only execution-modality field.
- **Workflows are the designated path forward**: PR #2158's Gate step has `on_reject` values like `"abort"` and `"retry"` and explicit `PAUSED` semantics — this is clearly the primitive chosen for "must-pass checkpoints." The speckit workflow bundled in `workflows/speckit/workflow.yml` is the example of how a maintainer-endorsed enforced flow is built.
- **Issue #2104 is OPEN as a feature request**, not closed as a bug or converted to a PR. Upstream has neither accepted "after-hooks should block" as a defect nor committed to any roadmap item.
- **Issue #2279 was closed as "not a bug"** by maintainer mnriem (2026-04-20). The user's after_tasks `optional: false` hook emitted `EXECUTE_COMMAND:` but the commit never happened. Maintainer response: your extension's *own internal config* (`auto_commit.after_tasks.enabled`) is what governs whether it runs; the after-hook firing is ancillary. This confirms the mental model: after-hooks are notifications; extensions run or no-op based on their own configuration.

**Absence confirmed**: searched issues/discussions for "blocking", "after hook", "auto-run", "advisory" — no roadmap issue for `blocking: true` on after-hooks exists as of 2026-04-22.

### Q6 — Community signal

**Preflight would not be filing the first request. There is an existing OPEN feature request (#2104) that is effectively the same ask. Two bug reports (#2149, #2279) have been closed in ways that confirm the advisory-by-design interpretation. No community thread exists that frames the after-hook non-execution as a defect.**

Relevant threads:

| # | State | Framing | Relevance |
|---|-------|---------|-----------|
| [#2104](https://github.com/github/spec-kit/issues/2104) | **OPEN** (feature req) | "when `optional: false` the AI agent only indicates that execution is mandatory. Wouldn't it be possible to add a new option like `auto_run: true` …" | **Direct**: community request for the feature preflight wants. Frames it as a missing feature, not a bug. |
| [#2149](https://github.com/github/spec-kit/issues/2149) | CLOSED (per-agent bug) | Cursor doesn't execute `optional: false` pre-hooks. Maintainer: migrate Cursor commands→skills. | **Indirect**: upstream *does* treat pre-hook non-execution as a defect, but per-agent. Strengthens the asymmetry reading. |
| [#2279](https://github.com/github/spec-kit/issues/2279) | CLOSED "not a bug" | `after_tasks` / `optional: false` git commit hook doesn't commit. Maintainer: your extension's own config gate is `enabled: false`, fix that. | **Direct**: maintainer (mnriem) *explicitly* routed around the "after-hook should enforce" framing. |
| [#2178](https://github.com/github/spec-kit/issues/2178) | CLOSED (fixed) | Claude Code stops after pre-hook block. Fixed by PR #2227 — Claude-specific skill invocation enablement. | **Indirect**: pre-hook execution IS treated as enforcement worth fixing bugs for. |
| [#1701](https://github.com/github/spec-kit/issues/1701) | CLOSED (fixed) | "Extension hooks (after_tasks, after_implement) are never triggered." Fixed by PR #1702 — added EXECUTE_COMMAND marker. | **Direct**: original bug was "hooks don't emit anything", solved by emitting a marker — upstream solved-for "visibility," not "enforcement." |
| [#2221](https://github.com/github/spec-kit/discussions/2221) | OPEN discussion | "Should spec-kit support an optional complexity-aware review for AI-generated specs?" | **Adjacent**: near-exact preflight use-case, framed as open-ended question. |

Preflight should engage #2104 (comment on it, or open a parallel discussion) rather than file a new issue for the asymmetry. An "after-hook does not block" report will almost certainly be closed as a duplicate of #2104 with the same "this is a feature request, not a bug" framing.

## Implications for preflight

- **If (α):** *(not applicable given verdict)* — File an upstream PR patching all 9 templates to add "Wait for the result of the hook command before completing." Expect a quick merge.
- **If (β):** **Topology A's enforcement claim is wrong-by-design. Revisit before Spike 2.** The options that remain available to preflight, in order of preference:
  1. **Workflow Gate (preferred).** Ship preflight as a spec-kit **workflow**, not as an after-hook on top of a spec-kit **extension**. Define a workflow that runs `/speckit.specify` → `Gate: preflight-review` → `/speckit.plan` → `Gate: preflight-review` → `/speckit.tasks`. Each Gate step is a first-class spec-kit primitive with real `APPROVE`/`REJECT`/`PAUSED` semantics (evidence: PR #2158). This is upstream's designated path.
  2. **Pre-hook relocation.** Move preflight's review from `after_specify`/`after_plan` to `before_plan`/`before_tasks`/`before_implement`. Pre-hooks have the "Wait for the result" directive and ARE treated as enforcement. "Review the spec *before* planning" is also arguably more useful than "review the spec *after* specifying" for the user's mental model. Cost: review happens one step later than intended; acceptable for most uses. Also: Cursor and older Claude Code versions still may not comply, per #2149 / #2178.
  3. **Soft-enforcement via optional hook + convention.** Accept advisory-by-design, ship `after_specify` as `optional: true` with a strong prompt, document that reviewers should run it. This is what most existing spec-kit extensions already do. Lowest friction; weakest enforcement.
  4. **Upstream proposal.** Contribute a comment on issue #2104 making preflight's case for `auto_run: true` (or for an explicit `blocking: true` field on hooks). Track as a long-horizon upstream ask independent of what preflight ships in the near term.
- **If (γ):** *(not applicable given verdict)* — Open an upstream discussion referencing #2104 to ask for clarification, wait for maintainer signal, do not file a patch.

## Implications for Topology A (ADR-007)

**Topology A's enforcement claim does not survive this finding, but Topology A itself may still survive — it just needs to be rewired off `after_*` hooks and onto something that is actually enforced.** The specific claim in ADR-007 that "preflight hooks auto-fire at workflow gates" was predicated on `after_specify` / `after_plan` with `optional: false` executing synchronously and blocking host-agent completion. That predicate is false. Concretely:

- The "review runs inside the spec-kit command" behavior preflight assumed it could achieve via `after_*` hooks is not available through the hook mechanism at all — not now, and not on any published roadmap.
- The enforcement primitive spec-kit has chosen is the workflow engine's Gate step, which lives on a different integration surface (workflow YAML + step registry, not `extensions.yml`).
- Topology A can be rewritten as "preflight as a spec-kit **workflow** extension" — shipping a bundled workflow that wraps `/speckit.specify` + `Gate: /speckit.preflight.review` + `/speckit.plan` — and this preserves the "author-time enforcement" value proposition. But that is a **different topology** than the one ADR-007 currently describes. It looks like **Topology A-prime** or maybe a distinct **Topology D** (workflow-extension composite).
- If preflight ships only as an `after_*` hook (no workflow), it is honestly what spec-kit currently calls "advisory / recommendation" — which is still useful, but is not "enforcement at author-time." ADR-007's framing needs to say so.

**Recommendation: pause the ADR-007 promotion gate and author Amendment 2 (or ADR-007-bis) that reframes the enforcement mechanism from "after-hook with `optional: false`" to "workflow Gate step," and evaluate Topology A-prime (workflow-extension) against Topologies B/C in the light of this finding.**

## Signal back to workflow-research (Gate 2.5)

**STOP Spike 2 as currently scoped.** The tack-room launcher should not be built on the assumption that `after_*` hooks with `optional: false` will block and enforce — they will not. Before Spike 2 resumes, the workflow-research worktree should either (a) rescope Spike 2 to target the spec-kit workflow engine (`src/specify_cli/workflows/`, PR #2158) as the enforcement surface, or (b) explicitly accept advisory-only semantics and design the tack-room launcher around that weaker guarantee. Either path is viable; the current path is not.

## Cross-reference resolution

This finding **contradicts** the framing in `docs/analysis/2026-04-14-speckit-after-hook-execution-bug.md`. Specifically:

- The 2026-04-14 doc's title ("mandatory execution bug") and summary ("Breaks auto-execution semantics for any extension that declares `optional: false` on an after-hook") claim the asymmetry is a defect. This investigation finds it is intentional design.
- The 2026-04-14 doc's "Root cause" section (lines 65-98) correctly identifies the template-level asymmetry and its mechanism, and labels it a "prompt engineering gap." The observation is accurate; the *label* (gap/bug) is wrong. It is a prompt engineering *choice*, not a gap.
- The 2026-04-14 doc's "Upstream PR plan" (line 149) proposes patching all 9 templates. **Do not file this PR as currently drafted.** It would almost certainly be closed as invalid — upstream would either route it to #2104 as a feature request requiring design discussion, or reject it on grounds that the after-hook surface is intentionally advisory and the enforcement primitive is now workflow Gates.
- The 2026-04-14 doc's "Why before-hooks work" section (lines 100-104) is a correct description of the mechanism; but the framing that the after-hook block "should" have the same directive misses that the structural placement (*after* "Stop and report: Command ends…") encodes "post-completion notification," not "pre-completion gate."
- The 2026-04-14 doc's "Impact / For preflight specifically" (lines 140-141) — *"preflight's value proposition (hook-enforced review at stage boundaries) is degraded to 'manual invocation with a reminder prompt.'"* This framing is correct on the degradation direction but wrong on the causation: the value proposition is not *degraded*, it was *never available* via the hook surface. The degradation was a misread of the contract, not a bug in the implementation.

**Recommended follow-up for the 2026-04-14 doc:** add a "Status: superseded" header pointing to this document. Keep the 2026-04-14 analysis as historical record of the original (incorrect) framing, because it still contains accurate mechanical description that feeds into this classification.
