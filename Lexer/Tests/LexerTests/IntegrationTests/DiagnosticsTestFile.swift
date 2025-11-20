//
//  DiagnosticsTest.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
import Foundation
import Diagnostics
@testable import Lexer

enum DiagnosticsTestFile: TestFile {
    static let name = "diagnostics"
    
    static let tokens: [Token] = [
        Token(kind: TokenKind.keyword(Keyword.class), location: SourceLocation(line: 2, column: 1, file: "")),
        Token(kind: TokenKind.identifier("Test"), location: SourceLocation(line: 2, column: 7, file: "")),
        Token(kind: TokenKind.leftBrace, location: SourceLocation(line: 2, column: 12, file: "")),
        Token(kind: TokenKind.identifier("x"), location: SourceLocation(line: 3, column: 5, file: "")),
        Token(kind: TokenKind.colon, location: SourceLocation(line: 3, column: 7, file: "")),
        Token(kind: TokenKind.identifier("Int"), location: SourceLocation(line: 3, column: 9, file: "")),
        Token(kind: TokenKind.assign, location: SourceLocation(line: 3, column: 13, file: "")),
        Token(kind: TokenKind.identifier("y"), location: SourceLocation(line: 4, column: 5, file: "")),
        Token(kind: TokenKind.colon, location: SourceLocation(line: 4, column: 7, file: "")),
        Token(kind: TokenKind.identifier("String"), location: SourceLocation(line: 4, column: 9, file: "")),
        Token(kind: TokenKind.assign, location: SourceLocation(line: 4, column: 16, file: "")),
        Token(kind: TokenKind.semicolon, location: SourceLocation(line: 5, column: 9, file: "")),
        Token(kind: TokenKind.identifier("z"), location: SourceLocation(line: 6, column: 5, file: "")),
        Token(kind: TokenKind.colon, location: SourceLocation(line: 6, column: 7, file: "")),
        Token(kind: TokenKind.identifier("Int"), location: SourceLocation(line: 6, column: 9, file: "")),
        Token(kind: TokenKind.assign, location: SourceLocation(line: 6, column: 13, file: "")),
        Token(kind: TokenKind.identifier("w"), location: SourceLocation(line: 7, column: 5, file: "")),
        Token(kind: TokenKind.colon, location: SourceLocation(line: 7, column: 7, file: "")),
        Token(kind: TokenKind.identifier("String"), location: SourceLocation(line: 7, column: 9, file: "")),
        Token(kind: TokenKind.assign, location: SourceLocation(line: 7, column: 16, file: ""))
    ]
    
    static let diagnostics: [Diagnostic] = [
        Diagnostic(LexerError.invalidInteger, location: SourceLocation(line: 3, column: 16, file: "")),
        Diagnostic(LexerError.unescapedNewline, location: SourceLocation(line: 4, column: 19, file: "")),
        Diagnostic(LexerError.invalidInteger, location: SourceLocation(line: 6, column: 16, file: "")),
        Diagnostic(LexerError.unescapedNewline, location: SourceLocation(line: 7, column: 19, file: ""))
    ]
}
