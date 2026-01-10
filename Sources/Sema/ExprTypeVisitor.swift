//
//  ExprTypeVisitor.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/01/2026.
//

import Foundation
import AST
import Diagnostics

struct ExprTypeVisitor: ExprVisitor {
    typealias Diag = Diagnostic
    let context: Context
    var type: CanonicalType?
    
    init(context: Context) {
        self.context = context
    }
    
    mutating func visit(_ expr: StringLiteralExpr) throws(Diag) {
        type = .string
    }
    
    mutating func visit(_ expr: IntegerLiteralExpr) throws(Diag) {
        type = .int
    }
    
    mutating func visit(_ expr: BoolLiteralExpr) throws(Diag) {
        type = .bool
    }
    
    mutating func visit(_ expr: DeclRefExpr) throws(Diag) {
        let member = try expr.member(context)
        guard let binding = member.decl as? BindingDecl else {
            throw SemaError.funcUsedAsValue(expr.name)
                .diagnostic(at: expr.location)
        }
        type = binding.canonicalType.resolved(member.selfType)
    }
    
    mutating func visit(_ expr: FuncCallExpr) throws(Diag) {
        let member = try expr.calledExpression.member(context)
        
        guard let funcDecl = member.decl as? FuncDecl else {
            let type = try context.typeSystem.typeCheck(
                expr.calledExpression,
                with: context
            )
            throw SemaError.cannotCallNonFunction(type.type)
                .diagnostic(at: expr.calledExpression.location)
        }
        
        let paramsCount = funcDecl.parameters.parameters.count
        let argumentsCount = expr.arguments.count
        for (index, param) in funcDecl.parameters.parameters.enumerated() {
            guard index < argumentsCount else {
                throw SemaError.argumentCountMismatch(
                    expected: paramsCount,
                    got: argumentsCount
                ).diagnostic(at: expr.location)
            }
            let argument = expr.arguments[index]
            let argumentType = try context.typeSystem.typeCheck(
                argument,
                with: context
            )
            
            let paramType = param.type.canonical.resolved(member.selfType)
            if !context.typeSystem.checkFlow(from: argumentType, into: paramType) {
                throw SemaError.argumentTypeMismatch(
                    expected: paramType.type,
                    got: argumentType.type
                ).diagnostic(at: argument.location)
            }
        }
        
        if argumentsCount > paramsCount {
            throw SemaError.argumentCountMismatch(
                expected: paramsCount,
                got: argumentsCount
            ).diagnostic(at: expr.location)
        }
        
        type = funcDecl.returnClause.type.canonical.resolved(member.selfType)
    }
    
    mutating func visit(_ expr: MemberAccessExpr) throws(Diag) {
        let member = try expr.member(context)
        guard let binding = member.decl as? BindingDecl else {
            let member = expr.member
            throw SemaError.funcUsedAsValue(member.name)
                .diagnostic(at: member.location)
        }
        type = binding.canonicalType.resolved(member.selfType)
    }
    
    mutating func visit(_ expr: StaticDispatchExpr) throws(Diag) {
        let baseType = try context.typeSystem.typeCheck(expr.base, with: context)
        guard let decl = context.typeSystem.lookup(type: baseType) else {
            throw SemaError.undefinedType(baseType.type)
                .diagnostic(at: expr.base.location)
        }
        let dispatchType = expr.type.canonical
        
        guard context.typeSystem.lookup(type: dispatchType) != nil else {
            throw SemaError.undefinedType(dispatchType.type)
                .diagnostic(at: expr.type.location)
        }
        
        if decl.canonicalType != dispatchType, decl.superclass(dispatchType) == nil {
            throw SemaError.invalidStaticDispatch(
                type: baseType.type,
                parent: expr.type.name
            ).diagnostic(at: expr.type.location)
        }
        type = expr.type.canonical.resolved(context.selfType)
    }
    
    mutating func visit(_ expr: IfExpr) throws(Diag) {
        let typeSystem = context.typeSystem
        let conditionType = try typeSystem.typeCheck(
            expr.condition,
            with: context
        )
        
        guard conditionType == .bool else {
            throw SemaError.conditionTypeMismatch(conditionType.type)
                .diagnostic(at: expr.condition.location)
        }
        
        let thenType = try typeSystem.typeCheck(expr.thenBody, with: context)
        let elseType = try typeSystem.typeCheck(expr.elseBody, with: context)
        
        type = typeSystem.joinedType(thenType, elseType)
    }
    
    mutating func visit(_ expr: WhileExpr) throws(Diag) {
        let typeSystem = context.typeSystem
        let conditionType = try typeSystem.typeCheck(
            expr.condition,
            with: context
        )
        
        guard conditionType == .bool else {
            throw SemaError.conditionTypeMismatch(conditionType.type)
                .diagnostic(at: expr.condition.location)
        }
        
        try typeSystem.typeCheck(expr.body, with: context)
        type = .object
    }
    
