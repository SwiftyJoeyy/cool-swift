// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import Lexer
import Basic
import CodeGen
import Sema
import Diagnostics
import Parser
import AST

@main
struct CoolCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "coolc",
        abstract: "Cool compiler - compile Cool programs"
    )
    
    @Argument(help: "The source file to compile", transform: URL.init(fileURLWithPath:))
    var input: URL
    
    @Option(name: .shortAndLong, help: "Write output to <file>")
    var output: String?
    
    @Flag(name: .short, help: "Emit LLVM IR instead of an executable")
    var emitIR: Bool = false
    
    mutating func run() throws {
        let outputURL: URL
        if emitIR {
            outputURL = input.deletingPathExtension().appendingPathExtension("ll")
        } else {
            outputURL = input.deletingPathExtension().appendingPathExtension("ll")
        }
        
//        let sourceManager = SourceManager()
//        try sourceManager.registerFile(input.path(percentEncoded: false))
//        
//        let diagnostics = CoolDiagnosticsEngine(sourceManager: sourceManager)
//        
//        let moduleInterface = ModuleInterfaceSymbols()
//        let interfaceFile = try ModuleInterfaceParser.parse(using: diagnostics)
//        try moduleInterface.load(interfaceFile)
//    
//        let file = sourceManager.sourceFiles.first!
//        let lexer = CoolLexer(file.contents, file: file.path)
//        var parser = try CoolParser(
//            lexemes: Lexemes(lexer: lexer),
//            diagnostics: diagnostics
//        )
//        
//        let sema = Sema(
//            diagnostics: diagnostics,
//            interfaceSymbols: moduleInterface
//        )
//        let typeSystem = try sema.analyze(parser.parse())
//        try sema.checkEntryPoint(typeSystem: typeSystem)
//        let irGenerator = IRGenerator(
//            typeSystem: typeSystem
//        )
//        let data = irGenerator.generate().data(using: .utf8)
//        try data?.write(to: outputURL)
//        
    }
}

enum ModuleInterfaceParser {
    static func parse(
        using diagnostics: some DiagnosticsEngine
    ) throws -> InterfaceFile {
        let bundle = Bundle.module
        guard let path = bundle.path(forResource: "Core", ofType: "clmodule", inDirectory: "Resources") else {
            throw NSError(domain: "", code: 0)
        }
        
        let contents = try String(contentsOfFile: path, encoding: .utf8)
        
        let lexer = CoolLexer(contents, file: path)
        var parser = try CoolParser(
            lexemes: Lexemes(lexer: lexer),
            diagnostics: diagnostics
        )
        
        return try parser.parseInterface()
    }
}
