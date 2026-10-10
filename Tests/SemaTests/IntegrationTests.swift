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
        let source = try String(contentsOf: fileURL, encoding: .utf8)
        let diags = try analyze(source, file: fileURL.lastPathComponent)
        #expect(diags.isEmpty)
    }
}
