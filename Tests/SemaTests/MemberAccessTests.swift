//
//  MemberAccessTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/01/2026.
//

import Testing
import Foundation
import Sema
import Diagnostics

@Suite struct MemberAccessTests {
// MARK: - Property Access Tests
    @Test func `validates member access on object`() throws {
        let source = """
        class Foo {
            value : Int;
        };
        class Main {
            test() : Int {
                (new Foo).value
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects undefined member`() throws {
        let source = """
        class Foo { };
        class Main {
            test() : Int {
                (new Foo).undefined
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "value of type 'Foo' has no member 'undefined'")
    }
    
    @Test func `validates nested member access`() throws {
        let source = """
        class Inner {
            value : Int;
        };
        class Outer {
            inner : Inner;
        };
        class Main {
            test() : Int {
                (new Outer).inner.value
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates member access on self`() throws {
        let source = """
        class Main {
            x : Int;
            getX() : Int {
                self.x
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Method Call Tests
    @Test func `validates method call with no arguments`() throws {
        let source = """
        class Foo {
            getValue() : Int { 42 };
        };
        class Main {
            test() : Int {
                (new Foo).getValue()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates method call with arguments`() throws {
        let source = """
        class Foo {
            add(a : Int, b : Int) : Int { a };
        };
        class Main {
            test() : Int {
                (new Foo).add(1, 2)
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects argument count mismatch in method call`() throws {
        let source = """
        class Foo {
            getValue() : Int { 42 };
        };
        class Main {
            test() : Int {
                (new Foo).getValue(5)
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "extra argument in call")
    }
    
    @Test func `detects argument type mismatch in method call`() throws {
        let source = """
        class Foo {
            set(x : Int) : Int { x };
        };
        class Main {
            test() : Int {
                (new Foo).set("hello")
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to expected argument type 'Int'")
    }
    
    @Test func `validates method chaining`() throws {
        let source = """
        class Builder {
            build() : Builder { new Builder };
        };
        class Main {
            test() : Builder {
                (new Builder).build().build()
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Inherited Member Tests
    @Test func `validates access to inherited property`() throws {
        let source = """
        class Base {
            x : Int;
        };
        class Derived inherits Base { };
        class Main {
            test() : Int {
                (new Derived).x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates call to inherited method`() throws {
        let source = """
        class Base {
            getValue() : Int { 42 };
        };
        class Derived inherits Base { };
        class Main {
            test() : Int {
                (new Derived).getValue()
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Static Dispatch Tests
    @Test func `validates static dispatch to parent`() throws {
        let source = """
        class Base {
            foo() : Int { 1 };
        };
        class Derived inherits Base {
            foo() : Int { 2 };
            test() : Int {
                (new Derived)@Base.foo()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `resolves static dispatch calls with a static dispatch base`() throws {
        let source = """
        class Base {
            foo() : Int { 1 };
        };
        class Main inherits Base {
            foo() : Int { 2 };
            test() : Int { self@Base.foo() };
        };
        """
        
        let main = try #require(try resolve(source).declarations.first { $0.name == "Main" })
        let test = try #require(main.methods.first { $0.name == "test" })
        let call = try #require(test.body as? ResolvedFuncCallExpr)
        guard case .staticDispatch(let dispatch) = call.base else {
            Issue.record("Expected a static dispatch base, got \(call.base)")
            return
        }
        #expect(dispatch.type.name == "Base")
        #expect(dispatch.base.type.name == "Main")
    }
    
    @Test func `static dispatch SELF_TYPE result is the receiver type`() throws {
        let source = """
        class A {
            me() : SELF_TYPE { self };
        };
        class B inherits A {
            onlyB() : Int { 1 };
            test() : Int { (new B)@A.me().onlyB() };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects invalid static dispatch to non-parent`() throws {
        let source = """
        class A { };
        class B { };
        class Main {
            test() : A {
                (new A)@B
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "type 'A' does not inherit from 'B'")
    }
    
    @Test func `validates static dispatch in deep inheritance`() throws {
        let source = """
        class GrandParent {
            foo() : Int { 1 };
        };
        class Parent inherits GrandParent {
            foo() : Int { 2 };
        };
        class Child inherits Parent {
            foo() : Int { 3 };
            test() : Int {
                (new Child)@GrandParent.foo()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates static dispatch to self type`() throws {
        let source = """
        class Base {
            foo() : Int { 1 };
        };
        class Derived inherits Base {
            test() : Int {
                (new Derived)@Derived.foo()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects invalid static dispatch to undefined type`() throws {
        let source = """
        class A { };
        class B { };
        class Main {
            test() : A {
                (new A)@C
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'C'")
    }
    
    @Test func `detects undefined member access base type`() throws {
        let source = """
        class A { };
        class B { };
        class Main {
            test() : A {
                (new C)@A
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'C'")
    }
    
// MARK: - Function vs Property Tests
    @Test func `detects method used as property`() throws {
        let source = """
        class Foo {
            getValue() : Int { 42 };
        };
        class Main {
            test() : Int {
                (new Foo).getValue
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot use method 'getValue' without calling it")
    }
    
    @Test func `detects property used as function`() throws {
        let source = """
        class Foo {
            value : Int;
        };
        class Main {
            test() : Int {
                (new Foo).value()
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot call non-function 'value'")
    }
    
// MARK: - Complex Member Access Tests
    @Test func `validates member access in method chain`() throws {
        let source = """
        class Point {
            x : Int;
            getX() : Int { x };
        };
        class Main {
            test() : Int {
                (new Point).getX()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates passing member access as argument`() throws {
        let source = """
        class Foo {
            value : Int;
        };
        class Main {
            process(x : Int) : Int { x };
            test() : Int {
                process((new Foo).value)
            };
        };
        """
        
        try analyze(source)
    }
}
