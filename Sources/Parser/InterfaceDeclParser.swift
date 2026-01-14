//
//  InterfaceFuncDeclParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/01/2026.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer

internal struct InterfaceFuncDeclParser {
    internal static func parse(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> InterfaceFuncDecl {
        let location = parser.currentToken.location
        guard case .identifier(let name) = parser.currentToken.kind else {
            throw ParserError.expectedFuncName.diagnostic(at: location)
        }
        
        let paramsClause = try ParamsParser.parse(from: &parser)
        
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
        
        return InterfaceFuncDecl(
            name: Identifier(value: name, location: location),
            parameters: paramsClause,
            returnClause: ReturnClause(
                type: TypeIdentifier(name: type, location: typeToken.location),
                location: colonLocation
            ),
            location: location
        )
    }
}

internal struct InterfaceVarDeclParser {
    internal static func parse(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> InterfaceVarDecl {
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
        
        return InterfaceVarDecl(
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
}
