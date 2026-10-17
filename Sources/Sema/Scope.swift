//
//  Scope.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/09/2026.
//

import Foundation
import AST
import Diagnostics

protocol Scope {
    var baseType: ResolvedType { get }
    func lookup(member: String) throws(Diagnostic) -> ScopedMember?
}

extension Scope {
    var selfType: ResolvedType {
        return ResolvedType(name: baseType.name, isSelfType: true)
    }
}

struct ScopedMember {
    let name: String
    let type: ResolvedType
    let refType: RefType
    
    enum RefType {
        case parameter, letBinding, caseBranch, selfRef
        case localDecl(SymbolMember)
    }
}

struct ClassScope: Scope {
    let symbol: ClassSymbol
    let typeSystem: any TypeSystem
    var baseType: ResolvedType {
        return symbol.type
    }
    
    func lookup(member: String) throws(Diagnostic) -> ScopedMember? {
        guard let symbolMember = symbol.lookup(member) else {
            return nil
        }
        let type = try typeSystem.checkType(symbolMember.decl.type, base: selfType)
        return ScopedMember(
            name: symbolMember.decl.name.value,
            type: type,
            refType: .localDecl(symbolMember)
        )
    }
}

struct FuncScope: Scope {
    let parentScope: any Scope
    let parameters: [String: ResolvedParameterDecl]
    
    var baseType: ResolvedType {
        return parentScope.baseType
    }
    
    func lookup(member: String) throws(Diagnostic) -> ScopedMember? {
        if let param = parameters[member] {
            return ScopedMember(
                name: param.name,
                type: param.type,
                refType: .parameter
            )
        }
        return try parentScope.lookup(member: member)
    }
}

struct LetScope: Scope {
    let parentScope: any Scope
    let environment: Environment
    
    var baseType: ResolvedType {
        return parentScope.baseType
    }
    
    func lookup(member: String) throws(Diagnostic) -> ScopedMember? {
        if let decl = environment.lookup(member) {
            return ScopedMember(
                name: decl.name,
                type: decl.type,
                refType: .letBinding
            )
        }
        return try parentScope.lookup(member: member)
    }
    
    class Environment {
        private var bindings = [String: ResolvedVarDecl]()
        
        func insert(_ binding: ResolvedVarDecl) {
            guard bindings[binding.name] == nil else { return }
            bindings[binding.name] = binding
        }
        func lookup(_ name: String) -> ResolvedVarDecl? {
            return bindings[name]
        }
    }
}

struct CaseBranchScope: Scope {
    let parentScope: any Scope
    let name: String
    let type: ResolvedType
    
    var baseType: ResolvedType {
        return parentScope.baseType
    }
    
    func lookup(member: String) throws(Diagnostic) -> ScopedMember? {
        if member == name {
            return ScopedMember(name: name, type: type, refType: .caseBranch)
        }
        return try parentScope.lookup(member: member)
    }
}
