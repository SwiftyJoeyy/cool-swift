//
//  CoolParserTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 14/08/2026.
//

import Testing
import Foundation
import AST
import Diagnostics
@testable import Parser

@Suite struct CoolParserTests: ParserTestSuite {
    func parseNode(from parser: inout CoolParser) throws(Diagnostic) -> SourceFile {
        return try parser.parse()
    }
    
    @Test func `reports error for top level code outside class`() throws {
        let (_, diags) = try parseWithDiags("hello : Int;")
        #expect(diags.map(\.id) == [ParserError.unexpectedTopLevelDeclaration.id])
    }
}
