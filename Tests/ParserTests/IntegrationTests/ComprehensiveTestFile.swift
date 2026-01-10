//
//  ComprehensiveTestFile.swift
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

enum ComprehensiveTestFile: TestFile {
    static let name = "comprehensive"
    
    static func validate(_ source: SourceFile) throws {
        try #require(source.declarations.count == 2)
        
        try validateListClass(classDecl: source.declarations[0])
        
        try validateMainClass(classDecl: source.declarations[1])
        
    }
    
    private static func validateListClass(classDecl: ClassDecl) throws {
        #expect(classDecl.name.value == "List")
        #expect(classDecl.inheritance == nil)
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 4)
        
        
        let itemVar = try #require(members[0] as? VarDecl)
        #expect(itemVar.name.value == "item")
        #expect(itemVar.typeAnnotation.type.description == "String")
        #expect(itemVar.initializer == nil)
        
        let nextVar = try #require(members[1] as? VarDecl)
        #expect(nextVar.name.value == "next")
        #expect(nextVar.typeAnnotation.type.description == "List")
        #expect(nextVar.initializer == nil)
        
        
        let initFunc = try #require(members[2] as? FuncDecl)
        #expect(initFunc.name.value == "init")
        #expect(initFunc.parameters.parameters.count == 2)
        #expect(initFunc.returnClause.type.description == "List")
        #expect((initFunc.body as? BlockExpr)?.expressions.count == 3)
        
        
        let flattenFunc = try #require(members[3] as? FuncDecl)
        #expect(flattenFunc.name.value == "flatten")
        #expect(flattenFunc.parameters.parameters.isEmpty)
        #expect(flattenFunc.returnClause.type.description == "String")
        
        let flattenLet = try #require(flattenFunc.body as? LetExpr)
        #expect(flattenLet.bindings.count == 1)
        let ifExpr = try #require(flattenLet.body as? IfExpr)
        #expect(ifExpr.condition is IsVoidExpr)
    }
    
    private static func validateMainClass(classDecl: ClassDecl) throws {
        #expect(classDecl.name.value == "Main")
        #expect(classDecl.inheritance?.inheritedType.description == "IO")
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 3)
        
        
        let mainFunc = try #require(members[0] as? FuncDecl)
        #expect(mainFunc.name.value == "main")
        #expect(mainFunc.parameters.parameters.isEmpty)
        #expect(mainFunc.returnClause.type.description == "Object")
        
        let mainLet = try #require(mainFunc.body as? LetExpr)
        try #require(mainLet.bindings.count == 3)
        
        
        let testCaseFunc = try #require(members[1] as? FuncDecl)
        #expect(testCaseFunc.name.value == "testCase")
        #expect(testCaseFunc.parameters.parameters.count == 1)
        #expect(testCaseFunc.returnClause.type.description == "String")
        
        let caseExpr = try #require(testCaseFunc.body as? CaseExpr)
        try #require(caseExpr.branches.count == 3)
        
        #expect(caseExpr.branches[0].binding.name.value == "n")
        #expect(caseExpr.branches[0].binding.typeAnnotation.type.description == "Int")
        
        #expect(caseExpr.branches[1].binding.name.value == "s")
        #expect(caseExpr.branches[1].binding.typeAnnotation.type.description == "String")
        
        #expect(caseExpr.branches[2].binding.name.value == "o")
        #expect(caseExpr.branches[2].binding.typeAnnotation.type.description == "Object")
        
        
        let testDispatchFunc = try #require(members[2] as? FuncDecl)
        #expect(testDispatchFunc.name.value == "testDispatch")
        #expect(testDispatchFunc.parameters.parameters.isEmpty)
        #expect(testDispatchFunc.returnClause.type.description == "Object")
        
        let dispatchLet = try #require(testDispatchFunc.body as? LetExpr)
        try #require(dispatchLet.bindings.count == 1)
        
        let funcCall = try #require(dispatchLet.body as? FuncCallExpr)
        #expect(funcCall.arguments.isEmpty)
        
        let memberAccess = try #require(funcCall.calledExpression as? MemberAccessExpr)
        #expect(memberAccess.member.description == "type_name")
        
        let staticDispatch = try #require(memberAccess.base as? StaticDispatchExpr)
        #expect(staticDispatch.base.description == "obj")
        #expect(staticDispatch.type.description == "Object")
    }
}
