---
status: draft
date: 2026-04-24
type: analysis
owner: nic
supports: ADR-009
---

# Spec-kit workflow engine mechanism — research for ADR-009

Research input for ADR-009 (integration topology ratification). ADR-009 chose **workflow-extension composite** as the topology on artifact-hygiene and enforcement-strength grounds. This document captures what the workflow engine *actually does* at spec-kit v0.8.0 — separating validated behavior from unvalidated assumptions — and names the concrete mechanism questions a validation spike must answer before ADR-009 moves Proposed → Accepted.

This doc deliberately contains mechanism-level detail that does not belong in the topology ADR itself. The ADR decides the shape; this doc tracks the plumbing; the spike validates the plumbing.

All citations against spec-kit at tag `v0.8.0` cached at `~/.cache/spec-kit`.

## 1. Workflow step type taxonomy

The workflow engine in v0.8.0 provides the following step types (`src/specify_cli/workflows/steps/`):

| Step type | Purpose | Key source |
|---|---|---|
| `command` | Dispatch a spec-kit-registered command via an integration CLI | `steps/command/__init__.py` |
| `prompt` | Send a free-form prompt string to an integration CLI (no registered command required) | `steps/prompt/__init__.py` |
| `shell` | Run an arbitrary shell command via `subprocess.run(shell=True, timeout=300)` | `steps/shell/__init__.py` |
| `gate` | Display a message and prompt the user for approve/reject | `steps/gate/__init__.py` |
| `if_then` | Conditional branching | `steps/if_then/__init__.py` |
| `switch` | Multi-way branch | `steps/switch/__init__.py` |
| `while_loop` | Loop while condition | `steps/while_loop/__init__.py` |
| `do_while` | Loop until condition | `steps/do_while/__init__.py` |
| `fan_out` | Parallel sub-runs | `steps/fan_out/__init__.py` |
| `fan_in` | Join parallel sub-runs | `steps/fan_in/__init__.py` |

The loop and branching primitives (`if_then`, `while_loop`, `do_while`, `switch`, `fan_in`, `fan_out`) unlock patterns beyond the linear specify→implement cycle — fix/review loops, conditional recovery paths, parallel reviewers. Relevant for preflight's future workflow designs; not directly used by the minimum viable review-and-gate shape.

## 2. Gate step — validated

**Source:** `src/specify_cli/workflows/steps/gate/__init__.py:26-69`

- Displays a `message` and prompts the user for one of `options` (default `[approve, reject]`)
- Does **not** invoke commands — a Gate step is a human-approval pause, not a command dispatcher
- `on_reject` accepts `abort`, `skip`, or `retry` (validated at `gate/__init__.py:109`)
- Non-interactive (`sys.stdin.isatty()` false) returns `StepStatus.PAUSED` for later `engine.resume(run_id)` (`gate/__init__.py:47-48`; `engine.py:454-512`)
- Interactive reject + `on_reject: abort` returns `StepStatus.FAILED` at step level, which the engine then remaps to **`RunStatus.ABORTED`** at run level (`engine.py:591-597`). Step-status and run-status are distinct; ADR-009's earlier drafts conflated them.
- `Ctrl+C` during any step triggers `KeyboardInterrupt` handling that saves state as `RunStatus.PAUSED` for clean resume (`engine.py:437-441`)

**The Gate primitive is stable and well-understood.** Validated by direct source read + bundled `workflows/speckit/workflow.yml` demonstrating the `review-spec` and `review-plan` uses.

## 3. CommandStep dispatch — partially validated; one concern

**Source:** `src/specify_cli/workflows/steps/command/__init__.py:31-148`; `src/specify_cli/integrations/base.py:127-130` and `:1313-1315`

CommandStep dispatch path for an integration that supports CLI dispatch (Claude, Copilot, etc.):

1. Workflow YAML declares `command: speckit.specify` (or similar)
2. `CommandStep._execute` calls `integration.dispatch_command(command_name, args, ...)`
3. Inside `dispatch_command`, `build_command_invocation(command_name, args)` produces the slash-invocation string
4. **`build_command_invocation()` computes `stem = command_name.rsplit(".", 1)[-1]`** — for `speckit.specify`, `stem = "specify"`, produces `/speckit-specify` (skills integrations) or `/speckit.specify` (markdown integrations)
5. Integration CLI located via `shutil.which(impl.key)` (`command/__init__.py:134`)
6. Subprocess invocation of the CLI with the slash-command string
7. Returns a dict with `exit_code`, `stdout`, `stderr`

