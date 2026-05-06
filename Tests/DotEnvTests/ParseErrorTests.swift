// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import DotEnv

@Suite("DotEnv.parse — error paths")
struct ParseErrorTests {
    @Test("a non-blank, non-comment line without '=' throws .missingEquals")
    func missingEquals() {
        #expect(throws: DotEnvError.missingEquals(line: 1)) {
            try DotEnv.parse("KEY value")
        }
    }

    @Test("identifier starting with a digit throws .invalidIdentifier")
    func invalidIdentifierLeadingDigit() {
        #expect(throws: DotEnvError.invalidIdentifier(line: 1)) {
            try DotEnv.parse("1KEY=val")
        }
    }

    @Test("punctuation between key and '=' triggers .missingEquals (KEY parses, then '-' is unexpected)")
    func keyPunctuationMissingEquals() {
        #expect(throws: DotEnvError.missingEquals(line: 1)) {
            try DotEnv.parse("KEY-NAME=val")
        }
    }

    @Test("a leading non-identifier character (no valid identifier at all) throws .invalidIdentifier")
    func invalidIdentifierNoIdentAtAll() {
        #expect(throws: DotEnvError.invalidIdentifier(line: 1)) {
            try DotEnv.parse("=value")     // no identifier before '='
        }
        #expect(throws: DotEnvError.invalidIdentifier(line: 1)) {
            try DotEnv.parse("-=value")    // starts with '-', not identifier
        }
    }

    @Test("unclosed double quote throws .unterminatedQuote")
    func unterminatedDoubleQuote() {
        #expect(throws: DotEnvError.unterminatedQuote(line: 1)) {
            try DotEnv.parse("KEY=\"unclosed")
        }
    }

    @Test("unclosed single quote throws .unterminatedQuote")
    func unterminatedSingleQuote() {
        #expect(throws: DotEnvError.unterminatedQuote(line: 1)) {
            try DotEnv.parse("KEY='unclosed")
        }
    }

    @Test("unsupported backslash escape throws .invalidEscape")
    func invalidEscape() {
        #expect(throws: DotEnvError.invalidEscape(line: 1)) {
            try DotEnv.parse(#"KEY="bad\zescape""#)
        }
    }

    @Test("'${VAR' without closing brace throws .unterminatedExpansion")
    func unterminatedExpansion() {
        #expect(throws: DotEnvError.unterminatedExpansion(line: 1)) {
            try DotEnv.parse("KEY=${UNCLOSED")
        }
    }

    @Test("error line numbers reflect the offending statement, not the file start")
    func errorLineNumber() {
        do {
            _ = try DotEnv.parse("""
            FOO=ok

            BAR="unclosed
            """)
            Issue.record("expected throw")
        } catch let e as DotEnvError {
            #expect(e == .unterminatedQuote(line: 3))
        } catch {
            Issue.record("wrong error type: \(error)")
        }
    }
}
