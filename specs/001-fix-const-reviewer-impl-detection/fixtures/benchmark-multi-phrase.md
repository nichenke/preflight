# Multi-phrase benchmark fixture — feature 001, SC-004

**Purpose**: exercise CONST-R04's phrase-level flagging claim. The rule says "Each offending phrase is flagged independently. The reviewer does not stop at the first shape — findings list every phrase that fails the property test." A reviewer that truncates to one finding per principle, or that caps findings at 2 per principle, would pass the other SCs while silently violating this claim at higher multiplicity.

**Expected result**: 7 `CONST-R04` findings — one per distinct implementation-detail phrase across the three principles (2 + 2 + 3).

## Startup

- [CONST-STARTUP-01] The `loadConfig()` helper SHALL read from `settings.json` at startup.

*Shapes embedded: function name (`loadConfig()`), file path (`settings.json`). Expected: 2 CONST-R04 findings.*

## Migration

- [CONST-MIGR-01] Initialization SHALL read `$PAI_CONFIG_DIR` and then invoke `migrate.sh --latest`.

*Shapes embedded: environment variable expression (`$PAI_CONFIG_DIR`), CLI invocation (`migrate.sh --latest`). Expected: 2 CONST-R04 findings.*

## Database provisioning

- [CONST-BOOTDB-01] At boot, `provision.sh --init` SHALL initialize PostgreSQL and write logs to `/var/log/pai/`.

*Shapes embedded: CLI invocation (`provision.sh --init`), tool/vendor name (PostgreSQL), directory path (`/var/log/pai/`). Expected: 3 CONST-R04 findings. This principle tests n=3 distinct shapes in one principle — specifically whether the reviewer caps at 2 findings per principle (a regression that n=2 fixtures would not catch). The CLI flag is `--init` rather than `--db` so the flag does not telegraph the tool/vendor phrase; each of the three shapes must be flagged by independent property-test application.*

## Pass/fail interpretation

- 7 findings → reviewer honors the rule's phrase-level flagging claim across n=2 and n=3 shape counts. Pass.
- 6 findings, 3-shape principle flags only 2 → reviewer silently caps at 2 findings per principle. Catch the regression here; SC-001..SC-003 would still pass.
- 4 findings (2 per principle, third principle flags none) or 3 findings (one per principle) → reviewer truncates at principle level. Multi-phrase guarantee is aspirational, not operational.
- Any other count → inspect which phrases produced duplicate or missing flags.
