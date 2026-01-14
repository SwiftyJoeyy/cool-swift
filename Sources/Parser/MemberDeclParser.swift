//
//  MemberDeclParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/01/2026.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer

public protocol MemberDeclParser {
    func parse(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> any Decl
}

public struct DefaultMemberDeclParser: MemberDeclParser {
    public func parse(from parser: inout CoolParser) throws(Diagnostic) -> any Decl {
        let nextToken = try parser.advanced()
        if nextToken.kind == .colon {
            return try VarDeclParser.parse(from: &parser)
        } else if nextToken.kind == .leftParen {
            return try FuncDeclParser.parse(from: &parser)
        }
        
        throw ParserError.unexpectedDeclaration
            .diagnostic(at: nextToken.location)
    }
}

public struct InterfaceMemberDeclParser: MemberDeclParser {
    public func parse(from parser: inout CoolParser) throws(Diagnostic) -> any Decl {
        let nextToken = try parser.advanced()
        if nextToken.kind == .colon {
            return try InterfaceVarDeclParser.parse(from: &parser)
        } else if nextToken.kind == .leftParen {
            return try InterfaceFuncDeclParser.parse(from: &parser)
        }
        
        throw ParserError.unexpectedDeclaration
            .diagnostic(at: nextToken.location)
    }
}
