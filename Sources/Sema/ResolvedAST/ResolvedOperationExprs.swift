//
//  ResolvedOperationExprs.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 12/09/2026.
//

import Foundation
import AST

public enum ResolvedBinaryOperator {
    case lessThan, lessThanOrEqual, plus, minus, slash, star, equal
}

public struct ResolvedOperationExpr: ResolvedExpr {
    public let type: ResolvedType
    public let lhs: any ResolvedExpr
    public let op: BinaryOperator
    public let rhs: any ResolvedExpr
    public let expr: any Expr
}

public struct ResolvedAssignmentExpr: ResolvedExpr {
    public let target: any ResolvedExpr
    public let value: any ResolvedExpr
    public let expr: any Expr
    
    public var type: ResolvedType {
        return target.type
    }
}

public struct ResolvedNewExpr: ResolvedExpr {
    public let type: ResolvedType
    public let expr: any Expr
}

public struct ResolvedNotExpr: ResolvedExpr {
    public let type: ResolvedType
    public let expression: any ResolvedExpr
    public let expr: any Expr
}

public struct ResolvedIsVoidExpr: ResolvedExpr {
    public let type: ResolvedType
    public let expression: any ResolvedExpr
    public let expr: any Expr
}

public struct ResolvedComplementExpr: ResolvedExpr {
    public let type: ResolvedType
    public let expression: any ResolvedExpr
    public let expr: any Expr
}
