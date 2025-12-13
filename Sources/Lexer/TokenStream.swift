//
//  TokenStream.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/12/2025.
//

import Foundation
import Diagnostics

public struct Lexemes {
    private var lexer: CoolLexer
    private var buffer = [Token]()
    private var position: Int = 0
    
    public var file: String {
        return lexer.file
    }
    
    public var reachedEnd: Bool {
        return lexer.reachedEnd
    }
    
    public init(lexer: CoolLexer) {
        self.lexer = lexer
    }
    
    public mutating func peek(ahead offset: Int = 0) throws(Diagnostic) -> Token {
        while buffer.count <= position + offset {
            buffer.append(try lexer.next())
        }
        return buffer[position + offset]
    }
    
    @discardableResult
    public mutating func consume() throws(Diagnostic) -> Token {
        let token = try peek()
        position += 1
        
        if position > 30 {
            let keepCount = 10
            buffer.removeFirst(position - keepCount)
            position = keepCount
        }
        
        return token
    }
}
