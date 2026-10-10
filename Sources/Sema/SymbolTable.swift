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
        return symbolsMap[type] ?? interfaceSymbols.lookup(type)
    }
}

final class ClassSymbol {
    private var decls = [String: MemberDecl]()
    private var declsIndex = [String: Int]()
    
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
    
    func insert(_ decl: MemberDecl, index: Int) {
        guard decls[decl.name.value] == nil else { return }
        declsIndex[decl.name.value] = index
        decls[decl.name.value] = decl
    }
    
    func lookup(_ id: String) -> SymbolMember? {
//        if id == .`self` {
//            return SymbolMember(
//                decl: SelfDecl(type: decl.name.value),
//                parent: type
//            )
//        }
        if let member = decls[id], let index = declsIndex[id] {
            return SymbolMember(decl: member, parent: type, index: index)
        }
        return superclass?.lookup(id)
    }
}

struct SymbolMember {
    let decl: MemberDecl
    let parent: ResolvedType
    let index: Int
}
