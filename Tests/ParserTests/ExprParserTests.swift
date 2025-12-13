//
//  ExprParserTests.swift
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

@Suite struct ExprParserTests {
// MARK: - Functions
    private func parse(_ source: String) throws -> Expr {
        var parser = try CoolParser(
            lexer: CoolLexer(source, file: "test.cl"),
            diagnostics: MockDiagEngine()
        )
        return try ExprParser.parse(from: &parser)
    }
    
// MARK: - Literal Expression Tests
    @Test func `parses integer literal`() throws {
        let expr = try parse("42")
        
        let intExpr = try #require(expr as? IntegerLiteralExpr)
        #expect(intExpr.value == "42")
    }
    
    @Test func `parses string literal`() throws {
        let expr = try parse("\"hello world\"")
        
        let strExpr = try #require(expr as? StringLiteralExpr)
        #expect(strExpr.value == "hello world")
    }
    
    @Test func `parses bool literal`() throws {
        do {
            let expr = try parse("true")
            
            let boolExpr = try #require(expr as? BoolLiteralExpr)
            #expect(boolExpr.value == "true")
        }
        
        do {
            let expr = try parse("false")
            
            let boolExpr = try #require(expr as? BoolLiteralExpr)
            #expect(boolExpr.value == "false")
        }
    }
    
// MARK: - Identifier and Reference Tests
    @Test func `parses identifier expression`() throws {
        let expr = try parse("x")
        
        let declRefExpr = try #require(expr as? DeclRefExpr)
        #expect(declRefExpr.name == "x")
    }
    
    @Test func `parses identifier with underscore`() throws {
        let expr = try parse("my_var")
        
        let declRefExpr = try #require(expr as? DeclRefExpr)
        #expect(declRefExpr.name == "my_var")
    }
    
// MARK: - Arithmetic Expression Tests
    @Test func `parses addition`() throws {
        let expr = try parse("1 + 2")
        
        let opExpr = try #require(expr as? OperationExpr)
        #expect(opExpr.lhs is IntegerLiteralExpr)
        #expect((opExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(opExpr.rhs is IntegerLiteralExpr)
    }
    
    @Test func `parses subtraction`() throws {
        let expr = try parse("5 - 3")
        
        let opExpr = try #require(expr as? OperationExpr)
        #expect(opExpr.lhs is IntegerLiteralExpr)
        #expect((opExpr.operatorExpr as? BinaryOperatorExpr)?.op == .minus)
        #expect(opExpr.rhs is IntegerLiteralExpr)
    }
    
    @Test func `parses multiplication`() throws {
        let expr = try parse("4 * 7")
        
        let opExpr = try #require(expr as? OperationExpr)
        #expect(opExpr.lhs is IntegerLiteralExpr)
        #expect((opExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        #expect(opExpr.rhs is IntegerLiteralExpr)
    }
    
    @Test func `parses division`() throws {
        let expr = try parse("10 / 2")
        
        let opExpr = try #require(expr as? OperationExpr)
        #expect(opExpr.lhs is IntegerLiteralExpr)
        #expect((opExpr.operatorExpr as? BinaryOperatorExpr)?.op == .slash)
        #expect(opExpr.rhs is IntegerLiteralExpr)
    }
    
