//
//  ControlFlowTests.swift
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

@Suite struct ControlFlowTests {
// MARK: - Functions
    private func analyze(_ source: String) throws {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        let sourceFile = try parser.parse()
        let sema = Sema(diagnostics: diagEngine)
        try sema.analyze(sourceFile)
    }
    
// MARK: - If Expression Tests
    @Test func `validates if with matching branch types`() throws {
        let source = """
        class Main {
            foo() : Int {
                if true then 1 else 2 fi
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects non bool condition in if`() throws {
        let source = """
        class Main {
            foo() : Int {
                if 5 then 1 else 2 fi
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "Cannot convert value of type 'Int' to expected condition type 'Bool'")
    }
    
    @Test func `detects mismatched branch types in if`() throws {
        let source = """
        class Main {
            foo() : Int {
                if true then 1 else "hello" fi
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'Object' to specified type 'Int'")
    }
    
    @Test func `validates if with common ancestor types`() throws {
        let source = """
        class Animal { };
        class Dog inherits Animal { };
        class Cat inherits Animal { };
        
        class Main {
            foo() : Animal {
                if true then new Dog else new Cat fi
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - While Expression Tests
    @Test func `validates while with bool condition`() throws {
        let source = """
        class Main {
            foo() : Object {
                while true loop 42 pool
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects non bool condition in while`() throws {
        let source = """
        class Main {
            foo() : Int {
                while 5 loop 42 pool
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "Cannot convert value of type 'Int' to expected condition type 'Bool'")
    }
    
    @Test func `while returns Object type`() throws {
        let source = """
        class Main {
            foo() : Object {
                while true loop 42 pool
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Block Expression Tests
    @Test func `validates block with single expression`() throws {
        let source = """
        class Main {
            foo() : Int {
                { 42; }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates block with multiple expressions`() throws {
        let source = """
        class Main {
            foo() : Int {
                {
                    1;
                    2;
                    3;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `block returns type of last expression`() throws {
        let source = """
        class Main {
            foo() : String {
                {
                    42;
                    true;
                    "hello";
                }
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Let Expression Tests
    @Test func `validates let binding`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 5 in x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates let with type mismatch in initializer`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- "hello" in x
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Int'")
    }
    
    @Test func `validates let binding shadows outer variable`() throws {
        let source = """
        class Main {
            x : String;
            foo() : Int {
                let x : Int <- 5 in x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `let binding not visible outside body`() throws {
        let source = """
        class Main {
            foo() : Int {
                {
                    let x : Int <- 5 in x;
                    x;
                }
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot find 'x' in scope")
    }
    
    @Test func `detects undefined variable use in let expr`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1,
                    y : Int <- "hello" in
                z
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Int'")
    }
    
    @Test func `validates nested let exprs`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1 in
                    let y : Int <- 2 in x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates invalid nested let binding type`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1 in
                    let y : String <- "" in y
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Int'")
    }
    
    @Test func `detects duplicate let binding names`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1,
                    x : Int <- 2 in
                x
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "invalid redeclaration of 'x'")
    }
    
    @Test func `validates multiple let bindings`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1,
                    y : Int <- 2,
                    z : Int <- 3 in
                x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates multiple let bindings with different types`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1,
                    y : String <- "hello",
                    z : Bool <- true in
                x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates later bindings reference earlier ones`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1,
                    y : Int <- x in
                y
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects type mismatch in multiple bindings`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1,
                    y : Int <- "hello" in
                y
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'String' to specified type 'Int'")
    }
    
    @Test func `validates shadowing in multiple bindings`() throws {
        let source = """
        class Main {
            x : String;
            foo() : Int {
                let x : Int <- 1,
                    y : Int <- x in
                y
            };
        };
        """
        
        try analyze(source)
    }

// MARK: - Case Expression Tests
    @Test func `validates case with single branch`() throws {
        let source = """
        class Main {
            foo(x : Int) : Int {
                case x of
                    y : Int => y;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates case with multiple branches`() throws {
        let source = """
        class Animal { };
        class Dog inherits Animal { };
        class Cat inherits Animal { };
        
        class Main {
            foo(a : Animal) : Int {
                case a of
                    d : Dog => 1;
                    c : Cat => 2;
                    x : Animal => 3;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `case result type is join of branches`() throws {
        let source = """
        class Animal { };
        class Dog inherits Animal { };
        
        class Main {
            foo(x : Animal) : Animal {
                case x of
                    d : Dog => new Dog;
                    a : Animal => new Animal;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates case branch variable shadows outer scope`() throws {
        let source = """
        class Main {
            x : String;
            foo(obj : Int) : Int {
                case obj of
                    x : Int => x;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates case branch with self variable`() throws {
        let source = """
        class Main {
            x : String;
            foo(obj : Object) : String {
                case obj of
                    x : Int => self.x;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects undefined type in case branch`() throws {
        let source = """
        class Main {
            foo(x : Int) : Int {
                case x of
                    y : UndefinedType => 5;
                esac
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "use of undeclared type 'UndefinedType'")
    }
    
// MARK: - Complex Control Flow Tests
    @Test func `validates nested if expressions`() throws {
        let source = """
        class Main {
            foo() : Int {
                if true then
                    if false then 1 else 2 fi
                else
                    3
                fi
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates if inside while`() throws {
        let source = """
        class Main {
            foo() : Object {
                while true loop
                    if false then 1 else 2 fi
                pool
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates let inside case`() throws {
        let source = """
        class Main {
            foo(x : Int) : Int {
                case x of
                    y : Int => let z : Int <- y in z;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates case binding variable used in body`() throws {
        let source = """
        class Main {
            foo(x : Int) : Int {
                case x of
                    y : Int => y;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates case binding with different types in branches`() throws {
        let source = """
        class Animal { };
        class Dog inherits Animal {
            bark() : String { "woof" };
        };
        
        class Main {
            foo(a : Animal) : String {
                case a of
                    d : Dog => d.bark();
                    x : Animal => "unknown";
                esac
            };
        };
        """
        
        try analyze(source)
    }
}
