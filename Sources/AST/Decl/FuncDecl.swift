//
//  FuncDecl.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct FuncDecl: MethodDecl {
    public let name: Identifier
    public let parameters: ParametersClause
    public let returnClause: ReturnClause
    public let body: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return """
        \(name)\(parameters.description)\(returnClause.description) {
            \(body.description)
        }
        """
    }
    
    public init(
        name: Identifier,
        parameters: ParametersClause,
        returnClause: ReturnClause,
        body: some Expr,
        location: SourceLocation
    ) {
        self.name = name
        self.parameters = parameters
        self.returnClause = returnClause
        self.body = body
        self.location = location
    }
}

public struct ParametersClause: ASTNode {
    public let parameters: [ParameterDecl]
    public let location: SourceLocation
    
    public var description: String {
        let params = parameters.map(\.description).joined(separator: ", ")
        return "(\(params))"
    }
    
    public init(parameters: [ParameterDecl], location: SourceLocation) {
        self.parameters = parameters
        self.location = location
    }
}

public struct ParameterDecl: BindingDecl {
    public let name: Identifier
    public let type: any TypeRef
    public let location: SourceLocation
    
    public var description: String {
        return "\(name): \(type.description)"
    }
    
    public init(name: Identifier, type: some TypeRef, location: SourceLocation) {
        self.name = name
        self.type = type
        self.location = location
    }
}

public struct ReturnClause: ASTNode {
    public let type: any TypeRef
    public let location: SourceLocation
    
    public var description: String {
        return ": \(type.description)"
    }
    
    public init(type: some TypeRef, location: SourceLocation) {
        self.type = type
        self.location = location
    }
}
