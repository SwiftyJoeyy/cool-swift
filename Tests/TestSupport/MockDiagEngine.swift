//
//  MockDiagEngine.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 24/11/2025.
//

import Foundation
import Diagnostics

public final class MockDiagEngine: DiagnosticsEngine {
    public var diags = [Diagnostic]()
    
    public init() { }
    
    public func insert(_ diagnostic: Diagnostic) {
        diags.append(diagnostic)
    }
    public func emit() { }
}
