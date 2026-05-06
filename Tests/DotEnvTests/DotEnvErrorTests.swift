// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnvError")
struct DotEnvErrorTests {
    @Test("DotEnvError is Sendable, Equatable, Error")
    func conformances() {
        let a: DotEnvError = .missingEquals(line: 1)
        let b: DotEnvError = .missingEquals(line: 1)
        let c: DotEnvError = .missingEquals(line: 2)
        let d: DotEnvError = .invalidIdentifier(line: 1)
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
        let _: any Error = a
        let _: any Sendable = a
    }

    @Test("All five cases are distinguishable")
    func cases() {
        let xs: [DotEnvError] = [
            .missingEquals(line: 1),
            .invalidIdentifier(line: 1),
            .unterminatedQuote(line: 1),
            .invalidEscape(line: 1),
            .unterminatedExpansion(line: 1),
        ]
        for i in 0..<xs.count {
            for j in 0..<xs.count where i != j {
                #expect(xs[i] != xs[j])
            }
        }
    }
}
