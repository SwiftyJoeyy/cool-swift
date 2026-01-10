//
//  Expr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation

public protocol ExprVisitor {
    associatedtype Diag: Error
    
    mutating func visit(_ expr: StringLiteralExpr) throws(Diag)
    mutating func visit(_ expr: IntegerLiteralExpr) throws(Diag)
    mutating func visit(_ expr: BoolLiteralExpr) throws(Diag)
    mutating func visit(_ expr: DeclRefExpr) throws(Diag)
    mutating func visit(_ expr: FuncCallExpr) throws(Diag)
    mutating func visit(_ expr: MemberAccessExpr) throws(Diag)
    mutating func visit(_ expr: StaticDispatchExpr) throws(Diag)
    mutating func visit(_ expr: IfExpr) throws(Diag)
    mutating func visit(_ expr: WhileExpr) throws(Diag)
    mutating func visit(_ expr: CaseExpr) throws(Diag)
    mutating func visit(_ expr: LetExpr) throws(Diag)
    mutating func visit(_ expr: BlockExpr) throws(Diag)
    mutating func visit(_ expr: OperationExpr) throws(Diag)
    mutating func visit(_ expr: AssignmentExpr) throws(Diag)
    mutating func visit(_ expr: NewExpr) throws(Diag)
    mutating func visit(_ expr: NotExpr) throws(Diag)
    mutating func visit(_ expr: IsVoidExpr) throws(Diag)
    mutating func visit(_ expr: ComplementExpr) throws(Diag)
}

public protocol Expr: ASTNode {
    func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag)
}
