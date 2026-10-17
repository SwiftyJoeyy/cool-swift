//
//  ExprIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import AST
import Basic
import Foundation
import Sema

struct ExprIRGenerator {
    private var scopes: [[String: String]]
    let function: IRFunction
    let context: IRContext
    let boxing: BoxingIRGenerator
    let selfType: String
    
    init(
        function: IRFunction,
        context: IRContext,
        selfType: String,
        locals: [String: String] = [:]
    ) {
        self.function = function
        self.context = context
        self.boxing = BoxingIRGenerator(function: function, strings: context.strings)
        self.selfType = selfType
        self.scopes = [locals]
    }
    
    mutating func generate(_ expr: any ResolvedExpr) -> String {
        switch expr {
            case let expr as ResolvedLiteralExpr:
                return visit(expr)
            case let expr as ResolvedDeclRefExpr:
                return visit(expr)
            case let expr as ResolvedFuncCallExpr:
                return visit(expr)
            case let expr as ResolvedStaticDispatchExpr:
                return visit(expr)
            case let expr as ResolvedNewExpr:
                return visit(expr)
            case let expr as ResolvedIfExpr:
                return visit(expr)
            case let expr as ResolvedWhileExpr:
                return visit(expr)
            case let expr as ResolvedCaseExpr:
                return visit(expr)
            case let expr as ResolvedLetExpr:
                return visit(expr)
            case let expr as ResolvedBlockExpr:
                return visit(expr)
            case let expr as ResolvedOperationExpr:
                return visit(expr)
            case let expr as ResolvedAssignmentExpr:
                return visit(expr)
            case let expr as ResolvedNotExpr:
                return visit(expr)
            case let expr as ResolvedIsVoidExpr:
                return visit(expr)
            case let expr as ResolvedComplementExpr:
                return visit(expr)
            default:
                fatalError("Unsupported expression \(type(of: expr))")
        }
    }
    
    // MARK: - References
    private func visit(_ expr: ResolvedLiteralExpr) -> String {
        switch expr.value {
            case .int(let value):
                return boxing.boxInt("\(value)")
            case .bool(let value):
                return boxing.boxBool("\(value)")
            case .string(let value):
                return boxing.boxString(value)
        }
    }
    
    private mutating func visit(_ expr: ResolvedDeclRefExpr) -> String {
        if case .selfRef = expr.refType {
            return "%self"
        }
        return function.value("load ptr, ptr \(address(of: expr))")
    }
    
    private mutating func visit(_ expr: ResolvedStaticDispatchExpr) -> String {
        return generate(expr.base)
    }
    
    // MARK: - Dispatch
    private mutating func visit(_ expr: ResolvedFuncCallExpr) -> String {
        var arguments = [String]()
        for argument in expr.arguments {
            arguments.append(generate(argument))
        }
        
        if case .staticDispatch(let dispatch) = expr.base {
            let object = generate(dispatch.base)
            checkNotVoid(object, "Dispatch to void", at: expr)
            let method = context.classes[dispatch.type.name].slot(of: expr.name).method
            let argumentList = function.argumentList(object, arguments)
            return function.value("call ptr \(IRName.method(method))(\(argumentList))")
        }
        
        let object = receiver(expr.base, at: expr, ifVoid: "Dispatch to void")
        let layout = context.classes[expr.base.type.name]
        return function.virtualCall(expr.name, on: object, in: layout, arguments: arguments)
    }
    
    private func visit(_ expr: ResolvedNewExpr) -> String {
        guard expr.type.isSelfType else {
            return function.value("call ptr \(IRName.constructor(expr.type.name))()")
        }
        let constructor = function.loadVTableEntry(
            of: "%self",
            in: context.classes[selfType],
            slot: RuntimeABI.VTableSlot.constructor
        )
        return function.value("call ptr \(constructor)()")
    }
    
    // MARK: - Control Flow
    private mutating func visit(_ expr: ResolvedIfExpr) -> String {
        let thenLabel = function.label("if.then")
        let elseLabel = function.label("if.else")
        let endLabel = function.label("if.end")
        
        let condition = boxing.unboxBool(generate(expr.condition))
        function.emit("br i1 \(condition), label %\(thenLabel), label %\(elseLabel)")
        
        function.startBlock(thenLabel)
        let thenValue = generate(expr.thenBody)
        let thenBlock = function.block
        function.emit("br label %\(endLabel)")
        
        function.startBlock(elseLabel)
        let elseValue = generate(expr.elseBody)
        let elseBlock = function.block
        function.emit("br label %\(endLabel)")
        
        function.startBlock(endLabel)
        return function.value(
            "phi ptr [ \(thenValue), %\(thenBlock) ], [ \(elseValue), %\(elseBlock) ]"
        )
    }
    
