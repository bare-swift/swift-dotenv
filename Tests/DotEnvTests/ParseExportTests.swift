// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv.parse — export prefix")
struct ParseExportTests {
    @Test("`export KEY=value` is parsed as KEY=value")
    func basicExport() throws {
        let entries = try DotEnv.parse("export FOO=bar")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar", line: 1)])
    }

    @Test("`export` followed by tab")
    func exportTab() throws {
        let entries = try DotEnv.parse("export\tFOO=bar")
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "bar", line: 1)])
    }

    @Test("`export` with quoted value")
    func exportQuoted() throws {
        let entries = try DotEnv.parse(#"export FOO="hello world""#)
        #expect(entries == [DotEnv.Entry(key: "FOO", value: "hello world", line: 1)])
    }

    @Test("`export` mixed with unprefixed lines")
    func exportMixed() throws {
        let entries = try DotEnv.parse("""
        export FOO=one
        BAR=two
        export BAZ=three
        """)
        #expect(entries == [
            DotEnv.Entry(key: "FOO", value: "one",   line: 1),
            DotEnv.Entry(key: "BAR", value: "two",   line: 2),
            DotEnv.Entry(key: "BAZ", value: "three", line: 3),
        ])
    }

    @Test("a key literally named `export` (no trailing space) is still a valid identifier")
    func exportAsKey() throws {
        let entries = try DotEnv.parse("export=value")
        #expect(entries == [DotEnv.Entry(key: "export", value: "value", line: 1)])
    }
}
