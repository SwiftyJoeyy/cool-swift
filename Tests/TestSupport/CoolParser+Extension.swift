//
//  CoolParser+Extension.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 13/12/2025.
//

import Foundation
import Lexer
import Parser

public let testFile = "test.cl"

extension CoolParser {
    public static func new(
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