    private mutating func visit(_ expr: ResolvedWhileExpr) -> String {
        let conditionLabel = function.label("while.cond")
        let bodyLabel = function.label("while.body")
        let endLabel = function.label("while.end")
        function.emit("br label %\(conditionLabel)")
        
        function.startBlock(conditionLabel)
        let condition = boxing.unboxBool(generate(expr.condition))
        function.emit("br i1 \(condition), label %\(bodyLabel), label %\(endLabel)")
        
        function.startBlock(bodyLabel)
        _ = generate(expr.body)
        function.emit("br label %\(conditionLabel)")
        
        function.startBlock(endLabel)
        return "null"
    }
    
    private mutating func visit(_ expr: ResolvedCaseExpr) -> String {
        let object = generate(expr.expression)
        checkNotVoid(object, "Match on void in case statement", at: expr)
        
        let loopLabel = function.label("case.loop")
        let parentLabel = function.label("case.parent")
        let noMatchLabel = function.label("case.nomatch")
        let endLabel = function.label("case.end")
        let checkLabels = expr.branches.map { _ in function.label("case.check") }
        let branchLabels = expr.branches.map { _ in function.label("case.branch") }
        
        let cursor = function.alloca()
        function.emit("store ptr \(function.value("load ptr, ptr \(object)")), ptr \(cursor)")
        function.emit("br label %\(loopLabel)")
        
        function.startBlock(loopLabel)
        let vtable = function.value("load ptr, ptr \(cursor)")
        let exhausted = function.value("icmp eq ptr \(vtable), null")
        function.emit(
            "br i1 \(exhausted), label %\(noMatchLabel), label %\(checkLabels.first ?? parentLabel)"
        )
        
        for (index, branch) in expr.branches.enumerated() {
            function.startBlock(checkLabels[index])
            let branchVTable = IRName.vtable(context.classes[branch.type.name])
            let matches = function.value("icmp eq ptr \(vtable), \(branchVTable)")
            let next = index + 1 < checkLabels.count ? checkLabels[index + 1]: parentLabel
            function.emit("br i1 \(matches), label %\(branchLabels[index]), label %\(next)")
        }
        
        function.startBlock(parentLabel)
        let parent = function.value("load ptr, ptr \(vtable)")
        function.emit("store ptr \(parent), ptr \(cursor)")
        function.emit("br label %\(loopLabel)")
        
        function.startBlock(noMatchLabel)
        fail("No match in case statement", at: expr)
        
        var incoming = [String]()
        for (index, branch) in expr.branches.enumerated() {
            function.startBlock(branchLabels[index])
            let binding = function.alloca()
            function.emit("store ptr \(object), ptr \(binding)")
            
            scopes.append([branch.name: binding])
            let value = generate(branch.body)
            scopes.removeLast()
            
            incoming.append("[ \(value), %\(function.block) ]")
            function.emit("br label %\(endLabel)")
        }
        
        function.startBlock(endLabel)
        return function.value("phi ptr \(incoming.joined(separator: ", "))")
    }
    
    private mutating func visit(_ expr: ResolvedLetExpr) -> String {
        scopes.append([:])
        for binding in expr.bindings {
            // The initializer can't see the binding it initializes.
            let value = binding.initializer.map { generate($0) }
            ?? boxing.defaultValue(for: binding.type)
            let slot = function.alloca()
            function.emit("store ptr \(value), ptr \(slot)")
            scopes[scopes.count - 1][binding.name] = slot
        }
        let value = generate(expr.body)
        scopes.removeLast()
        return value
    }
    
    private mutating func visit(_ expr: ResolvedBlockExpr) -> String {
        var value = "null"
        for expression in expr.expressions {
            value = generate(expression)
        }
        return value
    }
    
