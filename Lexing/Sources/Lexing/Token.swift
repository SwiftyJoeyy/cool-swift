//
//  Token.swift
//  Lexer
//
//  Created by Joe Maghzal on 24/10/2025.
//

import Foundation

public struct Token: Equatable, Hashable {
    public let kind: TokenKind
    public let location: SourceLocation
}

public struct SourceLocation: Equatable, Hashable {
    public let line: Int
    public let column: Int
    public let file: String
}
