//
//  LexerError.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Diagnostics

internal enum LexerError {
    case unescapedNewline
    case stringTooLong
    case missingEndQuote
    case stringContainsNull
    
    case unterminatedComment
    case reachedEndOfFile
    case invalidInteger
}

extension LexerError: DiagnosticConvertible {
    var id: String {
        return "LexerError-\(self)"
    }
    
    var severity: Diagnostics.DiagnosticSeverity {
        return .error
    }
    
    var message: String {
        return "\(self)"
    }
}

extension Diagnostic {
    @_disfavoredOverload internal init(
        _ error: LexerError,
        startPosition: SourcePosition? = nil,
        highlights: [any HighlightableToken] = []
    ) {
        self.init(error, startPosition: startPosition, highlights: highlights)
    }
}
