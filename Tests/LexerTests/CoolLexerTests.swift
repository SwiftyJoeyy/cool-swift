//
//  CoolLexerTests.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Diagnostics
@testable import Lexer

@Suite struct CoolLexerTests {
// MARK: - Init tests
    @Test func `lexer can be initialized with string`() {
        let lexer = CoolLexer("test", file: "")
        #expect(lexer.reachedEnd == false)
    }
    
    @Test func `lexer reachedEnd is true for empty string`() {
        let lexer = CoolLexer("", file: "")
        #expect(lexer.reachedEnd == true)
    }
    
// MARK: - White space tests
    @Test func `lexer skips whitespace before tokens`() throws {
        var lexer = CoolLexer("   \"hello\"", file: "")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips tabs before tokens`() throws {
        var lexer = CoolLexer("\t\t\"hello\"", file: "")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips newlines before tokens`() throws {
        var lexer = CoolLexer("\n\n\"hello\"", file: "")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
// MARK: - Comments tests
    @Test func `lexer skips single-line comments`() throws {
        var lexer = CoolLexer("-- this is a comment\n\"hello\"", file: "")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips multi-line comments`() throws {
        var lexer = CoolLexer("(* this is a\nmulti-line comment *)\n\"hello\"", file: "")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips nested multi-line comments`() throws {
        var lexer = CoolLexer("(* outer (* inner *) outer *)\n\"hello\"", file: "")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer throws on unterminated multi-line comment`() throws {
        var lexer = CoolLexer("(* unterminated comment", file: "")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try lexer.next()
        }
        #expect(diag.id == Diagnostic(LexerError.unterminatedComment).id)
    }
    
// MARK: - End of file tests
    @Test func `lexer returns endOfFile token when at end`() throws {
        var lexer = CoolLexer("   ", file: "")
        let token = try lexer.next()
        #expect(token.kind == .endOfFile)
    }
    
// MARK: - Lexing tests
    @Test func `lexer correctly lexes string literals`() throws {
        var lexer = CoolLexer("\"test\"", file: "")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("test"))
    }
    
    @Test func `lexer correctly lexes integer literals`() throws {
        var lexer = CoolLexer("42", file: "")
        let token = try lexer.next()
        #expect(token.kind == .integerLiteral("42"))
    }
    
    @Test func `lexer returns unknown token for unrecognized characters`() throws {
        var lexer = CoolLexer("?", file: "")
        let token = try lexer.next()
        #expect(token.kind == .unknown("?"))
    }
    
    @Test func `lexer can lex multiple tokens in sequence`() throws {
        var lexer = CoolLexer("123 \"hello\"", file: "")
        let token1 = try lexer.next()
        #expect(token1.kind == .integerLiteral("123"))
        let token2 = try lexer.next()
        #expect(token2.kind == .stringLiteral("hello"))
    }
}
