//
//  CoolLexer.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Diagnostics

internal protocol TokenLexer {
    static func matches(_ char: UInt8) -> Bool
    
    static func lex(for cursor: inout Cursor) throws(Diagnostic) -> Token
}

public struct CoolLexer {
    private let chain = Chain(
        StringLiteralLexer.self,
        IntegerLiteralLexer.self,
        OperatorLexer.self,
        PunctuationLexer.self,
        IdentifierLexer.self
    )
    private var cursor: Cursor
    
    public var reachedEnd: Bool {
        return cursor.reachedEnd
    }
    
    public init(_ string: String) {
        self.cursor = Cursor(string)
    }
    
    public mutating func next() throws(Diagnostic) -> Token {
        if cursor.reachedEnd {
            return Token(kind: .endOfFile, location: cursor.location)
        }
        try skipWhitespaceAndComments()
        
        guard let char = cursor.peek() else {
            return Token(kind: .endOfFile, location: cursor.location)
        }
        
        defer {
            cursor.advance()
        }
        
        if let lexer = chain.lexer(char) {
            return try lexer.lex(for: &cursor)
        }
        return Token(kind: .unknown(char.unicode), location: cursor.location)
    }
    
    private mutating func skipWhitespaceAndComments() throws(Diagnostic) {
        while let char = cursor.peek() {
            if char == .space || char == .newline ||
                char == UInt8(ascii: "\t") || char == UInt8(ascii: "\r") {
                cursor.advance()
                continue
            }
            
            if char == "-" && cursor.peek(aheadBy: 1) == "-" {
                cursor.advance(by: 2)
                while let char = cursor.peek(), char != .newline {
                    cursor.advance()
                }
                continue
            }
            
            if char == "(" && cursor.peek(aheadBy: 1) == "*" {
                let start = cursor.location
                cursor.advance(by: 2)
                var depth = 1
                
                while depth > 0, let char = cursor.peek() {
                    cursor.advance()
                    if char == "(" && cursor.peek() == "*" {
                        cursor.advance()
                        depth += 1
                    } else if char == "*" && cursor.peek() == ")" {
                        cursor.advance()
                        depth -= 1
                    }
                }
                
                if depth > 0 {
                    throw Diagnostic(LexerError.unterminatedComment, location: start)
                }
                continue
            }
            
            break
        }
    }
}

extension CoolLexer {
    private struct Chain<each L: TokenLexer> {
        private let lexer: (repeat (each L).Type)
        
        internal init(_ lexer: repeat (each L).Type) {
            self.lexer = (repeat each lexer)
        }
        
        internal func lexer(_ char: UInt8) -> TokenLexer.Type? {
            for item in repeat each lexer {
                if item.matches(char) {
                    return item
                }
            }
            return nil
        }
    }
}
