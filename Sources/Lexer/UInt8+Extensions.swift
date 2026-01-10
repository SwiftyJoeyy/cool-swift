//
//  UInt8+Extensions.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

extension UInt8 {
    /// Valid separators
    internal static let separators: Set<UInt8> = [.space, .newline, .tab, .carriageReturn]
    
    /// 13
    internal static let carriageReturn = UInt8(ascii: "\r")
    
    /// 10
    internal static let newline = UInt8(ascii: "\n")
    
    /// 92
    internal static let backslash = UInt8(ascii: "\\")
    
    /// 34
    internal static let quote = UInt8(ascii: "\"")
    
    /// 32
    internal static let space = UInt8(ascii: " ")
    
    /// 9
    internal static let tab = UInt8(ascii: "\t")
    
    /// 8
    internal static let backspace = UInt8(ascii: "\u{08}")
    
    /// 12
    internal static let formfeed = UInt8(ascii: "\u{0C}")
    
    internal var unicode: String {
        return String(UnicodeScalar(self))
    }
    
    internal var validSeparator: Bool {
        return Self.separators.contains(self)
    }
}

extension UInt8? {
    internal static func == (i: Self, s: Unicode.Scalar) -> Bool {
        return i == UInt8(ascii: s)
    }
    
    internal static func != (i: Self, s: Unicode.Scalar) -> Bool {
        return i != UInt8(ascii: s)
    }
    
    internal static func ~= (s: Unicode.Scalar, i: Self) -> Bool {
        return i == UInt8(ascii: s)
    }
}
    
extension UInt8 {
    internal static func > (i: Self, s: Unicode.Scalar) -> Bool {
        return i > UInt8(ascii: s)
    }
    
    internal static func >= (i: Self, s: Unicode.Scalar) -> Bool {
        return i >= UInt8(ascii: s)
    }
    
    internal static func < (i: Self, s: Unicode.Scalar) -> Bool {
        return i > UInt8(ascii: s)
    }
    
    internal static func <= (i: Self, s: Unicode.Scalar) -> Bool {
        return i <= UInt8(ascii: s)
    }
}
