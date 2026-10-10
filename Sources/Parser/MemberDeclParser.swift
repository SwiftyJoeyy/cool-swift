//
//  MemberDeclParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/01/2026.
//

public import AST
public import Diagnostics
import Foundation
import Lexer

public protocol MemberDeclParser {
    func parse(
        from parser: inout CoolParser
    ) throws(Diagnostic) -> MemberDecl
}

public struct DefaultMemberDeclParser: MemberDeclParser {
    public func parse(from parser: inout CoolParser) throws(Diagnostic) -> MemberDecl {
        let nextToken = try parser.advanced()
        if nextToken.kind == .colon {
            return MemberDecl(try VarDeclParser.parse(from: &parser))
        } else if nextToken.kind == .leftParen {
            return MemberDecl(try FuncDeclParser.parse(from: &parser))
        }
        
        throw ParserError.unexpectedDeclaration
            .diagnostic(at: nextToken.location)
    }
}

public struct InterfaceMemberDeclParser: MemberDeclParser {
    public func parse(from parser: inout CoolParser) throws(Diagnostic) -> MemberDecl {
        let nextToken = try parser.advanced()
        if nextToken.kind == .colon {
            return MemberDecl(try InterfaceVarDeclParser.parse(from: &parser))
        } else if nextToken.kind == .leftParen {
            return MemberDecl(try InterfaceFuncDeclParser.parse(from: &parser))
        }
        
        throw ParserError.unexpectedDeclaration
            .diagnostic(at: nextToken.location)
    }
}
