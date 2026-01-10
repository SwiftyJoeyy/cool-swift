//
//  Diagnostic.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Basic

public struct Diagnostic: Error {
    public let id: String
    public let severity: DiagnosticSeverity
    public let message: String
    public var location: SourceLocation?
    
#if DEBUG
    public var debugInfo: String?
#endif
    
    public init(
        id: String,
        severity: DiagnosticSeverity,
        message: String,
        location: SourceLocation? = nil,
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

extension Diagnostic: Equatable, Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.severity == rhs.severity && lhs.message == rhs.message && lhs.location == rhs.location
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(severity)
        hasher.combine(message)
        hasher.combine(location)
    }
}

extension Diagnostic {
    public consuming func starts(at location: SourceLocation) -> Self {
        self.location = location
        return self
    }
    
#if DEBUG
    internal consuming func debugInfo(_ info: String) -> Self {
        self.debugInfo = info
        return self
    }
#endif
}

public enum DiagnosticSeverity: Equatable, Hashable, Sendable {
    case error, warning, note
}
