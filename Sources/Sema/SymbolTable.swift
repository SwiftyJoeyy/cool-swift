//
//  SymbolTable.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/12/2025.
//

import Foundation
import AST

class SymbolTable {
    let interfaceSymbols: ModuleInterfaceSymbols
    private(set) var symbols = [ClassSymbol]()
    private var symbolsMap = [ResolvedType: ClassSymbol]()
    
    init(interfaceSymbols: ModuleInterfaceSymbols) {
        self.interfaceSymbols = interfaceSymbols
    }
    
    func insert(_ symbol: ClassSymbol) {
        let type = symbol.type
        guard symbolsMap[type] == nil, interfaceSymbols.lookup(type) == nil else { return }
        symbolsMap[type] = symbol
        symbols.append(symbol)
    }
    
    func lookup(_ type: ResolvedType) -> ClassSymbol? {
        return symbolsMap[type.classType] ?? interfaceSymbols.lookup(type)
    }
}

final class ClassSymbol {
    private var decls = [String: MemberDecl]()
    
    let decl: ClassDecl
    var superclass: ClassSymbol?
    
    var type: ResolvedType {
        return decl.type
    }
    var members: [MemberDecl] {
        return decl.membersBlock.members
    }
    
    init(decl: ClassDecl) {
        self.decl = decl
    }
    
    func insert(_ decl: MemberDecl) {
        guard decls[decl.name.value] == nil else { return }
        decls[decl.name.value] = decl
    }
    
    func lookup(_ id: String) -> SymbolMember? {
        if let member = decls[id] {
            return SymbolMember(decl: member, parent: type)
        }
        return superclass?.lookup(id)
    }
}

struct SymbolMember {
    let decl: MemberDecl
    let parent: ResolvedType
}
