//
//  AssignmentTests.swift
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

@Suite struct AssignmentTests {
// MARK: - Functions
    private func analyze(_ source: String) throws {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        let sourceFile = try parser.parse()
        let sema = Sema(diagnostics: diagEngine, interfaceSymbols: .test)
        try sema.analyze(sourceFile)
    }
    
// MARK: - Basic Assignment Tests
    @Test func `validates assignment to parameter`() throws {
        let source = """
        class Main {
            foo(x : Int) : Int {
                x <- 5
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates assignment to let binding`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1 in
                {
                    x <- 2;
                    x;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates assignment returns assigned value`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                x <- 42
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Type Mismatch Tests
    @Test func `detects assignment type mismatch Int to String`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                x <- "hello"
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot assign value of type 'String' to type 'Int'")
    }
    
    @Test func `detects assignment type mismatch String to Bool`() throws {
        let source = """
        class Main {
            flag : Bool;
            foo() : Bool {
                flag <- "test"
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot assign value of type 'String' to type 'Bool'")
    }
    
// MARK: - Undefined Variable Tests
    @Test func `detects assignment to undefined variable`() throws {
        let source = """
        class Main {
            foo() : Int {
                undefined <- 5
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot find 'undefined' in scope")
    }
    
    @Test func `detects assignment to function`() throws {
        let source = """
        class Main {
            getValue() : Int { 42 };
            foo() : Int {
                getValue <- 5
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot assign to method 'getValue'")
    }
    
    // MARK: - Inheritance Tests
    @Test func `validates assignment of subtype to supertype variable`() throws {
        let source = """
        class Animal { };
        class Dog inherits Animal { };
        class Main {
            a : Animal;
            foo() : Animal {
                a <- new Dog
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Chained Assignment Tests
    @Test func `validates chained assignments`() throws {
        let source = """
        class Main {
            x : Int;
            y : Int;
            foo() : Int {
                x <- y <- 5
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Assignment in Complex Expressions Tests
    @Test func `validates assignment in if branch`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                if true then {
                    x <- 5;
                } else {
                    x <- 10;
                } fi
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates assignment in while loop`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                {
                    while true loop {
                        x <- 5;
                    } pool;
                    x;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates assignment in block`() throws {
        let source = """
        class Main {
            x : Int;
            foo() : Int {
                {
                    x <- 1;
                    x <- 2;
                    x <- 3;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Assignment Shadowing Tests
    @Test func `validates assignment to shadowed variable`() throws {
        let source = """
        class Main {
            x : String;
            foo(x : Int) : Int {
                x <- 42
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates assignment to self variable`() throws {
        let source = """
        class Main {
            x : String;
            foo(x : Int) : String {
                self.x <- "hello"
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates assignment in nested scopes`() throws {
        let source = """
        class Main {
            foo() : Int {
                let x : Int <- 1 in
                {
                    let y : Int <- 2 in
                    {
                        x <- y;
                        x;
                    };
                    x;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Complex Assignment Tests
    @Test func `validates assignment with expression on right side`() throws {
        let source = """
        class Main {
            x : Int;
            getValue() : Int { 42 };
            foo() : Int {
                x <- getValue()
            };
        };
        """
        
        try analyze(source)
    }
}
