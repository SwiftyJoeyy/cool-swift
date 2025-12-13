//
//  MockDiagEngine.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 24/11/2025.
//

import Foundation
import Diagnostics

class MockDiagEngine: DiagnosticsEngine {
    var diags = [Diagnostic]()
    func insert(_ diagnostic: Diagnostic) {
        diags.append(diagnostic)
    }
    func emit() { }
}
