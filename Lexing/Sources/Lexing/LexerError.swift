//
//  LexerError.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Diagnostics

public enum LexerError {
    case unescapedNewline
    case stringTooLong
    case missingEndQuote
    case stringContainsNull
    
    case unterminatedComment
    
    case unexpectedCharacter
    
    case invalidInteger
    case invalidIdentifier
}

extension LexerError: DiagnosticConvertible {
    public var id: String {
        return "LexerError-\(self)"
    }
    
    public var severity: Diagnostics.DiagnosticSeverity {
        return .error
    }
    
    public var message: String {
        return "\(self)"
    }
}
