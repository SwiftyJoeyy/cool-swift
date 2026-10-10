//
//  VarDeclParserTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/12/2025.
//

import Testing
import Foundation
import AST
import Diagnostics
@testable import Parser

@Suite struct VarDeclParserTests: ParserTestSuite {
// MARK: - Functions
    func parseNode(from parser: inout CoolParser) throws(Diagnostic) -> VarDecl {
        return try VarDeclParser.parse(from: &parser)
    }
    
// MARK: - Basic Variable Declaration Tests
    @Test func `parses variable without initializer`() throws {
        let source = "x : Int"
        let varDecl = try parse(source)
        
        #expect(varDecl.name.value == "x")
        #expect(varDecl.typeAnnotation.type.description == "Int")
        #expect(varDecl.initializer == nil)
    }
    
    @Test func `parses variable with initializer`() throws {
        let source = "x : Int <- 5"
        let varDecl = try parse(source)
        
        #expect(varDecl.name.value == "x")
        #expect(varDecl.typeAnnotation.type.description == "Int")
        #expect(varDecl.initializer?.expr is IntegerLiteralExpr)
    }
    
// MARK: - Variable with Complex Initializers
    @Test func `parses variable with string literal initializer`() throws {
        let source = "msg : String <- \"hello\""
        let varDecl = try parse(source)
        
        #expect(varDecl.initializer?.expr is StringLiteralExpr)
    }
    
    @Test func `parses variable with boolean literal initializer`() throws {
        let source = "flag : Bool <- false"
        let varDecl = try parse(source)
        
        #expect(varDecl.initializer?.expr is BoolLiteralExpr)
    }
    
    @Test func `parses variable with expression initializer`() throws {
        let source = "result : Int <- 5 + 3"
        let varDecl = try parse(source)
        
        #expect(varDecl.typeAnnotation.type.description == "Int")
        #expect(varDecl.initializer?.expr is OperationExpr)
    }
    
    @Test func `parses variable with new expression initializer`() throws {
        let source = "obj : Point <- new Point"
        let varDecl = try parse(source)
        
        #expect(varDecl.initializer?.expr is NewExpr)
    }
    
    @Test func `parses variable with function call initializer`() throws {
        let source = "val : Int <- compute()"
        let varDecl = try parse(source)
        
        #expect(varDecl.initializer?.expr is FuncCallExpr)
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
        let source = "x Int <- 5"
        
        let (varDecl, diags) = try parseWithDiags(source)
        
        #expect(varDecl.name.value == "x")
        #expect(varDecl.typeAnnotation.type.description == "Int")
        
        try #require(diags.count == 1)
        #expect(diags[0].id == ParserError.expectedSymbol(.colon).id)
    }
    
    @Test func `reports error on missing type annotation`() throws {
        do {
            let source = "x <- 5"
            
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
