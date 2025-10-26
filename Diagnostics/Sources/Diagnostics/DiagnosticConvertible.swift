//
//  DiagnosticConvertible.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public protocol DiagnosticConvertible {
    var id: String { get }
    
    var severity: DiagnosticSeverity { get }
    
    var message: String { get }
}
