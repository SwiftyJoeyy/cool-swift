//
//  DiagnosticsEngine.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 24/11/2025.
//

public import Basic
import Foundation

public protocol DiagnosticsEngine {
    func insert(_ diagnostic: Diagnostic)
    func emit()
}

extension DiagnosticsEngine {
    public func insert(
        _ diagnostic: any DiagnosticConvertible,
        at location: SourceLocation? = nil
    ) {
        insert(Diagnostic(diagnostic, location: location))
    }
}

public class CoolDiagnosticsEngine: DiagnosticsEngine {
    private let sourceManager: any SourceManageable
    private let output: any DiagnosticsOutput
    private var diagnostics = [Diagnostic]()
    
    public var hasErrors: Bool {
        return diagnostics.contains { $0.severity == .error }
    }
    
    public init(
        sourceManager: any SourceManageable,
        output: any DiagnosticsOutput
    ) {
        self.sourceManager = sourceManager
        self.output = output
    }
    
    public func insert(_ diagnostic: Diagnostic) {
        diagnostics.append(diagnostic)
    }
    
    public func emit() {
        for diagnostic in diagnostics {
            output.write(format(diagnostic))
        }
        diagnostics.removeAll()
    }
    
    private func format(_ diagnostic: Diagnostic) -> String {
        let (severity, color): (String, TextColor) = switch diagnostic.severity {
            case .error: ("error", .red)
            case .warning: ("warning", .yellow)
            case .note: ("note", .cyan)
        }
        let label = output.format("\(severity):", color: color, styles: [.bold])
        let message = output.format(diagnostic.message, styles: [.bold])
        guard let location = diagnostic.location else {
            return "\(label) \(message)\n"
        }
        
        let position = output.format(
            "\(location.file):\(location.line):\(location.column):",
            styles: [.bold]
        )
        var text = "\(position) \(label) \(message)\n"
        if let line = sourceManager.line(at: location) {
            let indent = String(repeating: " ", count: max(location.column - 1, 0))
            let caret = output.format("^", color: color, styles: [.bold])
            text += "\(line)\n\(indent)\(caret)\n"
        }
        return text
    }
}
