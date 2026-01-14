//
//  IntegrationTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/01/2026.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
import Parser
@testable import Sema

@Suite struct SemaIntegrationTests {
    @Test(arguments: Bundle.module.urls(
        forResourcesWithExtension: "cl",
        subdirectory: "Resources"
    ) ?? [])
    func `validate files`(fileURL: URL) throws {
        let source = try String(contentsOf: fileURL)
        var (parser, diagEngine) = try CoolParser.new(
            source: source,
            file: fileURL.lastPathComponent
        )
        let sourceFile = try parser.parse()
        let sema = Sema(diagnostics: diagEngine, interfaceSymbols: .test)
        try sema.analyze(sourceFile)
        #expect(diagEngine.diags.isEmpty)
    }
}
