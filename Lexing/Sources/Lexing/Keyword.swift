//
//  Keyword.swift
//  Lexer
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public enum Keyword: UInt8, Hashable, Equatable, Sendable {
    case `case`
    case `class`
    case `else`
    case esac
    case `false`
    case fi
    case `if`
    case `in`
    case inherits
    case isvoid
    case `let`
    case loop
    case new
    case not
    case of
    case pool
    case then
    case `true`
    case `while`
}

extension Keyword {
    private static let lookupTable: [String] = [
        "case",
        "class",
        "else",
        "esac",
        "false",
        "fi",
        "if",
        "in",
        "inherits",
        "isvoid",
        "let",
        "loop",
        "new",
        "not",
        "of",
        "pool",
        "then",
        "true",
        "while",
    ]
    
    public var text: String {
        return Self.lookupTable[Int(rawValue)]
    }
}
