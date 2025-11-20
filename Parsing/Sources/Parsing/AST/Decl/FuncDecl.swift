//
//  FuncDecl.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct FuncDecl: Decl {
    public let name: String
    public let parameters: ParametersClause
    public let returnClause: ReturnClause
    public let body: any Expr
    public let location: SourceLocation
}

public struct ParametersClause: ASTNode {
    public let parameters: [ParameterDecl]
    public let location: SourceLocation
}

public struct ParameterDecl: Decl {
    public let name: String
    public let type: any TypeRef
    public let location: SourceLocation
}

public struct ReturnClause: ASTNode {
    public let type: any TypeRef
    public let location: SourceLocation
}
