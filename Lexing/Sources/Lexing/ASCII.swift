//
//  ASCII.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

internal enum ASCII {
    /// 10
    internal static let newline = UInt8(ascii: "\n")
    
    /// 92
    internal static let backslash = UInt8(ascii: "\\")
    
    /// 34
    internal static let quote = UInt8(ascii: "\"")
    
    /// 32
    internal static let space = UInt8(ascii: " ")
}
