//
//  PrecedenceTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/12/2025.
//

import Testing
import Foundation
import AST
import Lexer
@testable import Parser

@Suite struct PrecedenceTests {
// MARK: - Functions
    private func parseExpr(_ source: String) throws -> Expr {
        var parser = try CoolParser(
            lexer: CoolLexer(source, file: "test.cl"),
            diagnostics: MockDiagEngine()
        )
        return try ExprParser.parse(from: &parser)
    }
    
// MARK: - Arithmetic Precedence Tests
    @Test func `multiplication has higher precedence than addition`() throws {
        let expr = try parseExpr("1 + 2 * 3")
        
        let addExpr = try #require(expr as? OperationExpr)
        
        #expect(addExpr.lhs.description == "1")
        
        #expect((addExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        
        let mulExpr = try #require(addExpr.rhs as? OperationExpr)
        #expect(mulExpr.lhs.description == "2")
        #expect((mulExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        #expect(mulExpr.rhs.description == "3")
    }
    
    @Test func `division has higher precedence than subtraction`() throws {
        let expr = try parseExpr("10 - 6 / 2")
        
        let subExpr = try #require(expr as? OperationExpr)
        #expect(subExpr.lhs.description == "10")
        
        #expect((subExpr.operatorExpr as? BinaryOperatorExpr)?.op == .minus)
        
        let divExpr = try #require(subExpr.rhs as? OperationExpr)
        #expect(divExpr.lhs.description == "6")
        #expect((divExpr.operatorExpr as? BinaryOperatorExpr)?.op == .slash)
        #expect(divExpr.rhs.description == "2")
    }
    
    @Test func `left associativity of addition`() throws {
        let expr = try parseExpr("1 + 2 + 3")
        
        let addExpr = try #require(expr as? OperationExpr)
        
        let lhs = try #require(addExpr.lhs as? OperationExpr)
        #expect(lhs.lhs.description == "1")
        #expect((lhs.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(lhs.rhs.description == "2")
        
        #expect((addExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        
        #expect(addExpr.rhs.description == "3")
    }
    
    @Test func `left associativity of multiplication`() throws {
        let expr = try parseExpr("2 * 3 * 4")
        
        let mullExpr = try #require(expr as? OperationExpr)
        
        let lhs = try #require(mullExpr.lhs as? OperationExpr)
        #expect(lhs.lhs.description == "2")
        #expect((lhs.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        #expect(lhs.rhs.description == "3")
        
        #expect((mullExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        
        #expect(mullExpr.rhs.description == "4")
    }
    
// MARK: - Comparison Precedence Tests
    @Test func `comparison has lower precedence than arithmetic`() throws {
        let expr = try parseExpr("1 + 2 < 3 + 4")
        
        let cmpExpr = try #require(expr as? OperationExpr)
        
        let lhs = try #require(cmpExpr.lhs as? OperationExpr)
        #expect(lhs.lhs.description == "1")
        #expect((lhs.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(lhs.rhs.description == "2")
        
        #expect((cmpExpr.operatorExpr as? BinaryOperatorExpr)?.op == .lessThan)
        
        let rhs = try #require(cmpExpr.rhs as? OperationExpr)
        #expect(rhs.lhs.description == "3")
        #expect((rhs.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(rhs.rhs.description == "4")
    }
    
// MARK: - Assignment Precedence Tests
    @Test func `assignment has lowest precedence`() throws {
        let expr = try parseExpr("x <- 1 + 2")
        
        let assignExpr = try #require(expr as? AssignmentExpr)
        #expect(assignExpr.value is OperationExpr)
    }
    
// MARK: - Parentheses Override Tests
    @Test func `parentheses override multiplication precedence`() throws {
        let expr = try parseExpr("(1 + 2) * 3")
        
        let mullExpr = try #require(expr as? OperationExpr)
        
        let lhs = try #require(mullExpr.lhs as? OperationExpr)
        #expect(lhs.lhs.description == "1")
        #expect((lhs.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(lhs.rhs.description == "2")
        
        #expect((mullExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        
        #expect(mullExpr.rhs.description == "3")
    }
    
    @Test func `nested parentheses`() throws {
        let expr = try parseExpr("((1 + 2) * 3) + 4")
        
        let outerAddExpr = try #require(expr as? OperationExpr)
        
        let mullExpr = try #require(outerAddExpr.lhs as? OperationExpr)
        #expect((mullExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        #expect(mullExpr.rhs.description == "3")
        
        let innerAddExpr = try #require(mullExpr.lhs as? OperationExpr)
        #expect(innerAddExpr.lhs.description == "1")
        #expect((innerAddExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(innerAddExpr.rhs.description == "2")
        
        #expect((outerAddExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        
        #expect(outerAddExpr.rhs.description == "4")
    }
    
// MARK: - Unary Precedence Tests
    @Test func `not has high precedence`() throws {
        let expr = try parseExpr("not true = false")
        
        let eqExpr = try #require(expr as? OperationExpr)
        #expect(eqExpr.lhs is NotExpr)
    }
    
    @Test func `isvoid has high precedence`() throws {
        let expr = try parseExpr("isvoid x < y")
        
        // Should parse as: (isvoid x) < y
        guard let cmpExpr = expr as? OperationExpr else {
            Issue.record("Expected OperationExpr")
            return
        }
        
        #expect(cmpExpr.lhs is IsVoidExpr)
    }
    
// MARK: - Complex Precedence Tests
    @Test func `complex expression with multiple precedence levels`() throws {
        let expr = try parseExpr("x <- a + b * c < d")
        
        let assignExpr = try #require(expr as? AssignmentExpr)
        #expect(assignExpr.target is DeclRefExpr)
        
        let cmpExpr = try #require(assignExpr.value as? OperationExpr)
        
        let addExpr = try #require(cmpExpr.lhs as? OperationExpr)
        #expect(addExpr.lhs.description == "a")
        #expect((addExpr.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        
        let mullExpr = try #require(addExpr.rhs as? OperationExpr)
        #expect(mullExpr.lhs.description == "b")
        #expect((mullExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        #expect(mullExpr.rhs.description == "c")
        
        #expect((cmpExpr.operatorExpr as? BinaryOperatorExpr)?.op == .lessThan)
        
        #expect(cmpExpr.rhs.description == "d")
    }
    
    @Test func `mixed arithmetic and comparison`() throws {
        let expr = try parseExpr("1 + 2 * 3 < 4 + 5")
        
        let cmpExpr = try #require(expr as? OperationExpr)
        
        let lhs = try #require(cmpExpr.lhs as? OperationExpr)
        #expect(lhs.lhs.description == "1")
        #expect((lhs.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        
        let mullExpr = try #require(lhs.rhs as? OperationExpr)
        #expect(mullExpr.lhs.description == "2")
        #expect((mullExpr.operatorExpr as? BinaryOperatorExpr)?.op == .star)
        #expect(mullExpr.rhs.description == "3")
        
        #expect((cmpExpr.operatorExpr as? BinaryOperatorExpr)?.op == .lessThan)
        
        let rhs = try #require(cmpExpr.rhs as? OperationExpr)
        #expect(rhs.lhs.description == "4")
        #expect((rhs.operatorExpr as? BinaryOperatorExpr)?.op == .plus)
        #expect(rhs.rhs.description == "5")
    }
}
