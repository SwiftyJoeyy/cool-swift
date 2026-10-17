//
//  ExampleProgramTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

import CodeGen
import CoreModule
import Foundation
import Parser
import Sema
import TestSupport
import Testing

/// Compiles each program in `Examples/` against the core module runtime, runs it
/// and compares its output with `Expected/<name>.out`.
@Suite struct ExampleProgramTests {
    struct Example: Sendable, CustomTestStringConvertible {
        let name: String
        var exitCode: Int32 = 0

        var testDescription: String {
            return name
        }
    }

    static let examples = [
        Example(name: "arith"),
        Example(name: "atoi"),
        Example(name: "cells"),
        Example(name: "hello-world"),
        Example(name: "hs"),
        Example(name: "list"),
        Example(name: "new-complex"),
        // Ends by calling `abort()` on purpose.
        Example(name: "primes", exitCode: 1),
        Example(name: "print-cool"),
        Example(name: "sort-list")
    ]

    /// The package root, found relative to this file.
    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

// MARK: - Tests
    @Test(arguments: examples)
    func `compiles and runs example`(example: Example) throws {
        let sourceURL = Self.root.appending(path: "Examples/\(example.name).cl")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)
        let ir = try generateIR(source, file: sourceURL.lastPathComponent)

        let directory = FileManager.default.temporaryDirectory
            .appending(path: "CodeGenTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let irURL = directory.appending(path: "\(example.name).ll")
        try ir.write(to: irURL, atomically: true, encoding: .utf8)

        let runtimeURL = directory.appending(path: "Runtime.c")
        try CoreModule.runtimeSource.write(to: runtimeURL, atomically: true, encoding: .utf8)
        
        let executable = directory.appending(path: example.name)
        let compile = try run(
            "/usr/bin/env",
            ["clang", "-w", irURL.path, runtimeURL.path, "-o", executable.path]
        )
        try #require(compile.status == 0, "clang failed:\n\(compile.stderr)")

        let input = try expected(example.name, extension: "in") ?? ""
        let result = try run(executable.path, [], input: input)
        let output = try #require(try expected(example.name, extension: "out"))

        #expect(result.status == example.exitCode, "stderr:\n\(result.stderr)")
        #expect(result.stdout == output)
    }

// MARK: - Functions
    private func generateIR(_ source: String, file: String) throws -> String {
        let interface = try CoreModule.interface(using: MockDiagEngine())
        let symbols = ModuleInterfaceSymbols()
        try symbols.load(interface)

        var (parser, diagEngine) = try CoolParser.new(source: source, file: file)
        let sema = Sema(diagnostics: diagEngine, interfaceSymbols: symbols)
        let resolved = try sema.analyze(parser.parse())
        try sema.checkEntryPoint(resolved)
        return IRGenerator(source: resolved).generate()
    }

    private func expected(_ name: String, extension ext: String) throws -> String? {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: ext,
            subdirectory: "Expected"
        ) else {
            return nil
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func run(
        _ executable: String,
        _ arguments: [String],
        input: String = ""
    ) throws -> (status: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stdin = Pipe()
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardInput = stdin
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        stdin.fileHandleForWriting.write(Data(input.utf8))
        try stdin.fileHandleForWriting.close()

        // Read before waiting so a full pipe can't block the process.
        let output = stdout.fileHandleForReading.readDataToEndOfFile()
        let errors = stderr.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        return (
            process.terminationStatus,
            String(decoding: output, as: UTF8.self),
            String(decoding: errors, as: UTF8.self)
        )
    }
}
