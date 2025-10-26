import Testing
import Diagnostics
@testable import Lexing

@Suite struct StringLiteralLexerTests {
// MARK: - Matching tests
    @Test func `matches returns true for quote`() {
        #expect(StringLiteralLexer.matches(UInt8(ascii: "\"")))
    }
    
    @Test func `matches returns false for non-quote`() {
        #expect(!StringLiteralLexer.matches(UInt8(ascii: "a")))
    }
    
// MARK: - Parsing tests
    @Test func `lex parses simple string literal`() throws {
        var cursor = Cursor("\"hello\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lex parses empty string literal`() throws {
        var cursor = Cursor("\"\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral(""))
    }
    
    @Test func `lex parses string with escaped newline`() throws {
        var cursor = Cursor("\"hello\\nworld\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral("hello\nworld"))
    }
    
    @Test func `lex parses string with escaped tab`() throws {
        var cursor = Cursor("\"hello\\tworld\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral("hello\tworld"))
    }
    
    @Test func `lex parses string with escaped backspace`() throws {
        var cursor = Cursor("\"hello\\bworld\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral("hello\u{08}world"))
    }
    
    @Test func `lex parses string with escaped formfeed`() throws {
        var cursor = Cursor("\"hello\\fworld\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral("hello\u{0C}world"))
    }
    
    @Test func `lex parses string with escaped quote`() throws {
        var cursor = Cursor("\"hello\\\"world\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral("hello\"world"))
    }
    
    @Test func `lex parses string with escaped backslash`() throws {
        var cursor = Cursor("\"hello\\\\world\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral("hello\\world"))
    }
    
    @Test func `lex parses string with escaped newline in source`() throws {
        var cursor = Cursor("\"\\\n\"")
        let token = try StringLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .stringLiteral(""))
    }
    
// MARK: - Error tests
    @Test func `lex throws on unescaped newline`() throws {
        var cursor = Cursor("\"hello\nworld\"")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try StringLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.unescapedNewline).id)
    }
    
    @Test func `lex throws on missing end quote`() throws {
        var cursor = Cursor("\"hello")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try StringLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.missingEndQuote).id)
    }
    
    @Test func `lex throws on missing end quote after backslash`() throws {
        var cursor = Cursor("\"hello \\")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try StringLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.missingEndQuote).id)
    }
    
    @Test func `lex throws on null character in string`() throws {
        var cursor = Cursor("\"hello\0world\"")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try StringLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.stringContainsNull).id)
    }
    
    @Test func `lex throws on string exceeding 1024 characters`() throws {
        let longString = "\"" + String(repeating: "a", count: 1025) + "\""
        var cursor = Cursor(longString)
        let diag = try #require(throws: Diagnostic.self) {
            _ = try StringLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.stringTooLong).id)
    }
}
