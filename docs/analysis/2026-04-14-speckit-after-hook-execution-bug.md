---
type: analysis
date: 2026-04-14
author: nic + Claude Opus 4.6
status: Superseded — the "it's a bug" framing is wrong; see replacement below
source: spec-kit v0.6.2 (git tag) / main @ 0.6.3.dev0
superseded_by: docs/analysis/2026-04-22-speckit-hook-philosophy.md
superseded_on: 2026-04-22
---

# spec-kit after-hook mandatory execution bug

> **⚠️ SUPERSEDED (2026-04-22).** This document frames the after-hook non-execution as a **bug** to be patched upstream. The Stream B / Gate 2.5 investigation on 2026-04-22 concluded with verdict **(β) intentional advisory design** — the behavior is *not* a bug. `optional: false` only guarantees the `EXECUTE_COMMAND` marker is rendered; execution is explicitly delegated to the host AI agent per `src/specify_cli/extensions.py:2509`, and upstream community / maintainer signals (issue #2104 OPEN feature request for `auto_run: true`; issue #2279 closed "not a bug") confirm the advisory reading.
>
> **Do NOT file the upstream PR this document drafts.** It would be closed as duplicate of #2104 or rejected on design grounds.
>
> The accurate mechanical description in this doc (asymmetry identification, template-level diff, code-path trace) remains useful historical record and feeds the classification in the replacement doc. Keep reading this doc *as history*, not as a ticket for action.
>
> See `docs/analysis/2026-04-22-speckit-hook-philosophy.md` for the current framing, full evidence, and implications for preflight's enforcement model.

## Summary

spec-kit command templates have a systematic asymmetry: `before_*` mandatory hooks auto-execute correctly, but `after_*` mandatory hooks are emitted as `EXECUTE_COMMAND` directives that the host agent prints but does not actually invoke. Discovered during preflight Topology A spike Phase 1 testing. Affects every spec-kit core command that supports hooks (9 templates). Breaks auto-execution semantics for any extension that declares `optional: false` on an after-hook.

## Affected scope

All 9 command templates in `templates/commands/`:

| Template | Before-hook blocks | After-hook blocks | "Wait for result" occurrences |
|---|---:|---:|---:|
| analyze.md | 1 | 1 | 1 (before only) |
| checklist.md | 1 | 1 | 1 (before only) |
| clarify.md | 1 | 1 | 1 (before only) |
| constitution.md | 1 | 1 | 1 (before only) |
| implement.md | 1 | 1 | 1 (before only) |
| plan.md | 1 | 1 | 1 (before only) |
| specify.md | 1 | 1 | 1 (before only) |
| tasks.md | 1 | 1 | 1 (before only) |
| taskstoissues.md | 1 | 1 | 1 (before only) |

**100% consistent asymmetry.** Every single template has the "Wait for the result of the hook command before proceeding to the Outline." instruction attached to the before-hook block and omits it from the after-hook block.

## Reproduction

1. Install spec-kit from git source: `pipx install "git+https://github.com/github/spec-kit.git@v0.6.2"`
2. Create a spec-kit project: `mkdir test && cd test && git init && specify init`
3. Install an extension that declares `optional: false` on an after-hook. Example extension.yml:
   ```yaml
   schema_version: "1.0"
   extension:
     id: "test-hook"
     name: "Test Hook"
     version: "0.1.0"
     description: "Reproduction"
   requires:
     speckit_version: ">=0.1.0"
   provides:
     commands:
       - name: "test.hook.target"
         file: "commands/test.hook.target.md"
         description: "Target command the hook invokes"
   hooks:
     after_specify:
       command: "test.hook.target"
       optional: false
       description: "Auto-run after /speckit.specify"
   ```
4. Install with `specify extension add <path> --dev`
5. Verify `.specify/extensions.yml` contains the hook with `optional: false`
6. Run `/speckit.specify <any feature>` in Claude Code
7. **Observed**: command completes, then emits "Automatic Hook: test-hook / Executing: /test.hook.target / EXECUTE_COMMAND: test.hook.target" as output text and stops. The target command is never actually invoked.
8. **Expected**: host agent (Claude Code) executes `test.hook.target` and waits for its result — same as what happens with `before_specify` mandatory hooks (demonstrated by git extension's `speckit.git.feature` auto-creating feature branches).

## Root cause

In `templates/commands/specify.md` (and the 8 other command templates with identical patterns):

**Before-hook handling** (auto-execution works — `specify.md:44-52`):
```
- **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```
```

**After-hook handling** (auto-execution broken — `specify.md:257-264`):
```
     - **Mandatory hook** (`optional: false`):
       ```
       ## Extension Hooks

       **Automatic Hook**: {extension}
       Executing: `/{command}`
       EXECUTE_COMMAND: {command}
       ```
```

Note also the inconsistency: before-hook block uses "**Automatic Pre-Hook**:" while after-hook block uses "**Automatic Hook**:" (missing "Post-" or similar). Minor stylistic inconsistency, but worth fixing as part of the same PR.

The after-hook block emits the `EXECUTE_COMMAND` directive as a literal output line but does not instruct the host agent to actually execute it. Host agents treat the line as informational output and stop. The before-hook block works because of the explicit "Wait for the result of the hook command before proceeding to the Outline." line, which tells Claude Code to invoke the command and wait for its output before continuing.

This is a **prompt engineering gap**, not a code bug. Spec-kit's Python code (`extensions.py:2436-2461`) correctly generates the formatted hook messages. The gap is in the skill prompt templates that instruct host agents how to interpret those messages.

## Why before-hooks work

The before-hook block appears in the skill's **Pre-Execution Checks** section, which runs before the main command outline. The "Wait for the result" instruction gives Claude Code a clear sequencing directive: "run the hook, wait, then continue to the Outline." This sequencing is what turns the EXECUTE_COMMAND directive from informational text into an actual tool call.

The after-hook block appears at the end of the skill (step 9 in specify.md, step N in others) as a "check for extension hooks" bullet list. There's no sequencing directive — no "Wait for the result before reporting success" or equivalent. So Claude Code treats the EXECUTE_COMMAND line as informational output and ends the response.

## Upstream fix

Add a single instruction line to each after-hook Mandatory block. For `specify.md:257-264`:

```diff
     - **Mandatory hook** (`optional: false`):
       ```
       ## Extension Hooks

-      **Automatic Hook**: {extension}
+      **Automatic Post-Hook**: {extension}
       Executing: `/{command}`
       EXECUTE_COMMAND: {command}
+
+      Wait for the result of the hook command before completing.
       ```
```

Apply the same diff (adjusted for indentation context) to:
- `plan.md:97-104`
- `tasks.md:119-126`
- `taskstoissues.md:91-98`
- `analyze.md:~223`
- `checklist.md` after-hook block
- `clarify.md` after-hook block
- `constitution.md` after-hook block
- `implement.md` after-hook block

Also:
- `extensions.py:2456` currently renders **Automatic Hook** for mandatory hooks emitted at runtime — should also be updated to distinguish `**Automatic Pre-Hook**` vs `**Automatic Post-Hook**` based on event timing (before_* vs after_*) for consistency with the skill templates.

## Impact

**For extensions**: Any extension that declares `optional: false` on an `after_*` hook will silently fail to auto-execute. Users see the EXECUTE_COMMAND directive and may not realize it should have been invoked. This is a silent failure — no error, just missing behavior.

**For preflight specifically**: preflight's `after_specify` and `after_plan` hooks exist precisely to auto-fire the review ensemble at workflow gates. Without this fix, preflight's value proposition (hook-enforced review at stage boundaries) is degraded to "manual invocation with a reminder prompt." The research arc's Q1 framing assumed hooks were enforcement gates; they're not, for after-hooks.

**For the broader ecosystem**: This is load-bearing for any extension that wants to run validation, linting, or gating work after a spec-kit stage completes. It's plausible that the only reason this hasn't been reported widely is that most existing extensions only use `optional: true` (suggestions) or before-hooks.

## Workaround for the spike

Manually invoke `/speckit.preflight.review` after `/speckit.specify` and `/speckit.plan`. Acceptable for Phase 1 validation since the review content and ensemble dispatch are what we're testing, not the hook firing mechanism. Document the workaround in the spike 1 report.

## Upstream PR plan

1. File issue at `github/spec-kit` with this document's summary + reproduction
2. Submit PR patching all 9 templates plus `extensions.py:2456` (for the Pre-Hook / Post-Hook label distinction)
3. Include a minimal test extension in the PR demonstrating before + after hook auto-execution parity
4. Reference preflight's spike as the discovery context

## Verification steps after upstream fix

Once the upstream PR is merged and a new spec-kit release is cut:
1. `pipx reinstall specify-cli --spec "git+https://github.com/github/spec-kit.git@vX.Y.Z"`
2. Reinstall preflight's extension in the test project
3. Run `/speckit.specify` and confirm `after_specify` hook auto-fires `/speckit.preflight.review` without manual intervention
4. Run `/speckit.plan` and confirm `after_plan` hook auto-fires the review
5. Confirm the ensemble dispatches both subagents and produces merged findings

If all 5 pass, the Q1 / "has blocking hooks shipped" research question is fully resolved in preflight's favor and Topology A's enforcement claim stands.
