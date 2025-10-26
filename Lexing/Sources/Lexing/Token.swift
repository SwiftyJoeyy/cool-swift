//
//  Token.swift
//  Lexer
//
//  Created by Joe Maghzal on 24/10/2025.
//

import Foundation
import Diagnostics

public struct Token: Equatable, Hashable, Sendable {
    public let kind: TokenKind
    public let location: SourceLocation
}

public struct SourceLocation: Equatable, Hashable, Sendable {
    public let line: Int
    public let column: Int
    public let file: String
}

extension SourceLocation: SourcePositionRepresentible {
    public var position: SourcePosition {
        return SourcePosition(offset: 0)
    }
}
