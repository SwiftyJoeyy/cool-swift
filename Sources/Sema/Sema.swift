//
//  Sema.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 20/12/2025.
//

import Foundation
import AST
import Basic
import Diagnostics

public struct Sema {
    private let diagnostics: DiagnosticsEngine
    private let interfaceSymbols: ModuleInterfaceSymbols
    
    public init(
        diagnostics: DiagnosticsEngine,
        interfaceSymbols: ModuleInterfaceSymbols
    ) {
        self.diagnostics = diagnostics
        self.interfaceSymbols = interfaceSymbols
    }
    
    public func analyze(_ source: SourceFile) throws(Diagnostic) {
        let symbols = try SymbolTableBuilder(interfaceSymbols: interfaceSymbols)
            .build(from: source.declarations)
        let typeSystem = TypeSystem(symbols: symbols)
        
        for symbol in symbols.symbols {
            try typeSystem.typeCheck(symbol)
        }
    }
}
