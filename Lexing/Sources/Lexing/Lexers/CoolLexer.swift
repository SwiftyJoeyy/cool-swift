//
//  CoolLexer.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public struct CoolLexer {
    private let chain = Chain(
        StringLiteralLexer.self,
//        IntegerLiteralLexer.self
    )
    
    private var cursor: Cursor
    
    public var reachedEnd: Bool {
        return cursor.reachedEnd
    }
    
    public init(_ string: String) {
        self.cursor = Cursor(string)
    }
    
    public mutating func next() throws -> Token {
        guard let char = cursor.peek(aheadBy: 1) else {
            throw LexerError.testing // TODO: - Add diagnostic
        }
        
        if let lexer = chain.lexer(char) {
            return try lexer.lex(for: &cursor)
        }
        cursor.advance()
        return Token(kind: .unknown(String(UnicodeScalar(char))))
    }
}

extension CoolLexer {
    internal struct Chain<each L: TokenLexer> {
        private let lexer: (repeat (each L).Type)
        
        internal init(_ lexer: repeat (each L).Type) {
            self.lexer = (repeat each lexer)
        }
        
        internal func lexer(_ char: UInt8) -> TokenLexer.Type? {
            for item in repeat each lexer {
                if item.matches(char) {
                    return item
                }
            }
            return nil
        }
    }
}

internal struct Cursor {
    private let input: [UInt8]
    private let length: Int
    private var position = -1
    
    internal var reachedEnd: Bool {
        return position == length - 1
    }
    
    internal init(_ string: String) {
        self.input = Array(string.utf8)
        self.length = input.count
    }
    
    internal func peek(aheadBy offset: Int = 0) -> UInt8? {
        let nexPos = position + offset
        guard nexPos < length, nexPos >= 0 else {
            return nil
        }
        return input[nexPos]
    }
    
    internal mutating func advance(by offset: Int = 1) {
        let nexPos = position + offset
        guard nexPos < length, nexPos >= 0 else {
            return
        }
        position = nexPos
    }
    
    internal mutating func next() -> UInt8? {
        advance()
        return input[position]
    }
}

internal enum LexerError: Error { #warning("This is for testing only, we need a proper diagnostic system")
    case testing
}
