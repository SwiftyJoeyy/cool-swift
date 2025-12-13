//
//  ControlFlowExprTests.swift
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

@Suite struct ControlFlowExprTests {
// MARK: - Functions
    private func parse(_ source: String) throws -> Expr {
        var parser = try CoolParser(
            lexer: CoolLexer(source, file: "test.cl"),
            diagnostics: MockDiagEngine()
        )
        return try ExprParser.parse(from: &parser)
    }
    private func parseWithDiags(
        _ source: String
    ) throws -> (expr: Expr, diags: [Diagnostic]) {
        let diagEngine = MockDiagEngine()
        var parser = try CoolParser(
            lexer: CoolLexer(source, file: "test.cl"),
            diagnostics: diagEngine
        )
        return (try ExprParser.parse(from: &parser), diagEngine.diags)
    }
    
// MARK: - Let Expression Tests
    @Test func `parses let with single binding`() throws {
        let expr = try parse("let x : Int in x")
        
        let letExpr = try #require(expr as? LetExpr)
        let binding = try #require(letExpr.bindings.first)
        
        #expect(binding.name == "x")
        #expect(binding.typeAnnotation.type.description == "Int")
        #expect(letExpr.body is DeclRefExpr)
    }
    
    @Test func `parses let with initialized binding`() throws {
        let expr = try parse("let x : Int <- 5 in x + 1")
        
        let letExpr = try #require(expr as? LetExpr)
        let binding = try #require(letExpr.bindings.first)
        
        #expect(binding.name == "x")
        #expect(binding.typeAnnotation.type.description == "Int")
        #expect(binding.initializer?.expr.description == "5")
    }
    
    @Test func `parses let with multiple bindings`() throws {
        let expr = try parse("let x : Int <- 5, y : String in x")
        
        let letExpr = try #require(expr as? LetExpr)
        try #require(letExpr.bindings.count == 2)
        let firstBinding = letExpr.bindings[0]
        let secondBinding = letExpr.bindings[1]
        
        #expect(firstBinding.name == "x")
        #expect(firstBinding.typeAnnotation.type.description == "Int")
        #expect(firstBinding.initializer?.expr is IntegerLiteralExpr)
        
        #expect(secondBinding.name == "y")
        #expect(secondBinding.typeAnnotation.type.description == "String")
        #expect(secondBinding.initializer == nil)
    }
    
    @Test func `parses let with complex body`() throws {
        let expr = try parse("let x : Int <- 5 in x + x * 2")
        
        let letExpr = try #require(expr as? LetExpr)
        #expect(letExpr.body is OperationExpr)
    }
    
    @Test func `parses nested let expressions`() throws {
        let expr = try parse("let x : Int <- 5 in let y : Int <- 10 in x + y")
        
        let outerLetExpr = try #require(expr as? LetExpr)
        let innerLetExpr = try #require(outerLetExpr.body as? LetExpr)
        let innerBinding = try #require(innerLetExpr.bindings.first)
       
        #expect(innerLetExpr.body is OperationExpr)
        #expect(innerBinding.name == "y")
        #expect(innerBinding.typeAnnotation.type.description == "Int")
        #expect(innerBinding.initializer?.expr is IntegerLiteralExpr)
    }
    
    @Test func `parses let with block body`() throws {
        let expr = try parse("let x : Int <- 5 in { x; x + 1; }")
        
        let letExpr = try #require(expr as? LetExpr)
        let blockExpr = try #require(letExpr.body as? BlockExpr)
        
        try #require(blockExpr.expressions.count == 2)
    }
    
    @Test func `reports error on missing in in let`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("let x : Int x")
        }
        #expect(error?.id == ParserError.expectedKeyword(.in).id)
    }
    
