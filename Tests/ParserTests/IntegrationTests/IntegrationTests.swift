//
//  IntegrationTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 06/12/2025.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
@testable import Parser

protocol TestFile {
    static var name: String { get }
    
    static func validate(_ program: SourceFile) throws
}

@Suite struct ParserIntegrationTests {
// MARK: - Functions
    private func parseFile(_ name: String) throws -> (SourceFile, [Diagnostic]) {
        let url = try #require(
            Bundle.module.url(
                forResource: name,
                withExtension: "cl",
                subdirectory: "Resources"
            )
        )
        let source = try String(contentsOf: url)
        
        var (parser, diagEngine) = try CoolParser.new(
            source: source,
            file: "\(name).cl"
        )
        return (try parser.parse(), diagEngine.diags)
    }
    
    private func verify(_ testFile: (some TestFile).Type) throws {
        let (program, diagnostics) = try parseFile(testFile.name)
        
        #expect(diagnostics.isEmpty)
        try testFile.validate(program)
    }
    
// MARK: - Tests
    @Test func `parses simple COOL program`() throws {
        try verify(SimpleTestFile.self)
    }
    
    @Test func `parses inheritance correctly`() throws {
        try verify(InheritanceTestFile.self)
    }
    
    @Test func `parses various expressions`() throws {
        try verify(ExpressionsTestFile.self)
    }
    
    @Test func `parses methods with different signatures`() throws {
        try verify(MethodsTestFile.self)
    }
    
    @Test func `parses comprehensive COOL program`() throws {
        try verify(ComprehensiveTestFile.self)
    }
}
