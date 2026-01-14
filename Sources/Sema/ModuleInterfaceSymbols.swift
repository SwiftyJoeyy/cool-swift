//
//  ModuleInterfaceSymbols.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/01/2026.
//

import Foundation
import AST
import Basic
import Diagnostics

public class ModuleInterfaceSymbols {
    private var symbols = [CanonicalType: ClassSymbol]()
    
    public func load(_ source: InterfaceFile) throws(Diagnostic) {
        let symbolTable = try SymbolTableBuilder(interfaceSymbols: self)
            .build(from: source.declarations)
        for symbol in symbolTable.symbols {
            symbols[symbol.canonicalType] = symbol
        }
    }
    
    internal func lookup(_ type: CanonicalType) -> ClassSymbol? {
        return symbols[type]
    }
}
