//
//  ResolvedType+CoreTypes.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/09/2026.
//

import Foundation
import AST

extension ResolvedType {
    public static let selfType = ResolvedType(name: "SELF_TYPE")
    public static let object = ResolvedType(name: "Object")
    public static let io = ResolvedType(name: "IO")
    public static let int = ResolvedType(name: "Int")
    public static let bool = ResolvedType(name: "Bool")
    public static let string = ResolvedType(name: "String")
    public static let main = ResolvedType(name: "Main")
}

extension TypeRef {
    var resolved: ResolvedType {
        return ResolvedType(name: name)
    }
}

extension ClassDecl {
    var type: ResolvedType {
        return ResolvedType(name: name.value)
    }
}

extension FuncDecl {
    var returnType: ResolvedType {
        return returnClause.type.resolved
    }
}

extension ResolvedType {
    var isBasicType: Bool {
        return self == .int || self == .bool || self == .string
    }
}
