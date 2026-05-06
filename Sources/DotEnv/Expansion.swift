// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Internal `${VAR}` / `$VAR` substitution.
///
/// Pure function: callers pass the raw value plus a lookup closure. The
/// expansion order — same-file entries → base environment → empty — is
/// composed by the caller into the closure.
enum Expansion {
    /// Substitute variable references in `value`. Undefined references
    /// (`lookup` returns nil) expand to the empty string.
    static func expand(_ value: String, lineNumber: Int, lookup: (String) -> String?) throws(DotEnvError) -> String {
        var out = ""
        out.reserveCapacity(value.count)
        let scalars = Array(value.unicodeScalars)
        var i = 0
        while i < scalars.count {
            let c = scalars[i]
            // Internal sentinel: U+0001 marks the *next* scalar as literal,
            // bypassing expansion. Used by the double-quoted parser for `\$`.
            if c.value == 0x0001 {
                let next = i + 1
                if next < scalars.count {
                    out.unicodeScalars.append(scalars[next])
                    i = next + 1
                } else {
                    i = next
                }
                continue
            }
            if c != "$" {
                out.unicodeScalars.append(c)
                i += 1
                continue
            }
            // '$' seen.
            let next = i + 1
            if next >= scalars.count {
                out.append("$")
                i = next
                continue
            }
            if scalars[next] == "{" {
                // ${VAR}
                var j = next + 1
                var name = ""
                while j < scalars.count && scalars[j] != "}" {
                    name.unicodeScalars.append(scalars[j])
                    j += 1
                }
                if j >= scalars.count {
                    throw .unterminatedExpansion(line: lineNumber)
                }
                out.append(lookup(name) ?? "")
                i = j + 1
                continue
            }
            if Parser.isIdentifierStart(scalars[next]) {
                // $VAR — longest valid identifier.
                var j = next + 1
                while j < scalars.count && Parser.isIdentifierContinue(scalars[j]) {
                    j += 1
                }
                let nameView = scalars[next..<j]
                let name = String(String.UnicodeScalarView(nameView))
                out.append(lookup(name) ?? "")
                i = j
                continue
            }
            // '$' followed by something that isn't '{' or an identifier start: literal.
            out.append("$")
            i = next
        }
        return out
    }
}
