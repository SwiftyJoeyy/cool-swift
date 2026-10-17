//
//  CoolSwift.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

import ArgumentParser
import Basic
import CodeGen
import CoreModule
import Diagnostics
import Foundation
import Lexer
import Parser
import Sema

@main
struct CoolCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "coolc",
        abstract: "Cool compiler - compile Cool programs"
    )
    
    @Argument(help: "The source file to compile", transform: URL.init(fileURLWithPath:))
    var input: URL
    
    @Option(
        name: .shortAndLong,
        help: "Write output to <file>",
        transform: URL.init(fileURLWithPath:)
    )
    var output: URL?
    
    @Flag(name: [.short, .customLong("emit-ir")], help: "Emit LLVM IR instead of an executable")
    var emitIR = false
    
    mutating func run() throws {
        let path = input.path(percentEncoded: false)
        let errorOutput = StandardErrorOutput()
        let sourceManager = SourceManager()
        do {
            try sourceManager.registerFile(path)
        } catch {
            errorOutput.write("error: cannot read '\(path)'\n")
            throw ExitCode.failure
        }
        let diagnostics = CoolDiagnosticsEngine(
            sourceManager: sourceManager,
            output: errorOutput
        )
        
        let ir: String
        do {
            ir = try generateIR(at: path, sourceManager: sourceManager, diagnostics: diagnostics)
        } catch let diagnostic as Diagnostic {
            diagnostics.insert(diagnostic)
            diagnostics.emit()
            throw ExitCode.failure
        }
        
        if emitIR {
            let outputURL = output ?? input.deletingPathExtension().appendingPathExtension("ll")
            try ir.write(to: outputURL, atomically: true, encoding: .utf8)
        } else {
            let compiler = ClangCompiler(runtimeSource: CoreModule.runtimeSource)
            try compiler.compile(ir, to: output ?? input.deletingPathExtension())
        }
    }
    
    private func generateIR(
        at path: String,
        sourceManager: SourceManager,
        diagnostics: CoolDiagnosticsEngine
    ) throws -> String {
        let interfaceSymbols = ModuleInterfaceSymbols()
        try interfaceSymbols.load(CoreModule.interface(using: diagnostics))
        
        let contents = sourceManager.sourceFiles.first { $0.path == path }?.contents ?? ""
        var parser = try CoolParser(
            lexemes: Lexemes(lexer: CoolLexer(contents, file: path)),
            diagnostics: diagnostics
        )
        let sourceFile = try parser.parse()
        try stopIfErrors(in: diagnostics)
        
        let sema = Sema(diagnostics: diagnostics, interfaceSymbols: interfaceSymbols)
        let resolved = try sema.analyze(sourceFile)
        try sema.checkEntryPoint(resolved)
        try stopIfErrors(in: diagnostics)
        
        return IRGenerator(source: resolved).generate()
    }
    
    /// Parsing recovers from some errors, so they're collected instead of thrown.
    private func stopIfErrors(in diagnostics: CoolDiagnosticsEngine) throws {
        guard diagnostics.hasErrors else { return }
        diagnostics.emit()
        throw ExitCode.failure
    }
}
