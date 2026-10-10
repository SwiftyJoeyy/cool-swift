//
//  ResolvedType+CoreTypes.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/09/2026.
//

import Foundation
import AST

extension ResolvedType {
    static let selfType = ResolvedType(name: "SELF_TYPE")
    static let object = ResolvedType(name: "Object")
    static let io = ResolvedType(name: "IO")
    static let int = ResolvedType(name: "Int")
    static let bool = ResolvedType(name: "Bool")
    static let string = ResolvedType(name: "String")
    static let main = ResolvedType(name: "Main")
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
