//
//  OperatorLexer.swift
//  Lexing
//
//  Created by Joe Maghzal on 28/10/2025.
//

import Foundation
import Diagnostics

internal struct OperatorLexer: TokenLexer {
    internal static func matches(_ char: UInt8) -> Bool {
        return char == "=" || char == "<" || char == "+" || char == "-" || char == "*" || char == "/"  || char == "~"
    }
    
    internal static func lex(for cursor: inout Cursor) throws(Diagnostic) -> Token {
        let start = cursor.location
        assert(cursor.peek() != nil)
        let char = cursor.peek()!.unicode
        
        switch char {
            case "=":
                if cursor.peek(aheadBy: 1) == ">" {
                    cursor.advance()
                    return Token(kind: .arrow, location: start)
                }
                return Token(kind: .equal, location: start)
            case "<":
                if cursor.peek(aheadBy: 1) == "-" {
                    cursor.advance()
                    return Token(kind: .assign, location: start)
                } else if cursor.peek(aheadBy: 1) == "=" {
                    cursor.advance()
                    return Token(kind: .lessThanOrEqual, location: start)
                }
                return Token(kind: .lessThan, location: start)
            case "+":
                return Token(kind: .plus, location: start)
            case "-":
                return Token(kind: .minus, location: start)
            case "*":
                return Token(kind: .star, location: start)
            case "/":
                return Token(kind: .slash, location: start)
            case "~":
                return Token(kind: .tilde, location: start)
            default:
                throw Diagnostic(LexerError.unexpectedCharacter, location: start)
        }
    }
}
