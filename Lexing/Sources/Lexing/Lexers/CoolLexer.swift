//
//  CoolLexer.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public struct CoolLexer: Lexer {
    private let chain = LexersChain(
        StringLiteralLexer.self,
        IntegerLiteralLexer.self
    )
    private var current: (any TokenLexer)?
    
    public init() { }
    
    public mutating func lexing(
        _ char: Char,
        at location: SourceLocation
    ) -> LexingResult {
        if current != nil {
            let result = current!.lexing(char, at: location)
            if result != .continue {
                current = nil
            }
            // TODO: - Handle failure diagnostics
            return result
        }
        current = chain.lexer(for: char, at: location)
        #warning("We should call self.lexing in case the lexer finishes after one character.")
        return .continue
    }
}

internal struct LexersChain<each L: TokenLexer> {
    private let lexer: (repeat (each L).Type)
    
    internal init(_ lexer: repeat (each L).Type) {
        self.lexer = (repeat each lexer)
    }
    
    internal func lexer(
        for char: Char,
        at location: SourceLocation
    ) -> (any TokenLexer)? {
        for lex in repeat each lexer {
            if lex.matches(char) {
                return lex.new(for: char, at: location)
            }
        }
        return nil
    }
}
