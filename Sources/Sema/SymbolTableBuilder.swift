//
//  ClassesValidator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 29/12/2025.
//

import Foundation
import AST
import Diagnostics

struct SymbolTableBuilder {
    private let symbols: SymbolTable
    
    init(symbols: SymbolTable) {
        self.symbols = symbols
    }
    
    func build(from decls: [ClassDecl]) throws(Diagnostic) {
        var declsMap = [CanonicalType: ClassDecl]()
        for decl in decls {
            if declsMap[decl.canonicalType] != nil {
                throw SemaError.duplicateClass(decl.name.value)
                    .diagnostic(at: decl.name.location)
            }
            declsMap[decl.canonicalType] = decl
        }
        
        for decl in decls {
            guard symbols.lookup(decl.canonicalType) == nil else { continue }
            try validateDecl(decl, declsMap: declsMap)
        }
    }
    
    private func validateDecl(
        _ decl: ClassDecl,
        declsMap: borrowing [CanonicalType: ClassDecl],
        types: consuming Set<CanonicalType> = []
    ) throws(Diagnostic) {
        let symbol = ClassSymbol(decl: decl)
        
        guard let inheritedType = decl.inheritance?.inheritedType else {
            try validateMembers(for: symbol)
            symbols.insert(symbol)
            return
        }
        let inhType = inheritedType.canonical
        guard let inhDecl = declsMap[inhType] ?? symbols.lookup(inhType)?.decl else {
            throw SemaError.undefinedParentClass(inheritedType.name)
                .diagnostic(at: inheritedType.location)
        }
        
        types.insert(decl.canonicalType)
        if types.contains(inhType) {
            throw SemaError.selfInheritance(decl.name.value)
                .diagnostic(at: decl.name.location)
        }
        types.insert(inhType)
        
        try validateDecl(inhDecl, declsMap: declsMap, types: consume types)
        
        symbol.superclass = symbols.lookup(inhType)
        try validateMembers(for: symbol)
        symbols.insert(symbol)
    }
    
    private func validateMembers(for symbol: ClassSymbol) throws(Diagnostic) {
        let declType = symbol.canonicalType
        for member in symbol.decl.membersBlock.members {
            if let item = symbol.lookup(member.name.canonical),
               item.parent == declType {
                throw  SemaError.duplicateDeclaration(member.name.value)
                    .diagnostic(at: member.name.location)
            }
            symbol.insert(member)
        }
    }
}
