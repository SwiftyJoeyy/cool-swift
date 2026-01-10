//
//  TypeSystem.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 30/12/2025.
//

import Foundation
import AST
import Basic
import Diagnostics

struct Context {
    let typeSystem: TypeSystem
    let scope: Scope
    
    var selfType: CanonicalType {
        return scope.selfType
    }
    
    func scoped(to scope: some Scope) -> Self {
        return Context(typeSystem: typeSystem, scope: scope)
    }
}

struct TypeSystem {
    let symbols: SymbolTable
    
    func checkFlow(
        from type: CanonicalType,
        into supertype: CanonicalType
    ) -> Bool {
        if type == supertype || supertype == .object {
            return true
        }
        return symbols.lookup(type)?.superclass(supertype) != nil
    }
    
    func joinedType(
        _ type1: CanonicalType,
        _ type2: CanonicalType
    ) -> CanonicalType {
        if type1 == type2 {
            return type1
        }
        var symbol1 = symbols.lookup(type1)
        var symbol2 = symbols.lookup(type2)
        
        while let symbol1V = symbol1, let symbol2V = symbol2 {
            let canType1 = symbol1V.canonicalType
            let canType2 = symbol2V.canonicalType
            
            if canType1 == canType2 {
                return canType1
            } else if canType1 == symbol2V.superclass?.canonicalType {
                return canType1
            } else if canType2 == symbol1V.superclass?.canonicalType {
                return canType2
            }
            symbol1 = symbol1?.superclass
            symbol2 = symbol2?.superclass
        }
        return .object
    }
    
    func lookup(type: CanonicalType) -> ClassSymbol? {
        return symbols.lookup(type)
    }
    
    func lookup(
        member: CanonicalIdentifier,
        on type: CanonicalType
    ) -> (any Decl)? {
        return symbols.lookup(type)?.lookup(member)?.decl
    }
    
    private func checkExistence(
        of type: CanonicalType,
        loc: SourceLocation
    ) throws(Diagnostic) {
        if type == .selfType { return }
        if lookup(type: type) == nil {
            throw SemaError.undefinedType(type.type)
                .diagnostic(at: loc)
        }
    }
}

extension TypeSystem {
    @discardableResult func typeCheck(
        _ expr: some Expr,
        with context: Context
    ) throws(Diagnostic) -> CanonicalType {
        var typeVisitor = ExprTypeVisitor(context: context)
        try expr.accept(&typeVisitor)
        guard let type = typeVisitor.type else {
            fatalError()
        }
        return type.resolved(context.selfType)
    }
    
    func typeCheck(_ symbol: ClassSymbol) throws(Diagnostic) {
        for member in symbol.members {
            switch member.kind {
                case .varDecl(let varDecl):
                    try typeCheck(varDecl, scope: VarDeclScope(symbol: symbol))
                case .funcDecl(let funcDecl):
                    try typeCheck(funcDecl, symbol: symbol)
                default:
                    break
            }
        }
    }
    
    func typeCheck(_ funcDecl: FuncDecl, symbol: ClassSymbol) throws(Diagnostic) {
        var params = [CanonicalIdentifier: ParameterDecl]()
        for param in funcDecl.parameters.parameters {
            if params[param.name.canonical] != nil {
                throw SemaError.duplicateDeclaration(param.name.value)
                    .diagnostic(at: param.name.location)
            }
            
            let loc = param.type.location
            try checkExistence(of: param.type.canonical, loc: loc)
            params[param.name.canonical] = param
        }
        
        let loc = funcDecl.returnClause.type.location
        let returnType = funcDecl.returnClause.type.canonical
            .resolved(symbol.canonicalType)
        try checkExistence(of: returnType, loc: loc)
        
        let bodyType = try typeCheck(
            funcDecl.body,
            with: Context(
                typeSystem: self,
                scope: FuncDeclScope(symbol: symbol, parameters: params)
            )
        )
        
        if !checkFlow(from: bodyType, into: returnType) {
            throw SemaError.initializerTypeMismatch(
                expected: returnType.type,
                got: bodyType.type
            ).diagnostic(at: funcDecl.body.location)
        }
    }
    
    @discardableResult func typeCheck(
        _ varDecl: VarDecl,
        scope: any Scope
    ) throws(Diagnostic) -> CanonicalType {
        let loc = varDecl.typeAnnotation.location
        let type = varDecl.canonicalType.resolved(scope.selfType)
        try checkExistence(of: type, loc: loc)
        
        guard let initializer = varDecl.initializer else {
            return type
        }
        let initType = try typeCheck(
            initializer.expr,
            with: Context(typeSystem: self, scope: scope)
        )
        if !checkFlow(from: initType, into: type) {
            throw SemaError.initializerTypeMismatch(
                expected: type.type,
                got: initType.type
            ).diagnostic(at: initializer.expr.location)
        }
        return type
    }
    
    @discardableResult func typeCheck(
        _ binding: CaseBranch.Binding,
        with context: Context
    ) throws(Diagnostic) -> CanonicalType {
        let loc = binding.typeAnnotation.type.location
        let type = binding.canonicalType.resolved(context.selfType)
        try checkExistence(of: type, loc: loc)
        return type
    }
}

extension CanonicalType {
    func resolved(_ parent: CanonicalType) -> CanonicalType {
        if self == .selfType {
            return parent
        }
        return self
    }
}
