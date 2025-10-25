////
////  IntegerLiteralLexer.swift
////  Lexing
////
////  Created by Joe Maghzal on 25/10/2025.
////
//
//import Foundation
//
//internal struct IntegerLiteralLexer {
//    private let location: SourceLocation
//    private var length = 0
//    private var literal = ""
//    
//    internal init(location: SourceLocation, literal: String) {
//        self.location = location
//        self.literal = literal
//    }
//}
//
//extension IntegerLiteralLexer: TokenLexer {
//    internal mutating func lexing(
////        _ char: Char,
//        at location: SourceLocation
//    ) -> LexingResult {
//        if char == " " { #warning("This is just for testing, fix it!")
//            return .found(
//                Token(
//                    kind: .integerLiteral(literal),
//                    location: self.location
//                )
//            )
//        }
//        literal.append(String(char))
//        length += 1
//        return .continue
//    }
//    
//    internal static func matches(_ char: Char) -> Bool {
//        switch char {
//            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
//                return true
//            default:
//                return false
//        }
//    }
//    
//    internal static func new(for char: Char, at location: SourceLocation) -> Self {
//        return IntegerLiteralLexer(location: location, literal: String(char))
//    }
//}
