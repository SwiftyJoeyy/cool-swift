//
//  VarDeclParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 22/11/2025.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer

internal struct VarDeclParser {
    internal static func parse(from parser: inout CoolParser) throws(Diagnostic) -> VarDecl {
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
        
        var initializer: InitializerClause?
        if try parser.advance(if: {$0.kind == .assign}) != nil {
            initializer = try parseInitializer(from: &parser)
        }
        
        return VarDecl(
            name: Identifier(value: name, location: location),
            typeAnnotation: TypeAnnotation(
                type: TypeIdentifier(
                    name: type,
                    location: typeToken.location
                ),
                location: colonLocation
            ),
            initializer: initializer,
            location: location
        )
    }
    
    internal static func parseInitializer(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> InitializerClause {
        let assignToken = parser.currentToken
        try parser.advance()
        let expr = try ExprParser.parse(from: &parser)
        return InitializerClause(expr: expr, location: assignToken.location)
    }
}
