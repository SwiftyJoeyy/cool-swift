//
//  ResolvedRefExprs.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 12/09/2026.
//

public import AST
import Foundation

public struct ResolvedDeclRefExpr: ResolvedExpr {
    public let name: String
    public let type: ResolvedType
    public let refType: DeclRefType
    public let expr: any Expr
}

public enum DeclRefType {
    case parameter, letBinding, caseBranch, selfRef
    case localDecl(base: DeclRefBase)
}

public enum DeclRefBase {
    case selfRef(ResolvedType), expr(any ResolvedExpr)
    case staticDispatch(ResolvedStaticDispatchExpr)
    
    /// The type the member is looked up on.
    public var type: ResolvedType {
        switch self {
            case .selfRef(let type): type
            case .expr(let resolvedExpr): resolvedExpr.type
            case .staticDispatch(let dispatch): dispatch.type
        }
    }
}

public struct ResolvedStaticDispatchExpr: ResolvedExpr {
    public let base: any ResolvedExpr
    public let type: ResolvedType
    public let expr: any Expr
}

public struct ResolvedFuncCallExpr: ResolvedExpr {
    public let name: String
    public let type: ResolvedType
    public let arguments: [any ResolvedExpr]
    public let base: DeclRefBase
    public let expr: any Expr
}

public struct ResolvedLiteralExpr: ResolvedExpr {
    public enum Value {
        case int(Int32), bool(Bool), string(String)
    }
    
    public let value: Value
    public let expr: any Expr
    
    public var type: ResolvedType {
        switch value {
            case .int: .int
            case .bool: .bool
            case .string: .string
        }
    }
}
