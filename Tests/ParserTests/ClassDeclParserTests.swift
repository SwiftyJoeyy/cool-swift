//
//  ClassDeclParserTests.swift
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

@Suite struct ClassDeclParserTests {
// MARK: - Functions
    private func parse(_ source: String) throws -> ClassDecl {
        var parser = try CoolParser.new(source: source).parser
        return try ClassDeclParser(memberParser: DefaultMemberDeclParser())
            .parse(from: &parser)
    }
    private func parseWithDiags(
        _ source: String
    ) throws -> (decl: ClassDecl, diags: [Diagnostic]) {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        let classDecl = try ClassDeclParser(memberParser: DefaultMemberDeclParser())
            .parse(from: &parser)
        return (classDecl, diagEngine.diags)
    }
    
// MARK: - Basic Class Declaration Tests
    @Test func `parses empty class`() throws {
        let source = "class Main { };"
        let classDecl = try parse(source)
        
        #expect(classDecl.name.value == "Main")
        #expect(classDecl.inheritance == nil)
        #expect(classDecl.membersBlock.members.isEmpty)
    }
    
// MARK: - Inheritance Tests
    @Test func `parses class with inheritance`() throws {
        let source = "class Child inherits Parent { };"
        let classDecl = try parse(source)
        
        #expect(classDecl.name.value == "Child")
        #expect(classDecl.inheritance != nil)
        #expect(classDecl.inheritance?.inheritedType.description == "Parent")
    }
    
// MARK: - Class Members Tests
    @Test func `parses class with a property`() throws {
        do {
            let source = """
            class Main { 
                x : Int; 
            };
            """
            let classDecl = try parse(source)
            
            try #require(classDecl.membersBlock.members.count == 1)
            let varDecl = try #require(classDecl.membersBlock.members[0] as? VarDecl)
            
            #expect(varDecl.name.value == "x")
            #expect(varDecl.typeAnnotation.type.description == "Int")
            #expect(varDecl.initializer == nil)
        }
        
        do {
            let source = """
            class Main { 
                x : Int <- 5;
            };
            """
            let classDecl = try parse(source)
            
            try #require(classDecl.membersBlock.members.count == 1)
            let varDecl = try #require(classDecl.membersBlock.members[0] as? VarDecl)
            
            #expect(varDecl.name.value == "x")
            #expect(varDecl.initializer != nil)
        }
    }
    
    @Test func `parses class with multiple properties`() throws {
        let source = """
        class Main {
            x : Int;
            y : String;
            z : Bool;
        };
        """
        let classDecl = try parse(source)
        
        let members = classDecl.membersBlock.members.compactMap({$0 as? VarDecl})
        try #require(members.count == 3)
        #expect(members.map(\.name.value) == ["x", "y", "z"])
        
        let names = members.compactMap({$0.typeAnnotation.type.description})
        #expect(names == ["Int", "String", "Bool"])
    }
    
    @Test func `parses class with a func`() throws {
        let source = """
        class Main {
            main() : Int { 0 };
        };
        """
        let classDecl = try parse(source)
        
        let members = classDecl.membersBlock.members.compactMap({$0 as? FuncDecl})
        try #require(members.count == 1)
        #expect(members[0].name.value == "main")
    }
    
    @Test func `parses class with multiple funcs`() throws {
        let source = """
        class Main {
            main() : Int { 0 };
            main2(x : Int) : Object { 0 };
            main3(x : Int) : Int { x };
        };
        """
        let classDecl = try parse(source)
        
        let members = classDecl.membersBlock.members.compactMap({$0 as? FuncDecl})
        try #require(members.count == 3)
        #expect(members.map(\.name.value) == ["main", "main2", "main3"])
    }
    
    @Test func `parses class with mixed members`() throws {
        let source = """
        class Main {
            x : Int <- 1;
            main() : Int { 0 };
            y : String;
            main2(x : Int) : Int { x };
        };
        """
        let classDecl = try parse(source)
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 4)
        #expect(members[0] is VarDecl)
        #expect(members[1] is FuncDecl)
        #expect(members[2] is VarDecl)
        #expect(members[3] is FuncDecl)
    }
    
// MARK: - Error Cases
    @Test func `reports error on missing class name`() throws {
        let source = "class { };"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedClassName.id)
    }
    
    @Test func `reports error on missing opening brace`() throws {
        let source = "class Main };"
        
        let (classDecl, diags) = try parseWithDiags(source)
        
        #expect(classDecl.name.value == "Main")
        
        try #require(diags.count == 1)
        #expect(diags[0].id ==  ParserError.expectedSymbol(.leftBrace).id)
    }
    
    @Test func `reports error on missing closing brace`() throws {
        let source = "class Main { ;"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedSymbol(.rightBrace).id)
    }
    
    @Test func `reports error on missing semicolon`() throws {
        let source = "class Main { }"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedSymbol(.semicolon).id)
    }
    
    @Test func `reports error on missing inherited type name`() throws {
        let source = "class Main inherits { };"
        
        let error = #expect(throws: Diagnostic.self) {
            _ = try parse(source)
        }
        #expect(error?.id == ParserError.expectedType.id)
    }
    
    @Test func `reports error on member parsing failure & keeps parsing`() throws {
        let source = """
        class Main {
            invalidX : <- 1;
            invalidMain() : Int { };
            validX : Int <- 1;
            validMain() : Int { x };
        };
        """
        
        let (classDecl, diags) = try parseWithDiags(source)
        
        #expect(classDecl.name.value == "Main")
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 2)
        #expect(members[0] is VarDecl)
        #expect(members[1] is FuncDecl)
        
        try #require(diags.count == 2)
        
        #expect(diags[0].id == ParserError.expectedTypeAnnotation.id)
        #expect(diags[1].id == ParserError.unexpectedExpression.id)
    }
    
    @Test func `reports error on missing semicolon after decl`() throws {
        let source = """
        class Main {
            invalidX : Int <- 1
        };
        """
        
        let (classDecl, diags) = try parseWithDiags(source)
        
        #expect(classDecl.name.value == "Main")
        
        let members = classDecl.membersBlock.members
        try #require(members.count == 1)
        
        try #require(diags.count == 1)
        
        #expect(diags[0].id == ParserError.expectedSymbol(.semicolon).id)
    }
    
    @Test func `reports error on unexpected token in class members block`() throws {
        do {
            let source = """
            class Main {
                *;
            };
            """
            
            let (classDecl, diags) = try parseWithDiags(source)
            
            #expect(classDecl.name.value == "Main")
            
            let members = classDecl.membersBlock.members
            try #require(members.count == 0)
            
            try #require(diags.count == 1)
            
            #expect(diags[0].id == ParserError.unexpectedDeclaration.id)
        }
        
        do {
            let source = """
            class Main {
                test *;
            };
            """
            
            let (classDecl, diags) = try parseWithDiags(source)
            
            #expect(classDecl.name.value == "Main")
            
            let members = classDecl.membersBlock.members
            try #require(members.count == 0)
            
            try #require(diags.count == 1)
            
            #expect(diags[0].id == ParserError.unexpectedDeclaration.id)
        }
    }
}
