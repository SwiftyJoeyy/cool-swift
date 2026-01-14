//
//  ModuleInterfaceSymbolsTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 14/01/2026.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
import Lexer
import Parser
@testable import Sema

@Suite struct ModuleInterfaceSymbolsTests {
// MARK: - Functions
    private func loadInterface(_ source: String, file: String = "test.clmodule") throws -> ModuleInterfaceSymbols {
        let loader = ModuleInterfaceSymbols()
        var (parser, _) = try CoolParser.new(source: source, file: file)
        let interfaceFile = try parser.parseInterface()
        try loader.load(interfaceFile)
        return loader
    }
    
// MARK: - Basic Tests
    @Test func `loads single class without members`() throws {
        let source = "class Foo { };"
        let symbols = try loadInterface(source)
        
        let fooSymbol = try #require(symbols.lookup(CanonicalType(type: "Foo")))
        #expect(fooSymbol.decl.name.value == "Foo")
        #expect(fooSymbol.members.isEmpty)
    }
    
    @Test func `loads multiple classes without members`() throws {
        let source = """
        class Foo { };
        class Bar { };
        class Baz { };
        """
        let symbols = try loadInterface(source)
        
        let fooSymbol = try #require(symbols.lookup(CanonicalType(type: "Foo")))
        #expect(fooSymbol.decl.name.value == "Foo")
        
        let barSymbol = try #require(symbols.lookup(CanonicalType(type: "Bar")))
        #expect(barSymbol.decl.name.value == "Bar")
        
        let bazSymbol = try #require(symbols.lookup(CanonicalType(type: "Baz")))
        #expect(bazSymbol.decl.name.value == "Baz")
    }
    
// MARK: - Class with Members Tests
    @Test func `loads class with interface function members`() throws {
        let source = """
        class Foo {
            bar() : Int;
            baz(x : String) : String;
        };
        """
        let symbols = try loadInterface(source)
        
        let fooSymbol = try #require(symbols.lookup(CanonicalType(type: "Foo")))
        #expect(fooSymbol.members.count == 2)
        
        let members = fooSymbol.members.compactMap { $0 as? InterfaceFuncDecl }
        #expect(members.count == 2)
        
        let names = Set(members.map(\.name.value))
        #expect(names == ["bar", "baz"])
    }
    
    @Test func `loads class with interface variable members`() throws {
        let source = """
        class Foo {
            x : Int;
            y : String;
        };
        """
        let symbols = try loadInterface(source)
        
        let fooSymbol = try #require(symbols.lookup(CanonicalType(type: "Foo")))
        #expect(fooSymbol.members.count == 2)
        
        let members = fooSymbol.members.compactMap { $0 as? InterfaceVarDecl }
        #expect(members.count == 2)
        
        let names = Set(members.map(\.name.value))
        #expect(names == ["x", "y"])
    }
    
    @Test func `loads class with mixed interface members`() throws {
        let source = """
        class Foo {
            x : Int;
            bar() : Int;
            y : String;
            baz(x : String) : String;
        };
        """
        let symbols = try loadInterface(source)
        
        let fooSymbol = try #require(symbols.lookup(CanonicalType(type: "Foo")))
        #expect(fooSymbol.members.count == 4)
        
        let funcMembers = fooSymbol.members.compactMap { $0 as? InterfaceFuncDecl }
        #expect(funcMembers.count == 2)
        
        let varMembers = fooSymbol.members.compactMap { $0 as? InterfaceVarDecl }
        #expect(varMembers.count == 2)
    }
    
// MARK: - Inheritance Tests
    @Test func `loads class with inheritance`() throws {
        let source = """
        class Base { };
        class Derived inherits Base { };
        """
        let symbols = try loadInterface(source)
        
        let baseSymbol = try #require(symbols.lookup(CanonicalType(type: "Base")))
        #expect(baseSymbol.decl.name.value == "Base")
        
        let derivedSymbol = try #require(symbols.lookup(CanonicalType(type: "Derived")))
        #expect(derivedSymbol.decl.name.value == "Derived")
        #expect(derivedSymbol.superclass?.decl.name.value == "Base")
    }
    
    @Test func `loads inheritance chain`() throws {
        let source = """
        class Base { };
        class Middle inherits Base { };
        class Derived inherits Middle { };
        """
        let symbols = try loadInterface(source)
        
        let baseSymbol = try #require(symbols.lookup(CanonicalType(type: "Base")))
        #expect(baseSymbol.decl.name.value == "Base")
        
        let middleSymbol = try #require(symbols.lookup(CanonicalType(type: "Middle")))
        #expect(middleSymbol.superclass?.decl.name.value == "Base")
        
        let derivedSymbol = try #require(symbols.lookup(CanonicalType(type: "Derived")))
        #expect(derivedSymbol.superclass?.decl.name.value == "Middle")
    }
    
// MARK: - Lookup Tests
    @Test func `lookup returns nil for nonexistent class`() throws {
        let source = "class Foo { };"
        let symbols = try loadInterface(source)
        
        #expect(symbols.lookup(CanonicalType(type: "Bar")) == nil)
        #expect(symbols.lookup(CanonicalType(type: "Baz")) == nil)
    }
    
    @Test func `lookup returns correct symbols`() throws {
        let source = """
        class Foo { };
        class Bar { };
        """
        let symbols = try loadInterface(source)
        
        let fooSymbol = try #require(symbols.lookup(CanonicalType(type: "Foo")))
        #expect(fooSymbol.decl.name.value == "Foo")
        
        let barSymbol = try #require(symbols.lookup(CanonicalType(type: "Bar")))
        #expect(barSymbol.decl.name.value == "Bar")
        
        #expect(fooSymbol.canonicalType != barSymbol.canonicalType)
    }
    
// MARK: - Error Cases
    @Test func `throws on duplicate class declarations`() throws {
        let source = """
        class Foo { };
        class Foo { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try loadInterface(source)
        }
        #expect(error?.message == "duplicate class 'Foo'")
    }
    
    @Test func `throws on undefined parent class`() throws {
        let source = """
        class Derived inherits Base { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try loadInterface(source)
        }
        #expect(error?.message == "parent class 'Base' is not defined")
    }
    
    @Test func `throws on cyclic inheritance`() throws {
        let source = """
        class A inherits B { };
        class B inherits A { };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try loadInterface(source)
        }
        #expect(error?.message == "class 'B' inherits from itself")
    }
    
    @Test func `throws on duplicate member declarations`() throws {
        let source = """
        class Foo {
            bar() : Int;
            bar() : Int;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try loadInterface(source)
        }
        #expect(error?.message == "invalid redeclaration of 'bar'")
    }
}