### Concern: namespaced extension commands

Extension manifests register commands in the form `speckit.{extension-id}.{command-name}` — e.g. `speckit.preflight.review`. When this name is passed to CommandStep:

- `stem = command_name.rsplit(".", 1)[-1]` → `"review"`
- Dispatched invocation: `/speckit-review` (skills) or `/speckit.review` (markdown)
- **This is not the command that was registered.** Registered skill names in `extensions.py:893-895` replace *all* dots with hyphens, producing `/speckit-preflight-review`.

**Implication:** the bundled `workflows/speckit/workflow.yml` shape (`command: speckit.specify`) works because `speckit.specify` has a single dot — the stem is the full final segment. Extension commands have two dots and the stem drops the middle segment.

**Open question for the spike:** how are extension commands meant to be invoked from a workflow? Options:
- (a) Extension command names adopt single-segment form (`speckit.preflightreview` — ugly but dispatch-compatible)
- (b) Extension integrations override `build_command_invocation()` to preserve full namespaces
- (c) Workflows bypass CommandStep for extension commands and use PromptStep with literal slash-invocation strings
- (d) Upstream fix required (no community project has hit this yet — catalog empty)

## 4. PromptStep — partially validated; permission & output concerns

**Source:** `src/specify_cli/workflows/steps/prompt/__init__.py`; `src/specify_cli/integrations/base.py:1286-1291`

PromptStep sends a free-form prompt string to the integration CLI. For Claude/skills integrations, the subprocess invocation is approximately:

```
claude -p <prompt> --model <model> --output-format json
```

### Concern 1: permission surface

`PromptStep._try_dispatch` does **not** pass `--allowedTools`, `--permission-mode`, or `--dangerously-skip-permissions` to the Claude CLI. In `-p` (headless) mode, tool-use permission prompts cannot be answered interactively. A PromptStep whose instruction involves agent tool use (e.g. "run git status, create a commit") will hit permission prompts that cannot be satisfied without user pre-approval in Claude settings.

**Implication for #31 (auto-commit):** the draft ADR-009 resolution "workflow PromptStep handles commit-message formation" is **not demonstrated to work** as-is. Viable only with documented permission contract (either rely on user-configured allowlist, or require `--dangerously-skip-permissions` which may or may not be a good idea for a shipped workflow).

### Concern 2: output capture

PromptStep records `exit_code`, `stdout`, and `stderr` in step output, but the docstring notes "Full response text capture is a planned enhancement" (`steps/prompt/__init__.py` class docstring). This means:

- The workflow cannot inspect the response content to branch on it
- A downstream Gate cannot display the prompt output via `show_file` (no file written by PromptStep)
- Verifying "the prompt succeeded at its intended task" reduces to checking `exit_code == 0`, which is weak evidence for e.g. "a commit was actually created with an appropriate message"

### Observation: a preflight review via PromptStep is *differently shaped* than a commit via PromptStep

A commit prompt like "create a git commit for these changes" is a **low-observation** task — the LLM can run the tool use, the user sees the commit in git history afterward. Whether the workflow captured the output or not is secondary.

A review prompt like "run the preflight review on the current spec" is a **high-observation** task — the review produces structured findings that the next Gate step needs to display so the user can make an informed approve/reject decision. PromptStep's "we capture exit code and discard response text" shape is not obviously compatible with review's output needs.

**This distinction matters.** The user's observation that "`claude -p` might be fine for git commit, but not for review" is directly on-point. Commit can tolerate fire-and-check-exit-code semantics; review cannot.

## 5. ShellStep — validated

**Source:** `src/specify_cli/workflows/steps/shell/__init__.py`

Runs arbitrary shell commands via `subprocess.run(shell=True, timeout=300)` with captured `exit_code`, `stdout`, `stderr`. Straightforward; no concerns.

**Note:** spec-kit's security guidance (per a comment in `steps/shell/__init__.py`) is that "workflow authors control commands; catalog-installed workflows should be reviewed before use." ShellStep exists but is not a replacement for PromptStep for cases where LLM judgment is desired (e.g. commit message formation).

## 6. Workflow distribution — partially validated

**Source:** `src/specify_cli/workflows/catalog.py`; `src/specify_cli/__init__.py:1354-1380`

Spec-kit v0.8.0 ships:

