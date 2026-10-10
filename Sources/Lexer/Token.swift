//
//  Token.swift
//  Lexer
//
//  Created by Joe Maghzal on 24/10/2025.
//

public import Basic
import Foundation

public struct Token: Equatable, Hashable, Sendable {
    public let kind: TokenKind
    public let location: SourceLocation
}
