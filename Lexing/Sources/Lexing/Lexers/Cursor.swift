//
//  Cursor.swift
//  Lexing
//
//  Created by Joe Maghzal on 26/10/2025.
//

import Foundation

internal struct Cursor {
    private let input: [UInt8]
    private let length: Int
    private let file: String
    
    private var position = 0
    private var line = 1
    private var column = 1
    
    internal var reachedEnd: Bool {
        return position >= length
    }
    
    internal var location: SourceLocation {
        SourceLocation(line: line, column: column, file: file)
    }
    
    internal init(_ string: String, file: String = "") {
        self.input = Array(string.utf8)
        self.length = input.count
        self.file = file
    }
    
    internal func peek(aheadBy offset: Int = 0) -> UInt8? {
        let pos = position + offset
        guard pos < length else {
            return nil
        }
        return input[pos]
    }
    
    @discardableResult internal mutating func advance(by offset: Int = 1) -> Bool {
        guard position + offset <= length else {
            position = length
            return false
        }
        
        for _ in 0..<offset {
            position += 1
            guard position < length else { break }
            if input[position] == .newline {
                line += 1
                column = 0
            } else {
                column += 1
            }
        }
        
        return true
    }
    
    internal mutating func advance(until predicate: (UInt8) -> Bool) {
        while let char = peek(), !predicate(char) {
            advance()
        }
    }
    
    internal mutating func next() -> UInt8? {
        guard advance() else {
            return nil
        }
        return peek()
    }
}
