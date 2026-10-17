//
//  ModuleInterfaceSymbols.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/01/2026.
//

public import AST
public import Diagnostics
import Foundation

public class ModuleInterfaceSymbols {
    private(set) var symbols = [ResolvedType: ClassSymbol]()
    private var orderedSymbols = [ClassSymbol]()
    
    public init() { }
    
    public func load(_ source: InterfaceFile) throws(Diagnostic) {
        let symbolTable = try SymbolTableBuilder(interfaceSymbols: self)
            .build(from: source.declarations)
        for symbol in symbolTable.symbols {
            symbols[symbol.type] = symbol
            orderedSymbols.append(symbol)
        }
    }
    
    func lookup(_ type: ResolvedType) -> ClassSymbol? {
        return symbols[type.classType]
    }
    
    func resolvedDeclarations() -> [ResolvedInterfaceClassDecl] {
        return orderedSymbols.map { symbol in
            let methods = symbol.members.compactMap { member -> ResolvedInterfaceFuncDecl? in
                guard case .interfaceFuncDecl(let method) = member.kind else {
                    return nil
                }
                return resolved(method, in: symbol)
            }
            return ResolvedInterfaceClassDecl(
                name: symbol.decl.name.value,
                parent: symbol.superclass?.type,
                methods: methods,
                decl: symbol.decl
            )
        }
    }
    
    private func resolved(
        _ method: InterfaceFuncDecl,
        in symbol: ClassSymbol
    ) -> ResolvedInterfaceFuncDecl {
        func resolve(_ type: any TypeRef) -> ResolvedType {
            guard type.resolved == .selfType else {
                return type.resolved
            }
            return ResolvedType(name: symbol.type.name, isSelfType: true)
        }
        
        return ResolvedInterfaceFuncDecl(
            name: method.name.value,
            type: resolve(method.returnClause.type),
            parameters: method.parameters.parameters.map {
                ResolvedParameterDecl(name: $0.name.value, type: resolve($0.type), decl: $0)
            },
            decl: method
        )
    }
}
