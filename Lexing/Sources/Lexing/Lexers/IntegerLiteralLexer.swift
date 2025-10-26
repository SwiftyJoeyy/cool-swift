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
        return isNumber(char)
    }
    
    static func lex(for cursor: inout Cursor) throws(Diagnostic) -> Token {
        let start = cursor.location
        var literal = cursor.peek()?.unicode ?? ""
        while let char = cursor.peek(aheadBy: 1) {
            guard isNumber(char) else {
                if endOfInt(char) {
                    break
                }
                cursor.advance(until: endOfInt)
                throw Diagnostic(.invalidInteger)
            }
            literal.append(char.unicode)
            cursor.advance()
        }
        
        return Token(
            kind: .integerLiteral(literal),
            location: start
        )
    }
    
    private static func endOfInt(_ char: UInt8) -> Bool {
        #warning("Check for other valid chars like operators")
        return char == .newline || char == .space
    }
    
    private static func isNumber(_ char: UInt8) -> Bool {
        return char >= UInt8(ascii: "0") && char <= UInt8(ascii: "9")
    }
}
