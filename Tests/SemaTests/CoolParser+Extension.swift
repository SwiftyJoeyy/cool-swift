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
