//
//  ControlExpr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct IfExpr: Expr {
    public let condition: any Expr
    public let thenBody: any Expr
    public let elseBody: any Expr
    public let location: SourceLocation
}

public struct WhileExpr: Expr {
    public let condition: any Expr
    public let body: any Expr
    public let location: SourceLocation
}

public struct CaseExpr: Expr {
    public let expr: any Expr
    public let branches: [CaseBranchExpr]
    public let location: SourceLocation
}

public struct CaseBranchExpr: Expr {
    public let binding: VarDecl
    public let body: any Expr
    public let location: SourceLocation
}
