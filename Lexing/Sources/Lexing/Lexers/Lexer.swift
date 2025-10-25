//
//  TokenLexer.swift
//  Lexer
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public typealias Char = Character

public protocol Lexer {
    mutating func lexing(_ char: Char, at location: SourceLocation) -> LexingResult
}

internal protocol TokenLexer: Lexer {
    static func matches(_ char: Char) -> Bool
    
    static func new(for char: Char, at location: SourceLocation) -> Self
}

public enum LexingResult: Equatable, Hashable {
    case `continue`
    case found(Token)
    // TODO: - Add Diagnostic to failed
    case failed
}