    @Test func `parses complex arithmetic expression`() throws {
        do {
            let expr = try parse("1 + 2 * 3")
            
            let addExpr = try #require(expr as? OperationExpr)
            
            #expect(addExpr.lhs is IntegerLiteralExpr)
            #expect((addExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
            
            let mulExpr = try #require(addExpr.rhs as? OperationExpr)
            #expect(mulExpr.lhs is IntegerLiteralExpr)
            #expect((mulExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
            #expect(mulExpr.rhs is IntegerLiteralExpr)
        }
        
        do {
            let expr = try parse("2 * 3 + 1")
            
            let addExpr = try #require(expr as? OperationExpr)
            
            let mulExpr = try #require(addExpr.lhs as? OperationExpr)
            #expect(mulExpr.lhs is IntegerLiteralExpr)
            #expect((mulExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
            #expect(mulExpr.rhs is IntegerLiteralExpr)
            
            #expect(addExpr.rhs is IntegerLiteralExpr)
            #expect((addExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        }
    }
    
    @Test func `parses parenthesized expression`() throws {
        let expr = try parse("(1 + 2) * 3")
        
        let mulExpr = try #require(expr as? OperationExpr)
        
        let addExpr = try #require(mulExpr.lhs as? OperationExpr)
        #expect(addExpr.lhs is IntegerLiteralExpr)
        #expect((addExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(addExpr.rhs is IntegerLiteralExpr)
        
        #expect((mulExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        #expect(mulExpr.rhs is IntegerLiteralExpr)
    }
    
// MARK: - Comparison Expression Tests
    @Test func `parses less than`() throws {
        let expr = try parse("x < 5")
        
        let opExpr = try #require(expr as? OperationExpr)
        #expect(opExpr.lhs is DeclRefExpr)
        #expect((opExpr.operatorExpr as? BinaryOperatorExpr)?.op == .lessThan)
        #expect(opExpr.rhs is IntegerLiteralExpr)
    }
    
    @Test func `parses less than or equal`() throws {
        let expr = try parse("x <= 5")
        
        let opExpr = try #require(expr as? OperationExpr)
        #expect(opExpr.lhs is DeclRefExpr)
        #expect((opExpr.operatorExpr as? BinaryOperatorExpr)?.op == .lessThanOrEqual)
        #expect(opExpr.rhs is IntegerLiteralExpr)
    }
    
    @Test func `parses equality`() throws {
        let expr = try parse("x = 5")
        
        let opExpr = try #require(expr as? OperationExpr)
        #expect(opExpr.lhs is DeclRefExpr)
        #expect((opExpr.operatorExpr as? BinaryOperatorExpr)?.op == .equal)
        #expect(opExpr.rhs is IntegerLiteralExpr)
    }
    
// MARK: - Assignment Expression Tests
    @Test func `parses assignment`() throws {
        let expr = try parse("x <- 5")
        
        let assignExpr = try #require(expr as? AssignmentExpr)
        #expect(assignExpr.target is DeclRefExpr)
        #expect(assignExpr.value is IntegerLiteralExpr)
    }
    
    @Test func `parses complex assignment`() throws {
        let expr = try parse("x <- y + 5")
        
        let assignExpr = try #require(expr as? AssignmentExpr)
        #expect(assignExpr.target is DeclRefExpr)
        #expect(assignExpr.value is OperationExpr)
    }
    
// MARK: - Unary Expression Tests
    @Test func `parses not expression`() throws {
        let expr = try parse("not true")
        
        let notExpr = try #require(expr as? NotExpr)
        #expect(notExpr.expression is BoolLiteralExpr)
    }
    
    @Test func `parses isvoid expression`() throws {
        let expr = try parse("isvoid x")
        
        let isVoidExpr = try #require(expr as? IsVoidExpr)
        #expect(isVoidExpr.expression is DeclRefExpr)
    }
    
    @Test func `parses isvoid with parenthesized expression`() throws {
        let expr = try parse("isvoid (1 + 2)")
        
        let isVoidExpr = try #require(expr as? IsVoidExpr)
        #expect(isVoidExpr.expression is OperationExpr)
    }
    
    @Test func `parses new expression`() throws {
        let expr = try parse("new Point")
        
        let newExpr = try #require(expr as? NewExpr)
        #expect(newExpr.type.description == "Point")
    }
    
    @Test func `reports error on missing identifier in new expression`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("new (x + 2)")
        }
        #expect(error?.id == ParserError.expectedType.id)
    }
    
