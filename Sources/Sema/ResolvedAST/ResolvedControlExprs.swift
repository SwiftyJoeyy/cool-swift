//
//  ResolvedControlExprs.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 12/09/2026.
//

import Foundation
public import AST

public struct ResolvedIfExpr: ResolvedExpr {
    public let type: ResolvedType
    public let condition: any ResolvedExpr
    public let thenBody: any ResolvedExpr
    public let elseBody: any ResolvedExpr
    public let expr: any Expr
}

public struct ResolvedWhileExpr: ResolvedExpr {
    public let type: ResolvedType
    public let condition: any ResolvedExpr
    public let body: any ResolvedExpr
    public let expr: any Expr
}

public struct ResolvedCaseExpr: ResolvedExpr {
    public let type: ResolvedType
    public let expression: any ResolvedExpr
    public let branches: [CaseBranch]
    public let expr: any Expr
    
    public struct CaseBranch {
        public let type: ResolvedType
        public let name: String
        public let body: any ResolvedExpr
    }
}

public struct ResolvedBlockExpr: ResolvedExpr {
    public let expressions: [any ResolvedExpr]
    public let expr: any Expr
    
    public var type: ResolvedType {
        return expressions.last!.type
    }
}

public struct ResolvedLetExpr: ResolvedExpr {
    public let bindings: [ResolvedVarDecl]
    public let body: any ResolvedExpr
    public let expr: any Expr
    
    public var type: ResolvedType {
        return body.type
    }
}
