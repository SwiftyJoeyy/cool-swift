//
//  CoreModule.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

public import AST
public import Diagnostics
import Foundation
import Lexer
import Parser

public enum CoreModule {
    public static var runtimeSource: String {
        return EmbeddedResources.runtimeC
    }
    
    public static func interface(
        using diagnostics: some DiagnosticsEngine
    ) throws -> InterfaceFile {
        let source = EmbeddedResources.coreClmodule

        var parser = try CoolParser(
            lexemes: Lexemes(lexer: CoolLexer(source, file: "Core.clmodule")),
            diagnostics: diagnostics
        )
        return try parser.parseInterface()
    }
}
