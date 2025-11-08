//
//  PunctuationLexerTests.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Diagnostics
@testable import Lexing

@Suite struct PunctuationLexerTests {
// MARK: - Matching tests
    @Test func `matches returns true for punctuation characters`() {
        #expect(PunctuationLexer.matches(UInt8(ascii: "@")))
        #expect(PunctuationLexer.matches(UInt8(ascii: ":")))
        #expect(PunctuationLexer.matches(UInt8(ascii: ",")))
        #expect(PunctuationLexer.matches(UInt8(ascii: ".")))
        #expect(PunctuationLexer.matches(UInt8(ascii: "{")))
        #expect(PunctuationLexer.matches(UInt8(ascii: "(")))
        #expect(PunctuationLexer.matches(UInt8(ascii: "}")))
        #expect(PunctuationLexer.matches(UInt8(ascii: ")")))
        #expect(PunctuationLexer.matches(UInt8(ascii: ";")))
    }
    
    @Test func `matches returns false for non-punctuation characters`() {
        #expect(!PunctuationLexer.matches(UInt8(ascii: "a")))
        #expect(!PunctuationLexer.matches(UInt8(ascii: "+")))
        #expect(!PunctuationLexer.matches(UInt8(ascii: "=")))
        #expect(!PunctuationLexer.matches(UInt8(ascii: " ")))
        #expect(!PunctuationLexer.matches(UInt8(ascii: "0")))
    }
    
// MARK: - Single character punctuation tests
    @Test func `lex parses at symbol`() throws {
        var cursor = Cursor("@")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .at)
    }
    
    @Test func `lex parses colon`() throws {
        var cursor = Cursor(":")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .colon)
    }
    
    @Test func `lex parses comma`() throws {
        var cursor = Cursor(",")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .comma)
    }
    
    @Test func `lex parses dot`() throws {
        var cursor = Cursor(".")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .dot)
    }
    
    @Test func `lex parses left brace`() throws {
        var cursor = Cursor("{")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .leftBrace)
    }
    
    @Test func `lex parses left paren`() throws {
        var cursor = Cursor("(")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .leftParen)
    }
    
    @Test func `lex parses right brace`() throws {
        var cursor = Cursor("}")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .rightBrace)
    }
    
    @Test func `lex parses right paren`() throws {
        var cursor = Cursor(")")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .rightParen)
    }
    
    @Test func `lex parses semicolon`() throws {
        var cursor = Cursor(";")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .semicolon)
    }
    
// MARK: - Punctuation followed by other characters
    @Test func `lex parses at followed by identifier`() throws {
        var cursor = Cursor("@Object")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .at)
        cursor.advance()
        #expect(cursor.peek() == "O")
    }
    
    @Test func `lex parses colon followed by type`() throws {
        var cursor = Cursor(": Int")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .colon)
        cursor.advance()
        #expect(cursor.peek() == .space)
    }
    
    @Test func `lex parses comma followed by space`() throws {
        var cursor = Cursor(", ")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .comma)
        cursor.advance()
        #expect(cursor.peek() == .space)
    }
    
    @Test func `lex parses dot followed by identifier`() throws {
        var cursor = Cursor(".method")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .dot)
        cursor.advance()
        #expect(cursor.peek() == "m")
    }
    
    @Test func `lex parses semicolon followed by newline`() throws {
        var cursor = Cursor(";\n")
        let token = try PunctuationLexer.lex(for: &cursor)
        #expect(token.kind == .semicolon)
        cursor.advance()
        #expect(cursor.peek() == .newline)
    }
    
// MARK: - Punctuation sequences
    @Test func `lex parses left paren followed by right paren`() throws {
        var cursor = Cursor("()")
        let token1 = try PunctuationLexer.lex(for: &cursor)
        #expect(token1.kind == .leftParen)
        cursor.advance()
        let token2 = try PunctuationLexer.lex(for: &cursor)
        #expect(token2.kind == .rightParen)
    }
    
    @Test func `lex parses left brace followed by right brace`() throws {
        var cursor = Cursor("{}")
        let token1 = try PunctuationLexer.lex(for: &cursor)
        #expect(token1.kind == .leftBrace)
        cursor.advance()
        let token2 = try PunctuationLexer.lex(for: &cursor)
        #expect(token2.kind == .rightBrace)
    }
    
    @Test func `lex parses method call punctuation`() throws {
        var cursor = Cursor(".foo()")
        let token1 = try PunctuationLexer.lex(for: &cursor)
        #expect(token1.kind == .dot)
    }
}
