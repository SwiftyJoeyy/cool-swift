//
//  DiagnosticConvertible.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation
import Basic

public protocol DiagnosticConvertible {
    var id: String { get }
    
    var severity: DiagnosticSeverity { get }
    
    var message: String { get }
}

extension DiagnosticConvertible {
    @discardableResult public func diagnostic(
        at location: SourceLocation? = nil
    ) -> Diagnostic {
        return Diagnostic(self, location: location)
    }
}
