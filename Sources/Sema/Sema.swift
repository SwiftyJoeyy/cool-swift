//
//  Sema.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 20/12/2025.
//

import Foundation
import AST
import Basic
import Diagnostics

public struct Sema {
    private let diagnostics: DiagnosticsEngine
    private let symbols = SymbolTable()
    
    public init(diagnostics: DiagnosticsEngine) {
        self.diagnostics = diagnostics
        registerCoreTypes()
    }
    
    public func analyze(_ source: SourceFile) throws(Diagnostic) {
        try SymbolTableBuilder(symbols: symbols).build(from: source.declarations)
        let typeSystem = TypeSystem(symbols: symbols)
        
        for symbol in symbols.symbols {
            try typeSystem.typeCheck(symbol)
        }
    }
    
    private func registerCoreTypes() {
        symbols.insert(ClassSymbol(decl: .object))
        symbols.insert(ClassSymbol(decl: .io))
        symbols.insert(ClassSymbol(decl: .string))
        symbols.insert(ClassSymbol(decl: .int))
        symbols.insert(ClassSymbol(decl: .bool))
    }
}

#warning("Remove these & parse them using clmodule")
extension ClassDecl {
    fileprivate static var object: ClassDecl {
        return ClassDecl(
            name: Identifier(value: "Object", location: .empty),
            inheritance: nil,
            membersBlock: MembersBlock(members: [], location: .empty),
            location: .empty
        )
    }
    fileprivate static var io: ClassDecl {
        return ClassDecl(
            name: Identifier(value: "IO", location: .empty),
            inheritance: nil,
            membersBlock: MembersBlock(members: [], location: .empty),
            location: .empty
        )
    }
    fileprivate static var string: ClassDecl {
        return ClassDecl(
            name: Identifier(value: "String", location: .empty),
            inheritance: nil,
            membersBlock: MembersBlock(members: [], location: .empty),
            location: .empty
        )
    }
    fileprivate static var int: ClassDecl {
        return ClassDecl(
            name: Identifier(value: "Int", location: .empty),
            inheritance: nil,
            membersBlock: MembersBlock(members: [], location: .empty),
            location: .empty
        )
    }
    fileprivate static var bool: ClassDecl {
        return ClassDecl(
            name: Identifier(value: "Bool", location: .empty),
            inheritance: nil,
            membersBlock: MembersBlock(members: [], location: .empty),
            location: .empty
        )
    }
}
