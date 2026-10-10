//
//  ResolvedDecls.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 12/09/2026.
//

import Foundation
public import AST

public struct ResolvedClassDecl: ResolvedDecl {
    public let name: String
    public let parent: ResolvedType
    public let properties: [ResolvedVarDecl]
    public let methods: [ResolvedFuncDecl]
    public let decl: any Decl
    
    public var type: ResolvedType {
        return ResolvedType(name: name)
    }
}

public struct ResolvedVarDecl: ResolvedDecl {
    public let name: String
    public let type: ResolvedType
    public let initializer: (any ResolvedExpr)?
    public let decl: any Decl
}

public struct ResolvedFuncDecl: ResolvedDecl {
    public let name: String
    public let type: ResolvedType
    public let parentType: ResolvedType
    public let parameters: [ResolvedParameterDecl]
    public let body: any ResolvedExpr
    public let decl: any Decl
}

public struct ResolvedParameterDecl: ResolvedDecl {
    public let name: String
    public let type: ResolvedType
    public let decl: any Decl
}
