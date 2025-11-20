//
//  OperatorsTestFile.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Foundation
import Diagnostics
@testable import Lexer

enum OperatorsTestFile: TestFile {
    static let name = "operators"
    
    static let tokens: [Token] = [
        Token(kind: .keyword(.class), location: SourceLocation(line: 2, column: 1, file: "")),
        Token(kind: .identifier("Test"), location: SourceLocation(line: 2, column: 7, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 2, column: 12, file: "")),
        Token(kind: .identifier("test"), location: SourceLocation(line: 3, column: 5, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 3, column: 9, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 3, column: 10, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 3, column: 12, file: "")),
        Token(kind: .identifier("Int"), location: SourceLocation(line: 3, column: 14, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 3, column: 18, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 4, column: 9, file: "")),
        Token(kind: .integerLiteral("1"), location: SourceLocation(line: 5, column: 13, file: "")),
        Token(kind: .plus, location: SourceLocation(line: 5, column: 15, file: "")),
        Token(kind: .integerLiteral("2"), location: SourceLocation(line: 5, column: 17, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 5, column: 18, file: "")),
        Token(kind: .integerLiteral("3"), location: SourceLocation(line: 6, column: 13, file: "")),
        Token(kind: .minus, location: SourceLocation(line: 6, column: 15, file: "")),
        Token(kind: .integerLiteral("4"), location: SourceLocation(line: 6, column: 17, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 6, column: 18, file: "")),
        Token(kind: .integerLiteral("5"), location: SourceLocation(line: 7, column: 13, file: "")),
        Token(kind: .star, location: SourceLocation(line: 7, column: 15, file: "")),
        Token(kind: .integerLiteral("6"), location: SourceLocation(line: 7, column: 17, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 7, column: 18, file: "")),
        Token(kind: .integerLiteral("7"), location: SourceLocation(line: 8, column: 13, file: "")),
        Token(kind: .slash, location: SourceLocation(line: 8, column: 15, file: "")),
        Token(kind: .integerLiteral("8"), location: SourceLocation(line: 8, column: 17, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 8, column: 18, file: "")),
        Token(kind: .tilde, location: SourceLocation(line: 9, column: 13, file: "")),
        Token(kind: .integerLiteral("9"), location: SourceLocation(line: 9, column: 14, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 9, column: 15, file: "")),
        Token(kind: .integerLiteral("10"), location: SourceLocation(line: 10, column: 13, file: "")),
        Token(kind: .lessThan, location: SourceLocation(line: 10, column: 16, file: "")),
        Token(kind: .integerLiteral("11"), location: SourceLocation(line: 10, column: 18, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 10, column: 20, file: "")),
        Token(kind: .integerLiteral("12"), location: SourceLocation(line: 11, column: 13, file: "")),
        Token(kind: .lessThanOrEqual, location: SourceLocation(line: 11, column: 16, file: "")),
        Token(kind: .integerLiteral("13"), location: SourceLocation(line: 11, column: 19, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 11, column: 21, file: "")),
        Token(kind: .integerLiteral("14"), location: SourceLocation(line: 12, column: 13, file: "")),
        Token(kind: .equal, location: SourceLocation(line: 12, column: 16, file: "")),
        Token(kind: .integerLiteral("15"), location: SourceLocation(line: 12, column: 18, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 12, column: 20, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 13, column: 13, file: "")),
        Token(kind: .assign, location: SourceLocation(line: 13, column: 15, file: "")),
        Token(kind: .integerLiteral("16"), location: SourceLocation(line: 13, column: 18, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 13, column: 20, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 14, column: 9, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 15, column: 5, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 15, column: 6, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 16, column: 1, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 16, column: 2, file: "")),
        Token(kind: .endOfFile, location: SourceLocation(line: 17, column: 0, file: ""))
    ]
    
    static let diagnostics: [Diagnostic] = []
}
