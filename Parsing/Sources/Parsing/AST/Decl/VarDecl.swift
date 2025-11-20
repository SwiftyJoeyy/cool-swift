//
//  VarDecl.swift
//  Parsing
//
//  Created by Joe Maghzal on 11/11/2025.
//

import Foundation
import Basic

public struct VarDecl: Decl {
    public let name: String
    public let typeAnnotation: TypeAnnotation
    public let initializer: InitializerClause?
    public let location: SourceLocation
}

public struct TypeAnnotation: ASTNode {
    public let type: any TypeRef
    public let location: SourceLocation
}

public struct InitializerClause: ASTNode {
    public let expr: any Expr
    public let location: SourceLocation
}
