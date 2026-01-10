//
//  ClassDeclParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 22/11/2025.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer

internal struct ClassDeclParser {
    internal static func parse(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> ClassDecl {
        let location = parser.currentToken.location
        
        let identifierToken = try parser.advance()
        guard case .identifier(let name) = identifierToken.kind else {
            throw ParserError.expectedClassName.diagnostic(at: location)
        }
        
        var inheritance: InheritanceClause?
        if try parser.advance(if: {$0.kind == .keyword(.inherits)}) != nil {
            inheritance = try parseInheritanceClause(from: &parser)
        }
        
        let membersBlock = try parseMembersBlock(from: &parser, classLocation: location)
        
        if try parser.advance().kind != .semicolon {
          throw ParserError.expectedSymbol(.semicolon).diagnostic(at: location)
        }
        
        return ClassDecl(
            name: Identifier(value: name, location: identifierToken.location),
            inheritance: inheritance,
            membersBlock: membersBlock,
            location: location
        )
    }
    
    internal static func parseInheritanceClause(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> InheritanceClause {
        let inheritsToken = parser.currentToken
        
        let identifierToken = try parser.advance()
        guard case .identifier(let inheritted) = identifierToken.kind else {
            throw ParserError.expectedType.diagnostic(at: inheritsToken.location)
        }
        
        return InheritanceClause(
            inheritedType: TypeIdentifier(
                name: inheritted,
                location: identifierToken.location
            ),
            location: inheritsToken.location
        )
    }
    
    internal static func parseMembersBlock(
        from parser: inout CoolParser,
        classLocation: SourceLocation
    ) throws(Diagnostic) -> MembersBlock {
        let braceLocation: SourceLocation
        if let braceToken = try parser.advance(if: {$0.kind == .leftBrace}) {
            braceLocation = braceToken.location
        } else {
            braceLocation = parser.currentToken.location
            parser.diagnose(ParserError.expectedSymbol(.leftBrace).diagnostic(at: classLocation))
        }
        
        if try parser.advance().kind == .rightBrace {
            return MembersBlock(members: [], location: braceLocation)
        }
        var members = [any Decl]()
        
        while !parser.at(.rightBrace) && !parser.at(.endOfFile) {
            do throws(Diagnostic) {
                guard parser.currentToken.kind.isIdentifier else {
                    throw ParserError.unexpectedDeclaration
                        .diagnostic(at: parser.currentToken.location)
                }
                
                let nextToken = try parser.advanced()
                if nextToken.kind == .colon {
                    try members.append(VarDeclParser.parse(from: &parser))
                } else if nextToken.kind == .leftParen {
                    try members.append(FuncDeclParser.parse(from: &parser))
                } else {
                    throw ParserError.unexpectedDeclaration
                        .diagnostic(at: nextToken.location)
                }
                
                if try parser.advance(if: {$0.kind == .semicolon}) == nil {
                    throw ParserError.expectedSymbol(.semicolon)
                        .diagnostic(at: nextToken.location)
                }
            } catch {
                parser.diagnose(error)
                try parser.advance()
                try parser.advance(until: {$0.kind == .semicolon || $0.kind.isIdentifier || $0.kind == .rightBrace})
                if parser.at(.rightBrace) {
                    break
                } else if parser.at(.semicolon) {
                    try parser.advance()
                }
                continue
            }
            try parser.advance()
        }
        
        if !parser.at(.rightBrace) {
            throw ParserError.expectedSymbol(.rightBrace)
                .diagnostic(at: classLocation)
        }
        return MembersBlock(members: members, location: braceLocation)
    }
}
