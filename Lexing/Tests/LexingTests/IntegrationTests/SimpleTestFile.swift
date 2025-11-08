//
//  SimpleTestFile.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Foundation
import Diagnostics
@testable import Lexing

enum SimpleTestFile: TestFile {
    static let name = "simple"
    
    static let tokens: [Token] = [
        Token(kind: .keyword(.class), location: SourceLocation(line: 2, column: 1, file: "")),
        Token(kind: .identifier("Main"), location: SourceLocation(line: 2, column: 7, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 2, column: 12, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 3, column: 5, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 3, column: 7, file: "")),
        Token(kind: .identifier("Int"), location: SourceLocation(line: 3, column: 9, file: "")),
        Token(kind: .assign, location: SourceLocation(line: 3, column: 13, file: "")),
        Token(kind: .integerLiteral("42"), location: SourceLocation(line: 3, column: 16, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 3, column: 18, file: "")),
        Token(kind: .identifier("main"), location: SourceLocation(line: 5, column: 5, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 5, column: 9, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 5, column: 10, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 5, column: 12, file: "")),
        Token(kind: .identifier("Int"), location: SourceLocation(line: 5, column: 14, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 5, column: 18, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 6, column: 9, file: "")),
        Token(kind: .plus, location: SourceLocation(line: 6, column: 11, file: "")),
        Token(kind: .integerLiteral("1"), location: SourceLocation(line: 6, column: 13, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 7, column: 5, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 7, column: 6, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 8, column: 1, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 8, column: 2, file: "")),
        Token(kind: .endOfFile, location: SourceLocation(line: 9, column: 0, file: ""))
    ]
    
    static let diagnostics: [Diagnostic] = []
}
