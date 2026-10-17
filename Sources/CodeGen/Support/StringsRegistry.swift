//
//  StringsRegistry.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

/// Interns C string constants and emits them as private globals.
final class StringsRegistry {
    private var globals = [String: String]()
    private var definitions = [String]()
    
    func generate() -> String {
        return definitions.joined(separator: "\n")
    }
    
    func global(for value: String) -> String {
        if let global = globals[value] {
            return global
        }
        let global = "@.str.\(globals.count)"
        globals[value] = global
        
        let bytes = Array(value.utf8) + [0]
        let literal = bytes.map(escape).joined()
        definitions.append(
            "\(global) = private unnamed_addr constant [\(bytes.count) x i8] c\"\(literal)\""
        )
        return global
    }
    
    private func escape(_ byte: UInt8) -> String {
        let isPrintable = (0x20...0x7E).contains(byte)
        guard isPrintable, byte != UInt8(ascii: "\""), byte != UInt8(ascii: "\\") else {
            return String(format: "\\%02X", byte)
        }
        return String(UnicodeScalar(byte))
    }
}
