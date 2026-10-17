//
//  Sema.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 20/12/2025.
//

public import AST
public import Diagnostics
import Foundation

public struct Sema {
    private let diagnostics: any DiagnosticsEngine
    private let interfaceSymbols: ModuleInterfaceSymbols
    
    public init(
        diagnostics: any DiagnosticsEngine,
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
        
        return ResolvedSource(
            declarations: decls,
            interfaceDeclarations: interfaceSymbols.resolvedDeclarations()
        )
    }
    
    public func checkEntryPoint(_ source: ResolvedSource) throws(Diagnostic) {
        let classes = Dictionary(
            source.declarations.map({($0.type, $0)}),
            uniquingKeysWith: { first, _ in first }
        )
        guard let mainClass = classes[.main] else {
            throw SemaError.missingMainClass.diagnostic()
        }
        
        var current: ResolvedClassDecl? = mainClass
        while let decl = current {
            if let mainFunc = decl.methods.first(where: {$0.name == "main"}) {
                guard !mainFunc.parameters.isEmpty else { return }
                let location = (mainFunc.decl as? FuncDecl)?.parameters.location
                throw SemaError.mainMethodCannotHaveParameters
                    .diagnostic(at: location ?? mainFunc.decl.location)
            }
            current = classes[decl.parent]
        }
        throw SemaError.missingMainMethod
            .diagnostic(at: mainClass.decl.location)
    }
}
