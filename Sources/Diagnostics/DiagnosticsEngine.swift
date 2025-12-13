//
//  DiagnosticsEngine.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 24/11/2025.
//

import Foundation
import Basic

public protocol DiagnosticsEngine {
    func insert(_ diagnostic: Diagnostic)
    func emit()
}

extension DiagnosticsEngine {
    public func insert(
        _ diagnostic: DiagnosticConvertible,
        at location: SourceLocation? = nil
    ) {
        insert(Diagnostic(diagnostic, location: location))
    }
}

public class CoolDiagnosticsEngine: DiagnosticsEngine {
    private let sourceManager: SourceManageable
    private var diagnostics = [Diagnostic]()
    
    public init(sourceManager: some SourceManageable) {
        self.sourceManager = sourceManager
    }
    
    public func insert(_ diagnostic: Diagnostic) {
        diagnostics.append(diagnostic)
    }
    
    public func emit() {
        #warning("Implement this")
    }
}
