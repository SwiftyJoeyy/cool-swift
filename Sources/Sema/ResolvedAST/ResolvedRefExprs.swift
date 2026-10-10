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
    case localDecl(index: Int, base: DeclRefBase)
}

public enum DeclRefBase {
    case selfRef(ResolvedType), expr(any ResolvedExpr)
    
    public var type: ResolvedType {
        switch self {
            case .selfRef(let type): type
            case .expr(let resolvedExpr): resolvedExpr.type
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
    public let index: Int
    public let arguments: [any ResolvedExpr]
    public let base: DeclRefBase
    public let expr: any Expr
}

public struct ResolvedLiteralExpr: ResolvedExpr {
    public let type: ResolvedType
    public let value: String
    public let expr: any Expr
}


// For Decl ref with base = self:
// decl index
// decl name
// decl type
// base type

// For Decl ref with unknown base:
// decl index
// decl name
// decl type
// Resolved base Decl ref


// x.y.test().z.test2()
//
//let xx = ResolvedFuncCallExpr(
//    name: "test2",
//    type: ResolvedType(name: "String"),
//    arguments: [],
//    calledExpression: ResolvedDeclRefExpr(
//        name: "z",
//        type: ResolvedType(name: "Z"),
//        index: 1,
//        base: ResolvedFuncCallExpr(
//            name: "test",
//            type: ResolvedType(name: "Test"),
//            arguments: [],
//            calledExpression: ResolvedDeclRefExpr(
//                name: "y",
//                type: ResolvedType(name: "Y"),
//                index: 0,
//                base: ResolvedDeclRefExpr(
//                    name: "x",
//                    type: ResolvedType(name: "X"),
//                    index: 0,
//                    base: SelfDeclRefExpr(
//                        name: "self",
//                        type: ResolvedType(name: "Base")
//                    ),
//                ),
//            ),
//        ),
//    ),
//)
