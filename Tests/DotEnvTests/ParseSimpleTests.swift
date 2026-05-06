// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv.parse — simple unquoted")
struct ParseSimpleTests {
    @Test("empty source → no entries")
    func emptySource() throws {
        #expect(try DotEnv.parse("").isEmpty)
    }

    @Test("only whitespace and comments → no entries")
    func onlyWhitespaceAndComments() throws {
        let entries = try DotEnv.parse("""
        # comment
            # indented comment

        """)
        #expect(entries.isEmpty)
    }

    @Test("KEY=value")
    func basic() throws {
        let entries = try DotEnv.parse("FOO=bar")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar", line: 1)])
    }

    @Test("KEY= (empty value)")
    func emptyValue() throws {
        let entries = try DotEnv.parse("FOO=")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "", line: 1)])
    }

    @Test("multiple lines tracked with 1-based line numbers")
    func multipleLines() throws {
        let entries = try DotEnv.parse("""
        FOO=one
        BAR=two
        BAZ=three
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "one",   line: 1),
            DotEnv.Entry(key: "BAR", value: "two",   line: 2),
            DotEnv.Entry(key: "BAZ", value: "three", line: 3),
        ])
    }

    @Test("blank lines and full-line comments increment the line counter")
    func blankLines() throws {
        let entries = try DotEnv.parse("""
        # header
        FOO=one

        # mid
        BAR=two
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "one", line: 2),
            DotEnv.Entry(key: "BAR", value: "two", line: 5),
        ])
    }

    @Test("leading whitespace before KEY is allowed")
    func leadingWhitespace() throws {
        let entries = try DotEnv.parse("   FOO=bar")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar", line: 1)])
    }

    @Test("whitespace around '=' is trimmed for unquoted values")
    func whitespaceAroundEquals() throws {
        let entries = try DotEnv.parse("FOO  =  bar  ")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar", line: 1)])
    }

    @Test("identifiers permit digits and underscores after the first char")
    func identifierDigitsUnderscores() throws {
        let entries = try DotEnv.parse("DB_HOST_2=x")
        #expect(entries == [DotEnv.Entry(key: "DB_HOST_2", value: "x", line: 1)])
    }
}
