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
    
    public init?(_ keyword: String) {
        switch keyword {
            case "false":
                self = .false
                return
            case "true":
                self = .true
                return
            default:
                break
        }
        
        let lowercased = keyword.lowercased()
        switch lowercased {
            case "case": self = .case
            case "class": self = .class
            case "else": self = .else
            case "esac": self = .esac
            case "fi": self = .fi
            case "if": self = .if
            case "in": self = .in
            case "inherits": self = .inherits
            case "isvoid": self = .isvoid
            case "let": self = .let
            case "loop": self = .loop
            case "new": self = .new
            case "not": self = .not
            case "of": self = .of
            case "pool": self = .pool
            case "then": self = .then
            case "while": self = .while
            default: return nil
        }
    }
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
