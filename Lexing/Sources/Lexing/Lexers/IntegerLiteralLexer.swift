//
//  IntegerLiteralLexer.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Diagnostics

internal struct IntegerLiteralLexer: TokenLexer {
    internal static func matches(_ char: UInt8) -> Bool {
        return valid(char)
    }
    
    static func lex(for cursor: inout Cursor) throws(Diagnostic) -> Token {
        let start = cursor.location
        assert(cursor.peek() != nil)
        var literal = cursor.peek()!.unicode
        
        while let char = cursor.peek(aheadBy: 1) {
            guard valid(char) else {
                if validSeparator(char) {
                    break
                }
                cursor.advance(until: validSeparator)
                throw Diagnostic(LexerError.invalidInteger, location: start)
            }
            literal.append(char.unicode)
            cursor.advance()
        }
        
        return Token(
            kind: .integerLiteral(literal),
            location: start
        )
    }
    
    private static func validSeparator(_ char: UInt8) -> Bool {
        if char == .space || char == .newline || char == .tab {
            return true
        }
        if OperatorLexer.matches(char) {
            return true
        }
        if PunctuationLexer.matches(char) {
            return true
        }
        return false
    }
    
    private static func valid(_ char: UInt8) -> Bool {
        return char >= "0" && char <= "9"
    }
}
