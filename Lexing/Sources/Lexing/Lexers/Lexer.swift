//
//  TokenLexer.swift
//  Lexer
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

internal protocol TokenLexer {
    static func matches(_ char: UInt8) -> Bool
    
    static func lex(for cursor: inout Cursor) throws -> Token
}
