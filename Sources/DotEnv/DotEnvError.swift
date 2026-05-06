// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Errors thrown by ``DotEnv/parse(_:baseEnvironment:)``.
public enum DotEnvError: Error, Equatable, Sendable {
    /// A non-blank, non-comment line that does not contain `=`.
    case missingEquals(line: Int)

    /// The key on the left of `=` does not match `[A-Za-z_][A-Za-z0-9_]*`.
    case invalidIdentifier(line: Int)

    /// A `'` or `"` was opened but never closed before EOF.
    case unterminatedQuote(line: Int)

    /// A `\` inside a double-quoted string is followed by a byte that isn't
    /// `n`, `r`, `t`, `\`, `"`, `'`, or `$`.
    case invalidEscape(line: Int)

    /// `${VAR` opened but `}` not seen before EOF.
    case unterminatedExpansion(line: Int)
}
