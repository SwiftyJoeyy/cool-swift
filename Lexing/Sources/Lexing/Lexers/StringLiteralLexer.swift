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
                throw Diagnostic(.stringContainsNull)
            }
            
            if char == .quote {
                return Token(kind: .stringLiteral(literal), location: start)
            }
            
            if char == .newline {
                cursor.advance(until: {$0 == .quote})
                throw Diagnostic(.unescapedNewline)
            }
            
            if length > 1024 {
                cursor.advance(until: {$0 == .quote})
                throw Diagnostic(.stringTooLong)
            }
            
            if char == .backslash {
                guard let next = cursor.next() else {
                    throw Diagnostic(.missingEndQuote)
                }
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
        
        throw Diagnostic(.missingEndQuote)
    }
}
