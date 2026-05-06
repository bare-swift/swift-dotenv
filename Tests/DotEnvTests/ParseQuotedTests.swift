// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv.parse — quoted values")
struct ParseQuotedTests {
    @Test("double-quoted simple value")
    func doubleSimple() throws {
        let entries = try DotEnv.parse(#"FOO="hello world""#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "hello world", line: 1)])
    }

    @Test("single-quoted simple value")
    func singleSimple() throws {
        let entries = try DotEnv.parse(#"FOO='hello world'"#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "hello world", line: 1)])
    }

    @Test("single-quoted is literal: $VAR is NOT a variable reference")
    func singleLiteral() throws {
        let entries = try DotEnv.parse(#"FOO='no $VAR expansion'"#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "no $VAR expansion", line: 1)])
    }

    @Test("double-quoted backslash escapes: \\n \\r \\t \\\\ \\\" \\' \\$")
    func doubleEscapes() throws {
        let entries = try DotEnv.parse(#"FOO="a\nb\rc\td\\e\"f\'g\$h""#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "a\nb\rc\td\\e\"f'g$h", line: 1)])
    }

    @Test("double-quoted may contain literal newlines (multi-physical-line)")
    func doubleMultiLine() throws {
        let entries = try DotEnv.parse("FOO=\"line1\nline2\"")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "line1\nline2", line: 1)])
    }

    @Test("single-quoted may contain literal newlines")
    func singleMultiLine() throws {
        let entries = try DotEnv.parse("FOO='line1\nline2'")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "line1\nline2", line: 1)])
    }

    @Test("empty quoted value")
    func emptyQuoted() throws {
        #expect(try DotEnv.parse(#"FOO="""#) == [DotEnv.Entry(key: "FOO", value: "", line: 1)])
        #expect(try DotEnv.parse(#"FOO=''"#) == [DotEnv.Entry(key: "FOO", value: "", line: 1)])
    }

    @Test("quoted value followed by another assignment on next line")
    func quotedThenAnother() throws {
        let entries = try DotEnv.parse("""
        FOO="hello"
        BAR=world
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "hello", line: 1),
            DotEnv.Entry(key: "BAR", value: "world", line: 2),
        ])
    }

    @Test("multi-line quoted value advances the next entry's line number")
    func multiLineThenAnother() throws {
        let entries = try DotEnv.parse("""
        FOO="line1
        line2
        line3"
        BAR=baz
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "line1\nline2\nline3", line: 1),
            DotEnv.Entry(key: "BAR", value: "baz",                  line: 4),
        ])
    }
}