// MARK: - Case Expression Tests
    @Test func `parses case with single branch`() throws {
        let expr = try parse("case x of y : Int => 1; esac")
        
        let caseExpr = try #require(expr as? CaseExpr)
        #expect(caseExpr.expr.description == "x")
        try #require(caseExpr.branches.count == 1)
        
        let branch = caseExpr.branches[0]
        #expect(branch.binding.name == "y")
        #expect(branch.binding.typeAnnotation.type.description == "Int")
        #expect(branch.body is IntegerLiteralExpr)
    }
    
    @Test func `parses case with multiple branches`() throws {
        let expectedBranches: [(name: String, type: String, expr: String)] = [
            ("y", "Int", "1"),
            ("z", "String", "2")
        ]
        let expr = try parse("""
        case x of
            y : Int => 1;
            z : String => 2;
        esac
        """)
        
        let caseExpr = try #require(expr as? CaseExpr)
        #expect(caseExpr.expr.description == "x")
        try #require(caseExpr.branches.count == 2)
        
        for i in 0..<expectedBranches.count {
            let branch = caseExpr.branches[i]
            let expBranch = expectedBranches[i]
            #expect(branch.binding.name == expBranch.name)
            #expect(branch.binding.typeAnnotation.type.description == expBranch.type)
            #expect(branch.body.description == expBranch.expr)
        }
    }
    
    @Test func `parses case with complex expressions`() throws {
        let expr = try parse("""
        case x + 1 of
            y : Int => y + 10;
        esac
        """)
        
        let caseExpr = try #require(expr as? CaseExpr)
        
        #expect(caseExpr.expr is OperationExpr)
        #expect(caseExpr.expr.description == "x + 1")
        try #require(caseExpr.branches.count == 1)
        
        let branch = caseExpr.branches[0]
        #expect(branch.binding.name == "y")
        #expect(branch.binding.typeAnnotation.type.description == "Int")
        #expect(branch.body is OperationExpr)
    }
    
    @Test func `reports error on missing of in case`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("case x y : Int => 1; esac")
        }
        #expect(error?.id == ParserError.expectedKeyword(.of).id)
    }
    
    @Test func `reports error on missing arrow in case`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("case x of y : Int 1; esac")
        }
        #expect(error?.id == ParserError.expectedSymbol(.arrow).id)
    }
    
    @Test func `reports error on missing semicolon in case`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("case x of y : Int => 1 esac")
        }
        #expect(error?.id == ParserError.expectedSymbol(.semicolon).id)
    }
    
    @Test func `reports error on missing esac in case`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("case x of y : Int => 1;")
        }
        #expect(error?.id == ParserError.expectedKeyword(.esac).id)
    }
    
// MARK: - If Expression Tests
    @Test func `parses simple if expression`() throws {
        let expr = try parse("if x then 1 else 0 fi")
        
        let ifExpr = try #require(expr as? IfExpr)
        
        #expect(ifExpr.condition is DeclRefExpr)
        #expect(ifExpr.thenBody is IntegerLiteralExpr)
        #expect(ifExpr.elseBody is IntegerLiteralExpr)
    }
    
    @Test func `parses if with comparison condition`() throws {
        let expr = try parse("if x < 10 then 1 else 0 fi")
        
        let ifExpr = try #require(expr as? IfExpr)
        
        #expect(ifExpr.condition is OperationExpr)
        #expect(ifExpr.thenBody is IntegerLiteralExpr)
        #expect(ifExpr.elseBody is IntegerLiteralExpr)
    }
    
    @Test func `parses nested if expressions`() throws {
        let expr = try parse("if x then if y < 10 then 1 else 2 fi else 3 fi")
        
        let outerIfExpr = try #require(expr as? IfExpr)
        
        #expect(outerIfExpr.condition is DeclRefExpr)
        
        let innerIfExpr = try #require(outerIfExpr.thenBody as? IfExpr)
        #expect(innerIfExpr.condition is OperationExpr)
        
        #expect(innerIfExpr.thenBody is IntegerLiteralExpr)
        
        #expect(innerIfExpr.elseBody is IntegerLiteralExpr)
        
        #expect(outerIfExpr.elseBody is IntegerLiteralExpr)
    }
    
    @Test func `parses if with block bodies`() throws {
        let expr = try parse("if x then { 1; 2; } else { 3; 4; } fi")
        
        let ifExpr = try #require(expr as? IfExpr)
        
        let thenBlockExpr = try #require(ifExpr.thenBody as? BlockExpr)
        try #require(thenBlockExpr.expressions.count == 2)
        
        let elseBlockExpr = try #require(ifExpr.elseBody as? BlockExpr)
        try #require(elseBlockExpr.expressions.count == 2)
    }
    
    @Test func `reports error on missing then in if`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("if true 1 else 0 fi")
        }
        #expect(error?.id == ParserError.expectedKeyword(.then).id)
    }
    
    @Test func `reports error on missing fi in if`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("if true then 1 else 0")
        }
        #expect(error?.id == ParserError.expectedKeyword(.fi).id)
    }
    
    @Test func `reports error on missing else in if`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("if true then 1 0")
        }
        #expect(error?.id == ParserError.expectedKeyword(.else).id)
    }
    
