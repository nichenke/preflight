# Benchmark constitution fixture — feature 001, SC-001

**Purpose**: exercise CONST-R04's implementation-detail property test against the exact leak shapes flagged in issue #13. A reviewer applying the broadened CONST-R04 MUST flag every principle below.

**Expected result**: 5 `CONST-R04` findings — one per principle.

## Content Integrity

- [CONST-CI-01] The `getPaiDir()` helper is the canonical way to locate the PAI directory; every module that needs the path SHALL call it.

## Distribution

- [CONST-DIST-01] When PAI is installed in a custom location, the system SHALL resolve the install root via `process.env.PAI_DIR || fallback` before reading any on-disk state.

## Bootstrapping

- [CONST-BOOT-01] New PAI installations SHALL be initialized by running `bootstrap.sh --target <dir>`; any other initialization path is out of conformance.

## Configuration

- [CONST-CFG-01] Per-user overrides SHALL live in `settings.json` at the PAI root; the system SHALL NOT read configuration from any other filename.

## Memory

- [CONST-MEM-01] All agent memory artifacts SHALL be written under `MEMORY/` relative to the PAI root and SHALL NOT be scattered across other directories.
