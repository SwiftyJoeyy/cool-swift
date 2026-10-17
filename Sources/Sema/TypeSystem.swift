//
//  TypeSystem.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/09/2026.
//

import Foundation
import AST
import Diagnostics

protocol TypeSystem {
    func typeCheck(_ symbol: ClassSymbol) throws(Diagnostic) -> ResolvedClassDecl
    
    func typeCheck(
        _ varDecl: VarDecl,
        scope: any Scope
    ) throws(Diagnostic) -> ResolvedVarDecl
    
    func typeCheck(
        _ funcDecl: FuncDecl,
        scope: any Scope
    ) throws(Diagnostic) -> ResolvedFuncDecl
    
    func typeCheck(
        _ expr: any Expr,
        scope: any Scope
    ) throws(Diagnostic) -> any ResolvedExpr
    
    
    
    func lookup(
        member: String,
        on type: ResolvedType
    ) -> SymbolMember?
    
    
    
    func checkType(
        _ type: any TypeRef,
        base: ResolvedType
    ) throws(Diagnostic) -> ResolvedType
    
    func conforms(_ type: ResolvedType, to supertype: ResolvedType) -> Bool
    
    func joinedType(
        _ type1: ResolvedType,
        _ type2: ResolvedType
    ) -> ResolvedType
}

struct DefaultTypeSystem: TypeSystem {
    private let symbols: SymbolTable
    
    init(symbols: SymbolTable) {
        self.symbols = symbols
    }
    
    func typeCheck(_ symbol: ClassSymbol) throws(Diagnostic) -> ResolvedClassDecl {
        let scope = ClassScope(symbol: symbol, typeSystem: self)
        var properties = [ResolvedVarDecl]()
        var methods = [ResolvedFuncDecl]()
        
        for member in symbol.members {
            switch member.kind {
                case .varDecl(let varDecl):
                    properties.append(try typeCheck(varDecl, scope: scope))
                case .funcDecl(let funcDecl):
                    methods.append(try typeCheck(funcDecl, scope: scope))
                default:
                    break
            }
        }
        
        return ResolvedClassDecl(
            name: symbol.decl.name.value,
            parent: symbol.superclass?.type ?? .object,
            properties: properties,
            methods: methods,
            decl: symbol.decl
        )
    }
    
    func typeCheck(
        _ varDecl: VarDecl,
        scope: any Scope
    ) throws(Diagnostic) -> ResolvedVarDecl {
        let type = try checkType(varDecl.typeAnnotation.type, base: scope.selfType)
        var initExpr: (any ResolvedExpr)?
        if let initializer = varDecl.initializer {
            let resolvedInit = try typeCheck(
                initializer.expr,
                scope: scope
            )
            if !conforms(resolvedInit.type, to: type) {
                throw SemaError.initializerTypeMismatch(
                    expected: type.description,
                    got: resolvedInit.type.description
                ).diagnostic(at: initializer.expr.location)
            }
            initExpr = resolvedInit
        }
        
        return ResolvedVarDecl(
            name: varDecl.name.value,
            type: type,
            initializer: initExpr,
            decl: varDecl
        )
    }
    
    func typeCheck(
        _ funcDecl: FuncDecl,
        scope: any Scope
    ) throws(Diagnostic) -> ResolvedFuncDecl {
        let returnType = try checkType(
            funcDecl.returnClause.type,
            base: scope.selfType
        )
        
        var params = [String: ResolvedParameterDecl]()
        var orderedParams = [ResolvedParameterDecl]()
        for param in funcDecl.parameters.parameters {
            if params[param.name.value] != nil {
                throw SemaError.duplicateDeclaration(param.name.value)
                    .diagnostic(at: param.name.location)
            }
            
            let resolvedType = try checkType(param.type, base: scope.baseType)
            let resolvedParam = ResolvedParameterDecl(
                name: param.name.value,
                type: resolvedType,
                decl: param
            )
            params[param.name.value] = resolvedParam
            orderedParams.append(resolvedParam)
        }
        let funcScope = FuncScope(parentScope: scope, parameters: params)
        let resolvedBody = try typeCheck(funcDecl.body, scope: funcScope)
        
        if !conforms(resolvedBody.type, to: returnType) {
            throw SemaError.initializerTypeMismatch(
                expected: returnType.description,
                got: resolvedBody.type.description
            ).diagnostic(at: funcDecl.body.location)
        }
        
        return ResolvedFuncDecl(
            name: funcDecl.name.value,
            type: returnType,
            parentType: scope.baseType,
            parameters: orderedParams,
            body: resolvedBody,
            decl: funcDecl
        )
    }
    
    func typeCheck(
        _ expr: any Expr,
        scope: any Scope
    ) throws(Diagnostic) -> any ResolvedExpr {
        var typeVisitor = ExprTypeVisitor(typeSystem: self, scope: scope)
        try expr.accept(&typeVisitor)
        guard let resolved = typeVisitor.resolvedExpr else {
            fatalError()
        }
        return resolved
    }
    
    func lookup(
        member: String,
        on type: ResolvedType
    ) -> SymbolMember? {
        return symbols.lookup(type)?.lookup(member)
    }
    
    func checkType(
        _ type: any TypeRef,
        base: ResolvedType
    ) throws(Diagnostic) -> ResolvedType {
        let resolved = type.resolved == .selfType ? base: type.resolved
        if symbols.lookup(resolved) == nil {
            throw SemaError.undefinedType(type.name)
                .diagnostic(at: type.location)
        }
        return resolved
    }
    
    func conforms(_ type: ResolvedType, to supertype: ResolvedType) -> Bool {
        if type == supertype || supertype == .object {
            return true
        }
        if supertype.isSelfType {
            return false
        }
        if type.classType == supertype {
            return true
        }
        var parent = symbols.lookup(type)?.superclass
        while parent != nil {
            if parent?.type == supertype {
                return true
            }
            parent = parent?.superclass
        }
        return false
    }
    
    func joinedType(
        _ type1: ResolvedType,
        _ type2: ResolvedType
    ) -> ResolvedType {
        if type1 == type2 {
            return type1
        }
        let type1 = type1.classType
        let type2 = type2.classType
        if type1 == type2 {
            return type1
        }
        var symbol1 = symbols.lookup(type1)?.superclass
        var symbol2 = symbols.lookup(type2)?.superclass
        var types: Set<ResolvedType> = [type1, type2]
        
        while let t1 = symbol1?.type, let t2 = symbol2?.type {
            if !types.insert(t1).inserted {
                return t1
            }
            if !types.insert(t2).inserted {
                return t2
            }
            symbol1 = symbol1?.superclass
            symbol2 = symbol2?.superclass
        }
        return .object
    }
}
