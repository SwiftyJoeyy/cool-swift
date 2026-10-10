//
//  ExprTypeVisitor.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/09/2026.
//

import Foundation
import AST
import Diagnostics

struct ExprTypeVisitor: ExprVisitor {
    typealias Diag = Diagnostic
    let typeSystem: any TypeSystem
    let scope: any Scope
    private(set) var resolvedExpr: any ResolvedExpr?
    
    mutating func visit(_ expr: StringLiteralExpr) throws(Diag) {
        resolvedExpr = ResolvedLiteralExpr(
            type: .string,
            value: expr.value,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: IntegerLiteralExpr) throws(Diag) {
        resolvedExpr = ResolvedLiteralExpr(
            type: .int,
            value: expr.value,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: BoolLiteralExpr) throws(Diag) {
        resolvedExpr = ResolvedLiteralExpr(
            type: .bool,
            value: expr.value,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: DeclRefExpr) throws(Diag) {
        resolvedExpr = try resolvedRefExpr(expr) { refType, refExpr throws(Diag) in
            guard case .localDecl(let member) = refType,
                  case .funcDecl = member.decl.kind
            else { return }
            throw SemaError.funcUsedAsValue(refExpr.name)
                .diagnostic(at: refExpr.location)
        }
    }
    
    mutating func visit(_ expr: FuncCallExpr) throws(Diag) {
        let (base, member, refExpr) = try declMember(from: expr.calledExpression)
        guard case .localDecl(let symbolMember) = member.refType,
              let funcDecl = symbolMember.decl.kind.decl as? (any MethodDecl)
        else {
            throw SemaError.cannotCallNonFunction(refExpr.name)
                .diagnostic(at: refExpr.location)
        }
        let paramsCount = funcDecl.parameters.parameters.count
        let argumentsCount = expr.arguments.count
        guard paramsCount == argumentsCount else {
            throw SemaError.argumentCountMismatch(
                expected: paramsCount,
                got: argumentsCount
            ).diagnostic(at: expr.location)
        }
        
        var arguments = [any ResolvedExpr]()
        for (index, param) in funcDecl.parameters.parameters.enumerated() {
            let argument = expr.arguments[index]
            let resolvedArg = try typeSystem.typeCheck(argument, scope: scope)
            
            let paramType = try typeSystem.checkType(param.type, base: base.type)
            if !typeSystem.conforms(resolvedArg.type, to: paramType) {
                throw SemaError.argumentTypeMismatch(
                    expected: paramType.name,
                    got: resolvedArg.type.name
                ).diagnostic(at: argument.location)
            }
            arguments.append(resolvedArg)
        }
        
        let returnType = funcDecl.returnClause.type
        let type = try typeSystem.checkType(returnType, base: base.type)
        resolvedExpr = ResolvedFuncCallExpr(
            name: funcDecl.name.value,
            type: type,
            index: symbolMember.index,
            arguments: arguments,
            base: base,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: MemberAccessExpr) throws(Diag) {
        resolvedExpr = try resolvedRefExpr(expr) { refType, refExpr throws(Diag) in
            guard case .localDecl(let member) = refType,
                  case .funcDecl = member.decl.kind
                    else { return }
            throw SemaError.funcUsedAsValue(refExpr.name)
                .diagnostic(at: refExpr.location)
        }
    }
    
    mutating func visit(_ expr: StaticDispatchExpr) throws(Diag) {
        let resolvedBase = try typeSystem.typeCheck(
            expr.base,
            scope: scope
        )
        let dispatchType = try typeSystem.checkType(expr.type, base: scope.baseType)
        guard typeSystem.conforms(resolvedBase.type, to: dispatchType) else {
            throw SemaError.invalidStaticDispatch(
                type: resolvedBase.type.name,
                parent: expr.type.name
            ).diagnostic(at: expr.type.location)
        }
        resolvedExpr = ResolvedStaticDispatchExpr(
            base: resolvedBase,
            type: dispatchType,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: IfExpr) throws(Diag) {
        let resolvedCondition = try typeSystem.typeCheck(
            expr.condition,
            scope: scope
        )
        guard resolvedCondition.type == .bool else {
            throw SemaError.conditionTypeMismatch(resolvedCondition.type.name)
                .diagnostic(at: expr.condition.location)
        }
        
        let resolvedThen = try typeSystem.typeCheck(expr.thenBody, scope: scope)
        let resolvedElse = try typeSystem.typeCheck(expr.elseBody, scope: scope)
        resolvedExpr = ResolvedIfExpr(
            type: typeSystem.joinedType(resolvedThen.type, resolvedElse.type),
            condition: resolvedCondition,
            thenBody: resolvedThen,
            elseBody: resolvedElse,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: WhileExpr) throws(Diag) {
        let resolvedCondition = try typeSystem.typeCheck(
            expr.condition,
            scope: scope
        )
        guard resolvedCondition.type == .bool else {
            throw SemaError.conditionTypeMismatch(resolvedCondition.type.name)
                .diagnostic(at: expr.condition.location)
        }
        
        let resolvedBody = try typeSystem.typeCheck(expr.body, scope: scope)
        resolvedExpr = ResolvedWhileExpr(
            type: .object,
            condition: resolvedCondition,
            body: resolvedBody,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: CaseExpr) throws(Diag) {
        let expression = try typeSystem.typeCheck(expr.expression, scope: scope)
        
        var resultType: ResolvedType?
        var branches = [ResolvedCaseExpr.CaseBranch]()
        for branch in expr.branches {
            let type = branch.binding.type
            let name = branch.binding.name
            let branchType = try typeSystem.checkType(type, base: scope.baseType)
            let resolvedBody = try typeSystem.typeCheck(
                branch.body,
                scope: CaseBranchScope(
                    parentScope: scope,
                    name: name.value,
                    type: branchType
                )
            )
            
            resultType = resultType.map {
                typeSystem.joinedType($0, resolvedBody.type)
            } ?? resolvedBody.type
            
            branches.append(
                ResolvedCaseExpr.CaseBranch(
                    type: branchType,
                    name: name.value,
                    body: resolvedBody
                )
            )
        }
        
        resolvedExpr = ResolvedCaseExpr(
            type: resultType!,
            expression: expression,
            branches: branches,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: LetExpr) throws(Diag) {
        let environment = LetScope.Environment()
        let scope = LetScope(
            parentScope: scope,
            environment: environment
        )
        
        var resolvedBindings = [ResolvedVarDecl]()
        for binding in expr.bindings {
            if environment.lookup(binding.name.value) != nil {
                throw SemaError.duplicateDeclaration(binding.name.value)
                    .diagnostic(at: binding.location)
            }
            resolvedBindings.append(try typeSystem.typeCheck(binding, scope: scope))
            environment.insert(binding)
        }
        
        let resolvedBody = try typeSystem.typeCheck(expr.body, scope: scope)
        resolvedExpr = ResolvedLetExpr(
            bindings: resolvedBindings,
            body: resolvedBody,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: BlockExpr) throws(Diag) {
        assert(!expr.expressions.isEmpty, "Parser should reject empty blocks")
        
        var expressions = [any ResolvedExpr]()
        for expression in expr.expressions {
            expressions.append(try typeSystem.typeCheck(expression, scope: scope))
        }
        resolvedExpr = ResolvedBlockExpr(
            expressions: expressions,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: OperationExpr) throws(Diag) {
        let resolvedLHS = try typeSystem.typeCheck(expr.lhs, scope: scope)
        let lhsType = resolvedLHS.type
        let resolvedRHS = try typeSystem.typeCheck(expr.rhs, scope: scope)
        let rhsType = resolvedRHS.type
        let op = expr.op
        
        if op.op == .equal, lhsType != rhsType, (lhsType.isBasicType || rhsType.isBasicType) {
            throw SemaError.binaryOperatorTypeMismatch(
                op: op.description,
                lhs: lhsType.name,
                rhs: rhsType.name
            ).diagnostic(at: op.location)
        } else if op.op != .equal, lhsType != .int || rhsType != .int {
            throw SemaError.binaryOperatorInvalidType(
                op: op.description,
                expected: "Int"
            ).diagnostic(at: op.location)
        }
        
        resolvedExpr = ResolvedOperationExpr(
            type: op.op.isComparison ? .bool: .int,
            lhs: resolvedLHS,
            op: op,
            rhs: resolvedRHS,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: AssignmentExpr) throws(Diag) {
        let resolvedTarget = try resolvedRefExpr(expr.target) { refType, refExpr throws(Diag) in
            guard case .localDecl(let member) = refType,
                  case .funcDecl = member.decl.kind
                    else { return }
            throw SemaError.cannotAssignToFunc(refExpr.name)
                .diagnostic(at: refExpr.location)
        }
        
        let resolvedValue = try typeSystem.typeCheck(expr.value, scope: scope)
        guard typeSystem.conforms(resolvedValue.type, to: resolvedTarget.type) else {
            throw SemaError.assignmentTypeMismatch(
                expected: resolvedTarget.type.name,
                got: resolvedValue.type.name
            ).diagnostic(at: expr.value.location)
        }
        resolvedExpr = ResolvedAssignmentExpr(
            target: resolvedTarget,
            value: resolvedValue,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: NewExpr) throws(Diag) {
        let resolvedType = try typeSystem.checkType(expr.type, base: scope.baseType)
        resolvedExpr = ResolvedNewExpr(
            type: resolvedType,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: NotExpr) throws(Diag) {
        let expression = try typeSystem.typeCheck(expr.expression, scope: scope)
        guard expression.type == .bool else {
            throw SemaError.unaryOperatorInvalidType(op: "not", expected: "Bool")
                .diagnostic(at: expr.expression.location)
        }
        resolvedExpr = ResolvedNotExpr(
            type: .bool,
            expression: expression,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: IsVoidExpr) throws(Diag) {
        let expression = try typeSystem.typeCheck(expr.expression, scope: scope)
        resolvedExpr = ResolvedIsVoidExpr(
            type: .bool,
            expression: expression,
            expr: expr
        )
    }
    
    mutating func visit(_ expr: ComplementExpr) throws(Diagnostic) {
        let expression = try typeSystem.typeCheck(expr.expression, scope: scope)
        guard expression.type == .int else {
            throw SemaError.unaryOperatorInvalidType(op: "~", expected: "Int")
                .diagnostic(at: expr.expression.location)
        }
        resolvedExpr = ResolvedComplementExpr(
            type: .int,
            expression: expression,
            expr: expr
        )
    }
    
    private func resolvedRefExpr(
        _ expr: any Expr,
        validate: (ScopedMember.RefType, DeclRefExpr) throws(Diag) -> Void
    ) throws(Diag) -> ResolvedDeclRefExpr {
        let (base, member, refExpr) = try declMember(from: expr)
        
        try validate(member.refType, refExpr)
        let refType: DeclRefType = switch member.refType {
            case .parameter: .parameter
            case .letBinding: .letBinding
            case .caseBranch: .caseBranch
            case .selfRef: .selfRef
            case .localDecl(let member): .localDecl(index: member.index, base: base)
        }
        return ResolvedDeclRefExpr(
            name: member.name,
            type: member.type,
            refType: refType,
            expr: expr
        )
    }
    
    private func declMember(
        from expr: any Expr
    ) throws(Diag) -> (base: DeclRefBase, member: ScopedMember, expr: DeclRefExpr) {
        if let refExpr = expr as? DeclRefExpr {
            if refExpr.name == "self" {
                return (.selfRef(scope.baseType), ScopedMember(name: "self", type: scope.baseType, refType: .selfRef), refExpr)
            }
            guard let member = try scope.lookup(member: refExpr.name) else {
                throw SemaError.undefinedIdentifier(refExpr.name)
                    .diagnostic(at: expr.location)
            }
            return (.selfRef(scope.baseType), member, refExpr)
        } else if let accessExpr = expr as? MemberAccessExpr {
            let resolvedBase = try typeSystem.typeCheck(
                accessExpr.base,
                scope: scope
            )
            guard let symbolMember = typeSystem.lookup(
                member: accessExpr.member.name,
                on: resolvedBase.type
            ) else {
                throw SemaError.undefinedMember(
                    member: accessExpr.member.name,
                    baseType: resolvedBase.type.name
                ).diagnostic(at: accessExpr.member.location)
            }
            
            let type = try typeSystem.checkType(symbolMember.decl.type, base: symbolMember.parent)
            let member = ScopedMember(
                name: symbolMember.decl.name.value,
                type: type,
                refType: .localDecl(symbolMember)
            )
            return (.expr(resolvedBase), member, accessExpr.member)
        }
        
        fatalError()
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
