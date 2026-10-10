//
//  CoolParserTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 14/08/2026.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
@testable import Parser

@Suite struct CoolParserTests {
    private func parseWithDiags(_ source: String) throws -> (SourceFile, [Diagnostic]) {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        return (try parser.parse(), diagEngine.diags)
    }
    
    @Test func `reports error for top level code outside class`() throws {
        let (_, diags) = try parseWithDiags("hello : Int;")
        #expect(diags.map(\.id) == [ParserError.unexpectedTopLevelDeclaration.id])
    }
}
