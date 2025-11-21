//
//  OperationExpr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public protocol OperatorExpr: ASTNode {
    
}

public struct OperationExpr: Expr {
    public let lhs: any Expr
    public let exprOperator: OperatorExpr
    public let rhs: any Expr
    public let location: SourceLocation
}

public struct NewExpr: Expr {
    public let type: any TypeRef
    public let location: SourceLocation
}

public struct NotExpr: Expr {
    public let expression: any Expr
    public let location: SourceLocation
}

public struct IsVoidExpr: Expr {
    public let expression: any Expr
    public let location: SourceLocation
}
