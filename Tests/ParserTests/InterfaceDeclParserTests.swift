//
//  InterfaceDeclParserTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 14/01/2026.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
@testable import Parser

@Suite struct InterfaceFuncDeclParserTests {
// MARK: - Functions
    private func parse(_ source: String) throws -> InterfaceFuncDecl {
        var parser = try CoolParser.new(source: source).parser
        return try InterfaceFuncDeclParser.parse(from: &parser)
    }
    private func parseWithDiags(
        _ source: String
    ) throws -> (decl: InterfaceFuncDecl, diags: [Diagnostic]) {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        return (try InterfaceFuncDeclParser.parse(from: &parser), diagEngine.diags)
    }
    
// MARK: - Tests
    @Test func `parses interface function without parameters`() throws {
        let source = "main() : Int"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.name.value == "main")
        #expect(funcDecl.parameters.parameters.isEmpty)
    }
    
    @Test func `parses interface function with single parameter`() throws {
        let source = "add(x : Int) : Int"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.name.value == "add")
        
        let params = funcDecl.parameters.parameters
        try #require(params.count == 1)
        
        let param = params[0]
        #expect(param.name.value == "x")
        #expect(param.type.description == "Int")
    }
    
    @Test func `parses interface function with multiple parameters`() throws {
        let expectedParams = [("x", "Int"), ("y", "String"), ("z", "Bool")]
        let source = "calculate(x : Int, y : String, z : Bool) : Object"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.name.value == "calculate")
        
        let params = funcDecl.parameters.parameters
        try #require(params.count == expectedParams.count)
        
        for i in 0..<expectedParams.count {
            let param = params[i]
            let expectedParam = expectedParams[i]
            #expect(param.name.value == expectedParam.0)
            #expect(param.type.description == expectedParam.1)
        }
    }
    
    @Test func `parses interface function return type`() throws {
        let source = "get() : Object"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.returnClause.type.description == "Object")
    }
    
// MARK: - Error Cases
    @Test func `reports error on missing function name`() throws {
        let source = "() : Int"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedFuncName.id)
    }
    
    @Test func `reports error on missing opening paren`() throws {
        let source = "foo) : Int"
        
        let (_, diags) = try parseWithDiags(source)
        try #require(diags.count == 1)
        #expect(diags[0].id == ParserError.expectedSymbol(.leftParen).id)
    }
    
    @Test func `reports error on missing closing paren`() throws {
        let source = "foo( : Int"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightParen).id)
    }
    
    @Test func `reports error on missing colon before return type`() throws {
        let source = "foo() Int"
        
        let (_, diags) = try parseWithDiags(source)
        try #require(diags.count == 1)
        #expect(diags[0].id == ParserError.expectedSymbol(.colon).id)
    }
    
    @Test func `reports error on missing return type`() throws {
        let source = "foo() :"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedType.id)
    }
    
    @Test func `reports error on missing parameter type`() throws {
        let source = "foo(x) : Int"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedType.id)
    }
    
    @Test func `reports error on missing parameter name`() throws {
        let source = "foo(: Int) : Int"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedParamName.id)
    }
    
    @Test func `reports error on missing comma between parameters`() throws {
        let source = "foo(x : Int y : String) : Int"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightParen).id)
    }
}

@Suite struct InterfaceVarDeclParserTests {
// MARK: - Functions
    private func parse(_ source: String) throws -> InterfaceVarDecl {
        var parser = try CoolParser.new(source: source).parser
        return try InterfaceVarDeclParser.parse(from: &parser)
    }
    private func parseWithDiags(
        _ source: String
    ) throws -> (decl: InterfaceVarDecl, diags: [Diagnostic]) {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        return (try InterfaceVarDeclParser.parse(from: &parser), diagEngine.diags)
    }
    
// MARK: - Basic Interface Variable Declaration Tests
    @Test func `parses interface variable`() throws {
        let source = "x : Int"
        let varDecl = try parse(source)
        
        #expect(varDecl.name.value == "x")
        #expect(varDecl.typeAnnotation.type.description == "Int")
    }
    
    @Test func `parses interface variable with String type`() throws {
        let source = "msg : String"
        let varDecl = try parse(source)
        
        #expect(varDecl.name.value == "msg")
        #expect(varDecl.typeAnnotation.type.description == "String")
    }
    
    @Test func `parses interface variable with Bool type`() throws {
        let source = "flag : Bool"
        let varDecl = try parse(source)
        
        #expect(varDecl.name.value == "flag")
        #expect(varDecl.typeAnnotation.type.description == "Bool")
    }
    
    @Test func `parses interface variable with custom type`() throws {
        let source = "obj : Point"
        let varDecl = try parse(source)
        
        #expect(varDecl.name.value == "obj")
        #expect(varDecl.typeAnnotation.type.description == "Point")
    }
    
// MARK: - Error Cases
    @Test func `reports error on missing variable name`() throws {
        let source = ": Int"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedVarName.id)
    }
    
    @Test func `reports error on missing colon and parses`() throws {
        let source = "x Int"
        
        let (varDecl, diags) = try parseWithDiags(source)
        
        #expect(varDecl.name.value == "x")
        #expect(varDecl.typeAnnotation.type.description == "Int")
        
        try #require(diags.count == 1)
        #expect(diags[0].id == ParserError.expectedSymbol(.colon).id)
    }
    
    @Test func `reports error on missing type annotation`() throws {
        do {
            let source = "x"
            
            let error = #expect(throws: Diagnostic.self) {
                _ = try parse(source)
            }
            #expect(error?.id == ParserError.expectedTypeAnnotation.id)
        }
        
        do {
            let source = "x :"
            
            let error = #expect(throws: Diagnostic.self) {
                _ = try parse(source)
            }
            #expect(error?.id == ParserError.expectedTypeAnnotation.id)
        }
    }
}
