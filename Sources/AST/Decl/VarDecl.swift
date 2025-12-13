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
    
    public var description: String {
        return "\(name): \(typeAnnotation.description) \(initializer?.description ?? "")"
    }
    
    public init(
        name: String,
        typeAnnotation: TypeAnnotation,
        initializer: InitializerClause?,
        location: SourceLocation
    ) {
        self.name = name
        self.typeAnnotation = typeAnnotation
        self.initializer = initializer
        self.location = location
    }
}

public struct TypeAnnotation: ASTNode {
    public let type: any TypeRef
    public let location: SourceLocation
    
    public var description: String {
        return type.description
    }
    
    public init(type: some TypeRef, location: SourceLocation) {
        self.type = type
        self.location = location
    }
}

public struct InitializerClause: ASTNode {
    public let expr: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "<- \(expr.description)"
    }
    
    public init(expr: some Expr, location: SourceLocation) {
        self.expr = expr
        self.location = location
    }
}
