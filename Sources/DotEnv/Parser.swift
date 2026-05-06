// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Internal parser for `.env` source.
enum Parser {
    /// One parsed assignment, prior to `${VAR}` expansion.
    struct RawAssignment {
        var key: String
        var value: String
        /// `true` if expansion should be applied (unquoted or double-quoted).
        /// `false` if single-quoted (literal).
        var expandsVariables: Bool
        var line: Int
    }

    /// Walk `source`, yielding one logical line per top-level statement.
    /// Returns `(lineText, startLineNumber)` pairs. Quoted multi-line values
    /// are coalesced.
    static func logicalLines(_ source: String) throws(DotEnvError) -> [(String, Int)] {
        var out: [(String, Int)] = []
        let scalars = Array(source.unicodeScalars)
        var i = 0
        var line = 1
        while i < scalars.count {
            let lineStart = line
            var j = i
            while j < scalars.count && (scalars[j] == " " || scalars[j] == "\t") {
                j += 1
            }
            // Blank line?
            if j == scalars.count || scalars[j] == "\n" {
                if j < scalars.count { line += 1 }
                i = j + (j < scalars.count ? 1 : 0)
                continue
            }
            // Full-line comment?
            if scalars[j] == "#" {
                while j < scalars.count && scalars[j] != "\n" { j += 1 }
                if j < scalars.count { line += 1 }
                i = j + (j < scalars.count ? 1 : 0)
                continue
            }
            // Real statement: scan until end-of-logical-line, tracking quote state.
            var quote: Unicode.Scalar? = nil
            var prevWasBackslash = false
            var endIdx = j
            while endIdx < scalars.count {
                let c = scalars[endIdx]
                if let q = quote {
                    if c == "\\" && q == "\"" {
                        prevWasBackslash.toggle()
                        endIdx += 1
                        continue
                    }
                    if c == q && !prevWasBackslash {
                        quote = nil
                    }
                    prevWasBackslash = false
                    if c == "\n" { line += 1 }
                    endIdx += 1
                    continue
                }
                if c == "\n" {
                    break
                }
                if c == "'" || c == "\"" {
                    quote = c
                    prevWasBackslash = false
                    endIdx += 1
                    continue
                }
                endIdx += 1
            }
            if quote != nil {
                throw .unterminatedQuote(line: lineStart)
            }
            let content = String(String.UnicodeScalarView(scalars[i..<endIdx]))
            out.append((content, lineStart))
            if endIdx < scalars.count && scalars[endIdx] == "\n" {
                line += 1
                i = endIdx + 1
            } else {
                i = endIdx
            }
        }
        return out
    }

    /// Parse one logical line into a ``RawAssignment``.
    static func parseStatement(_ line: String, lineNumber: Int) throws(DotEnvError) -> RawAssignment {
        var s = Substring(line)
        s = trimLeading(s)
        if s.hasPrefix("export ") || s.hasPrefix("export\t") {
            s = s.dropFirst("export".count)
            s = trimLeading(s)
        }
        guard let (key, rest) = readIdentifier(s) else {
            throw .invalidIdentifier(line: lineNumber)
        }
        var afterKey = trimLeading(rest)
        guard afterKey.first == "=" else {
            throw .missingEquals(line: lineNumber)
        }
        afterKey = afterKey.dropFirst()
        afterKey = trimLeading(afterKey)
        let (value, isLiteral, _) = try readValue(afterKey, lineNumber: lineNumber)
        return RawAssignment(key: key, value: value, expandsVariables: !isLiteral, line: lineNumber)
    }

    // MARK: - Helpers

    static func trimLeading(_ s: Substring) -> Substring {
        var i = s.startIndex
        while i < s.endIndex && (s[i] == " " || s[i] == "\t") {
            i = s.index(after: i)
        }
        return s[i..<s.endIndex]
    }

    static func trimTrailing(_ s: Substring) -> Substring {
        var i = s.endIndex
        while i > s.startIndex {
            let prev = s.index(before: i)
            if s[prev] == " " || s[prev] == "\t" {
                i = prev
            } else {
                break
            }
        }
        return s[s.startIndex..<i]
    }

    /// Read an identifier matching `[A-Za-z_][A-Za-z0-9_]*` from the start of `s`.
    static func readIdentifier(_ s: Substring) -> (String, Substring)? {
        guard let first = s.unicodeScalars.first, isIdentifierStart(first) else {
            return nil
        }
        var i = s.unicodeScalars.index(after: s.unicodeScalars.startIndex)
        while i < s.unicodeScalars.endIndex {
            if isIdentifierContinue(s.unicodeScalars[i]) {
                i = s.unicodeScalars.index(after: i)
            } else {
                break
            }
        }
        let nameView = s.unicodeScalars[s.unicodeScalars.startIndex..<i]
        let name = String(String.UnicodeScalarView(nameView))
        let rest = Substring(s.unicodeScalars[i..<s.unicodeScalars.endIndex])
        return (name, rest)
    }

    static func isIdentifierStart(_ c: Unicode.Scalar) -> Bool {
        switch c.value {
        case 0x41...0x5A: return true
        case 0x61...0x7A: return true
        case 0x5F: return true
        default: return false
        }
    }

    static func isIdentifierContinue(_ c: Unicode.Scalar) -> Bool {
        if isIdentifierStart(c) { return true }
        return c.value >= 0x30 && c.value <= 0x39
    }

    /// Read the value portion (everything after `=`).
    /// In Task 7 only the unquoted branch is implemented; quoting + inline
    /// comments arrive in Tasks 8 and 10.
    static func readValue(_ s: Substring, lineNumber: Int) throws(DotEnvError) -> (value: String, isLiteral: Bool, expands: Bool) {
        let trimmed = trimTrailing(s)
        return (String(trimmed), false, true)
    }
}
