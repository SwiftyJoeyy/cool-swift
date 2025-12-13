//
//  IdentifierLexer.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Foundation
import Diagnostics

internal struct IdentifierLexer: TokenLexer {
    internal static func matches(_ char: UInt8) -> Bool {
        return (char >= "a" && char <= "z") || (char >= "A" && char <= "Z")
    }
    
    internal static func lex(for cursor: inout Cursor) throws(Diagnostic) -> Token {
        let start = cursor.location
        assert(cursor.peek() != nil)
        var literal = cursor.peek()!.unicode
        
        while let char = cursor.peek(aheadBy: 1) {
            guard valid(char) else {
                if validSeparator(char) {
                    break
                }
                cursor.advance(until: validSeparator)
                throw LexerError.invalidIdentifier.diagnostic(at: start)
            }
            literal.append(char.unicode)
            cursor.advance()
        }
        
        if let keyword = Keyword(literal) {
            return Token(
                kind: .keyword(keyword),
                location: start
            )
        }
        
        return Token(
            kind: .identifier(literal),
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
        let isLetter = (char >= "a" && char <= "z") || (char >= "A" && char <= "Z")
        let isNumber = char >= "0" && char <= "9"
        return isLetter || isNumber || char == "_"
    }
}
