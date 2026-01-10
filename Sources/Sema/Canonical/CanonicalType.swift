//
//  CanonicalType.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/12/2025.
//

import Foundation
import AST

internal struct CanonicalType: Canonical {
    internal let type: String
    internal var id: String {
        return type
    }
}

extension CanonicalType {
    static let selfType = CanonicalType(type: "SELF_TYPE")
    static let object = CanonicalType(type: "Object")
    static let io = CanonicalType(type: "IO")
    static let int = CanonicalType(type: "Int")
    static let bool = CanonicalType(type: "Bool")
    static let string = CanonicalType(type: "String")
}

extension TypeRef {
    internal var canonical: CanonicalType {
        return CanonicalType(type: name)
    }
}

extension ClassDecl {
    internal var canonicalType: CanonicalType {
        return CanonicalType(
            type: name.value
        )
    }
}

extension BindingDecl {
    internal var canonicalType: CanonicalType {
        return type.canonical
    }
}

extension CanonicalType {
    var isBasicType: Bool {
        return self == .int || self == .bool || self == .string
    }
}
