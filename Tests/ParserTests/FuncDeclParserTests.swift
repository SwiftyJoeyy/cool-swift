//
//  FuncDeclParserTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/12/2025.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
@testable import Parser

@Suite struct FuncDeclParserTests {
// MARK: - Functions
    private func parse(_ source: String) throws -> FuncDecl {
        var parser = try CoolParser.new(source: source).parser
        return try FuncDeclParser.parse(from: &parser)
    }
    private func parseWithDiags(
        _ source: String
    ) throws -> (decl: FuncDecl, diags: [Diagnostic]) {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        return (try FuncDeclParser.parse(from: &parser), diagEngine.diags)
    }
    
// MARK: - Basic Function Declaration Tests
    @Test func `parses function without parameters`() throws {
        let source = "main() : Int { 42 }"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.name == "main")
        #expect(funcDecl.parameters.parameters.isEmpty)
    }
    
    @Test func `parses function with single parameter`() throws {
        let source = "add(x : Int) : Int { x + 1 }"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.name == "add")
        
        let params = funcDecl.parameters.parameters
        try #require(params.count == 1)
        
        let param = params[0]
        #expect(param.name == "x")
        #expect(param.type.description == "Int")
    }
    
    @Test func `parses function with multiple parameters`() throws {
        let expectedParams = [("x", "Int"), ("y", "String"), ("z", "Bool")]
        let source = "calculate(x : Int, y : String, z : Bool) : Object { x }"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.name == "calculate")
        
        let params = funcDecl.parameters.parameters
        try #require(params.count == expectedParams.count)
        
        for i in 0..<expectedParams.count {
            let param = params[i]
            let expectedParam = expectedParams[i]
            #expect(param.name == expectedParam.0)
            #expect(param.type.description == expectedParam.1)
        }
    }
    
    @Test func `parses function return type`() throws {
        let source = "get() : Object { self }"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.returnClause.type.description == "Object")
    }
    
// MARK: - Function Body Tests
    @Test func `parses function with single expression body`() throws {
        let source = "getValue() : Int { 42 }"
        let funcDecl = try parse(source)
        
        #expect(funcDecl.body is IntegerLiteralExpr)
    }
    
    @Test func `parses function with multiple expressions in body`() throws {
        let source = """
        compute() : Int {
            {
                1;
                2;
                3;
            }
        }
        """
        let funcDecl = try parse(source)
        
        #expect(funcDecl.body is BlockExpr)
    }
    
    @Test func `parses function with complex body`() throws {
        let source = """
        process(x : Int) : Int {
            let temp : Int <- x + 1 in
                temp * 2
        }
        """
        let funcDecl = try parse(source)
        
        #expect(funcDecl.body is LetExpr)
    }
    
    @Test func `parses function with control flow in body`() throws {
        let source = """
        check(x : Int) : Bool {
            if x < 10 then true else false fi
        }
        """
        let funcDecl = try parse(source)
        
        #expect(funcDecl.body is IfExpr)
    }
    
// MARK: - Error Cases
    @Test func `reports error on empty body`() throws {
        let source = "foo() : Int { }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.unexpectedExpression.id)
    }
    
    @Test func `reports error on missing function name`() throws {
        let source = "() : Int { 42 }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedFuncName.id)
    }
    
    @Test func `reports error on missing opening paren`() throws {
        let source = "foo) : Int { 42 }"
        
        let (_, diags) = try parseWithDiags(source)
        try #require(diags.count == 1)
        #expect(diags[0].id == ParserError.expectedSymbol(.leftParen).id)
    }
    
    @Test func `reports error on missing closing paren`() throws {
        let source = "foo( : Int { 42 }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightParen).id)
    }
    
    @Test func `reports error on missing colon before return type`() throws {
        let source = "foo() Int { 42 }"
        
        let (_, diags) = try parseWithDiags(source)
        try #require(diags.count == 1)
        #expect(diags[0].id == ParserError.expectedSymbol(.colon).id)
    }
    
    @Test func `reports error on missing return type`() throws {
        let source = "foo() : { 42 }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedType.id)
    }
    
    @Test func `reports error on missing opening brace in body`() throws {
        let source = "foo() : Int 42 }"
        
        let (_, diags) = try parseWithDiags(source)
        try #require(diags.count == 1)
        #expect(diags[0].id == ParserError.expectedSymbol(.leftBrace).id)
    }
    
    @Test func `reports error on missing closing brace in body`() throws {
        let source = "foo() : Int { 42"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightBrace).id)
    }
    
    @Test func `reports error on missing parameter type`() throws {
        let source = "foo(x) : Int { x }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedType.id)
    }
    
    @Test func `reports error on missing parameter name`() throws {
        let source = "foo(: Int) : Int { 42 }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedParamName.id)
    }
    
    @Test func `reports error on missing comma between parameters`() throws {
        let source = "foo(x : Int y : String) : Int { 42 }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightParen).id)
    }
}
