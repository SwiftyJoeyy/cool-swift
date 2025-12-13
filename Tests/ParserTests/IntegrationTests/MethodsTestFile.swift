//
//  MethodsTestFile.swift
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

enum MethodsTestFile: TestFile {
    static let name = "methods"
    
    static func validate(_ source: SourceFile) throws {
        try #require(source.declarations.count == 1)
        
        try validateCalculatorClass(classDecl: source.declarations[0])
    }
    
    private static func validateCalculatorClass(classDecl: ClassDecl) throws {
        #expect(classDecl.name == "Calculator")
        #expect(classDecl.inheritance == nil)
        
        let methods = classDecl.membersBlock.members.compactMap { $0 as? FuncDecl }
        try #require(methods.count == 7)
        
        try validateResetMethod(method: methods[0])
        try validateSquareMethod(method: methods[1])
        try validateAddMethod(method: methods[2])
        try validateGetStringMethod(method: methods[3])
        try validateGetBoolMethod(method: methods[4])
        try validateGetObjectMethod(method: methods[5])
        try validateProcessMethod(method: methods[6])
    }
    
    private static func validateResetMethod(method: FuncDecl) throws {
        #expect(method.name == "reset")
        #expect(method.parameters.parameters.isEmpty)
        #expect(method.returnClause.type.description == "Int")
        #expect(method.body is IntegerLiteralExpr)
        
        let intLiteral = try #require(method.body as? IntegerLiteralExpr)
        #expect(intLiteral.value == "0")
    }
    
    private static func validateSquareMethod(method: FuncDecl) throws {
        #expect(method.name == "square")
        try #require(method.parameters.parameters.count == 1)
        #expect(method.parameters.parameters[0].name == "x")
        #expect(method.parameters.parameters[0].type.description == "Int")
        #expect(method.returnClause.type.description == "Int")
        #expect(method.body is OperationExpr)
    }
    
    private static func validateAddMethod(method: FuncDecl) throws {
        #expect(method.name == "add")
        try #require(method.parameters.parameters.count == 2)
        #expect(method.parameters.parameters[0].name == "a")
        #expect(method.parameters.parameters[0].type.description == "Int")
        #expect(method.parameters.parameters[1].name == "b")
        #expect(method.parameters.parameters[1].type.description == "Int")
        #expect(method.returnClause.type.description == "Int")
        #expect(method.body is OperationExpr)
    }
    
    private static func validateGetStringMethod(method: FuncDecl) throws {
        #expect(method.name == "getString")
        #expect(method.parameters.parameters.isEmpty)
        #expect(method.returnClause.type.description == "String")
        #expect(method.body is StringLiteralExpr)
        
        let stringLiteral = try #require(method.body as? StringLiteralExpr)
        #expect(stringLiteral.value == "hello")
    }
    
    private static func validateGetBoolMethod(method: FuncDecl) throws {
        #expect(method.name == "getBool")
        #expect(method.parameters.parameters.isEmpty)
        #expect(method.returnClause.type.description == "Bool")
        #expect(method.body is BoolLiteralExpr)
        
        let boolLiteral = try #require(method.body as? BoolLiteralExpr)
        #expect(boolLiteral.value == "true")
    }
    
    private static func validateGetObjectMethod(method: FuncDecl) throws {
        #expect(method.name == "getObject")
        #expect(method.parameters.parameters.isEmpty)
        #expect(method.returnClause.type.description == "Object")
        #expect(method.body is NewExpr)
        
        let newExpr = try #require(method.body as? NewExpr)
        #expect(newExpr.type.description == "Object")
    }
    
    private static func validateProcessMethod(method: FuncDecl) throws {
        #expect(method.name == "process")
        try #require(method.parameters.parameters.count == 1)
        #expect(method.parameters.parameters[0].name == "x")
        #expect(method.parameters.parameters[0].type.description == "Int")
        #expect(method.returnClause.type.description == "Int")
        #expect(method.body is BlockExpr)
        
        let blockExpr = try #require(method.body as? BlockExpr)
        try #require(blockExpr.expressions.count == 2)
        #expect(blockExpr.expressions[0] is FuncCallExpr)
        #expect(blockExpr.expressions[1] is FuncCallExpr)
    }
}
