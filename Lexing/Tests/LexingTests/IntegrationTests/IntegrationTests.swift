//
//  IntegrationTests.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Foundation
import Diagnostics
@testable import Lexing

protocol TestFile {
    static var name: String { get }
    static var tokens: [Token] { get }
    static var diagnostics: [Diagnostic] { get }
}

@Suite struct IntegrationTests {
// MARK: - Helper Functions
    private func lexFile(_ name: String) throws -> ([Token], [Diagnostic]) {
        let url = try #require(
            Bundle.module.url(
                forResource: name,
                withExtension: "cl",
                subdirectory: "Resources"
            )
        )
        
        var lexer = CoolLexer(try String(contentsOf: url))
        var tokens = [Token]()
        var diagnostics = [Diagnostic]()
        
        while !lexer.reachedEnd {
            do {
                let token = try lexer.next()
                tokens.append(token)
            } catch {
                diagnostics.append(error)
            }
        }
        
        return (tokens, diagnostics)
    }
    
    private func verify(_ testFile: (some TestFile).Type) throws {
        let (tokens, diagnostics) = try lexFile(testFile.name)

        #expect(tokens == testFile.tokens)
        #expect(diagnostics.map(\.id) == testFile.diagnostics.map(\.id))
    }
    
// MARK: - Test Methods
    @Test func `lexes simple COOL program`() throws {
        try verify(SimpleTestFile.self)
    }
    
    @Test func `lexes all operators correctly`() throws {
        try verify(OperatorsTestFile.self)
    }
    
    @Test func `lexes keywords case-insensitively`() throws {
        try verify(KeywordsTestFile.self)
    }
    
    @Test func `lexes method dispatch and punctuation`() throws {
        try verify(DispatchTestFile.self)
    }
    
    @Test func `lexes comprehensive COOL program`() throws {
        try verify(ComprehensiveTestFile.self)
    }
    
    @Test func `handles lexer diagnostics correctly`() throws {
        try verify(DiagnosticsTestFile.self)
    }
}
