//
//  InterfaceFuncDecl.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/01/2026.
//

import Foundation
import Basic

public struct InterfaceFuncDecl: MethodDecl {
    public let name: Identifier
    public let parameters: ParametersClause
    public let returnClause: ReturnClause
    public let location: SourceLocation
    
    public var description: String {
        return """
        \(name)\(parameters.description)\(returnClause.description)
        """
    }
    
    public init(
        name: Identifier,
        parameters: ParametersClause,
        returnClause: ReturnClause,
        location: SourceLocation
    ) {
        self.name = name
        self.parameters = parameters
        self.returnClause = returnClause
        self.location = location
    }
}

public struct InterfaceVarDecl: BindingDecl {
    public let name: Identifier
    public let typeAnnotation: TypeAnnotation
    public let location: SourceLocation
    
    public var type: any TypeRef {
        return typeAnnotation.type
    }
    public var description: String {
        return "\(name): \(typeAnnotation.description)"
    }
    
    public init(
        name: Identifier,
        typeAnnotation: TypeAnnotation,
        location: SourceLocation
    ) {
        self.name = name
        self.typeAnnotation = typeAnnotation
        self.location = location
    }
}

public struct InterfaceFile: ASTNode {
    public let declarations: [ClassDecl]
    public let location: SourceLocation
    
    public var description: String {
        ""
    }
    
    public init(declarations: [ClassDecl], location: SourceLocation) {
        self.declarations = declarations
        self.location = location
    }
}
