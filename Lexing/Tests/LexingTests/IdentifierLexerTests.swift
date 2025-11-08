//
//  IdentifierLexerTests.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Diagnostics
@testable import Lexing

@Suite struct IdentifierLexerTests {
// MARK: - Matching tests
    @Test func `matches returns true for letters`() {
        #expect(IdentifierLexer.matches(UInt8(ascii: "a")))
        #expect(IdentifierLexer.matches(UInt8(ascii: "z")))
        #expect(IdentifierLexer.matches(UInt8(ascii: "A")))
        #expect(IdentifierLexer.matches(UInt8(ascii: "Z")))
        #expect(IdentifierLexer.matches(UInt8(ascii: "m")))
    }
    
    @Test func `matches returns false for non-letters`() {
        #expect(!IdentifierLexer.matches(UInt8(ascii: "0")))
        #expect(!IdentifierLexer.matches(UInt8(ascii: "_")))
        #expect(!IdentifierLexer.matches(UInt8(ascii: "+")))
        #expect(!IdentifierLexer.matches(UInt8(ascii: " ")))
        #expect(!IdentifierLexer.matches(UInt8(ascii: "@")))
    }
    
// MARK: - Simple identifier tests
    @Test func `lex parses single letter identifier`() throws {
        var cursor = Cursor("x")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("x"))
    }
    
    @Test func `lex parses lowercase identifier`() throws {
        var cursor = Cursor("count")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("count"))
    }
    
    @Test func `lex parses uppercase identifier`() throws {
        var cursor = Cursor("String")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("String"))
    }
    
    @Test func `lex parses identifier with numbers`() throws {
        var cursor = Cursor("var123")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("var123"))
    }
    
    @Test func `lex parses identifier with underscores`() throws {
        var cursor = Cursor("my_var")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("my_var"))
    }
    
    @Test func `lex parses identifier with multiple underscores`() throws {
        var cursor = Cursor("__private__")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("__private__"))
    }
    
    @Test func `lex parses identifier with mixed case`() throws {
        var cursor = Cursor("myVariable")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("myVariable"))
    }
    
// MARK: - Keyword tests
    @Test func `lex parses class keyword`() throws {
        var cursor = Cursor("class")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.class))
    }
    
    @Test func `lex parses if keyword`() throws {
        var cursor = Cursor("if")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.if))
    }
    
    @Test func `lex parses while keyword`() throws {
        var cursor = Cursor("while")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.while))
    }
    
    @Test func `lex parses let keyword`() throws {
        var cursor = Cursor("let")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.let))
    }
    
    @Test func `lex parses inherits keyword`() throws {
        var cursor = Cursor("inherits")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.inherits))
    }
    
    @Test func `lex parses isvoid keyword`() throws {
        var cursor = Cursor("isvoid")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.isvoid))
    }
    
    @Test func `lex parses new keyword`() throws {
        var cursor = Cursor("new")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.new))
    }
    
// MARK: - Case insensitive keyword tests
    @Test func `lex parses uppercase class keyword`() throws {
        var cursor = Cursor("CLASS")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.class))
    }
    
    @Test func `lex parses mixed case while keyword`() throws {
        var cursor = Cursor("While")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.while))
    }
    
    @Test func `lex parses mixed case IF keyword`() throws {
        var cursor = Cursor("If")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.if))
    }
    
// MARK: - Boolean keyword tests
    @Test func `lex parses true keyword`() throws {
        var cursor = Cursor("true")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.true))
    }
    
    @Test func `lex parses false keyword`() throws {
        var cursor = Cursor("false")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .keyword(.false))
    }
    
    @Test func `lex parses True as identifier not keyword`() throws {
        var cursor = Cursor("True")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("True"))
    }
    
    @Test func `lex parses FALSE as identifier not keyword`() throws {
        var cursor = Cursor("FALSE")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("FALSE"))
    }
    
    @Test func `lex parses tRue as identifier not keyword`() throws {
        var cursor = Cursor("tRue")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("tRue"))
    }
    
// MARK: - Identifier followed by operators
    @Test func `lex parses identifier followed by plus`() throws {
        var cursor = Cursor("x+")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("x"))
    }
    
    @Test func `lex parses identifier followed by minus`() throws {
        var cursor = Cursor("count-")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("count"))
    }
    
    @Test func `lex parses identifier followed by less than`() throws {
        var cursor = Cursor("x<")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("x"))
    }
    
    @Test func `lex parses identifier followed by equal`() throws {
        var cursor = Cursor("var=")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("var"))
    }
    
// MARK: - Identifier followed by punctuation
    @Test func `lex parses identifier followed by dot`() throws {
        var cursor = Cursor("obj.")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("obj"))
    }
    
    @Test func `lex parses identifier followed by left paren`() throws {
        var cursor = Cursor("method(")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("method"))
    }
    
    @Test func `lex parses identifier followed by colon`() throws {
        var cursor = Cursor("x:")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("x"))
    }
    
    @Test func `lex parses identifier followed by semicolon`() throws {
        var cursor = Cursor("var;")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("var"))
    }
    
    @Test func `lex parses identifier followed by comma`() throws {
        var cursor = Cursor("arg,")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("arg"))
    }
    
// MARK: - Identifier followed by whitespace
    @Test func `lex parses identifier followed by space`() throws {
        var cursor = Cursor("name ")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("name"))
    }
    
    @Test func `lex parses identifier followed by newline`() throws {
        var cursor = Cursor("value\n")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("value"))
    }
    
    @Test func `lex parses identifier followed by tab`() throws {
        var cursor = Cursor("data\t")
        let token = try IdentifierLexer.lex(for: &cursor)
        #expect(token.kind == .identifier("data"))
    }
    
// MARK: - Error tests
    @Test func `lex throws on identifier with dollar sign`() throws {
        var cursor = Cursor("var$name")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try IdentifierLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.invalidIdentifier).id)
    }
    
    @Test func `lex throws on identifier with hash`() throws {
        var cursor = Cursor("name#value")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try IdentifierLexer.lex(for: &cursor)
        }
        #expect(diag.id == Diagnostic(.invalidIdentifier).id)
    }
}
