//
//  ResolvedType.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 12/09/2026.
//

public import AST
import Foundation

public protocol ResolvedExpr {
    var type: ResolvedType { get }
    var expr: any Expr { get }
}

public protocol ResolvedDecl {
    var name: String { get }
    var type: ResolvedType { get }
    var decl: any Decl { get }
}

public struct ResolvedType: Hashable, Equatable, Sendable, CustomStringConvertible {
    public let name: String
    public let isSelfType: Bool
    
    public var classType: ResolvedType {
        return ResolvedType(name: name)
    }
    
    public var description: String {
        return isSelfType ? "SELF_TYPE": name
    }
    
    init(name: String, isSelfType: Bool = false) {
        self.name = name
        self.isSelfType = isSelfType
    }
}

public struct ResolvedSource {
    public let declarations: [ResolvedClassDecl]
    public let interfaceDeclarations: [ResolvedInterfaceClassDecl]
}