- `workflows/catalog.json` with one bundled workflow: `speckit` ("Full SDD Cycle")
- `workflows/catalog.community.json` — **empty** (`"workflows": {}`)
- No `specify workflow add` CLI verb equivalent to `specify preset add` / `specify extension add`

The bundled-workflow install appears to happen as a one-shot shell-out during `specify init`. For third-party workflows:

- **Observation:** workflow registry state appears to persist in `.specify/workflows/workflow-registry.json` (schema at `workflows/catalog.py:57-121`)
- **Open question for the spike:** can a third-party workflow be installed by manual file copy + manual registry edit, or does spec-kit expect the registry to be written only by spec-kit-owned code paths?
- **Open question for the spike:** what is the actual load path? `.specify/workflows/<id>/workflow.yml`? Confirm from source.

## 7. Preset and extension manifests — no cross-version declaration fields

Preset manifest (`preset.yml`) and extension manifest (`extension.yml`) both carry `requires.speckit_version` but no fields for cross-surface version pinning (e.g. no `requires.preflight_workflow_version` on the extension to pin which workflow version it's compatible with). A `preflight install` wrapper that enforces three-surface coherence would be enforcing a **preflight-invented convention**, not reading spec-kit-supported manifest fields.

The `requires` metadata is stored on `WorkflowDefinition` but **runtime enforcement is not yet implemented** per `engine.py:50-52` ("declared but not yet enforced at runtime; enforcement is a planned enhancement"). This means stating that pin `>=0.6.2,<0.7.0` is "incompatible by definition" with a workflow declaring `>=0.7.2` is overstated — it's a **project policy** decision to bump the pin when adopting a workflow, not an upstream runtime constraint.

## 8. Bundled reference — `workflows/speckit/workflow.yml`

The bundled workflow (v0.8.0) demonstrates the patterns available to community workflow authors:

```yaml
schema_version: "1.0"
workflow:
  id: "speckit"
  name: "Full SDD Cycle"
  version: "1.0.0"
  author: "GitHub"
  description: "Runs specify → plan → tasks → implement with review gates"

requires:
  speckit_version: ">=0.7.2"
  integrations:
    any: ["copilot", "claude", "gemini"]

inputs:
  spec:
    type: string
    required: true
    prompt: "Describe what you want to build"
  integration:
    type: string
    default: "copilot"
    prompt: "Integration to use (e.g. claude, copilot, gemini)"

steps:
  - id: specify
    command: speckit.specify
    integration: "{{ inputs.integration }}"
    input:
      args: "{{ inputs.spec }}"

  - id: review-spec
    type: gate
    message: "Review the generated spec before planning."
    options: [approve, reject]
    on_reject: abort

  - id: plan
    command: speckit.plan
    ...
```

Note what the bundled workflow does **not** do:

- It does not run a review command (review is a manual human read between CommandStep and Gate)
- It does not address any of the namespaced-extension-command concerns (all commands are single-dot `speckit.*`)
- It does not auto-commit

**Implication:** the bundled workflow is a valid structural template for Gate-based approval, but it doesn't answer preflight's specific review-shaped needs.

## 9. Proposed preflight workflow shape (sketch — unvalidated)

An earlier draft of ADR-009 proposed:

```
specify (CommandStep)                → /speckit.specify
preflight-review-spec (CommandStep)  → /speckit.preflight.review  [OPEN: dispatch concern]
gate-spec (Gate)                     → message + [approve|reject], on_reject: abort
plan (CommandStep)                   → /speckit.plan
preflight-review-plan (CommandStep)  → /speckit.preflight.review  [OPEN: dispatch concern]
gate-plan (Gate)                     → message + [approve|reject], on_reject: abort
tasks (CommandStep)                  → /speckit.tasks
implement (CommandStep)              → /speckit.implement
[optional] commit (PromptStep)       → "commit these changes"       [OPEN: permission/verification]
```

Open questions mapped to sections above:
- Review command dispatch — § 3 (CommandStep dispatch concern on namespaced names)
- Review output surfacing — § 4 concern 2 (PromptStep output capture, or CommandStep stdout capture, or file-based handoff via Gate `show_file`)
- Auto-commit via PromptStep — § 4 concern 1 (permission surface) + concern 2 (verification)
- Workflow distribution — § 6

## 10. Open mechanism questions the spike must answer

A 1–2 day validation spike should produce concrete answers to:

1. **Command dispatch for namespaced extension commands.** Build a minimal preflight-extension + preflight-workflow where the workflow tries to dispatch the registered review command via CommandStep. Record: what gets invoked? If it fails, try single-segment naming (§ 3 option (a)) and measure friction. This determines whether preflight can use CommandStep at all for its review command, or must route through PromptStep.

2. **Review output handoff to Gate.** Produce a preflight review output (from the existing reviewer ensemble) inside the workflow, such that the subsequent Gate step displays it to the user. Determine the mechanism: does the review command write a file the Gate reads via `show_file`? Does stdout surfacing work? Both? Neither? Pick the working path.

3. **Auto-commit via PromptStep.** Implement a PromptStep that prompts the agent to commit changes. Test: does it work with default user settings? What permission pre-approval is required? Is the failure mode "permission prompt stalls silently" or "subprocess exits clean but no commit created" or something else? Based on findings, either document the permission contract or retire #31 to "unproven follow-up."

4. **Workflow install path.** Actually install a third-party (preflight-authored) workflow into a test project. Manual copy + registry edit if needed. Document the steps. This becomes the basis for the `preflight install` wrapper's workflow-copy logic.

The spike produces a short writeup answering these four questions. ADR-009 then gets a revision that folds answers in and moves Proposed → Accepted (or triggers a re-evaluation if answers invalidate the composite choice).

## 11. Citations

All source line-references are against spec-kit `v0.8.0` at `~/.cache/spec-kit`.

- `src/specify_cli/workflows/engine.py:22-92` — workflow engine state machine
- `src/specify_cli/workflows/engine.py:50-52` — "requires runtime enforcement planned enhancement" note
- `src/specify_cli/workflows/engine.py:437-441` — `KeyboardInterrupt` → `RunStatus.PAUSED`
- `src/specify_cli/workflows/engine.py:454-512` — `resume(run_id)` logic
- `src/specify_cli/workflows/engine.py:591-597` — gate abort `StepStatus.FAILED` → `RunStatus.ABORTED` remapping
- `src/specify_cli/workflows/steps/gate/__init__.py:26-69` — Gate step execute
- `src/specify_cli/workflows/steps/gate/__init__.py:47-48` — non-interactive TTY pause
- `src/specify_cli/workflows/steps/gate/__init__.py:109` — `on_reject` value validation
- `src/specify_cli/workflows/steps/command/__init__.py:31-148` — CommandStep dispatch
- `src/specify_cli/workflows/steps/command/__init__.py:117-145` — integration CLI resolution
- `src/specify_cli/workflows/steps/prompt/__init__.py` — PromptStep (class docstring; planned-enhancement note)
- `src/specify_cli/workflows/steps/prompt/__init__.py:117,130-135` — subprocess invocation and output capture
- `src/specify_cli/workflows/steps/shell/__init__.py` — ShellStep
- `src/specify_cli/integrations/base.py:127-130` — markdown `build_command_invocation` stem extraction
- `src/specify_cli/integrations/base.py:1286-1291` — skills `build_exec_args` (no permission flags)
- `src/specify_cli/integrations/base.py:1313-1315` — skills `build_command_invocation` stem extraction
- `src/specify_cli/extensions.py:893-895` — skill registration (dot-to-hyphen replacement)
- `src/specify_cli/extensions.py:2505-2527` — `execute_hook()` docstring: execution delegated to AI agent
- `workflows/speckit/workflow.yml` — bundled reference workflow
- `workflows/catalog.community.json` — empty community catalog
- `workflows/catalog.py:57-121` — workflow registry schema

## 12. Review-and-revision trail

This document consolidates mechanism-level findings that surfaced during ADR-009 stress-testing:

- Initial Explore pass (2026-04-24) — workflow engine stability + peer evidence scan
- Codex second-opinion (first draft) — Gate-vs-CommandStep factual correction
- Codex adversarial review (final committed draft) — namespaced-command dispatch concern + PromptStep permission concern + `>=0.7.2` overstatement + `StepStatus.FAILED` vs `RunStatus.ABORTED` conflation
- Technical red-team agent — same findings as Codex adversarial plus Gate TTY-detection fragility in Claude-agent shell, workflow-registry stale-state after re-runs, permission-prompt storm on `claude -p` spawns

The ADR was reshaped to topology-scope-only after these findings; this document inherits the mechanism content for the spike to validate.
