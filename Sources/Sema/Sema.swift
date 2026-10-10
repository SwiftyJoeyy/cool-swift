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
    
    public func analyze(_ source: SourceFile) throws(Diagnostic) -> ResolvedSource {
        let symbols = try SymbolTableBuilder(interfaceSymbols: interfaceSymbols)
            .build(from: source.declarations)
        let typeSystem = DefaultTypeSystem(symbols: symbols)
        
        var decls = [ResolvedClassDecl]()
        for symbol in symbols.symbols {
            decls.append(try typeSystem.typeCheck(symbol))
        }
        
        return ResolvedSource(declarations: decls)
    }
    
//    public func checkEntryPoint(typeSystem: TypeSystem) throws(Diagnostic) {
//        guard let mainSymbol = typeSystem.lookup(type: .main) else {
//            throw SemaError.missingMainClass.diagnostic()
//        }
//        
//        guard let mainFunc = mainSymbol.lookup(.main)?.decl as? FuncDecl else {
//            throw SemaError.missingMainMethod
//                .diagnostic(at: mainSymbol.decl.location)
//        }
//        
//        guard !mainFunc.parameters.parameters.isEmpty else { return }
//        throw SemaError.mainMethodCannotHaveParameters
//            .diagnostic(at: mainFunc.parameters.location)
//    }
}
