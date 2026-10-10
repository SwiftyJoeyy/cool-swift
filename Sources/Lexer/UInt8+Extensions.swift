//
//  UInt8+Extensions.swift
//  Lexing
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

extension UInt8 {
    /// Valid separators
    static let separators: Set<UInt8> = [.space, .newline, .tab, .carriageReturn]
    
    /// 13
    static let carriageReturn = UInt8(ascii: "\r")
    
    /// 10 
    static let newline = UInt8(ascii: "\n")
    
    /// 92
    static let backslash = UInt8(ascii: "\\")
    
    /// 34
    static let quote = UInt8(ascii: "\"")
    
    /// 32
    static let space = UInt8(ascii: " ")
    
    /// 9
    static let tab = UInt8(ascii: "\t")
    
    /// 8
    static let backspace = UInt8(ascii: "\u{08}")
    
    /// 12
    static let formfeed = UInt8(ascii: "\u{0C}")
    
    var unicode: String {
        return String(UnicodeScalar(self))
    }
    
    var validSeparator: Bool {
        return Self.separators.contains(self)
    }
}

extension UInt8? {
    static func == (i: Self, s: Unicode.Scalar) -> Bool {
        return i == UInt8(ascii: s)
    }
    
    static func != (i: Self, s: Unicode.Scalar) -> Bool {
        return i != UInt8(ascii: s)
    }
    
    static func ~= (s: Unicode.Scalar, i: Self) -> Bool {
        return i == UInt8(ascii: s)
    }
}
    
extension UInt8 {
    static func > (i: Self, s: Unicode.Scalar) -> Bool {
        return i > UInt8(ascii: s)
    }
    
    static func >= (i: Self, s: Unicode.Scalar) -> Bool {
        return i >= UInt8(ascii: s)
    }
    
    static func < (i: Self, s: Unicode.Scalar) -> Bool {
        return i > UInt8(ascii: s)
    }
    
    static func <= (i: Self, s: Unicode.Scalar) -> Bool {
        return i <= UInt8(ascii: s)
    }
}
