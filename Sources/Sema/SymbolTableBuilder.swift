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
    private let objectSymbol: ClassSymbol?
    
    init(interfaceSymbols: ModuleInterfaceSymbols) {
        self.symbols = SymbolTable(interfaceSymbols: interfaceSymbols)
        self.objectSymbol = symbols.lookup(.init(name: "Object"))
    }
    
    func build(from decls: [ClassDecl]) throws(Diagnostic) -> SymbolTable {
        var declsMap = [ResolvedType: ClassDecl]()
        for decl in decls {
            if declsMap[decl.type] != nil {
                throw SemaError.duplicateClass(decl.name.value)
                    .diagnostic(at: decl.name.location)
            }
            declsMap[decl.type] = decl
        }
        
        for decl in decls {
            guard symbols.lookup(decl.type) == nil else { continue }
            _ = try buildSymbol(from: decl, declsMap: declsMap)
        }
        
        return symbols
    }
    
    private func buildSymbol(
        from decl: ClassDecl,
        declsMap: borrowing [ResolvedType: ClassDecl],
        types: consuming Set<ResolvedType> = []
    ) throws(Diagnostic) -> ClassSymbol {
        let symbol = ClassSymbol(decl: decl)
        
        guard let inheritedType = decl.inheritance?.inheritedType else {
            try validateMembers(for: symbol)
            symbol.superclass = objectSymbol
            symbols.insert(symbol)
            return symbol
        }
        
        symbol.superclass = try inheritedSymbol(
            from: decl,
            declsMap: declsMap,
            types: consume types,
            inheritedType: inheritedType
        )
        try validateMembers(for: symbol)
        symbols.insert(symbol)
        return symbol
    }
    
    private func inheritedSymbol(
        from decl: ClassDecl,
        declsMap: borrowing [ResolvedType: ClassDecl],
        types: consuming Set<ResolvedType>,
        inheritedType: some TypeRef
    ) throws(Diagnostic) -> ClassSymbol {
        let inhType = inheritedType.resolved
        if let inhSymbol = symbols.lookup(inhType) {
            return inhSymbol
        }
        
        guard let inhDecl = declsMap[inhType] else {
            throw SemaError.undefinedParentClass(inheritedType.name)
                .diagnostic(at: inheritedType.location)
        }
        
        types.insert(decl.type)
        guard types.insert(inhType).inserted else {
            throw SemaError.selfInheritance(decl.name.value)
                .diagnostic(at: decl.name.location)
        }
        
        return try buildSymbol(
            from: inhDecl,
            declsMap: declsMap,
            types: consume types
        )
    }
    
    private func validateMembers(for symbol: ClassSymbol) throws(Diagnostic) {
        let type = symbol.type
        let members = symbol.decl.membersBlock.members
        for (index, member) in members.enumerated() {
            guard let item = symbol.lookup(member.name.value) else {
                symbol.insert(member, index: index)
                continue
            }
            
            if item.parent == type {
                throw SemaError.duplicateDeclaration(member.name.value)
                    .diagnostic(at: member.name.location)
            }
            
            switch (member.kind, item.decl.kind) {
                case (.varDecl, .varDecl):
                    throw SemaError.cannotOverrideProperty(member.name.value)
                        .diagnostic(at: member.name.location)
                case (.funcDecl(let new), .funcDecl(let base)):
                    var diffs = [FuncOverrideDiff]()
                    if new.returnType != base.returnType {
                        diffs.append(.returnTypeMismatch(expected: base.returnType.name, got: new.returnClause.type))
                    }
                    let baseParams = base.parameters.parameters
                    let newParams = new.parameters.parameters
                    var extraParams = newParams
                    
                    for i in 0..<baseParams.count {
                        let param = baseParams[i]
                        let index = newParams.firstIndex {
                            return $0.name.value == param.name.value
                        }
                        guard let index else {
                            diffs.append(.missingParam(param))
                            continue
                        }
                        let newParam = newParams[index]
                        if index != i {
                            diffs.append(.wrongIndex(param: newParam, expected: i, got: index))
                        }
                        if newParam.type.resolved != param.type.resolved {
                            diffs.append(.paramTypeMismatch(expected: param.type.name, got: newParam.type))
                        }
                        extraParams.removeAll(where: {$0.name.value == param.name.value})
                    }
                    
                    for i in 0..<extraParams.count {
                        let newParam = extraParams[i]
                        let param = baseParams[i]
                        if newParam.type.name == param.type.name {
                            let index = diffs.firstIndex {
                                guard case .missingParam(let expected) = $0 else {
                                    return false
                                }
                                return expected.name.value == param.name.value
                            }
                            let diff = FuncOverrideDiff.paramNameMismatch(
                                expected: param.name.value,
                                got: newParam.name
                            )
                            if let index {
                                diffs[index] = diff
                            } else {
                                diffs.append(diff)
                            }
                            continue
                        }
                        diffs.append(.extraParam(newParam))
                    }
                    
                    if !diffs.isEmpty {
                        throw SemaError.funcOverrideMismatch(diffs)
                            .diagnostic(at: member.name.location)
                    }
                    symbol.insert(member, index: index)
                case (.varDecl, .funcDecl(let decl)):
                    throw SemaError.propertyCannotOverrideFunc(decl.name.value)
                        .diagnostic(at: member.name.location)
                case (.funcDecl, .varDecl(let decl)):
                    throw SemaError.cannotOverrideProperty(decl.name.value)
                        .diagnostic(at: member.name.location)
                default: break
            }
        }
    }
}

extension Array {
    func safe(_ index: Int) -> Self.Element? {
        guard index < count else { return nil }
        return self[index]
    }
}
