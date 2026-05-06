// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv.parse — inline comments")
struct ParseInlineCommentTests {
    @Test("inline comment after unquoted value")
    func inlineUnquoted() throws {
        let entries = try DotEnv.parse("FOO=bar # trailing")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar", line: 1)])
    }

    @Test("inline comment requires whitespace before '#'")
    func inlineRequiresWhitespace() throws {
        let entries = try DotEnv.parse("FOO=bar#nope")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar#nope", line: 1)])
    }

    @Test("inline comment after quoted value (whitespace + '#') is dropped")
    func inlineAfterQuoted() throws {
        let entries = try DotEnv.parse(#"FOO="hello"  # trailing"#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "hello", line: 1)])
    }

    @Test("'#' inside double-quoted value is preserved")
    func hashInsideDoubleQuoted() throws {
        let entries = try DotEnv.parse(#"FOO="not # a comment""#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "not # a comment", line: 1)])
    }

    @Test("'#' inside single-quoted value is preserved")
    func hashInsideSingleQuoted() throws {
        let entries = try DotEnv.parse(#"FOO='also # not'"#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "also # not", line: 1)])
    }

    @Test("only whitespace between value and '#' counts as a comment delimiter")
    func multipleSpacesBeforeHash() throws {
        let entries = try DotEnv.parse("FOO=bar     # spaced")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar", line: 1)])
    }
}
