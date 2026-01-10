//
//  SimpleTestFile.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 06/12/2025.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
@testable import Parser

enum SimpleTestFile: TestFile {
    static let name = "simple"
    
    static func validate(_ source: SourceFile) throws {
        try #require(source.declarations.count == 1)
        
        try validateMainClass(classDecl: source.declarations[0])
    }
    
    private static func validateMainClass(classDecl: ClassDecl) throws {
        #expect(classDecl.name.value == "Main")
        #expect(classDecl.inheritance == nil)
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 2)
        
        // Validate property 'x : Int <- 42'
        let xProperty = try #require(members[0] as? VarDecl)
        #expect(xProperty.name.value == "x")
        #expect(xProperty.typeAnnotation.type.description == "Int")
        #expect(xProperty.initializer != nil)
        
        let initializer = try #require(xProperty.initializer?.expr as? IntegerLiteralExpr)
        #expect(initializer.value == "42")
        
        // Validate method 'main() : Int'
        let mainMethod = try #require(members[1] as? FuncDecl)
        #expect(mainMethod.name.value == "main")
        #expect(mainMethod.parameters.parameters.isEmpty)
        #expect(mainMethod.returnClause.type.description == "Int")
        
        // Validate method body
        let body = try #require(mainMethod.body as? DeclRefExpr)
        #expect(body.name == "x")
    }
}