// MARK: - Function Call Tests
    @Test func `parses function call without arguments`() throws {
        let expr = try parse("foo()")
        
        let funcCallExpr = try #require(expr as? FuncCallExpr)
        let declRefExpr = try #require(funcCallExpr.calledExpression as? DeclRefExpr)
        
        #expect(declRefExpr.name == "foo")
        #expect(funcCallExpr.arguments.isEmpty)
    }
    
    @Test func `parses function call with single argument`() throws {
        let expr = try parse("foo(5)")
        
        let funcCallExpr = try #require(expr as? FuncCallExpr)
        try #require(funcCallExpr.arguments.count == 1)
        #expect(funcCallExpr.arguments[0] is IntegerLiteralExpr)
    }
    
    @Test func `parses function call with multiple arguments`() throws {
        let expr = try parse("foo(1, 2, 3)")
        
        let funcCallExpr = try #require(expr as? FuncCallExpr)
        try #require(funcCallExpr.arguments.count == 3)
        #expect(funcCallExpr.arguments[0] is IntegerLiteralExpr)
        #expect(funcCallExpr.arguments[1] is IntegerLiteralExpr)
        #expect(funcCallExpr.arguments[2] is IntegerLiteralExpr)
    }
    
    @Test func `reports error on missing closing paren in func call`() throws {
        do {
            let error = #expect(throws: Diagnostic.self) {
                _ = try parse("foo(1, 2, 3")
            }
            #expect(error?.id == ParserError.expectedSymbol(.rightParen).id)
        }
        
        do {
            let error = #expect(throws: Diagnostic.self) {
                _ = try parse("foo(")
            }
            #expect(error?.id == ParserError.unexpectedExpression.id)
        }
    }
    
// MARK: - Member Access Tests
    @Test func `parses member access`() throws {
        let expr = try parse("obj.x")
        
        let memberAccExpr = try #require(expr as? MemberAccessExpr)
        #expect(memberAccExpr.base is DeclRefExpr)
        #expect(memberAccExpr.member is DeclRefExpr)
    }
    
    @Test func `parses member access with func call`() throws {
        let expr = try parse("obj.f()")
        dump(expr)
        let funcCallExpr = try #require(expr as? FuncCallExpr)
        
        let memberAccExpr = try #require(funcCallExpr.calledExpression as? MemberAccessExpr)
        #expect(memberAccExpr.base is DeclRefExpr)
        #expect(memberAccExpr.member is DeclRefExpr)
    }
    
// MARK: - Static Dispatch Tests
    @Test func `parses static dispatch`() throws {
        let expr = try parse("obj@Type")
        
        let staticDispExpr = try #require(expr as? StaticDispatchExpr)
        #expect(staticDispExpr.base is DeclRefExpr)
        #expect(staticDispExpr.type.description == "Type")
    }
    
    @Test func `parses static dispatch with member access`() throws {
        let expr = try parse("obj@Type.x")
        
        let memberAccExpr = try #require(expr as? MemberAccessExpr)
        
        let staticDispExpr = try #require(memberAccExpr.base as? StaticDispatchExpr)
        #expect(staticDispExpr.base is DeclRefExpr)
        #expect(staticDispExpr.type.description == "Type")
        
        #expect(memberAccExpr.member is DeclRefExpr)
    }
    
    @Test func `parses static dispatch with func call`() throws {
        let expr = try parse("obj@Type.f()")
        dump(expr)
        let funcCallExpr = try #require(expr as? FuncCallExpr)
        
        let memberAccExpr = try #require(funcCallExpr.calledExpression as? MemberAccessExpr)
        
        let staticDispExpr = try #require(memberAccExpr.base as? StaticDispatchExpr)
        #expect(staticDispExpr.base is DeclRefExpr)
        #expect(staticDispExpr.type.description == "Type")
        
        #expect(memberAccExpr.member is DeclRefExpr)
    }
    
    @Test func `reports error on missing type in static dispatch`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("obj@.f()")
        }
        #expect(error?.id == ParserError.expectedType.id)
    }
    
// MARK: - Error Cases
    @Test func `reports error on missing closing paren`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse("(1 + 2")
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightParen).id)
    }
    
    @Test func `reports error on unexpected token`() throws {
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(")")
        }
        #expect(error?.id == ParserError.unexpectedExpression.id)
    }
}
