//
//  FuncDeclTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/01/2026.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
import Parser
@testable import Sema

@Suite struct FuncDeclTests {
// MARK: - Functions
    private func analyze(_ source: String) throws {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        let sourceFile = try parser.parse()
        let sema = Sema(diagnostics: diagEngine, interfaceSymbols: .test)
        try sema.analyze(sourceFile)
    }
    
// MARK: - Valid Function Declarations
    @Test func `validates function with matching return type`() throws {
        let source = """
        class Main {
            foo() : Int {
                42
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates function with parameters`() throws {
        let source = """
        class Main {
            add(a : Int, b : Int) : Int {
                a
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates function accessing parameters`() throws {
        let source = """
        class Main {
            add(x : Int, y : Int) : Int {
                x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates function with self access`() throws {
        let source = """
        class Main {
            x : Int;
            getX() : Int {
                x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates function calling other functions`() throws {
        let source = """
        class Main {
            getValue() : Int { 42 };
        
            doubleValue() : Int {
                getValue()
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Return Type Mismatch Tests
    @Test func `detects return type mismatch`() throws {
        let source = """
        class Main {
            foo() : Int {
                "hello"
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Int'")
    }
    
    @Test func `detects return type mismatch with custom types`() throws {
        let source = """
        class Foo { };
        class Bar { };
        class Main {
            test() : Foo {
                new Bar
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'Bar' to specified type 'Foo'")
    }
    
    @Test func `detects undefined return type`() throws {
        let source = """
        class Main {
            foo() : UndefinedType {
                5
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'UndefinedType'")
    }
    
// MARK: - Parameter Tests
    @Test func `detects duplicate parameter names`() throws {
        let source = """
        class Main {
            foo(x : Int, x : String) : Int {
                5
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "invalid redeclaration of 'x'")
    }
    
    @Test func `detects undefined parameter type`() throws {
        let source = """
        class Main {
            foo(x : UndefinedType) : Int {
                5
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'UndefinedType'")
    }
    
    @Test func `validates parameter shadowing instance variable`() throws {
        let source = """
        class Main {
            x : Int;
            foo(x : String) : String {
                x
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Inheritance Tests
    @Test func `validates calling parent method`() throws {
        let source = """
        class Base {
            getValue() : Int { 42 };
        };
        class Derived inherits Base {
            doubled() : Int {
                getValue()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates override with same return type`() throws {
        let source = """
        class Base {
            foo() : Int { 1 };
        };
        class Derived inherits Base {
            foo() : Int { 2 };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `allows subtype as return type in override`() throws {
        let source = """
        class Animal { };
        class Dog inherits Animal { };
        
        class Base {
            getAnimal() : Animal {
                new Animal
            };
        };
        class Derived inherits Base {
            getAnimal() : Dog {
                new Dog
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Complex Body Tests
    @Test func `validates function with block body`() throws {
        let source = """
        class Main {
            foo() : Int {
                {
                    let x : Int <- 5 in
                    x;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates function with if expression`() throws {
        let source = """
        class Main {
            abs(x : Int) : Int {
                if true then x else x fi
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates function with nested calls`() throws {
        let source = """
        class Main {
            a() : Int { 1 };
            b() : Int { a() };
            c() : Int { b() };
        };
        """
        
        try analyze(source)
    }
}
