//
//  DiagnosticsOutput.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

import Foundation

public protocol DiagnosticsOutput {
    var supportsColor: Bool { get }
    
    func write(_ text: String)
    
    func format(_ text: String, color: TextColor?, styles: [TextStyle]) -> String
}

extension DiagnosticsOutput {
    public func format(
        _ text: String,
        color: TextColor? = nil,
        styles: [TextStyle] = []
    ) -> String {
        let codes = styles.map(\.rawValue) + (color.map({[$0.rawValue]}) ?? [])
        guard supportsColor, !codes.isEmpty else {
            return text
        }
        return "\u{1B}[\(codes.joined(separator: ";"))m\(text)\u{1B}[0m"
    }
}

public enum TextColor: String, Sendable {
    case black = "30"
    case red = "31"
    case green = "32"
    case yellow = "33"
    case blue = "34"
    case magenta = "35"
    case cyan = "36"
    case white = "37"
}

public enum TextStyle: String, Sendable {
    case bold = "1"
    case dim = "2"
    case italic = "3"
    case underline = "4"
}
