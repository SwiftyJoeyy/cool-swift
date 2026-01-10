//
//  Scope.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 31/12/2025.
//

import Foundation
import AST

protocol Scope {
    var selfType: CanonicalType { get }
    func lookup(member: CanonicalIdentifier) -> ScopedMember?
}

struct ScopedMember {
    let decl: any Decl
    let selfType: CanonicalType
    
    init?(_ decl: (any Decl)?, selfType: CanonicalType) {
        guard let decl else {
            return nil
        }
        self.decl = decl
        self.selfType = selfType
    }
}

struct VarDeclScope: Scope {
    let symbol: ClassSymbol
    
    var selfType: CanonicalType {
        return symbol.canonicalType
    }
    
    func lookup(member: CanonicalIdentifier) -> ScopedMember? {
        return ScopedMember(symbol.lookup(member)?.decl, selfType: selfType)
    }
}

struct FuncDeclScope: Scope {
    let symbol: ClassSymbol
    let parameters: [CanonicalIdentifier: ParameterDecl]
    
    var selfType: CanonicalType {
        return symbol.canonicalType
    }
    
    func lookup(member: CanonicalIdentifier) -> ScopedMember? {
        if let param = parameters[member] {
            return ScopedMember(param, selfType: selfType)
        }
        return ScopedMember(symbol.lookup(member)?.decl, selfType: selfType)
    }
}

struct LetExprScope: Scope {
    let parentScope: any Scope
    let environment: LetExprEnvironment
    
    var selfType: CanonicalType {
        return parentScope.selfType
    }
    
    func lookup(member: CanonicalIdentifier) -> ScopedMember? {
        if let decl = environment.lookup(member) {
            return ScopedMember(decl, selfType: selfType)
        }
        return parentScope.lookup(member: member)
    }
    
    class LetExprEnvironment {
        private var bindings = [CanonicalIdentifier: any Decl]()
        
        func insert(_ binding: some Decl) {
            guard bindings[binding.name.canonical] == nil else { return }
            bindings[binding.name.canonical] = binding
        }
        
        func lookup(_ name: CanonicalIdentifier) -> (any Decl)? {
            return bindings[name]
        }
    }
}

struct CaseBranchScope: Scope {
    let parentScope: any Scope
    let binding: CaseBranch.Binding
    
    var selfType: CanonicalType {
        return parentScope.selfType
    }
    
    func lookup(member: CanonicalIdentifier) -> ScopedMember? {
        if member == binding.name.canonical {
            return ScopedMember(binding, selfType: selfType)
        }
        return parentScope.lookup(member: member)
    }
}
