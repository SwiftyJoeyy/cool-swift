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
@testable import Parser

let testFile = "test.cl"

extension CoolParser {
    static func new(
        source: String,
        file: String = testFile
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
