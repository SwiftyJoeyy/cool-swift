//
//  SymbolTable.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/12/2025.
//

import Foundation
import AST

class SymbolTable {
    private let interfaceSymbols: ModuleInterfaceSymbols
    private var symbolsMap = [CanonicalType: ClassSymbol]()
    
    var symbols: [ClassSymbol] {
        return Array(symbolsMap.values)
    }
    
    init(interfaceSymbols: ModuleInterfaceSymbols) {
        self.interfaceSymbols = interfaceSymbols
    }
    
    func insert(_ symbol: ClassSymbol) {
        guard symbolsMap[symbol.canonicalType] == nil else { return }
        symbolsMap[symbol.canonicalType] = symbol
    }
    
    func lookup(_ type: CanonicalType) -> ClassSymbol? {
        return symbolsMap[type] ?? interfaceSymbols.lookup(type)
    }
}

class ClassSymbol {
    private var decls = [CanonicalIdentifier: any Decl]()
    let decl: ClassDecl
    var superclass: ClassSymbol?
    
    var canonicalType: CanonicalType {
        return decl.canonicalType
    }
    var members: [any Decl] {
        return Array(decls.values)
    }
    var explicitSuperclass: ClassSymbol? {
        return superclass?.canonicalType == .object ? nil: superclass
    }
    
    init(decl: ClassDecl) {
        self.decl = decl
    }
    
    func insert(_ decl: some Decl) {
        guard decls[decl.name.canonical] == nil else { return }
        decls[decl.name.canonical] = decl
    }
    
    func lookup(_ id: CanonicalIdentifier) -> MemberDecl? {
        if id == .`self` {
            return MemberDecl(
                decl: SelfDecl(type: decl.name.value),
                parent: decl.canonicalType
            )
        }
        if let member = decls[id] {
            return MemberDecl(decl: member, parent: decl.canonicalType)
        }
        return superclass?.lookup(id)
    }
    
    func superclass(_ type: CanonicalType) -> ClassSymbol? {
        var parent = superclass
        while parent != nil {
            if parent?.canonicalType == type {
                return parent
            }
            parent = parent?.superclass
        }
        return nil
    }
}

struct MemberDecl {
    let decl: any Decl
    let parent: CanonicalType
}
