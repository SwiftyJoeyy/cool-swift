//
//  StringLiteralLexer.swift
//  Lexer
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

internal struct StringLiteralLexer: TokenLexer {
    internal static func matches(_ char: UInt8) -> Bool {
        return char == ASCII.quote
    }
    
    internal static func lex(for cursor: inout Cursor) throws -> Token {
        var literal = ""
        var length = 0
        
        func append(_ char: UInt8) {
            literal += String(UnicodeScalar(char))
            length += 1
        }
        
        func advanceToQuote() {
            while !cursor.reachedEnd {
                if let char = cursor.next(), char == ASCII.quote {
                    return
                }
            }
        }
        
        cursor.advance()
        
        while !cursor.reachedEnd {
            guard let char = cursor.next() else {
                advanceToQuote()
                throw LexerError.testing // TODO: - Add diagnostic
            }
            
            switch char {
                case ASCII.quote:
                    return Token(kind: .stringLiteral(literal)) // TODO: - Handle location
                    
                case ASCII.newline:
                    advanceToQuote()
                    throw LexerError.testing // TODO: - Add diagnostic
                    
                case ASCII.backslash:
                    guard let next = cursor.next() else {
                        advanceToQuote()
                        throw LexerError.testing // TODO: - Add diagnostic
                    }
                    
                    if next == ASCII.newline {
                        continue
                    }
                    append(char)
                    append(next)
                    
                default:
                    append(char)
            }
            
            if length == 1025 {
                break
            }
        }
        
        advanceToQuote()
        throw LexerError.testing // TODO: - Add diagnostic
    }
}
