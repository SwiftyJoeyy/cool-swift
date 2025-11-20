//
//  OperatorLexerTests.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Diagnostics
@testable import Lexer

@Suite struct OperatorLexerTests {
// MARK: - Matching tests
    @Test func `matches returns true for operator characters`() {
        #expect(OperatorLexer.matches(UInt8(ascii: "=")))
        #expect(OperatorLexer.matches(UInt8(ascii: "<")))
        #expect(OperatorLexer.matches(UInt8(ascii: "+")))
        #expect(OperatorLexer.matches(UInt8(ascii: "-")))
        #expect(OperatorLexer.matches(UInt8(ascii: "*")))
        #expect(OperatorLexer.matches(UInt8(ascii: "/")))
        #expect(OperatorLexer.matches(UInt8(ascii: "~")))
    }
    
    @Test func `matches returns false for non-operator characters`() {
        #expect(!OperatorLexer.matches(UInt8(ascii: "a")))
        #expect(!OperatorLexer.matches(UInt8(ascii: "@")))
        #expect(!OperatorLexer.matches(UInt8(ascii: ">")))
        #expect(!OperatorLexer.matches(UInt8(ascii: "(")))
        #expect(!OperatorLexer.matches(UInt8(ascii: " ")))
    }
    
// MARK: - Single-character operator tests
    @Test func `lex parses plus operator`() throws {
        var cursor = Cursor("+")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .plus)
    }
    
    @Test func `lex parses minus operator`() throws {
        var cursor = Cursor("-")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .minus)
    }
    
    @Test func `lex parses star operator`() throws {
        var cursor = Cursor("*")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .star)
    }
    
    @Test func `lex parses slash operator`() throws {
        var cursor = Cursor("/")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .slash)
    }
    
    @Test func `lex parses tilde operator`() throws {
        var cursor = Cursor("~")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .tilde)
    }
    
    @Test func `lex parses equal when not followed by arrow`() throws {
        var cursor = Cursor("=")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .equal)
    }
    
    @Test func `lex parses equal when followed by space`() throws {
        var cursor = Cursor("= ")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .equal)
    }
    
    @Test func `lex parses lessThan when not followed by dash or equal`() throws {
        var cursor = Cursor("<")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .lessThan)
    }
    
    @Test func `lex parses lessThan when followed by space`() throws {
        var cursor = Cursor("< ")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .lessThan)
    }
    
// MARK: - Two-character operator tests
    @Test func `lex parses arrow operator`() throws {
        var cursor = Cursor("=>")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .arrow)
    }
    
    @Test func `lex parses arrow operator followed by space`() throws {
        var cursor = Cursor("=> ")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .arrow)
    }
    
    @Test func `lex parses assign operator`() throws {
        var cursor = Cursor("<-")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .assign)
    }
    
    @Test func `lex parses assign operator followed by space`() throws {
        var cursor = Cursor("<- ")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .assign)
    }
    
    @Test func `lex parses lessThanOrEqual operator`() throws {
        var cursor = Cursor("<=")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .lessThanOrEqual)
    }
    
    @Test func `lex parses lessThanOrEqual operator followed by space`() throws {
        var cursor = Cursor("<= ")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .lessThanOrEqual)
    }
    
// MARK: - Operator sequence tests
    @Test func `lex parses plus followed by minus`() throws {
        var cursor = Cursor("+-")
        let token1 = try OperatorLexer.lex(for: &cursor)
        #expect(token1.kind == .plus)
        cursor.advance()
        let token2 = try OperatorLexer.lex(for: &cursor)
        #expect(token2.kind == .minus)
    }
    
    @Test func `lex parses operators in expression`() throws {
        var cursor = Cursor("*5")
        let token = try OperatorLexer.lex(for: &cursor)
        #expect(token.kind == .star)
        cursor.advance()
        #expect(cursor.peek() == "5")
    }
}
