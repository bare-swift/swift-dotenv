// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Sendable, Foundation-free `.env` parser with `${VAR}` expansion.
public enum DotEnv: Sendable {
    public struct Entry: Sendable, Hashable {
        public let key: String
        public let value: String
        public let line: Int
        public init(key: String, value: String, line: Int) {
            self.key = key
            self.value = value
            self.line = line
        }
    }

    /// Parse `.env` source into ordered key/value entries.
    public static func parse(
        _ source: String,
        baseEnvironment: [String: String] = [:]
    ) throws(DotEnvError) -> [Entry] {
        let lines = try Parser.logicalLines(source)
        var entries: [Entry] = []
        entries.reserveCapacity(lines.count)
        var seen: [String: String] = [:]
        for (text, lineNumber) in lines {
            let raw = try Parser.parseStatement(text, lineNumber: lineNumber)
            // Expansion lands in Task 11. For now: literal pass-through.
            let value = raw.value
            entries.append(Entry(key: raw.key, value: value, line: raw.line))
            seen[raw.key] = value
            _ = baseEnvironment    // unused until Task 11
        }
        return entries
    }
}

extension Array where Element == DotEnv.Entry {
    public var dictionary: [String: String] {
        var out: [String: String] = [:]
        out.reserveCapacity(count)
        for e in self { out[e.key] = e.value }
        return out
    }
}
