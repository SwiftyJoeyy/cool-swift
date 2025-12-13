// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import Lexer
import Basic

@main
struct CoolCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "coolc")
    
    @Argument(transform: URL.init(fileURLWithPath:)) var fileURL: URL
    
    mutating func run() throws {
    }
}
