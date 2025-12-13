//
//  InheritanceTestFile.swift
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

enum InheritanceTestFile: TestFile {
    static let name = "inheritance"
    
    static func validate(_ source: SourceFile) throws {
        try #require(source.declarations.count == 2)
        
        try validatePointClass(classDecl: source.declarations[0])
        try validatePoint3DClass(classDecl: source.declarations[1])
    }
    
    private static func validatePointClass(classDecl: ClassDecl) throws {
        #expect(classDecl.name == "Point")
        #expect(classDecl.inheritance == nil)
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 3)
        
        // Validate Point properties
        let xProp = try #require(members[0] as? VarDecl)
        #expect(xProp.name == "x")
        #expect(xProp.typeAnnotation.type.description == "Int")
        #expect(xProp.initializer == nil)
        
        let yProp = try #require(members[1] as? VarDecl)
        #expect(yProp.name == "y")
        #expect(yProp.typeAnnotation.type.description == "Int")
        #expect(yProp.initializer == nil)
        
        // Validate Point init method
        let initMethod = try #require(members[2] as? FuncDecl)
        #expect(initMethod.name == "init")
        try #require(initMethod.parameters.parameters.count == 2)
        #expect(initMethod.parameters.parameters[0].name == "x_val")
        #expect(initMethod.parameters.parameters[0].type.description == "Int")
        #expect(initMethod.parameters.parameters[1].name == "y_val")
        #expect(initMethod.parameters.parameters[1].type.description == "Int")
        #expect(initMethod.returnClause.type.description == "SELF_TYPE")
    }
    
    private static func validatePoint3DClass(classDecl: ClassDecl) throws {
        #expect(classDecl.name == "Point3D")
        #expect(classDecl.inheritance != nil)
        #expect(classDecl.inheritance?.inheritedType.description == "Point")
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 2)
        
        // Validate Point3D property
        let zProp = try #require(members[0] as? VarDecl)
        #expect(zProp.name == "z")
        #expect(zProp.typeAnnotation.type.description == "Int")
        #expect(zProp.initializer == nil)
        
        // Validate Point3D init3D method
        let init3DMethod = try #require(members[1] as? FuncDecl)
        #expect(init3DMethod.name == "init3D")
        try #require(init3DMethod.parameters.parameters.count == 3)
        #expect(init3DMethod.parameters.parameters[0].name == "x_val")
        #expect(init3DMethod.parameters.parameters[1].name == "y_val")
        #expect(init3DMethod.parameters.parameters[2].name == "z_val")
        #expect(init3DMethod.returnClause.type.description == "SELF_TYPE")
    }
}
