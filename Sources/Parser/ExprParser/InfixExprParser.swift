//
//  InfixExprParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/12/2025.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer

extension ExprParser {
    internal static func parseInfix(
        from parser: inout CoolParser,
        left: Expr,
        precedence: Precedence
    ) throws(Diagnostic) -> Expr {
        let opToken = parser.currentToken
        
        switch opToken.kind {
            case .plus, .minus, .star, .slash, .lessThan, .lessThanOrEqual, .equal:
                try parser.advance()
                let right = try parse(
                    from: &parser,
                    minPrecedence: precedence.higher
                )
                return OperationExpr(
                    lhs: left,
                    operatorExpr: parseBinaryOpExpr(from: opToken),
                    rhs: right,
                    location: left.location
                )
                
            case .assign:
                try parser.advance()
                let right = try parse(
                    from: &parser,
                    minPrecedence: precedence
                )
                return AssignmentExpr(
                    target: left,
                    value: right,
                    location: left.location
                )
                
            case .dot:
                try parser.advance()
                let member = try parse(from: &parser, minPrecedence: precedence.higher)
                return MemberAccessExpr(
                    base: left,
                    member: member,
                    location: left.location
                )
                
            case .at:
                try parser.advance()
                let typeToken = parser.currentToken
                guard case .identifier(let type) = typeToken.kind else {
                    throw ParserError.expectedType
                        .diagnostic(at: parser.currentToken.location)
                }
                return StaticDispatchExpr(
                    base: left,
                    type: TypeIdentifier(name: type, location: typeToken.location),
                    location: left.location
                )
                
            case .leftParen:
                try parser.advance()
                let args = try parseFuncCallArgs(from: &parser)
                return FuncCallExpr(
                    calledExpression: left,
                    arguments: args,
                    location: left.location
                )
            default:
                fatalError()
        }
    }
    
    private static func parseBinaryOpExpr(from token: Token) -> BinaryOperatorExpr {
        let op: BinaryOperatorExpr.Operator
        switch token.kind {
            case .lessThan:
                op = .lessThan
            case .lessThanOrEqual:
                op = .lessThanOrEqual
            case .plus:
                op = .plus
            case .minus:
                op = .minus
            case .slash:
                op = .slash
            case .star:
                op = .star
            case .equal:
                op = .equal
            default:
                fatalError()
        }
        return BinaryOperatorExpr(op: op, location: token.location)
    }
    
    private static func parseFuncCallArgs(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> [Expr] {
        if parser.at(.rightParen) {
            return []
        }
        
        var args = [Expr]()
        args.append(try parse(from: &parser))
        try parser.advance()
        while parser.at(.comma) {
            try parser.advance()
            args.append(try parse(from: &parser))
            try parser.advance()
        }
        
        if !parser.at(.rightParen) {
            throw ParserError.expectedSymbol(.rightParen)
                .diagnostic(at: parser.currentToken.location)
        }
        return args
    }
}
