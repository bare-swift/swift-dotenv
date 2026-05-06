// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv.Entry")
struct EntryTests {
    @Test("Entry stores key, value, line")
    func fields() {
        let e = DotEnv.Entry(key: "FOO", value: "bar", line: 7)
        #expect(e.key == "FOO")
        #expect(e.value == "bar")
        #expect(e.line == 7)
    }

    @Test("Entry is Equatable + Hashable + Sendable")
    func conformances() {
        let a = DotEnv.Entry(key: "A", value: "1", line: 1)
        let b = DotEnv.Entry(key: "A", value: "1", line: 1)
        let c = DotEnv.Entry(key: "A", value: "2", line: 1)
        let d = DotEnv.Entry(key: "A", value: "1", line: 2)
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
        var set: Set<DotEnv.Entry> = []
        set.insert(a)
        #expect(set.contains(b))
        let _: any Sendable = a
    }

    @Test(".dictionary flattens last-wins on duplicate keys")
    func dictionaryLastWins() {
        let entries: [DotEnv.Entry] = [
            DotEnv.Entry(key: "A", value: "first", line: 1),
            DotEnv.Entry(key: "B", value: "two", line: 2),
            DotEnv.Entry(key: "A", value: "second", line: 3),
        ]
        let dict = entries.dictionary
        #expect(dict.count == 2)
        #expect(dict["A"] == "second")
        #expect(dict["B"] == "two")
    }

    @Test("empty array → empty dictionary")
    func dictionaryEmpty() {
        let entries: [DotEnv.Entry] = []
        #expect(entries.dictionary.isEmpty)
    }
}
