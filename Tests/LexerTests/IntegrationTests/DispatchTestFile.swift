//
//  DispatchTestFile.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Foundation
import Diagnostics
import Basic
@testable import Lexer

enum DispatchTestFile: TestFile {
    static let name = "dispatch"
    
    static let tokens: [Token] = [
        Token(kind: .keyword(.class), location: SourceLocation(line: 2, column: 1, file: "")),
        Token(kind: .identifier("Test"), location: SourceLocation(line: 2, column: 7, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 2, column: 12, file: "")),
        Token(kind: .identifier("test"), location: SourceLocation(line: 3, column: 5, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 3, column: 9, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 3, column: 10, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 3, column: 12, file: "")),
        Token(kind: .identifier("Object"), location: SourceLocation(line: 3, column: 14, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 3, column: 21, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 4, column: 9, file: "")),
        Token(kind: .identifier("obj"), location: SourceLocation(line: 5, column: 13, file: "")),
        Token(kind: .dot, location: SourceLocation(line: 5, column: 16, file: "")),
        Token(kind: .identifier("method"), location: SourceLocation(line: 5, column: 17, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 5, column: 23, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 5, column: 24, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 5, column: 25, file: "")),
        Token(kind: .identifier("obj"), location: SourceLocation(line: 6, column: 13, file: "")),
        Token(kind: .dot, location: SourceLocation(line: 6, column: 16, file: "")),
        Token(kind: .identifier("method"), location: SourceLocation(line: 6, column: 17, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 6, column: 23, file: "")),
        Token(kind: .integerLiteral("1"), location: SourceLocation(line: 6, column: 24, file: "")),
        Token(kind: .comma, location: SourceLocation(line: 6, column: 25, file: "")),
        Token(kind: .integerLiteral("2"), location: SourceLocation(line: 6, column: 27, file: "")),
        Token(kind: .comma, location: SourceLocation(line: 6, column: 28, file: "")),
        Token(kind: .integerLiteral("3"), location: SourceLocation(line: 6, column: 30, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 6, column: 31, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 6, column: 32, file: "")),
        Token(kind: .identifier("obj"), location: SourceLocation(line: 7, column: 13, file: "")),
        Token(kind: .at, location: SourceLocation(line: 7, column: 16, file: "")),
        Token(kind: .identifier("Parent"), location: SourceLocation(line: 7, column: 17, file: "")),
        Token(kind: .dot, location: SourceLocation(line: 7, column: 23, file: "")),
        Token(kind: .identifier("method"), location: SourceLocation(line: 7, column: 24, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 7, column: 30, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 7, column: 31, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 7, column: 32, file: "")),
        Token(kind: .identifier("self"), location: SourceLocation(line: 8, column: 13, file: "")),
        Token(kind: .dot, location: SourceLocation(line: 8, column: 17, file: "")),
        Token(kind: .identifier("type_name"), location: SourceLocation(line: 8, column: 18, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 8, column: 27, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 8, column: 28, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 8, column: 29, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 9, column: 13, file: "")),
        Token(kind: .keyword(.new), location: SourceLocation(line: 9, column: 14, file: "")),
        Token(kind: .identifier("Test"), location: SourceLocation(line: 9, column: 18, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 9, column: 22, file: "")),
        Token(kind: .dot, location: SourceLocation(line: 9, column: 23, file: "")),
        Token(kind: .identifier("init"), location: SourceLocation(line: 9, column: 24, file: "")),
        Token(kind: .leftParen, location: SourceLocation(line: 9, column: 28, file: "")),
        Token(kind: .rightParen, location: SourceLocation(line: 9, column: 29, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 9, column: 30, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 10, column: 9, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 11, column: 5, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 11, column: 6, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 12, column: 1, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 12, column: 2, file: "")),
        Token(kind: .endOfFile, location: SourceLocation(line: 13, column: 0, file: ""))
    ]
    
    static let diagnostics: [Diagnostic] = []
}
