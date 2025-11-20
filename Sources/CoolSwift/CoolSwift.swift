// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import Lexer

@main
struct CoolCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "coolc")
    
    @Argument(transform: URL.init(fileURLWithPath:)) var fileURL: URL
    
    mutating func run() throws {
        let contents = try String(contentsOf: fileURL)
        var lexer = CoolLexer(contents)
        
        while !lexer.reachedEnd {
            do {
                _ = try lexer.next()
            } catch {
                if let location = error.location {
                    print("Error at line \(location.line) column \(location.column)")
                }
                print(error.message)
            }
        }
    }
}
