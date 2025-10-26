import Testing
import Diagnostics
@testable import Lexing

@Suite struct IntegerLiteralLexerTests {
// MARK: - Matching tests
    @Test func `matches returns true for digits`() {
        #expect(IntegerLiteralLexer.matches(UInt8(ascii: "0")))
        #expect(IntegerLiteralLexer.matches(UInt8(ascii: "5")))
        #expect(IntegerLiteralLexer.matches(UInt8(ascii: "9")))
    }
    
    @Test func `matches returns false for non-digits`() {
        #expect(!IntegerLiteralLexer.matches(UInt8(ascii: "a")))
        #expect(!IntegerLiteralLexer.matches(UInt8(ascii: " ")))
    }
    
// MARK: - Parsing tests
    @Test func `lex parses single digit integer`() throws {
        var cursor = Cursor("5")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("5"))
    }
    
    @Test func `lex parses multiple digit integer`() throws {
        var cursor = Cursor("12345")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("12345"))
    }
    
    @Test func `lex parses integer followed by space`() throws {
        var cursor = Cursor("123 ")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("123"))
    }
    
    @Test func `lex parses integer followed by newline`() throws {
        var cursor = Cursor("123\n")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("123"))
    }
    
// MARK: - Error tests
    @Test func `lex throws on invalid characters in integer`() throws {
        var cursor = Cursor("123abc")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try IntegerLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.invalidInteger).id)
    }
}
