//
//  SemaTestSupport.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/12/2025.
//

import Foundation
import AST
import Diagnostics
import Parser
import TestSupport
@testable import Sema

extension ModuleInterfaceSymbols {
    nonisolated(unsafe) static let test: ModuleInterfaceSymbols = {
        let loader = ModuleInterfaceSymbols()
        let url = Bundle.module.url(
            forResource: "Core",
            withExtension: "clmodule",
            subdirectory: "Resources"
        )!
        let source = try! String(contentsOf: url, encoding: .utf8)
        
        var (parser, _) = try! CoolParser.new(
            source: source,
            file: "Core.clmodule"
        )
        let file = try! parser.parseInterface()
        try! loader.load(file)
        return loader
    }()
}

@discardableResult
func analyze(_ source: String, file: String = testFile) throws -> [Diagnostic] {
    var (parser, diagEngine) = try CoolParser.new(source: source, file: file)
    let sourceFile = try parser.parse()
    let sema = Sema(diagnostics: diagEngine, interfaceSymbols: .test)
    _ = try sema.analyze(sourceFile)
    return diagEngine.diags
}

/// Parses and type checks `source`, returning the resolved program.
func resolve(_ source: String) throws -> ResolvedSource {
    var (parser, diagEngine) = try CoolParser.new(source: source)
    let sourceFile = try parser.parse()
    return try Sema(diagnostics: diagEngine, interfaceSymbols: .test)
        .analyze(sourceFile)
}

@discardableResult func build(_ source: String) throws -> SymbolTable {
    var (parser, _) = try CoolParser.new(source: source)
    let sourceFile = try parser.parse()
    return try SymbolTableBuilder(interfaceSymbols: .test)
        .build(from: sourceFile.declarations)
}
