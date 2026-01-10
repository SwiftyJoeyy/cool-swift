//
//  PrefixExprParser.swift
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
    internal static func parsePrefix(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> Expr {
        let token = parser.currentToken
        switch token.kind {
            case .keyword(.if):
                return try parseIfExpr(from: &parser)
            case .keyword(.while):
                return try parseWhileExpr(from: &parser)
            case .keyword(.case):
                return try parseCaseExpr(from: &parser)
            case .keyword(.let):
                return try parseLetExpr(from: &parser)
            case .leftBrace:
                return try parseBlockExpr(from: &parser)
                
            case .keyword(.not):
                try parser.advance()
                return NotExpr(
                    expression: try parse(from: &parser, minPrecedence: .unary),
                    location: token.location
                )
            case .keyword(.isvoid):
                try parser.advance()
                return IsVoidExpr(
                    expression: try parse(from: &parser, minPrecedence: .unary),
                    location: token.location
                )
            case .keyword(.new):
                let identifierToken = try parser.advance()
                guard case .identifier(let type) = identifierToken.kind else {
                    throw ParserError.expectedType
                        .diagnostic(at: parser.currentToken.location)
                }
                return NewExpr(
                    type: TypeIdentifier(
                        name: type,
                        location: identifierToken.location
                    ),
                    location: token.location
                )
                
            case .integerLiteral(let value):
                return IntegerLiteralExpr(value: value, location: token.location)
            case .stringLiteral(let value):
                return StringLiteralExpr(value: value, location: token.location)
            case .keyword(let keyword) where keyword == .true || keyword == .false:
                return BoolLiteralExpr(value: keyword.text, location: token.location)
            case .identifier(let name):
                return DeclRefExpr(name: name, location: token.location)
            case .leftParen:
                try parser.advance()
                let expr = try parse(from: &parser)
                if try parser.advance().kind != .rightParen {
                    throw ParserError.expectedSymbol(.rightParen)
                        .diagnostic(at: parser.currentToken.location)
                }
                return expr
                
            default:
                throw ParserError.unexpectedExpression
                    .diagnostic(at: token.location)
        }
    }
    
    private static func parseIfExpr(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> IfExpr {
        let ifToken = parser.currentToken
        try parser.advance()
        
        let condition = try parse(from: &parser)
        if try parser.advance().kind != .keyword(.then) {
            throw ParserError.expectedKeyword(.then)
                .diagnostic(at: parser.currentToken.location)
        }
        
        try parser.advance()
        let thenBody = try parse(from: &parser)
        if try parser.advance().kind != .keyword(.else) {
            throw ParserError.expectedKeyword(.else)
                .diagnostic(at: parser.currentToken.location)
        }
        
        try parser.advance()
        let elseBody = try parse(from: &parser)
        if try parser.advance().kind != .keyword(.fi) {
            throw ParserError.expectedKeyword(.fi)
                .diagnostic(at: parser.currentToken.location)
        }
        
        return IfExpr(
            condition: condition,
            thenBody: thenBody,
            elseBody: elseBody,
            location: ifToken.location
        )
    }
    
    private static func parseWhileExpr(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> WhileExpr {
        let whileToken = parser.currentToken
        try parser.advance()
        
        let condition = try parse(from: &parser)
        if try parser.advance().kind != .keyword(.loop) {
            throw ParserError.expectedKeyword(.loop)
                .diagnostic(at: parser.currentToken.location)
        }
        
        try parser.advance()
        let body = try parse(from: &parser)
        
        if try parser.advance().kind != .keyword(.pool) {
            throw ParserError.expectedKeyword(.pool)
                .diagnostic(at: parser.currentToken.location)
        }
        
        return WhileExpr(
            condition: condition,
            body: body,
            location: whileToken.location
        )
    }
    
    private static func parseCaseExpr(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> CaseExpr {
        let caseToken = parser.currentToken
        try parser.advance()
        
        let expr = try parse(from: &parser)
        if try parser.advance().kind != .keyword(.of) {
            throw ParserError.expectedKeyword(.of)
                .diagnostic(at: parser.currentToken.location)
        }
        
        try parser.advance()
        var branches = [CaseBranch]()
        
        do throws(Diagnostic) {
            while !parser.at(.keyword(.esac)) {
                let binding = try parseCaseBranchBinding(from: &parser)
                if try parser.advance().kind != .arrow {
                    throw ParserError.expectedSymbol(.arrow)
                        .diagnostic(at: parser.currentToken.location)
                }
                try parser.advance()
                let body = try parse(from: &parser)
                if try parser.advance().kind != .semicolon {
                    throw ParserError.expectedSymbol(.semicolon)
                        .diagnostic(at: parser.currentToken.location)
                }
                try parser.advance()
                
                branches.append(
                    CaseBranch(
                        binding: binding,
                        body: body,
                        location: binding.location
                    )
                )
            }
        } catch {
            try parser.advance(until: {$0.kind == .keyword(.esac)})
            if parser.at(.keyword(.esac)) {
                throw error
            }
        }
        
        if !parser.at(.keyword(.esac)) {
            throw ParserError.expectedKeyword(.esac)
                .diagnostic(at: parser.currentToken.location)
        }
        
        return CaseExpr(
            expr: expr,
            branches: branches,
            location: caseToken.location
        )
    }
    
    private static func parseCaseBranchBinding(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> CaseBranch.Binding {
        let location = parser.currentToken.location
        guard case .identifier(let name) = parser.currentToken.kind else {
            throw ParserError.expectedVarName.diagnostic(at: location)
        }
        
        let colonLocation: SourceLocation
        if let colonToken = try parser.advance(if: {$0.kind == .colon}) {
            colonLocation = colonToken.location
        } else {
            colonLocation = parser.currentToken.location
            parser.diagnose(ParserError.expectedSymbol(.colon).diagnostic(at: colonLocation))
        }
        
        let typeToken = try parser.advance()
        guard case .identifier(let type) = typeToken.kind else {
            throw ParserError.expectedTypeAnnotation.diagnostic(at: location)
        }
        
        return CaseBranch.Binding(
            name: Identifier(value: name, location: location),
            typeAnnotation: TypeAnnotation(
                type: TypeIdentifier(
                    name: type,
                    location: typeToken.location
                ),
                location: colonLocation
            ),
            location: location
        )
    }
    
    private static func parseLetExpr(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> LetExpr {
        let letToken = parser.currentToken
        try parser.advance()
        
        var bindings = [VarDecl]()
        
        var parseBinding = true
        while parseBinding {
            bindings.append(try VarDeclParser.parse(from: &parser))
            parseBinding = try parser.advance(if: {$0.kind == .comma}) != nil
            try parser.advance()
        }
        
        if !parser.at(.keyword(.in)) {
            throw ParserError.expectedKeyword(.in)
                .diagnostic(at: parser.currentToken.location)
        }
        try parser.advance()
        
        let body = try parse(from: &parser)
        return LetExpr(
            bindings: bindings,
            body: body,
            location: letToken.location
        )
    }
    
    private static func parseBlockExpr(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> BlockExpr {
        let braceToken = parser.currentToken
        try parser.advance()
        var expressions = [Expr]()
        
        do throws(Diagnostic) {
            while !parser.at(.rightBrace) {
                expressions.append(try parse(from: &parser))
                if try parser.advance().kind != .semicolon {
                    throw ParserError.expectedSymbol(.semicolon)
                        .diagnostic(at: parser.currentToken.location)
                }
                try parser.advance()
            }
        } catch {
            try parser.advance(until: {$0.kind == .rightBrace})
            if parser.at(.rightBrace) {
                throw error
            }
        }
        
        if !parser.at(.rightBrace) {
            throw ParserError.expectedSymbol(.rightBrace)
                .diagnostic(at: parser.currentToken.location)
        }
        
        return BlockExpr(
            expressions: expressions,
            location: braceToken.location
        )
    }
}
