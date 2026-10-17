//
//  ClangCompiler.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

import ArgumentParser
import Foundation

protocol IRCompiler {
    func compile(_ ir: String, to outputURL: URL) throws
}

struct ClangCompiler: IRCompiler {
    let runtimeSource: String
    
    func compile(_ ir: String, to outputURL: URL) throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "coolc-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        
        let irURL = directory.appending(path: "program.ll")
        let runtimeURL = directory.appending(path: "Runtime.c")
        try ir.write(to: irURL, atomically: true, encoding: .utf8)
        try runtimeSource.write(to: runtimeURL, atomically: true, encoding: .utf8)
        
        let clang = Process()
        clang.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        clang.arguments = [
            "clang", "-w",
            irURL.path,
            runtimeURL.path,
            "-o", outputURL.path(percentEncoded: false)
        ]
        try clang.run()
        clang.waitUntilExit()
        
        guard clang.terminationStatus == 0 else {
            throw ExitCode(clang.terminationStatus)
        }
    }
}
