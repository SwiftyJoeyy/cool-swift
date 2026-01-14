//
//  VarDeclSemaTests.swift
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

@Suite struct VarDeclSemaTests {
// MARK: - Helper Functions
    private func analyze(_ source: String) throws {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        let sourceFile = try parser.parse()
        let sema = Sema(diagnostics: diagEngine, interfaceSymbols: .test)
        try sema.analyze(sourceFile)
    }
    
// MARK: - Valid Variable Declarations
    @Test func `validates variable with matching type initializer`() throws {
        let source = """
        class Main {
            x : Int <- 42;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates variable with string initializer`() throws {
        let source = """
        class Main {
            msg : String <- "hello";
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates variable with bool initializer`() throws {
        let source = """
        class Main {
            flag : Bool <- true;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates variable without initializer`() throws {
        let source = """
        class Main {
            x : Int;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates variable with new expression`() throws {
        let source = """
        class Foo { };
        class Main {
            obj : Foo <- new Foo;
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Type Mismatch Tests
    @Test func `detects type mismatch - expected Int got String`() throws {
        let source = """
        class Main {
            x : Int <- "hello";
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Int'")
    }
    
    @Test func `detects type mismatch - expected String got Int`() throws {
        let source = """
        class Main {
            msg : String <- 42;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'Int' to specified type 'String'")
    }
    
    @Test func `detects type mismatch - expected Bool got Int`() throws {
        let source = """
        class Main {
            flag : Bool <- 123;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'Int' to specified type 'Bool'")
    }
    
    @Test func `detects type mismatch - expected custom type got String`() throws {
        let source = """
        class Foo { };
        class Main {
            obj : Foo <- "test";
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Foo'")
    }
    
// MARK: - Undefined Type Tests
    @Test func `detects undefined type in declaration`() throws {
        let source = """
        class Main {
            x : UndefinedType;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'UndefinedType'")
    }
    
    @Test func `detects undefined type in new expression`() throws {
        let source = """
        class Main {
            obj : Foo <- new Foo;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'Foo'")
    }
    
// MARK: - Instance Member in Property Initializer Tests
    @Test func `allows instance member access in property initializer`() throws {
        let source = """
        class Main {
            x : Int;
            y : Int <- x;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `allows new object member access in property initializer`() throws {
        let source = """
        class Foo {
            value : Int;
        };
        class Main {
            x : Int <- (new Foo).value;
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Function as Value Tests
    @Test func `detects function used as value in initializer`() throws {
        let source = """
        class Main {
            foo() : Int { 42 };
            x : Int <- (new Main).foo;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot use method 'foo' without calling it")
    }
    
// MARK: - Member Access Tests
    @Test func `validates member access on new object`() throws {
        let source = """
        class Foo {
            value : Int;
        };
        class Main {
            x : Int <- (new Foo).value;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects undefined member access`() throws {
        let source = """
        class Foo { };
        class Main {
            x : Int <- (new Foo).undefined;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "value of type 'Foo' has no member 'undefined'")
    }
    
    @Test func `detects function used as value in member access`() throws {
        let source = """
        class Foo {
            getValue() : Int { 42 };
        };
        class Main {
            x : Int <- (new Foo).getValue;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot use method 'getValue' without calling it")
    }
    
// MARK: - Function Call Tests
    @Test func `validates function call with no arguments`() throws {
        let source = """
        class Foo {
            getValue() : Int { 42 };
        };
        class Main {
            x : Int <- (new Foo).getValue();
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates function call with matching arguments`() throws {
        let source = """
        class Foo {
            add(a : Int, b : Int) : Int { a };
        };
        class Main {
            x : Int <- (new Foo).add(1, 2);
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects argument count mismatch too few`() throws {
        let source = """
        class Foo {
            add(a : Int, b : Int) : Int { a };
        };
        class Main {
            x : Int <- (new Foo).add(1);
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "missing argument for parameter in call")
    }
    
    @Test func `detects argument count mismatch too many`() throws {
        let source = """
        class Foo {
            getValue() : Int { 42 };
        };
        class Main {
            x : Int <- (new Foo).getValue(1);
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "extra argument in call")
    }
    
    @Test func `detects argument type mismatch`() throws {
        let source = """
        class Foo {
            set(value : Int) : Int { value };
        };
        class Main {
            x : Int <- (new Foo).set("hello");
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to expected argument type 'Int'")
    }
    
    @Test func `detects calling non function`() throws {
        let source = """
        class Foo {
            value : Int;
        };
        class Main {
            x : Int <- (new Foo).value();
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot call value of non-function type 'Int'")
    }
    
// MARK: - Complex Initializer Tests
    @Test func `validates nested member access`() throws {
        let source = """
        class Inner {
            value : Int;
        };
        class Outer {
            inner : Inner;
        };
        class Main {
            x : Int <- (new Outer).inner.value;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates method chain`() throws {
        let source = """
        class Builder {
            build() : Builder { self };
        };
        class Main {
            b : Builder <- (new Builder).build().build();
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects type mismatch in nested expression`() throws {
        let source = """
        class Foo {
            getValue() : String { "test" };
        };
        class Main {
            x : Int <- (new Foo).getValue();
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Int'")
    }
    
// MARK: - Multiple Variables Tests
    @Test func `validates multiple variables with different types`() throws {
        let source = """
        class Main {
            x : Int <- 42;
            msg : String <- "hello";
            flag : Bool <- true;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates multiple variables in inheritance chain`() throws {
        let source = """
        class Base {
            x : Int <- 1;
        };
        class Derived inherits Base {
            y : String <- "test";
        };
        """
        
        try analyze(source)
    }
}
