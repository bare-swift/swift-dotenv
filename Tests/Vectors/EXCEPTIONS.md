# Test-parity exceptions

Per [RFC-0002](https://github.com/bare-swift/bare-swift/blob/main/rfcs/0002-test-parity-policy.md), this file documents why some upstream test cases are not extracted as fixtures.

## Source: `dotenvy` (Rust crate)

`dotenvy` ships its tests as `.env` fixture files in `tests/`. Each fixture
pairs an input file with an expected key/value mapping (or expected error).

The Swift translation:

- Hand-translated each fixture to an inline Swift test row in the appropriate
  `Parse*Tests.swift` / `ExpansionTests.swift` / `ParseErrorTests.swift`
  file. Inline rows match the codebase pattern (no Foundation runtime fixture
  loading; we already use this approach for swift-uuid, swift-xxhash, swift-jsonpointer).
- Round-trip property tests (`DotEnvRoundTripTests.swift`) approximate
  dotenvy's randomised tests using a deterministic LCG — no Foundation, no
  `proptest` equivalent needed.

## Out of scope for v0.1 (no Swift counterpart)

- dotenvy's file I/O tests (`from_path`, `from_filename`, `from_iter` over
  files). Caller responsibility — documented in CHANGELOG.
- dotenvy's `setenv`/process-environment loading tests (`dotenv()`).
  Caller responsibility — documented in CHANGELOG.
- POSIX shell-style expansion modifiers (`${VAR:-default}` etc.). dotenvy
  itself does not support these; nothing to translate.

## Refresh

When upstream releases new versions, re-read tests and add Swift
equivalents for any new cases. Record source commits here when refreshing:

- `dotenvy`: tracked at upstream commit (record at next refresh)
