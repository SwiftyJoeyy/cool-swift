//
//  PunctuationLexer.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Foundation
import Diagnostics

internal struct PunctuationLexer: TokenLexer {
    internal static func matches(_ char: UInt8) -> Bool {
        return char == "@" || char == ":" || char == "," || char == "." || char == "{" || char == "(" || char == ")" || char == "}" || char == ";"
    }
    
    internal static func lex(for cursor: inout Cursor) throws(Diagnostic) -> Token {
        let start = cursor.location
        assert(cursor.peek() != nil)
        let char = cursor.peek()!.unicode
        
        switch char {
            case "@":
                return Token(kind: .at, location: start)
            case ":":
                return Token(kind: .colon, location: start)
            case ",":
                return Token(kind: .comma, location: start)
            case ".":
                return Token(kind: .dot, location: start)
            case "{":
                return Token(kind: .leftBrace, location: start)
            case "(":
                return Token(kind: .leftParen, location: start)
            case ")":
                return Token(kind: .rightParen, location: start)
            case "}":
                return Token(kind: .rightBrace, location: start)
            case ";":
                return Token(kind: .semicolon, location: start)
            default:
                throw Diagnostic(.unexpectedCharacter)
        }
    }
}