// MARK: - While Expression Tests
    @Test func `parses simple while loop`() throws {
        let expr = try parse("while x loop y pool")
        
        let whileExpr = try #require(expr as? WhileExpr)
        
        #expect(whileExpr.condition is DeclRefExpr)
        #expect(whileExpr.body is DeclRefExpr)
    }
    
    @Test func `parses while with comparison condition`() throws {
        let expr = try parse("while x < 10 loop x <- x + 1 pool")
        
        let whileExpr = try #require(expr as? WhileExpr)
        
        #expect(whileExpr.condition is OperationExpr)
        #expect(whileExpr.body is AssignmentExpr)
    }
    
    @Test func `parses while with block body`() throws {
        let expr = try parse("while x loop { x <- x + 1; y <- y + 1; } pool")
        
        let whileExpr = try #require(expr as? WhileExpr)
        
        #expect(whileExpr.condition is DeclRefExpr)
        let blockExpr = try #require(whileExpr.body as? BlockExpr)
        try #require(blockExpr.expressions.count == 2)
    }
    
    @Test func `parses nested while loops`() throws {
        let expr = try parse("while x loop while y loop z pool pool")
        
        let outerWhileExpr = try #require(expr as? WhileExpr)
        #expect(outerWhileExpr.condition is DeclRefExpr)
        
        let innerWhileExpr = try #require(outerWhileExpr.body as? WhileExpr)
        #expect(innerWhileExpr.condition is DeclRefExpr)
        #expect(innerWhileExpr.body is DeclRefExpr)
    }
    
    @Test func `reports error on missing loop in while`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("while x y pool")
        }
        #expect(error?.id == ParserError.expectedKeyword(.loop).id)
    }
    
    @Test func `reports error on missing pool in while`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("while x loop y")
        }
        #expect(error?.id == ParserError.expectedKeyword(.pool).id)
    }
    
// MARK: - Block Expression Tests
    @Test func `parses block with single expression`() throws {
        let expr = try parse("{ 42; }")
        
        let blockExpr = try #require(expr as? BlockExpr)
        
        try #require(blockExpr.expressions.count == 1)
        #expect(blockExpr.expressions[0] is IntegerLiteralExpr)
    }
    
    @Test func `parses block with multiple expressions`() throws {
        let expr = try parse("{ 1; 2; 3; }")
        
        let blockExpr = try #require(expr as? BlockExpr)
        
        try #require(blockExpr.expressions.count == 3)
        #expect(blockExpr.expressions[0] is IntegerLiteralExpr)
        #expect(blockExpr.expressions[1] is IntegerLiteralExpr)
        #expect(blockExpr.expressions[2] is IntegerLiteralExpr)
    }
    
    @Test func `parses block with complex expressions`() throws {
        let expr = try parse("{ x <- 1; y <- 2; x + y; }")
        
        let blockExpr = try #require(expr as? BlockExpr)
        
        try #require(blockExpr.expressions.count == 3)
        #expect(blockExpr.expressions[0] is AssignmentExpr)
        #expect(blockExpr.expressions[1] is AssignmentExpr)
        #expect(blockExpr.expressions[2] is OperationExpr)
    }
    
    @Test func `parses nested blocks`() throws {
        let expr = try parse("{ { 1; }; 2; }")
        
        let outerBlockExpr = try #require(expr as? BlockExpr)
        
        try #require(outerBlockExpr.expressions.count == 2)
        #expect(outerBlockExpr.expressions[0] is BlockExpr)
        #expect(outerBlockExpr.expressions[1] is IntegerLiteralExpr)
        
        let innerBlockExpr = try #require(outerBlockExpr.expressions[0] as? BlockExpr)
        try #require(innerBlockExpr.expressions.count == 1)
        #expect(innerBlockExpr.expressions[0] is IntegerLiteralExpr)
    }
    
    @Test func `reports error on missing semicolon in block`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("{ 42 }")
        }
        #expect(error?.id == ParserError.expectedSymbol(.semicolon).id)
    }
    
    @Test func `reports error on missing closing brace in block`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("{ 42; ")
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightBrace).id)
    }
    
// MARK: - Complex Control Flow Tests
    @Test func `parses if inside while`() throws {
        let expr = try parse("while x loop if y then 1 else 2 fi pool")
        
        let whileExpr = try #require(expr as? WhileExpr)
        #expect(whileExpr.body is IfExpr)
    }
    
    @Test func `parses while inside if`() throws {
        let expr = try parse("if x then while y loop z pool else 0 fi")
        
        let ifExpr = try #require(expr as? IfExpr)
        #expect(ifExpr.thenBody is WhileExpr)
    }
    
    @Test func `parses let inside if`() throws {
        let expr = try parse("if x then let y : Int <- 5 in y else 0 fi")
        
        let ifExpr = try #require(expr as? IfExpr)
        #expect(ifExpr.thenBody is LetExpr)
    }
    
    @Test func `parses case inside let`() throws {
        let expr = try parse("""
        let x : Object in
            case x of
                y : Int => 1;
            esac
        """)
        
        let letExpr = try #require(expr as? LetExpr)
        #expect(letExpr.body is CaseExpr)
    }
}
