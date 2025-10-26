//
//  Diagnostic.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public struct Diagnostic: Error {
    public let id: String
    public let severity: DiagnosticSeverity
    public let message: String
    public var startPosition: SourcePosition?
    public var highlights: [any HighlightableToken]
    
    public init(
        id: String,
        severity: DiagnosticSeverity,
        message: String,
        startPosition: SourcePosition? = nil,
        highlights: [any HighlightableToken] = []
    ) {
        self.id = id
        self.severity = severity
        self.message = message
        self.startPosition = startPosition
        self.highlights = highlights
    }
    
    public init(
        _ diagnostic: some DiagnosticConvertible,
        startPosition: SourcePosition? = nil,
        highlights: [any HighlightableToken] = []
    ) {
        self.init(
            id: diagnostic.id,
            severity: diagnostic.severity,
            message: diagnostic.message,
            startPosition: startPosition,
            highlights: highlights
        )
    }
}

extension Diagnostic {
    public consuming func starts(at position: SourcePosition) -> Self {
        startPosition = position
        return self
    }
    
    public consuming func highlights(at token: any HighlightableToken) -> Self {
        highlights.append(token)
        return self
    }
}

public enum DiagnosticSeverity: Equatable, Hashable, Sendable {
    case error, warning, note
}
