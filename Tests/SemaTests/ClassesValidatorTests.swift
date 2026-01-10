//
//  ClassesValidatorTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 29/12/2025.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
import Parser
@testable import Sema

@Suite struct ClassesValidatorTests {
// MARK: - Functions
    @discardableResult
    private func validate(_ source: String) throws -> SymbolTable {
        var (parser, _) = try CoolParser.new(source: source)
        let sourceFile = try parser.parse()
        let symbols = SymbolTable()
        try SymbolTableBuilder(symbols: symbols)
            .build(from: sourceFile.declarations)
        return symbols
    }
    
// MARK: - Duplicate Class Tests
    @Test func `detects duplicate class declarations`() throws {
        let source = """
        class Main { };
        class Main { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "duplicate class 'Main'")
    }
    
    @Test func `allows multiple different classes`() throws {
        let source = """
        class Main { };
        class Foo { };
        class Bar { };
        """
        
        let table = try validate(source)
        
        #expect(table.classNames == ["Main", "Foo", "Bar"])
    }
    
// MARK: - Inheritance Validation Tests
    @Test func `detects undefined parent class`() throws {
        let source = """
        class Main inherits Foo { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "parent class 'Foo' is not defined")
    }
    
    @Test func `detects self inheritance`() throws {
        let source = """
        class Main inherits Main { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "class 'Main' inherits from itself")
    }
    
    @Test func `detects cyclic inheritance with two classes`() throws {
        let source = """
        class A inherits B { };
        class B inherits A { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "class 'B' inherits from itself")
    }
    
    @Test func `detects cyclic inheritance with three classes`() throws {
        let source = """
        class A inherits B { };
        class B inherits C { };
        class C inherits A { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "class 'C' inherits from itself")
    }
    
    @Test func `detects cyclic inheritance after valid inheritance`() throws {
        let source = """
        class A inherits B { };
        class B { };
        
        class D inherits E { };
        class E inherits D { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "class 'E' inherits from itself")
    }
    
    @Test func `allows valid inheritance chain`() throws {
        let expectedClasses = ["Base": nil, "Middle": "Base", "Derived": "Middle"]
        let source = """
        class Base { };
        class Middle inherits Base { };
        class Derived inherits Middle { };
        """
        
        let table = try validate(source)
        
        for item in table.symbols {
            let inheritance = expectedClasses[item.decl.name.value]
            #expect(item.superclass?.decl.name.value == inheritance)
        }
    }
    
// MARK: - Member Validation Tests
    @Test func `detects duplicate function declarations in same class`() throws {
        let source = """
        class Main {
            foo() : Int { 0 };
            foo() : Int { 1 };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "invalid redeclaration of 'foo'")
    }
    
    @Test func `detects duplicate variable declarations in same class`() throws {
        let source = """
        class Main {
            x : Int;
            x : Int;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "invalid redeclaration of 'x'")
    }
    
    @Test func `detects duplicate mixed member declarations in same class`() throws {
        let source = """
        class Main {
            foo : Int;
            foo() : Int { 0 };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try validate(source)
        }
        #expect(error?.message == "invalid redeclaration of 'foo'")
    }
    
    @Test func `allows function override`() throws {
        let source = """
        class Base {
            foo() : Int { 0 };
        };
        class Derived inherits Base {
            foo() : Int { 1 };
        };
        """
        
        let table = try validate(source)
        
        for item in table.symbols {
            let identifier = CanonicalIdentifier(name: "foo")
            #expect(item.lookup(identifier)?.parent.type == item.canonicalType.type)
        }
    }
    
    @Test func `allows variable override`() throws {
        let source = """
        class Base {
            x : Int;
        };
        class Derived inherits Base {
            x : Int;
        };
        """
        
        let table = try validate(source)
        
        for item in table.symbols {
            let identifier = CanonicalIdentifier(name: "x")
            #expect(item.lookup(identifier)?.parent.type == item.canonicalType.type)
        }
    }
    
    @Test func `allows different members in parent and child`() throws {
        let expectedClasses = [
            "Base": Set(["foo"]),
            "Derived": Set(["bar"])
        ]
        
        let source = """
        class Base {
            foo() : Int { 0 };
        };
        class Derived inherits Base {
            bar() : Int { 1 };
        };
        """
        
        let table = try validate(source)
        for item in table.symbols {
            #expect(item.memberNames == expectedClasses[item.decl.name.value])
        }
    }
    
    @Test func `allows same member name in unrelated classes`() throws {
        let expectedClasses = [
            "A": Set(["foo"]),
            "B": Set(["foo"])
        ]
        
        let source = """
        class A {
            foo() : Int { 0 };
        };
        class B {
            foo() : Int { 1 };
        };
        """
        
        let table = try validate(source)
        for item in table.symbols {
            #expect(item.memberNames == expectedClasses[item.decl.name.value])
        }
    }
    
// MARK: - Complex Tests
    @Test func `validates complex class hierarchy with members`() throws {
        let expectedClasses = [
            "Base": (nil, Set(["x", "foo"])),
            "Middle": ("Base", Set(["y", "bar"])),
            "Derived": ("Middle", Set(["z", "baz"])),
        ]
        
        let source = """
        class Base {
            x : Int;
            foo() : Int { 0 };
        };
        class Middle inherits Base {
            y : String;
            bar() : String { "hello" };
        };
        class Derived inherits Middle {
            z : Bool;
            baz() : Bool { true };
        };
        """
        
        try validate(source)
        
        let table = try validate(source)
        for item in table.symbols {
            let expectedClass = expectedClasses[item.decl.name.value]
            #expect(item.superclass?.decl.name.value == expectedClass?.0)
            #expect(item.memberNames == expectedClass?.1)
        }
    }
    
    @Test func `detects override in deep hierarchy`() throws {
        let expectedParents = ["Base": "Base", "Middle": "Base", "Derived": "Derived"]
        
        let source = """
        class Base {
            foo() : Int { 0 };
        };
        class Middle inherits Base { };
        class Derived inherits Middle {
            foo() : Int { 2 };
        };
        """
        
        let table = try validate(source)
        
        for item in table.symbols {
            let identifier = CanonicalIdentifier(name: "foo")
            let expectedParent = expectedParents[item.canonicalType.type]
            #expect(item.lookup(identifier)?.parent.type == expectedParent)
        }
    }
}

extension SymbolTable {
    fileprivate var classNames: Set<String> {
        return Set(symbols.map(\.decl.name.value))
    }
}

extension ClassSymbol {
    fileprivate var memberNames: Set<String> {
        return Set(members.map(\.name.value))
    }
}