    mutating func visit(_ expr: CaseExpr) throws(Diag) {
        let typeSystem = context.typeSystem
        _ = try typeSystem.typeCheck(expr.expr, with: context)
        
        var resultType: CanonicalType?
        for branch in expr.branches {
            _ = try typeSystem.typeCheck(branch.binding, with: context)
            
            let bodyType = try typeSystem.typeCheck(
                branch.body,
                with: Context(
                    typeSystem: typeSystem,
                    scope: CaseBranchScope(
                        parentScope: context.scope,
                        binding: branch.binding
                    )
                )
            )
            
            resultType = resultType.map {
                typeSystem.joinedType($0, bodyType)
            } ?? bodyType
        }
        
        type = resultType!
    }
    
    mutating func visit(_ expr: LetExpr) throws(Diag) {
        let environment = LetExprScope.LetExprEnvironment()
        let scope = LetExprScope(
            parentScope: context.scope,
            environment: environment
        )
        for binding in expr.bindings {
            if environment.lookup(binding.name.canonical) != nil {
                throw SemaError.duplicateDeclaration(binding.name.value)
                    .diagnostic(at: binding.location)
            }
            try context.typeSystem.typeCheck(binding, scope: scope)
            environment.insert(binding)
        }
        
        type = try context.typeSystem.typeCheck(
            expr.body,
            with: context.scoped(to: scope)
        )
    }
    
    mutating func visit(_ expr: BlockExpr) throws(Diag) {
        assert(!expr.expressions.isEmpty, "Parser should reject empty blocks")
        
        var returnType: CanonicalType!
        for expression in expr.expressions {
            returnType = try context.typeSystem.typeCheck(expression, with: context)
        }
        type = returnType
    }
    
    mutating func visit(_ expr: OperationExpr) throws(Diag) {
        let lhsType = try context.typeSystem.typeCheck(expr.lhs, with: context)
        let rhsType = try context.typeSystem.typeCheck(expr.rhs, with: context)
        let op = expr.op
        
        if op.op == .equal, lhsType != rhsType, (lhsType.isBasicType || rhsType.isBasicType) {
            throw SemaError.binaryOperatorTypeMismatch(
                op: op.description,
                lhs: lhsType.type,
                rhs: rhsType.type
            ).diagnostic(at: op.location)
        } else if op.op != .equal, lhsType != .int || rhsType != .int {
            throw SemaError.binaryOperatorInvalidType(
                op: op.description,
                expected: "Int"
            ).diagnostic(at: op.location)
        }
        
        type = op.op.isComparison ? .bool: .int
    }
    
    mutating func visit(_ expr: AssignmentExpr) throws(Diag) {
        let target = expr.target
        let member = try target.member(context)
        guard let binding = member.decl as? BindingDecl else {
            throw SemaError.cannotAssignToFunc(member.decl.name.value)
                .diagnostic(at: target.location)
        }
        let varType = binding.canonicalType.resolved(member.selfType)
        let valueType = try context.typeSystem.typeCheck(expr.value, with: context)
        
        if !context.typeSystem.checkFlow(from: valueType, into: varType) {
            throw SemaError.assignmentTypeMismatch(
                expected: varType.type,
                got: valueType.type
            ).diagnostic(at: expr.value.location)
        }
        
        type = varType
    }
    
    mutating func visit(_ expr: NewExpr) throws(Diag) {
        let canonicalType = expr.type.canonical.resolved(context.selfType)
        if context.typeSystem.lookup(type: canonicalType) == nil {
            throw SemaError.undefinedType(expr.type.name)
                .diagnostic(at: expr.type.location)
        }
        type = canonicalType
    }
    
    mutating func visit(_ expr: NotExpr) throws(Diag) {
        let exprType = try context.typeSystem.typeCheck(
            expr.expression,
            with: context
        )
        guard exprType == .bool else {
            throw SemaError.unaryOperatorInvalidType(op: "not", expected: "Bool")
                .diagnostic(at: expr.expression.location)
        }
        type = .bool
    }
    
    mutating func visit(_ expr: IsVoidExpr) throws(Diag) {
        _ = try context.typeSystem.typeCheck(expr.expression, with: context)
        type = .bool
    }
    
    mutating func visit(_ expr: ComplementExpr) throws(Diagnostic) {
        let exprType = try context.typeSystem.typeCheck(
            expr.expression,
            with: context
        )
        guard exprType == .int else {
            throw SemaError.unaryOperatorInvalidType(op: "~", expected: "Int")
                .diagnostic(at: expr.expression.location)
        }
        type = .int
    }
}

extension BinaryOperator.Operator {
    fileprivate var isComparison: Bool {
        switch self {
            case .lessThan, .lessThanOrEqual, .equal:
                return true
            default:
                return false
        }
    }
}
