//
//  ExpressionsTestFile.swift
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

enum ExpressionsTestFile: TestFile {
    static let name = "expressions"
    
    static func validate(_ source: SourceFile) throws {
        try #require(source.declarations.count == 1)
        
        try validateExprTestClass(classDecl: source.declarations[0])
    }
    
    private static func validateExprTestClass(classDecl: ClassDecl) throws {
        #expect(classDecl.name.value == "ExprTest")
        #expect(classDecl.inheritance == nil)
        
        let methods = classDecl.membersBlock.members.compactMap { $0 as? FuncDecl }
        try #require(methods.count == 5)
        
        try validateComputeMethod(method: methods[0])
        try validateCheckMethod(method: methods[1])
        try validateFactorialMethod(method: methods[2])
        try validateCalculateMethod(method: methods[3])
        try validateCreateMethod(method: methods[4])
    }
    
    private static func validateComputeMethod(method: FuncDecl) throws {
        #expect(method.name.value == "compute")
        try #require(method.parameters.parameters.count == 2)
        #expect(method.parameters.parameters[0].name.value == "x")
        #expect(method.parameters.parameters[0].type.description == "Int")
        #expect(method.parameters.parameters[1].name.value == "y")
        #expect(method.parameters.parameters[1].type.description == "Int")
        #expect(method.returnClause.type.description == "Bool")
        #expect(method.body is OperationExpr)
    }
    
    private static func validateCheckMethod(method: FuncDecl) throws {
        #expect(method.name.value == "check")
        try #require(method.parameters.parameters.count == 1)
        #expect(method.parameters.parameters[0].name.value == "val")
        #expect(method.parameters.parameters[0].type.description == "Int")
        #expect(method.returnClause.type.description == "String")
        #expect(method.body is IfExpr)
        
        let ifExpr = try #require(method.body as? IfExpr)
        #expect(ifExpr.condition is OperationExpr)
        #expect(ifExpr.thenBody is StringLiteralExpr)
        #expect(ifExpr.elseBody is IfExpr)
    }
    
    private static func validateFactorialMethod(method: FuncDecl) throws {
        #expect(method.name.value == "factorial")
        try #require(method.parameters.parameters.count == 1)
        #expect(method.parameters.parameters[0].name.value == "n")
        #expect(method.returnClause.type.description == "Int")
        #expect(method.body is LetExpr)
        
        let letExpr = try #require(method.body as? LetExpr)
        try #require(letExpr.bindings.count == 1)
        #expect(letExpr.bindings[0].name.value == "result")
        #expect(letExpr.body is LetExpr)
    }
    
    private static func validateCalculateMethod(method: FuncDecl) throws {
        #expect(method.name.value == "calculate")
        #expect(method.parameters.parameters.isEmpty)
        #expect(method.returnClause.type.description == "Int")
        #expect(method.body is LetExpr)
        
        let letExpr = try #require(method.body as? LetExpr)
        try #require(letExpr.bindings.count == 1)
        #expect(letExpr.bindings[0].name.value == "x")
        #expect(letExpr.body is LetExpr)
    }
    
    private static func validateCreateMethod(method: FuncDecl) throws {
        #expect(method.name.value == "create")
        #expect(method.parameters.parameters.isEmpty)
        #expect(method.returnClause.type.description == "Object")
        #expect(method.body is NewExpr)
        
        let newExpr = try #require(method.body as? NewExpr)
        #expect(newExpr.type.description == "Object")
    }
}
