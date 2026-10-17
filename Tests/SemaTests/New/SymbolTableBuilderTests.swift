//
//  SymbolTableBuilderTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/09/2026.
//

import Testing
import Foundation
import AST
import Basic
import Diagnostics
@testable import Sema

@Suite struct SymbolTableBuilderTests {
    // MARK: - Functions
    private func buildError(_ source: String) -> Diagnostic? {
        return #expect(throws: Diagnostic.self) {
            try build(source)
        }
    }
    
    private func symbol(_ name: String, in table: SymbolTable) throws -> ClassSymbol {
        return try #require(table.lookup(ResolvedType(name: name)))
    }
    
    // MARK: - Registration Tests
    @Test func `builds empty table from no declarations`() throws {
        let table = try build("")
        
        #expect(table.symbols.isEmpty)
    }
    
    @Test func `registers every declared class`() throws {
        let source = """
        class Main { };
        class Foo { };
        class Bar { };
        """
        
        let table = try build(source)
        
        #expect(table.classNames == ["Main", "Foo", "Bar"])
    }
    
    @Test func `registers each class once when child is declared before parent`() throws {
        let source = """
        class Derived inherits Base { };
        class Base { };
        """
        
        let table = try build(source)
        
        #expect(table.classNames == ["Base", "Derived"])
    }
    
    @Test func `does not register interface classes as user symbols`() throws {
        let source = """
        class Main inherits IO { };
        """
        
        let table = try build(source)
        
        #expect(table.classNames == ["Main"])
        #expect(table.lookup(ResolvedType(name: "IO")) != nil)
        #expect(table.lookup(ResolvedType.int) != nil)
    }
    
    @Test func `looks up declared classes by type`() throws {
        let source = """
        class Main { };
        """
        
        let table = try build(source)
        
        let main = try symbol("Main", in: table)
        #expect(main.type == ResolvedType(name: "Main"))
        #expect(table.lookup(ResolvedType(name: "Missing")) == nil)
    }
    
    // MARK: - Duplicate Class Tests
    @Test func `detects duplicate class declarations`() throws {
        let source = """
        class Main { };
        class Main { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "duplicate class 'Main'")
        #expect(error?.location?.line == 2)
    }
    
    @Test func `detects duplicate class declarations that are not adjacent`() throws {
        let source = """
        class A { };
        class B { };
        class A inherits B { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "duplicate class 'A'")
        #expect(error?.location?.line == 3)
    }
    
    // MARK: - Superclass Tests
    @Test func `root class inherits from Object`() throws {
        let source = """
        class Main { };
        """
        
        let table = try build(source)
        
        let main = try symbol("Main", in: table)
        #expect(main.superclass?.type == ResolvedType(name: "Object"))
    }
    
    @Test func `class inherits from interface class`() throws {
        let source = """
        class Main inherits IO { };
        """
        
        let table = try build(source)
        
        let main = try symbol("Main", in: table)
        let io = try symbol("IO", in: table)
        #expect(main.superclass === io)
    }
    
    @Test func `links superclass to the registered parent symbol`() throws {
        let source = """
        class Derived inherits Base { };
        class Base { };
        """
        
        let table = try build(source)
        
        let base = try symbol("Base", in: table)
        let derived = try symbol("Derived", in: table)
        #expect(derived.superclass === base)
    }
    
    @Test func `builds valid inheritance chain`() throws {
        let expectedParents = [
            "Base": "Object",
            "Middle": "Base",
            "Derived": "Middle"
        ]
        let source = """
        class Derived inherits Middle { };
        class Base { };
        class Middle inherits Base { };
        """
        
        let table = try build(source)
        
        #expect(table.classNames == Set(expectedParents.keys))
        for item in table.symbols {
            let expected = expectedParents[item.decl.name.value]
            #expect(item.superclass?.decl.name.value == expected)
        }
    }
    
    @Test func `finds ancestors through superclass lookup`() throws {
        let source = """
        class Base { };
        class Middle inherits Base { };
        class Derived inherits Middle { };
        class Other { };
        """
        
        let table = try build(source)
        
        let derived = try symbol("Derived", in: table)
        var superclasses = Set<String>()
        var superclass = derived.superclass
        while let sc = superclass {
            superclasses.insert(sc.type.name)
            superclass = sc.superclass
        }
        #expect(superclasses == ["Middle", "Base", "Object"])
    }
    
    // MARK: - Inheritance Validation Tests
    @Test(arguments: ["Int", "String", "Bool"])
    func `detects inheriting from a basic type`(type: String) throws {
        let error = buildError("class A inherits \(type) { };")
        
        #expect(error?.message == "cannot inherit from basic type '\(type)'")
        #expect(error?.location?.line == 1)
    }
    
    @Test func `allows inheriting from IO`() throws {
        let table = try build("class Main inherits IO { };")
        
        #expect(try symbol("Main", in: table).superclass?.type == ResolvedType(name: "IO"))
    }
    
    @Test func `detects undefined parent class`() throws {
        let source = """
        class Main inherits Foo { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "parent class 'Foo' is not defined")
        #expect(error?.location?.line == 1)
    }
    
    @Test func `detects undefined parent class deep in chain`() throws {
        let source = """
        class A inherits B { };
        class B inherits C { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "parent class 'C' is not defined")
        #expect(error?.location?.line == 2)
    }
    
    @Test func `detects self inheritance`() throws {
        let source = """
        class Main inherits Main { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "class 'Main' inherits from itself")
    }
    
    @Test func `detects cyclic inheritance with two classes`() throws {
        let source = """
        class A inherits B { };
        class B inherits A { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "class 'B' inherits from itself")
        #expect(error?.location?.line == 2)
    }
    
    @Test func `detects cyclic inheritance with three classes`() throws {
        let source = """
        class A inherits B { };
        class B inherits C { };
        class C inherits A { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "class 'C' inherits from itself")
    }
    
    @Test func `detects cycle reached through a valid class`() throws {
        let source = """
        class Leaf inherits A { };
        class A inherits B { };
        class B inherits A { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "class 'B' inherits from itself")
    }
    
    @Test func `detects cyclic inheritance after valid inheritance`() throws {
        let source = """
        class A inherits B { };
        class B { };
        
        class D inherits E { };
        class E inherits D { };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "class 'E' inherits from itself")
    }
    
    @Test func `allows multiple children of the same parent`() throws {
        let source = """
        class Base { };
        class Left inherits Base { };
        class Right inherits Base { };
        """
        
        let table = try build(source)
        
        let base = try symbol("Base", in: table)
        #expect(try symbol("Left", in: table).superclass === base)
        #expect(try symbol("Right", in: table).superclass === base)
        #expect(table.symbols.count == 3)
    }
    
    // MARK: - Member Registration Tests
    @Test func `registers members on their declaring class`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int { 0 };
            y : String;
        };
        """
        
        let table = try build(source)
        
        let main = try symbol("Main", in: table)
        for name in ["x", "foo", "y"] {
            let member = try #require(main.lookup(name))
            #expect(member.parent == main.type)
            #expect(member.decl.name.value == name)
        }
    }
    
    @Test func `returns nil for unknown members`() throws {
        let source = """
        class Main { x : Int; };
        """
        
        let table = try build(source)
        
        let main = try symbol("Main", in: table)
        #expect(main.lookup("missing") == nil)
    }
    
    @Test func `resolves inherited members to the declaring class`() throws {
        let source = """
        class Base {
            x : Int;
            foo() : Int { 0 };
        };
        class Derived inherits Base {
            bar() : Int { 1 };
        };
        """
        
        let table = try build(source)
        
        let derived = try symbol("Derived", in: table)
        let base = ResolvedType(name: "Base")
        #expect(derived.lookup("x")?.parent == base)
        #expect(derived.lookup("foo")?.parent == base)
        #expect(derived.lookup("bar")?.parent == derived.type)
    }
    
    @Test func `resolves interface members through inheritance`() throws {
        let source = """
        class Main inherits IO { };
        """
        
        let table = try build(source)
        
        let main = try symbol("Main", in: table)
        let member = main.lookup("out_string")
        #expect(member?.parent == ResolvedType(name: "IO"))
    }
    
    @Test func `resolves Object members from root class`() throws {
        let source = """
        class Main { };
        """
        
        let table = try build(source)
        
        let main = try symbol("Main", in: table)
        let member = main.lookup("type_name")
        #expect(member?.parent == ResolvedType(name: "Object"))
    }
    
    @Test func `allows same member name in unrelated classes`() throws {
        let source = """
        class A { foo() : Int { 0 }; };
        class B { foo() : Int { 1 }; };
        """
        
        let table = try build(source)
        
        for name in ["A", "B"] {
            let item = try symbol(name, in: table)
            #expect(item.lookup("foo")?.parent == item.type)
        }
    }
    
    // MARK: - Duplicate Member Tests
    @Test func `detects duplicate function declarations in same class`() throws {
        let source = """
        class Main {
            foo() : Int { 0 };
            foo() : Int { 1 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "invalid redeclaration of 'foo'")
        #expect(error?.location?.line == 3)
    }
    
    @Test func `detects duplicate variable declarations in same class`() throws {
        let source = """
        class Main {
            x : Int;
            x : Int;
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "invalid redeclaration of 'x'")
        #expect(error?.location?.line == 3)
    }
    
    @Test func `detects duplicate mixed member declarations in same class`() throws {
        let source = """
        class Main {
            foo : Int;
            foo() : Int { 0 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "invalid redeclaration of 'foo'")
    }
    
    @Test func `detects duplicate members in child class`() throws {
        let source = """
        class Base { };
        class Derived inherits Base {
            x : Int;
            x : Int;
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "invalid redeclaration of 'x'")
        #expect(error?.location?.line == 4)
    }
    
    // MARK: - Override Tests
    @Test func `detects property override`() throws {
        let source = """
        class Base {
            x : Int;
        };
        class Derived inherits Base {
            x : Int;
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "overriding a property is not allowed: 'x'")
        #expect(error?.location?.line == 5)
    }
    
    @Test func `detects property override in deep hierarchy`() throws {
        let source = """
        class Base { x : Int; };
        class Middle inherits Base { };
        class Derived inherits Middle { x : String; };
        """
        
        let error = buildError(source)
        
        #expect(error?.message == "overriding a property is not allowed: 'x'")
    }
    
    @Test func `allows function override with matching signature`() throws {
        let source = """
        class Base {
            foo(a : Int, b : String) : Int { 0 };
        };
        class Derived inherits Base {
            foo(a : Int, b : String) : Int { 1 };
        };
        """
        
        let table = try build(source)
        
        for name in ["Base", "Derived"] {
            let item = try symbol(name, in: table)
            #expect(item.lookup("foo")?.parent == item.type)
        }
    }
    
    @Test func `resolves override in deep hierarchy`() throws {
        let expectedParents = [
            "Base": "Base",
            "Middle": "Base",
            "Derived": "Derived"
        ]
        let source = """
        class Base {
            foo() : Int { 0 };
        };
        class Middle inherits Base { };
        class Derived inherits Middle {
            foo() : Int { 2 };
        };
        """
        
        let table = try build(source)
        
        for item in table.symbols {
            let member = item.lookup("foo")
            #expect(member?.parent.name == expectedParents[item.decl.name.value])
        }
    }
    
    @Test func `override belongs to the child class`() throws {
        let source = """
        class Base {
            foo() : Int { 0 };
        };
        class Derived inherits Base {
            bar() : Int { 1 };
            foo() : Int { 2 };
        };
        """
        
        let table = try build(source)
        
        let derived = try symbol("Derived", in: table)
        let member = derived.lookup("foo")
        #expect(member?.parent == derived.type)
    }
    
    @Test func `detects override return type mismatch`() throws {
        let source = """
        class Base {
            foo() : Int { 0 };
        };
        class Derived inherits Base {
            foo() : String { "" };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.id.hasPrefix("SemaError-funcOverrideMismatch") == true)
        #expect(error?.id.contains("returnTypeMismatch") == true)
        #expect(error?.location?.line == 5)
    }
    
    @Test func `detects override parameter type mismatch`() throws {
        let source = """
        class Base {
            foo(a : Int) : Int { 0 };
        };
        class Derived inherits Base {
            foo(a : String) : Int { 1 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.id.hasPrefix("SemaError-funcOverrideMismatch") == true)
        #expect(error?.id.contains("paramTypeMismatch") == true)
    }
    
    @Test func `detects override parameter name mismatch`() throws {
        let source = """
        class Base {
            foo(a : Int) : Int { 0 };
        };
        class Derived inherits Base {
            foo(b : Int) : Int { 1 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.id.hasPrefix("SemaError-funcOverrideMismatch") == true)
        #expect(error?.id.contains("paramNameMismatch") == true)
    }
    
    @Test func `detects override with missing parameter`() throws {
        let source = """
        class Base {
            foo(a : Int, b : Int) : Int { 0 };
        };
        class Derived inherits Base {
            foo(a : Int) : Int { 1 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.id.hasPrefix("SemaError-funcOverrideMismatch") == true)
        #expect(error?.id.contains("missingParam") == true)
    }
    
    @Test func `detects override with extra parameter`() throws {
        let source = """
        class Base {
            foo(a : Int) : Int { 0 };
        };
        class Derived inherits Base {
            foo(a : Int, b : Bool) : Int { 1 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.id.hasPrefix("SemaError-funcOverrideMismatch") == true)
        #expect(error?.id.contains("extraParam") == true)
    }
    
    @Test func `detects override with reordered parameters`() throws {
        let source = """
        class Base {
            foo(a : Int, b : String) : Int { 0 };
        };
        class Derived inherits Base {
            foo(b : String, a : Int) : Int { 1 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error?.id.hasPrefix("SemaError-funcOverrideMismatch") == true)
        #expect(error?.id.contains("wrongIndex") == true)
    }
    
    @Test func `detects function overriding a property`() throws {
        let source = """
        class Base {
            foo : Int;
        };
        class Derived inherits Base {
            foo() : Int { 0 };
        };
        """
        
        let error = buildError(source)
        
        #expect(error != nil)
    }
    
    @Test func `detects property overriding a function`() throws {
        let source = """
        class Base {
            foo() : Int { 0 };
        };
        class Derived inherits Base {
            foo : Int;
        };
        """
        
        let error = buildError(source)
        
        #expect(error != nil)
    }
    
    // MARK: - Complex Tests
    @Test func `builds complex class hierarchy with members`() throws {
        let expectedClasses = [
            "Base": ("Object", Set(["x", "foo"])),
            "Middle": ("Base", Set(["y", "bar"])),
            "Derived": ("Middle", Set(["z", "baz", "foo"])),
        ]
        let source = """
        class Derived inherits Middle {
            z : Bool;
            baz() : Bool { true };
            foo() : Int { 1 };
        };
        class Base {
            x : Int;
            foo() : Int { 0 };
        };
        class Middle inherits Base {
            y : String;
            bar() : String { "hello" };
        };
        """
        
        let table = try build(source)
        
        #expect(table.classNames == Set(expectedClasses.keys))
        for item in table.symbols {
            let expected = expectedClasses[item.decl.name.value]
            #expect(item.superclass?.decl.name.value == expected?.0)
            #expect(item.memberNames == expected?.1)
        }
        
        let derived = try symbol("Derived", in: table)
        let lookups = [
            "x": "Base",
            "y": "Middle",
            "z": "Derived",
            "foo": "Derived",
            "bar": "Middle",
            "baz": "Derived",
            "abort": "Object"
        ]
        for (name, parent) in lookups {
            let member = derived.lookup(name)
            #expect(member?.parent.name == parent, "\(name)")
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
