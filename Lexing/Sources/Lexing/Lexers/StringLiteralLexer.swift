//
//  StringLiteralLexer.swift
//  Lexer
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Diagnostics

internal struct StringLiteralLexer: TokenLexer {
    internal static func matches(_ char: UInt8) -> Bool {
        return char == .quote
    }
    
    internal static func lex(for cursor: inout Cursor) throws(Diagnostic) -> Token {
        let start = cursor.location
        var literal = ""
        var length = 0
        
        @inline(__always) func append(_ char: UInt8) {
            literal += char.unicode
            length += 1
        }
        
        while let char = cursor.next() {
            if char == 0 {
                throw Diagnostic(LexerError.stringContainsNull, location: start)
            }
            
            if char == .quote {
                return Token(kind: .stringLiteral(literal), location: start)
            }
            
            if char == .newline {
                cursor.advance(until: validSeparator)
                throw Diagnostic(LexerError.unescapedNewline, location: start)
            }
            
            if length >= 1024 {
                cursor.advance(until: validSeparator)
                throw Diagnostic(LexerError.stringTooLong, location: start)
            }
            
            if char == .backslash {
                guard let next = cursor.next() else { break }
                switch next {
                    case .newline: break
                    case "n": append(.newline)
                    case "t": append(.tab)
                    case "b": append(.backspace)
                    case "f": append(.formfeed)
                    default: append(next)
                }
                continue
            }
            
            append(char)
        }
        
        throw Diagnostic(LexerError.missingEndQuote, location: start)
    }
    
    private static func validSeparator(_ char: UInt8) -> Bool {
        return char == .quote
    }
}
