//
//  CoolParser+Extension.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/12/2025.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer
import Parser
@testable import Sema

extension CoolParser {
    static func new(
        source: String,
        file: String = "test.cl"
    ) throws -> (parser: CoolParser, diagEngine: MockDiagEngine) {
        let diagEngine = MockDiagEngine()
        let parser = try CoolParser(
            lexemes: Lexemes(
                lexer: CoolLexer(source, file: file)
            ),
            diagnostics: diagEngine
        )
        
        return (parser, diagEngine)
    }
}

extension ModuleInterfaceSymbols {
    static var test: ModuleInterfaceSymbols {
        let loader = ModuleInterfaceSymbols()
        let url = Bundle.module.url(
            forResource: "Core",
            withExtension: "clmodule",
            subdirectory: "Resources"
        )!
        let source = try! String(contentsOf: url)
        
        var (parser, _) = try! CoolParser.new(
            source: source,
            file: "Core.clmodule"
        )
        let file = try! parser.parseInterface()
        try! loader.load(file)
        return loader
    }
}
