//
//  FuncDeclParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 06/12/2025.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer

internal struct FuncDeclParser {
    internal static func parse(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> FuncDecl {
        let location = parser.currentToken.location
        guard case .identifier(let name) = parser.currentToken.kind else {
            throw ParserError.expectedFuncName.diagnostic(at: location)
        }
        
        let paramsClause = try parseParams(from: &parser)
        
        var colonLocation = parser.currentToken.location
        if let colonToken = try parser.advance(if: {$0.kind == .colon}) {
            colonLocation = colonToken.location
        } else {
            parser.diagnose(
                ParserError.expectedSymbol(.colon).diagnostic(at: colonLocation)
            )
        }
        
        let typeToken = try parser.advance()
        guard case .identifier(let type) = typeToken.kind else {
            throw ParserError.expectedType.diagnostic(at: typeToken.location)
        }
        
        var braceLocation = parser.currentToken.location
        if let braceToken = try parser.advance(if: {$0.kind == .leftBrace}) {
            braceLocation = braceToken.location
        } else {
            parser.diagnose(
                ParserError.expectedSymbol(.leftBrace).diagnostic(at: braceLocation)
            )
        }
        
        try parser.advance()
        let body = try ExprParser.parse(from: &parser)
        
//        guard try parser.advance().kind == .semicolon else {
//            throw ParserError.expectedSymbol(.semicolon)
//                .diagnostic(at: parser.currentToken.location)
//        }
        
        guard try parser.advance().kind == .rightBrace else {
            throw ParserError.expectedSymbol(.rightBrace)
                .diagnostic(at: parser.currentToken.location)
        }
        
        return FuncDecl(
            name: name,
            parameters: paramsClause,
            returnClause: ReturnClause(
                type: TypeIdentifier(name: type, location: typeToken.location),
                location: colonLocation
            ),
            body: body,
            location: location
        )
    }
    
    internal static func parseParams(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> ParametersClause {
        var parenLocation = parser.currentToken.location
        if let parenToken = try parser.advance(if: {$0.kind == .leftParen}) {
            parenLocation = parenToken.location
        } else {
            parser.diagnose(
                ParserError.expectedSymbol(.leftParen).diagnostic(at: parenLocation)
            )
        }
        
        if try parser.advance().kind == .rightParen {
            return ParametersClause(parameters: [], location: parenLocation)
        }
        
        var params = [ParameterDecl]()
        
        do throws(Diagnostic) {
            while !parser.at(.rightParen) {
                let paramLocation = parser.currentToken.location
                guard case .identifier(let name) = parser.currentToken.kind else {
                    throw ParserError.expectedParamName.diagnostic(at: paramLocation)
                }
                
                var colonLocation = parser.currentToken.location
                if let colonToken = try parser.advance(if: {$0.kind == .colon}) {
                    colonLocation = colonToken.location
                } else {
                    parser.diagnose(
                        ParserError.expectedSymbol(.colon).diagnostic(at: colonLocation)
                    )
                }
                
                let typeToken = try parser.advance()
                guard case .identifier(let type) = typeToken.kind else {
                    throw ParserError.expectedType.diagnostic(at: typeToken.location)
                }
                
                params.append(
                    ParameterDecl(
                        name: name,
                        type: TypeIdentifier(name: type, location: typeToken.location),
                        location: paramLocation
                    )
                )
                
                if try parser.advance().kind == .comma {
                    try parser.advance()
                } else {
                    break
                }
            }
        } catch {
            try parser.advance(until: {$0.kind == .rightParen})
            if parser.at(.rightParen) {
                throw error
            }
        }
        
        if !parser.at(.rightParen) {
            throw ParserError.expectedSymbol(.rightParen)
                .diagnostic(at: parser.currentToken.location)
        }
        
        return ParametersClause(
            parameters: params,
            location: parenLocation
        )
    }
}
