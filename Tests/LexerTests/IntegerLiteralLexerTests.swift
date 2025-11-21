//
//  IntegerLiteralLexerTests.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Diagnostics
@testable import Lexer

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
    
// MARK: - Integer followed by operators
    @Test func `lex parses integer followed by plus`() throws {
        var cursor = Cursor("123+")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("123"))
    }
    
    @Test func `lex parses integer followed by minus`() throws {
        var cursor = Cursor("456-")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("456"))
    }
    
    @Test func `lex parses integer followed by star`() throws {
        var cursor = Cursor("789*")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("789"))
    }
    
    @Test func `lex parses integer followed by slash`() throws {
        var cursor = Cursor("100/")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("100"))
    }
    
    @Test func `lex parses integer followed by less than`() throws {
        var cursor = Cursor("5<")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("5"))
    }
    
    @Test func `lex parses integer followed by equal`() throws {
        var cursor = Cursor("42=")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("42"))
    }
    
// MARK: - Integer followed by punctuation
    @Test func `lex parses integer followed by comma`() throws {
        var cursor = Cursor("1,")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("1"))
    }
    
    @Test func `lex parses integer followed by dot`() throws {
        var cursor = Cursor("1.")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("1"))
    }
    
    @Test func `lex parses integer followed by at`() throws {
        var cursor = Cursor("1@")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("1"))
    }
    
    @Test func `lex parses integer followed by right brace`() throws {
        var cursor = Cursor("1}")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("1"))
    }
    
    @Test func `lex parses integer followed by right paren`() throws {
        var cursor = Cursor("1)")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("1"))
    }
    
    @Test func `lex parses integer followed by semicolon`() throws {
        var cursor = Cursor("1;")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("1"))
    }
    
    @Test func `lex parses integer followed by colon`() throws {
        var cursor = Cursor("42:")
        let token = try IntegerLiteralLexer.lex(for: &cursor)
        #expect(token.kind == .integerLiteral("42"))
    }
    
// MARK: - Error tests
    @Test func `lex throws on invalid characters in integer`() throws {
        var cursor = Cursor("123abc")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try IntegerLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(LexerError.invalidInteger).id)
    }
    
    @Test func `lex throws on integer followed by underscore`() throws {
        var cursor = Cursor("123_")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try IntegerLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(LexerError.invalidInteger).id)
    }
    
    @Test func `lex throws on integer followed by letter`() throws {
        var cursor = Cursor("999x")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try IntegerLiteralLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(LexerError.invalidInteger).id)
    }
}
