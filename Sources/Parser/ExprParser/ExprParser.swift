//
//  ExprParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/12/2025.
//

import Foundation
import AST
import Diagnostics
import Lexer

struct ExprParser {
    static func parse(
        from parser: inout CoolParser,
        minPrecedence: Precedence = .none
    ) throws(Diagnostic) -> any Expr {
        var left = try parsePrefix(from: &parser)
        
        while let precedence = (try parser.advance(if: {$0.precedence != nil && $0.precedence! >= minPrecedence}))?.precedence {
            left = try parseInfix(from: &parser, left: left, precedence: precedence)
        }
        
        return left
    }
    
    static func parseOperand(
        of op: Token,
        from parser: inout CoolParser,
        minPrecedence: Precedence
    ) throws(Diagnostic) -> any Expr {
        guard parser.currentToken.kind.startsExpression else {
            throw ParserError.expectedOperand(after: op.kind.text)
                .diagnostic(at: op.location)
        }
        return try parse(from: &parser, minPrecedence: minPrecedence)
    }
}

extension TokenKind {
    fileprivate var startsExpression: Bool {
        switch self {
            case .identifier, .integerLiteral, .stringLiteral, .leftParen, .leftBrace, .tilde:
                return true
            case .keyword(let keyword):
                let keywords: [Keyword] = [.if, .while, .case, .let, .not, .isvoid, .new, .true, .false]
                return keywords.contains(keyword)
            default:
                return false
        }
    }
}

extension ExprParser {
    enum Precedence: Comparable {
        case none
        case assignment
        case comparison
        case additive
        case multiplicative
        case unary
        case postfix
        case custom(Int)
        
        private var rawValue: Int {
            switch self {
                case .none:
                    return 0
                case .assignment:
                    return 10
                case .comparison:
                    return 20
                case .additive:
                    return 30
                case .multiplicative:
                    return 40
                case .unary:
                    return 50
                case .postfix:
                    return 60
                case .custom(let value):
                    return value
            }
        }
        
        var higher: Precedence {
            return .custom(rawValue + 1)
        }
        
        static func < (lhs: Precedence, rhs: Precedence) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

extension Token {
    fileprivate var precedence: ExprParser.Precedence? {
        switch kind {
            case .assign:
                return .assignment
            case .lessThan, .lessThanOrEqual, .equal:
                return .comparison
            case .plus, .minus:
                return .additive
            case .star, .slash:
                return .multiplicative
            case .dot, .at, .leftParen:
                return .postfix
            default:
                return nil
        }
    }
}
