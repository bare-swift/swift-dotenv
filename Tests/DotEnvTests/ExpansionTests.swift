// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv.parse — variable expansion")
struct ExpansionTests {
    @Test("${VAR} resolves from earlier entries in the same source")
    func bracedFromEarlier() throws {
        let entries = try DotEnv.parse("""
        FOO=bar
        BAZ=${FOO}-suffix
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "bar",        line: 1),
            DotEnv.Entry(key: "BAZ", value: "bar-suffix", line: 2),
        ])
    }

    @Test("$VAR (unbraced) resolves longest valid identifier")
    func unbraced() throws {
        let entries = try DotEnv.parse("""
        FOO=bar
        BAZ=$FOO!
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "bar",  line: 1),
            DotEnv.Entry(key: "BAZ", value: "bar!", line: 2),
        ])
    }

    @Test("undefined variable expands to empty")
    func undefinedEmpty() throws {
        let entries = try DotEnv.parse("FOO=${MISSING}x")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "x", line: 1)])
    }

    @Test("forward references do NOT resolve")
    func forwardRef() throws {
        let entries = try DotEnv.parse("""
        FOO=${BAR}
        BAR=set
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "",    line: 1),
            DotEnv.Entry(key: "BAR", value: "set", line: 2),
        ])
    }

    @Test("baseEnvironment is consulted after same-file entries")
    func baseEnv() throws {
        let entries = try DotEnv.parse(
            "GREETING=hello $WHO",
            baseEnvironment: ["WHO": "world"]
        )
        #expect(entries == [DotEnv.Entry(key: "GREETING", value: "hello world", line: 1)])
    }

    @Test("same-file entry shadows baseEnvironment")
    func shadowing() throws {
        let entries = try DotEnv.parse("""
        WHO=local
        GREETING=hello $WHO
        """, baseEnvironment: ["WHO": "global"])
        #expect(entries == [
            DotEnv.Entry(key: "WHO",      value: "local",        line: 1),
            DotEnv.Entry(key: "GREETING", value: "hello local",  line: 2),
        ])
    }

    @Test("double-quoted values expand")
    func doubleQuotedExpands() throws {
        let entries = try DotEnv.parse("""
        FOO=bar
        BAZ="prefix ${FOO} suffix"
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "bar",                     line: 1),
            DotEnv.Entry(key: "BAZ", value: "prefix bar suffix",       line: 2),
        ])
    }

    @Test("single-quoted values do NOT expand (literal)")
    func singleQuotedLiteral() throws {
        let entries = try DotEnv.parse("""
        FOO=bar
        BAZ='prefix ${FOO} suffix'
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "bar",                       line: 1),
            DotEnv.Entry(key: "BAZ", value: "prefix ${FOO} suffix",      line: 2),
        ])
    }

    @Test("escaped \\$VAR inside double-quoted is literal $")
    func escapedDollar() throws {
        let entries = try DotEnv.parse(#"FOO="\$NOT_EXPANDED""#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "$NOT_EXPANDED", line: 1)])
    }

    @Test("'$' alone (no identifier follows) is literal")
    func loneDollar() throws {
        let entries = try DotEnv.parse("FOO=cost is $ today")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "cost is $ today", line: 1)])
    }

    @Test("'${' without closing '}' throws .unterminatedExpansion")
    func unterminatedBraced() {
        #expect(throws: DotEnvError.unterminatedExpansion(line: 1)) {
            try DotEnv.parse("FOO=${BAR")
        }
    }
}
