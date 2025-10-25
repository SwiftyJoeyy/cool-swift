//
//  StringLiteralLexer.swift
//  Lexer
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

internal struct StringLiteralLexer {
    private static let doubleQuote: Character = "\""
    
    private let location: SourceLocation
    private var length = 0
    private var literal = ""
    
    internal init(location: SourceLocation, literal: String) {
        self.location = location
        self.literal = literal
    }
}

extension StringLiteralLexer: TokenLexer {
    internal mutating func lexing(
        _ char: Char,
        at location: SourceLocation
    ) -> LexingResult {
        literal.append(String(char))
        length += 1
        
        if char == Self.doubleQuote {
            return .found(
                Token(
                    kind: .stringLiteral(literal),
                    location: self.location
                )
            )
        }
        return .continue
    }
    
    internal static func matches(_ char: Char) -> Bool {
        return char == Self.doubleQuote
    }
    
    internal static func new(for char: Char, at location: SourceLocation) -> Self {
        return StringLiteralLexer(location: location, literal: String(char))
    }
}
