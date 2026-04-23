# Multi-phrase benchmark fixture — feature 001, SC-004

**Purpose**: exercise CONST-R04's phrase-level flagging claim. The rule says "Each offending phrase is flagged independently. The reviewer does not stop at the first shape — findings list every phrase that fails the property test." A reviewer that truncates to one finding per principle would pass SC-001/SC-002/SC-003 while silently violating this claim.

**Expected result**: 4 `CONST-R04` findings — 2 per principle, one per distinct implementation-detail shape within each principle.

## Startup

- [CONST-STARTUP-01] The `loadConfig()` helper SHALL read from `settings.json` at startup.

*Shapes embedded: function name (`loadConfig()`), file path (`settings.json`). Expected: 2 CONST-R04 findings.*

## Migration

- [CONST-MIGR-01] Initialization SHALL read `$PAI_CONFIG_DIR` and then invoke `migrate.sh --latest`.

*Shapes embedded: environment variable expression (`$PAI_CONFIG_DIR`), CLI invocation (`migrate.sh --latest`). Expected: 2 CONST-R04 findings.*

## Pass/fail interpretation

- 4 findings → reviewer honors the rule's phrase-level flagging claim. Pass.
- 2 findings (one per principle) → reviewer truncates at principle level despite the rule's explicit claim. The rule's multi-phrase guarantee is aspirational, not operational. File an issue; either tighten reviewer prompting or weaken the rule's claim to "flag at least one shape per principle".
- Any other count → inspect which shape(s) produced duplicate or missing flags.
