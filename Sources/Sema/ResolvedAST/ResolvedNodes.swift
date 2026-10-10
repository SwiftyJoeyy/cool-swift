//
//  ResolvedType.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 12/09/2026.
//

import Foundation
import AST

public protocol ResolvedExpr {
    var type: ResolvedType { get }
    var expr: any Expr { get }
}

public protocol ResolvedDecl {
    var name: String { get }
    var type: ResolvedType { get }
    var decl: any Decl { get }
}

public struct ResolvedType: Hashable, Equatable, Sendable {
    public let name: String
}

public struct ResolvedSource {
    public let declarations: [ResolvedClassDecl]
}
