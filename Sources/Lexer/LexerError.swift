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
        switch self {
        case .unescapedNewline:
            return "Unescaped newline in string literal"
        case .stringTooLong:
            return "String constant too long"
        case .missingEndQuote:
            return "Missing closing quote for string literal"
        case .stringContainsNull:
            return "String contains null character"
        case .unterminatedComment:
            return "Unterminated comment"
        case .unexpectedCharacter:
            return "Unexpected character"
        case .invalidInteger:
            return "Invalid integer literal"
        case .invalidIdentifier:
            return "Invalid identifier"
        }
    }
}
