//
//  Diagnostic.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Basic

public struct Diagnostic: Error, Equatable, Hashable, Sendable {
    public let id: String
    public let severity: DiagnosticSeverity
    public let message: String
    public var location: SourceLocation?
    
    public init(
        id: String,
        severity: DiagnosticSeverity,
        message: String,
        location: SourceLocation? = nil
    ) {
        self.id = id
        self.severity = severity
        self.message = message
        self.location = location
    }
    
    public init(
        _ diagnostic: some DiagnosticConvertible,
        location: SourceLocation? = nil
    ) {
        self.init(
            id: diagnostic.id,
            severity: diagnostic.severity,
            message: diagnostic.message,
            location: location
        )
    }
}

extension Diagnostic {
    public consuming func starts(at location: SourceLocation) -> Self {
        self.location = location
        return self
    }
}

public enum DiagnosticSeverity: Equatable, Hashable, Sendable {
    case error, warning, note
}
