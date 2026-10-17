//
//  ExpressionTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/01/2026.
//

import Testing
import Foundation
import Diagnostics
import Sema

@Suite struct ExpressionTests {
// MARK: - Literal Tests
    @Test func `validates integer literal`() throws {
        let source = """
        class Main {
            x : Int <- 42;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates the largest integer literal`() throws {
        let source = """
        class Main {
            x : Int <- 2147483647;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects integer literal overflow`() throws {
        let source = """
        class Main {
            x : Int <- 2147483648;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "integer literal '2147483648' overflows when stored into 'Int'")
    }
    
    @Test func `resolves literals to typed values`() throws {
        let source = """
        class Main {
            i() : Int { 0042 };
            b() : Bool { true };
            s() : String { "hi" };
        };
        """
        
        let methods = try #require(try resolve(source).declarations.first?.methods)
        let values = methods.map { ($0.body as? ResolvedLiteralExpr)?.value }
        
        guard case .int(42) = values[0] else {
            Issue.record("Expected int literal, got \(String(describing: values[0]))")
            return
        }
        guard case .bool(true) = values[1] else {
            Issue.record("Expected bool literal, got \(String(describing: values[1]))")
            return
        }
        guard case .string("hi") = values[2] else {
            Issue.record("Expected string literal, got \(String(describing: values[2]))")
            return
        }
        #expect(methods.map(\.body.type) == [.int, .bool, .string])
    }
    
    @Test func `resolves block type to its last expression`() throws {
        let source = """
        class Main {
            foo() : String { { 1; true; "last"; } };
        };
        """
        
        let method = try #require(try resolve(source).declarations.first?.methods.first)
        let block = try #require(method.body as? ResolvedBlockExpr)
        #expect(block.type == .string)
    }
    
    @Test func `resolves binary operators`() throws {
        let source = """
        class Main {
            a() : Int { 1 + 2 };
            b() : Bool { 1 <= 2 };
            c() : Bool { 1 = 2 };
        };
        """
        
        let methods = try #require(try resolve(source).declarations.first?.methods)
        let operators = methods.compactMap { ($0.body as? ResolvedOperationExpr)?.op }
        #expect(operators == [.plus, .lessThanOrEqual, .equal])
    }
    
    @Test func `validates string literal`() throws {
        let source = """
        class Main {
            msg : String <- "hello";
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates bool literal`() throws {
        let source = """
        class Main {
            flag : Bool <- true;
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Arithmetic Operation Tests
    @Test func `validates addition of integers`() throws {
        let source = """
        class Main {
            foo() : Int {
                1 + 3
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects invalid addition String plus Int`() throws {
        let source = """
        class Main {
            foo() : Int {
                1 + "hello"
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "binary operator '+' can only be applied to operands of type 'Int'")
    }
    
    @Test func `detects invalid addition String plus String`() throws {
        let source = """
        class Main {
            foo() : Int {
                "hello" + "world"
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "binary operator '+' can only be applied to operands of type 'Int'")
    }
    
    @Test func `validates subtraction multiplication division`() throws {
        let source = """
        class Main {
            x : Int;
            y : Int;
            z : Int;
        
            foo() : Int {
                (x * z) - (1 / y)
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects type error in operations`() throws {
        let source = """
        class Main {
            x : Int;
            y : Int;
            z : Int;
        
            foo() : Bool {
                (x * z) - (1 / y)
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'Int' to specified type 'Bool'")
    }
    
// MARK: - Comparison Tests
    @Test func `validates equality comparison with integers`() throws {
        let source = """
        class Main {
            foo() : Bool {
                1 = 2
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates equality comparison with strings`() throws {
        let source = """
        class Main {
            foo() : Bool {
                "hello" = "world"
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates equality comparison with bools`() throws {
        let source = """
        class Main {
            foo() : Bool {
                true = false
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates equality comparison with objects`() throws {
        let source = """
        class Foo { };
        class Main {
            foo() : Bool {
                (new Foo) = (new Foo)
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates equality comparison with different object types`() throws {
        let source = """
        class A { };
        class B { };
        class Main {
            foo() : Bool {
                (new A) = (new B)
            };
        };
        """
    
        
        try analyze(source)
    }

    @Test func `detects equality comparison between String and Bool`() throws {
        let source = """
        class Main {
            foo() : Bool {
                "hello" = true
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "binary operator '=' cannot be applied to operands of type 'String' and 'Bool'")
    }
    
    @Test func `detects equality comparison between Int and String`() throws {
        let source = """
        class Main {
            foo() : Bool {
                5 = "hello"
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "binary operator '=' cannot be applied to operands of type 'Int' and 'String'")
    }
    
    @Test func `detects equality comparison between Int and Bool`() throws {
        let source = """
        class Main {
            foo() : Bool {
                5 = true
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "binary operator '=' cannot be applied to operands of type 'Int' and 'Bool'")
    }
    
    @Test func `validates less than comparison`() throws {
        let source = """
        class Main {
            foo() : Bool {
                1 < 2
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates less than or equal comparison`() throws {
        let source = """
        class Main {
            foo() : Bool {
                1 <= 2
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects less than comparison with non-int`() throws {
        let source = """
        class Main {
            foo() : Bool {
                "hello" < "world"
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "binary operator '<' can only be applied to operands of type 'Int'")
    }
    
// MARK: - Not Expression Tests
    @Test func `validates not expression with bool`() throws {
        let source = """
        class Main {
            foo() : Bool {
                not true
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects not on non-bool`() throws {
        let source = """
        class Main {
            foo() : Bool {
                not 5
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "'not' can only be applied to an operand of type 'Bool'")
    }
    
    @Test func `validates not returns bool`() throws {
        let source = """
        class Main {
            x : Bool;
            foo() : Bool {
                x <- not false
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - IsVoid Tests
    @Test func `validates isvoid on any expression`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Bool {
                isvoid x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `isvoid returns bool`() throws {
        let source = """
        class Main {
            flag : Bool;
            test() : Bool {
                flag <- isvoid 42
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates isvoid on object`() throws {
        let source = """
        class Foo { };
        class Main {
            test() : Bool {
                isvoid (new Foo)
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates isvoid on literals`() throws {
        let source = """
        class Main {
            test() : Bool {
                isvoid "hello"
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Complement Tests
    @Test func `validates complement expression with int`() throws {
        let source = """
        class Main {
            foo() : Int {
                ~5
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects complement on non int`() throws {
        do {
            let source = """
            class Main {
                foo() : Int {
                    ~true
                };
            };
            """
            
            let error = #expect(throws: Diagnostic.self) {
                try analyze(source)
            }
            #expect(error?.message == "'~' can only be applied to an operand of type 'Int'")
        }
        
        do {
            let source = """
            class Main {
                foo() : Int {
                    ~"hello"
                };
            };
            """
            
            let error = #expect(throws: Diagnostic.self) {
                try analyze(source)
            }
            #expect(error?.message == "'~' can only be applied to an operand of type 'Int'")
        }
    }
    
    @Test func `validates complement returns int`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                x <- ~42
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates operations on complement result`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                ~x + 1
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates complement on operation`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                ~(x + 1)
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates nested complement`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                ~~x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates complex expression with complement and operations`() throws {
        let source = """
        class Main {
            x : Int;
            y : Int;
            foo() : Int {
                (~x + y) * ~(x - y)
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - DeclRef Tests
    @Test func `detects reference to undefined variable`() throws {
        let source = """
        class Main {
            foo() : Int {
                undefined
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot find 'undefined' in scope")
    }
    
    @Test func `validates reference to self`() throws {
        let source = """
        class Point {
            x : Int;
            foo() : Point {
                self
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects method used as value`() throws {
        let source = """
        class Main {
            getValue() : Int { 42 };
            foo() : Int {
                getValue
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot use method 'getValue' without calling it")
    }
    
// MARK: - New Expression Tests
    @Test func `validates new with type`() throws {
        let source = """
        class Foo { };
        class Main {
            obj : Foo <- new Foo;
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects new with undefined type`() throws {
        let source = """
        class Main {
            obj : Object <- new Foo;
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'Foo'")
    }
    
    @Test func `validates new with builtin types`() throws {
        let source = """
        class Main {
            x : Int <- new Int;
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Complex Expression Tests
    @Test func `validates nested expressions`() throws {
        let source = """
        class Main {
            foo() : Int {
                ((1 + 2) * 3) - (4 / 2)
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates expression in block`() throws {
        let source = """
        class Main {
            foo() : Int {
                {
                    1 + 2;
                    3 * 4;
                    5 - 6;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates nested blocks`() throws {
        let source = """
        class Main {
            foo() : Int {
                {
                    {
                        1;
                    };
                    {
                        2;
                    };
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates mixed complex expressions`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                {
                    x <- 1 + 2;
                    if x < 5 then x * 2 else x / 2 fi;
                }
            };
        };
        """
        
        try analyze(source)
    }
}