    // MARK: - Operations
    private mutating func visit(_ expr: ResolvedOperationExpr) -> String {
        if expr.op == .equal {
            let lhs = generate(expr.lhs)
            let rhs = generate(expr.rhs)
            return boxing.boxBool(function.value("call i1 @cool.equals(ptr \(lhs), ptr \(rhs))"))
        }
        
        let lhs = boxing.unboxInt(generate(expr.lhs))
        let rhs = boxing.unboxInt(generate(expr.rhs))
        switch expr.op {
            case .plus:
                return boxing.boxInt(function.value("add i32 \(lhs), \(rhs)"))
            case .minus:
                return boxing.boxInt(function.value("sub i32 \(lhs), \(rhs)"))
            case .star:
                return boxing.boxInt(function.value("mul i32 \(lhs), \(rhs)"))
            case .slash:
                check(function.value("icmp eq i32 \(rhs), 0"), "Division by zero", at: expr)
                return boxing.boxInt(function.value("sdiv i32 \(lhs), \(rhs)"))
            case .lessThan:
                return boxing.boxBool(function.value("icmp slt i32 \(lhs), \(rhs)"))
            case .lessThanOrEqual:
                return boxing.boxBool(function.value("icmp sle i32 \(lhs), \(rhs)"))
            case .equal:
                fatalError("Handled above")
        }
    }
    
    private mutating func visit(_ expr: ResolvedAssignmentExpr) -> String {
        let value = generate(expr.value)
        function.emit("store ptr \(value), ptr \(address(of: expr.target))")
        return value
    }
    
    private mutating func visit(_ expr: ResolvedNotExpr) -> String {
        let value = boxing.unboxBool(generate(expr.expression))
        return boxing.boxBool(function.value("xor i1 \(value), true"))
    }
    
    private mutating func visit(_ expr: ResolvedIsVoidExpr) -> String {
        let value = generate(expr.expression)
        return boxing.boxBool(function.value("icmp eq ptr \(value), null"))
    }
    
    private mutating func visit(_ expr: ResolvedComplementExpr) -> String {
        let value = boxing.unboxInt(generate(expr.expression))
        return boxing.boxInt(function.value("sub i32 0, \(value)"))
    }
    
    // MARK: - Locations
    private mutating func address(of expr: ResolvedDeclRefExpr) -> String {
        switch expr.refType {
            case .selfRef:
                fatalError("'self' has no address, Sema should reject assigning to it")
            case .parameter, .letBinding, .caseBranch:
                return local(named: expr.name)
            case .localDecl(let base):
                let object = receiver(base, at: expr, ifVoid: "Attribute access on void")
                let layout = context.classes[base.type.name]
                let index = layout.fieldIndex(of: expr.name)
                return function.fieldAddress(of: object, in: layout, index: index)
        }
    }
    
    private mutating func receiver(
        _ base: DeclRefBase,
        at expr: any ResolvedExpr,
        ifVoid message: String
    ) -> String {
        switch base {
            case .selfRef:
                return "%self"
            case .expr(let baseExpr):
                let object = generate(baseExpr)
                checkNotVoid(object, message, at: expr)
                return object
            case .staticDispatch(let dispatch):
                let object = generate(dispatch.base)
                checkNotVoid(object, message, at: expr)
                return object
        }
    }
    
    private func local(named name: String) -> String {
        guard let slot = scopes.reversed().lazy.compactMap({$0[name]}).first else {
            fatalError("No local named '\(name)'")
        }
        return slot
    }
    
    // MARK: - Runtime Errors
    private func checkNotVoid(_ object: String, _ message: String, at expr: any ResolvedExpr) {
        guard object != "%self" else { return }
        check(function.value("icmp eq ptr \(object), null"), message, at: expr)
    }
    
    private func check(_ condition: String, _ message: String, at expr: any ResolvedExpr) {
        let failLabel = function.label("error")
        let continueLabel = function.label("ok")
        function.emit("br i1 \(condition), label %\(failLabel), label %\(continueLabel)")
        
        function.startBlock(failLabel)
        fail(message, at: expr)
        
        function.startBlock(continueLabel)
    }
    
    private func fail(_ message: String, at expr: any ResolvedExpr) {
        let location = expr.expr.location
        let text = "\(location.file):\(location.line): \(message)"
        function.emit("call void @cool.error(ptr \(context.strings.global(for: text)))")
        function.emit("unreachable")
    }
}
