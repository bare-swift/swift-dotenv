// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv round-trip")
struct DotEnvRoundTripTests {
    @Test("alphanumeric KEY=value pairs round-trip across many samples")
    func alphanumericRoundTrip() throws {
        var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
        for _ in 0..<200 {
            seed ^= seed << 13
            seed ^= seed >> 7
            seed ^= seed << 17
            let key = "K_" + String(seed % 0xFFFF_FFFF, radix: 16)
            let valLen = Int(seed % 16)
            var val = ""
            var local = seed
            for _ in 0..<valLen {
                local ^= local << 7
                local ^= local >> 9
                let alphabet = Array("abcdefghijklmnopqrstuvwxyz0123456789".unicodeScalars)
                val.unicodeScalars.append(alphabet[Int(local % UInt64(alphabet.count))])
            }
            let source = "\(key)=\(val)"
            let entries = try DotEnv.parse(source)
            #expect(entries == [DotEnv.Entry(key: key, value: val, line: 1)],
                    "key=\(key) val=\(val.debugDescription)")
        }
    }

    @Test("multi-pair source preserves order and tracks lines")
    func multiPair() throws {
        let source = """
        A=1
        B=2
        C=3
        D=4
        E=5
        """
        let entries = try DotEnv.parse(source)
        #expect(entries.count == 5)
        for (i, e) in entries.enumerated() {
            #expect(e.line == i + 1)
            #expect(e.value == String(i + 1))
        }
    }

    @Test("dictionary helper round-trips the last-wins semantics")
    func dictionaryRoundTrip() throws {
        let source = """
        K=first
        K=second
        K=third
        """
        let entries = try DotEnv.parse(source)
        #expect(entries.count == 3)
        #expect(entries.dictionary == ["K": "third"])
    }

    @Test("expansion + multi-line: a complex realistic .env round-trips correctly")
    func realistic() throws {
        let source = """
        # twelve-factor app
        APP_NAME=myapp
        DATABASE_URL=postgres://localhost/${APP_NAME}
        PORT=8080
        DEBUG="${APP_NAME} on :${PORT}"
        """
        let entries = try DotEnv.parse(source)
        #expect(entries == [
            DotEnv.Entry(key: "APP_NAME",     value: "myapp",                       line: 2),
            DotEnv.Entry(key: "DATABASE_URL", value: "postgres://localhost/myapp",  line: 3),
            DotEnv.Entry(key: "PORT",         value: "8080",                        line: 4),
            DotEnv.Entry(key: "DEBUG",        value: "myapp on :8080",              line: 5),
        ])
    }
}
