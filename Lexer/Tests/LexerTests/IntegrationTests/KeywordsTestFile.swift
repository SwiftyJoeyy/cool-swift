//
//  KeywordsTestFile.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Foundation
import Diagnostics
@testable import Lexer

enum KeywordsTestFile: TestFile {
    static let name = "keywords"
    
    static let tokens: [Token] = [
        Token(kind: .keyword(.class), location: SourceLocation(line: 2, column: 1, file: "")),
        Token(kind: .identifier("Foo"), location: SourceLocation(line: 2, column: 7, file: "")),
        Token(kind: .keyword(.inherits), location: SourceLocation(line: 2, column: 11, file: "")),
        Token(kind: .identifier("Bar"), location: SourceLocation(line: 2, column: 20, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 2, column: 24, file: "")),
        Token(kind: .keyword(.let), location: SourceLocation(line: 3, column: 5, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 3, column: 9, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 3, column: 11, file: "")),
        Token(kind: .identifier("Int"), location: SourceLocation(line: 3, column: 13, file: "")),
        Token(kind: .assign, location: SourceLocation(line: 3, column: 17, file: "")),
        Token(kind: .keyword(.if), location: SourceLocation(line: 3, column: 20, file: "")),
        Token(kind: .keyword(.true), location: SourceLocation(line: 3, column: 23, file: "")),
        Token(kind: .keyword(.then), location: SourceLocation(line: 3, column: 28, file: "")),
        Token(kind: .integerLiteral("1"), location: SourceLocation(line: 3, column: 33, file: "")),
        Token(kind: .keyword(.else), location: SourceLocation(line: 3, column: 35, file: "")),
        Token(kind: .integerLiteral("0"), location: SourceLocation(line: 3, column: 40, file: "")),
        Token(kind: .keyword(.fi), location: SourceLocation(line: 3, column: 42, file: "")),
        Token(kind: .keyword(.in), location: SourceLocation(line: 3, column: 45, file: "")),
        Token(kind: .keyword(.while), location: SourceLocation(line: 4, column: 9, file: "")),
        Token(kind: .keyword(.not), location: SourceLocation(line: 4, column: 15, file: "")),
        Token(kind: .keyword(.isvoid), location: SourceLocation(line: 4, column: 19, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 4, column: 26, file: "")),
        Token(kind: .keyword(.loop), location: SourceLocation(line: 4, column: 28, file: "")),
        Token(kind: .keyword(.case), location: SourceLocation(line: 5, column: 13, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 5, column: 18, file: "")),
        Token(kind: .keyword(.of), location: SourceLocation(line: 5, column: 20, file: "")),
        Token(kind: .identifier("n"), location: SourceLocation(line: 6, column: 17, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 6, column: 19, file: "")),
        Token(kind: .identifier("Int"), location: SourceLocation(line: 6, column: 21, file: "")),
        Token(kind: .arrow, location: SourceLocation(line: 6, column: 25, file: "")),
        Token(kind: .identifier("n"), location: SourceLocation(line: 6, column: 28, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 6, column: 29, file: "")),
        Token(kind: .keyword(.esac), location: SourceLocation(line: 7, column: 13, file: "")),
        Token(kind: .keyword(.pool), location: SourceLocation(line: 8, column: 9, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 8, column: 13, file: "")),
        Token(kind: .keyword(.class), location: SourceLocation(line: 11, column: 5, file: "")),
        Token(kind: .identifier("Test"), location: SourceLocation(line: 11, column: 11, file: "")),
        Token(kind: .keyword(.inherits), location: SourceLocation(line: 11, column: 16, file: "")),
        Token(kind: .identifier("Object"), location: SourceLocation(line: 11, column: 25, file: "")),
        Token(kind: .leftBrace, location: SourceLocation(line: 11, column: 32, file: "")),
        Token(kind: .keyword(.if), location: SourceLocation(line: 12, column: 9, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 12, column: 12, file: "")),
        Token(kind: .keyword(.then), location: SourceLocation(line: 12, column: 14, file: "")),
        Token(kind: .identifier("y"), location: SourceLocation(line: 12, column: 19, file: "")),
        Token(kind: .keyword(.else), location: SourceLocation(line: 12, column: 21, file: "")),
        Token(kind: .identifier("z"), location: SourceLocation(line: 12, column: 26, file: "")),
        Token(kind: .keyword(.fi), location: SourceLocation(line: 12, column: 28, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 12, column: 30, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 13, column: 5, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 13, column: 6, file: "")),
        Token(kind: .identifier("x"), location: SourceLocation(line: 16, column: 5, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 16, column: 7, file: "")),
        Token(kind: .identifier("Bool"), location: SourceLocation(line: 16, column: 9, file: "")),
        Token(kind: .assign, location: SourceLocation(line: 16, column: 14, file: "")),
        Token(kind: .keyword(.true), location: SourceLocation(line: 16, column: 17, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 16, column: 21, file: "")),
        Token(kind: .identifier("y"), location: SourceLocation(line: 17, column: 5, file: "")),
        Token(kind: .colon, location: SourceLocation(line: 17, column: 7, file: "")),
        Token(kind: .identifier("Bool"), location: SourceLocation(line: 17, column: 9, file: "")),
        Token(kind: .assign, location: SourceLocation(line: 17, column: 14, file: "")),
        Token(kind: .keyword(.false), location: SourceLocation(line: 17, column: 17, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 17, column: 22, file: "")),
        Token(kind: .rightBrace, location: SourceLocation(line: 18, column: 1, file: "")),
        Token(kind: .semicolon, location: SourceLocation(line: 18, column: 2, file: "")),
        Token(kind: .endOfFile, location: SourceLocation(line: 19, column: 0, file: ""))
    ]
    
    static let diagnostics: [Diagnostic] = []
}
