# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-05-06

### Added
- `DotEnv.parse(_:baseEnvironment:)` — pure-function `.env` parser. Sendable, Foundation-free, returns ordered `[DotEnv.Entry]` (key + already-expanded value + 1-based line number).
- Quoting: single-quoted (literal), double-quoted (with `\n`/`\r`/`\t`/`\\`/`\"`/`\'`/`\$` escapes), and unquoted with whitespace-trimming and inline `# comment` stripping.
- Variable expansion: `${VAR}` and `$VAR`, resolving against (1) earlier entries in the same source, (2) the supplied `baseEnvironment`, (3) empty string. Single-quoted values are not expanded; `\$` in double-quoted values is a literal `$`.
- `export KEY=value` prefix accepted and stripped.
- `Array<DotEnv.Entry>.dictionary` extension — last-wins flatten to `[String: String]`.
- `DotEnvError` typed error enum (`missingEquals`, `invalidIdentifier`, `unterminatedQuote`, `invalidEscape`, `unterminatedExpansion`), each carrying the offending source line.
- DocC documentation, full README example, NOTICE crediting upstream `dotenvy`.

### Limitations (out of scope for v0.1)
- File I/O. Caller reads the file (one line of Foundation or POSIX).
- Loading parsed entries into the process environment (`setenv`). One-line at the call site.
- Override-vs-set semantics flag. Caller policy.
- POSIX shell-style expansion modifiers: `${VAR:-default}`, `${VAR-default}`, `${VAR:?msg}`. dotenvy itself doesn't support these.
- Watch / reload, multi-file merging, source-preserving formatter.
