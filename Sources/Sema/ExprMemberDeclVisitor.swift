//
//  ExprMemberDeclVisitor.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 03/01/2026.
//

import Foundation
import AST
import Diagnostics

fileprivate struct ExprMemberDeclVisitor: ExprVisitor {
    typealias Diag = Diagnostic
    private let context: Context
    fileprivate var member: ScopedMember?
    
    fileprivate init(context: Context) {
        self.context = context
    }
    
    mutating func visit(_ expr: DeclRefExpr) throws(Diag) {
        guard let decl = context.scope.lookup(member: expr.canonical) else {
            throw SemaError.undefinedIdentifier(expr.name)
                .diagnostic(at: expr.location)
        }
//        if !decl.available {
//            throw SemaError.instanceMemberInPropertyInitializer(expr.name)
//                .diagnostic(at: expr.location)
//        }
        self.member = decl
    }
    
    mutating func visit(_ expr: MemberAccessExpr) throws(Diag) {
        let baseType = try context.typeSystem.typeCheck(
            expr.base,
            with: context
        )
        
        guard let decl = context.typeSystem.lookup(
            member: expr.member.canonical,
            on: baseType
        ) else {
            throw SemaError.undefinedMember(
                member: expr.member.name,
                baseType: baseType.type
            ).diagnostic(at: expr.member.location)
        }
        self.member = ScopedMember(decl, selfType: baseType)
    }
    
    mutating func visit(_ expr: StaticDispatchExpr) throws(Diag) { }
    mutating func visit(_ expr: StringLiteralExpr) throws(Diag) { }
    mutating func visit(_ expr: IntegerLiteralExpr) throws(Diag) { }
    mutating func visit(_ expr: BoolLiteralExpr) throws(Diag) { }
    mutating func visit(_ expr: FuncCallExpr) throws(Diag) { }
    mutating func visit(_ expr: IfExpr) throws(Diag) { }
    mutating func visit(_ expr: WhileExpr) throws(Diag) { }
    mutating func visit(_ expr: CaseExpr) throws(Diag) { }
    mutating func visit(_ expr: LetExpr) throws(Diag) { }
    mutating func visit(_ expr: BlockExpr) throws(Diag) { }
    mutating func visit(_ expr: OperationExpr) throws(Diag) { }
    mutating func visit(_ expr: AssignmentExpr) throws(Diag) { }
    mutating func visit(_ expr: NewExpr) throws(Diag) { }
    mutating func visit(_ expr: NotExpr) throws(Diag) { }
    mutating func visit(_ expr: IsVoidExpr) throws(Diag) { }
}

extension Expr {
    internal func member(_ context: Context) throws(Diagnostic) -> ScopedMember {
        var declVisitor = ExprMemberDeclVisitor(context: context)
        try accept(&declVisitor)
        guard let member = declVisitor.member else {
            fatalError()
        }
        return member
    }
}
