//
//  TokenKind.swift
//  Lexer
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public enum TokenKind: Hashable, Equatable {
    case arrow                        // => (used in case branches)
    case assign                       // <- (assignment)
    case at                           // @  (static dispatch)
    case colon                        // :
    case comma                        // ,
    case dot                          // .
    case endOfFile                    // End of file marker
    case equal                        // =  (equality)
    case identifier(String)           // Object identifiers (start with lowercase)
    case integerLiteral(String)       // Integer constants (stored as String, parse later)
    case keyword(Keyword)             // All keywords including true/false
    case leftBrace                    // {
    case leftParen                    // (
    case lessThan                     // <  (less than)
    case lessThanOrEqual              // <= (less than or equal)
    case minus                        // -  (subtract)
    case plus                         // +  (add)
    case rightBrace                   // }
    case rightParen                   // )
    case semicolon                    // ;
    case slash                        // /  (divide)
    case star                         // *  (multiply)
    case stringLiteral(String)        // String constants (without quotes)
    case tilde                        // ~  (integer complement)
}


extension TokenKind {
    public var text: String {
        switch self {
            case .identifier(let name): return name
            case .integerLiteral(let text): return text
            case .stringLiteral(let string): return string
            case .keyword(let keyword): return keyword.text
            case .arrow: return "=>"
            case .assign: return "<-"
            case .at: return "@"
            case .colon: return ":"
            case .comma: return ","
            case .dot: return "."
            case .endOfFile: return "<EOF>"
            case .equal: return "="
            case .leftBrace: return "{"
            case .leftParen: return "("
            case .lessThan: return "<"
            case .lessThanOrEqual: return "<="
            case .minus: return "-"
            case .plus: return "+"
            case .rightBrace: return "}"
            case .rightParen: return ")"
            case .semicolon: return ";"
            case .slash: return "/"
            case .star: return "*"
            case .tilde: return "~"
        }
    }
}
