// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Sendable, Foundation-free `.env` parser with `${VAR}` expansion.
///
/// Pure function: feed a string of `.env` contents, get back ordered
/// ``DotEnv/Entry`` values. File I/O and process-environment mutation are
/// intentionally out of scope.
public enum DotEnv: Sendable {
    /// One parsed assignment.
    ///
    /// `value` has already had escape sequences and `${VAR}` / `$VAR`
    /// expansion applied at parse time.
    public struct Entry: Sendable, Hashable {
        public let key: String
        public let value: String
        /// 1-based line where the `KEY=` assignment started.
        public let line: Int

        public init(key: String, value: String, line: Int) {
            self.key = key
            self.value = value
            self.line = line
        }
    }
}

extension Array where Element == DotEnv.Entry {
    /// Flatten to a dictionary; later entries overwrite earlier ones with the same key.
    public var dictionary: [String: String] {
        var out: [String: String] = [:]
        out.reserveCapacity(count)
        for e in self {
            out[e.key] = e.value
        }
        return out
    }
}
