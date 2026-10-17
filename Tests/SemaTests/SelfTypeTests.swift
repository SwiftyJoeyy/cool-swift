//
//  SelfTypeTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/01/2026.
//

import Testing
import Foundation
import Diagnostics

@Suite struct SelfTypeTests {
// MARK: - self Reference Tests
    @Test func `validates self in method`() throws {
        let source = """
        class Point {
            x : Int;
            getX() : Int {
                self.x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates calling method on self`() throws {
        let source = """
        class Main {
            foo() : Int { 42 };
            bar() : Int {
                self.foo()
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - SELF_TYPE Return Tests
    @Test func `validates SELF_TYPE return in method`() throws {
        let source = """
        class Point {
            copy() : SELF_TYPE {
                new SELF_TYPE
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates SELF_TYPE allows returning current class`() throws {
        let source = """
        class Point {
            x : Int;
            setX(newX : Int) : Point {
                {
                    x <- newX;
                    new SELF_TYPE;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates SELF_TYPE in inheritance`() throws {
        let source = """
        class Base {
            copy() : SELF_TYPE {
                new SELF_TYPE
            };
        };
        class Derived inherits Base {
            test() : SELF_TYPE {
                copy()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects returning the class where SELF_TYPE is expected`() throws {
        let source = """
        class A {
            make() : SELF_TYPE {
                new A
            };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot convert value of type 'A' to specified type 'SELF_TYPE'")
    }
    
    @Test func `validates returning self where SELF_TYPE is expected`() throws {
        let source = """
        class A {
            me() : SELF_TYPE {
                self
            };
            again() : SELF_TYPE {
                me()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates SELF_TYPE conforms to its class`() throws {
        let source = """
        class A {
            me() : A {
                let x : SELF_TYPE <- self in x
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `resolves SELF_TYPE return to the receiver type`() throws {
        let source = """
        class A {
            me() : SELF_TYPE { self };
        };
        class B inherits A {
            onlyB() : Int { 1 };
            test() : Int { (new B).me().onlyB() };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - SELF_TYPE Variable Tests
    @Test func `validates SELF_TYPE as variable type`() throws {
        let source = """
        class Point {
            foo() : Int {
                let x : SELF_TYPE <- new SELF_TYPE in 42
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - new SELF_TYPE Tests
    @Test func `validates new SELF_TYPE in method`() throws {
        let source = """
        class Point {
            clone() : Point {
                new SELF_TYPE
            };
        };
        """
        
        try analyze(source)
    }

    @Test func `validates new SELF_TYPE returns proper type`() throws {
        let source = """
        class Builder {
            obj : SELF_TYPE;
            build() : SELF_TYPE {
                {
                    obj <- new SELF_TYPE;
                    obj;
                }
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `inherited SELF_TYPE attribute takes the subclass type`() throws {
        let source = """
        class A {
            obj : SELF_TYPE;
        };
        class B inherits A {
            onlyB() : Int { 1 };
            test() : Int { { obj <- new SELF_TYPE; obj.onlyB(); } };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `detects assigning the class to a SELF_TYPE attribute`() throws {
        let source = """
        class A {
            obj : SELF_TYPE;
            reset() : A { obj <- new A };
        };
        """
        
        let error = #expect(throws: Diagnostic.self) {
            try analyze(source)
        }
        #expect(error?.message == "cannot assign value of type 'A' to type 'SELF_TYPE'")
    }
    
// MARK: - Method Chaining with SELF_TYPE Tests
    @Test func `validates method chaining with SELF_TYPE`() throws {
        let source = """
        class Builder {
            setX(x : Int) : SELF_TYPE {
                new SELF_TYPE
            };
            setY(y : Int) : SELF_TYPE {
                new SELF_TYPE
            };
            test() : SELF_TYPE {
                setX(1).setY(2)
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - Complex SELF_TYPE Tests
    @Test func `validates SELF_TYPE preserves through inheritance`() throws {
        let source = """
        class Base {
            identity() : SELF_TYPE {
                new SELF_TYPE
            };
        };
        class Derived inherits Base {
            extra : Int;
            test() : SELF_TYPE {
                identity()
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates SELF_TYPE in case expression`() throws {
        let source = """
        class Point {
            foo(x : SELF_TYPE) : Int {
                case x of
                    p : SELF_TYPE => 1;
                esac
            };
        };
        """
        
        try analyze(source)
    }
    
// MARK: - SELF_TYPE Parameter Tests
    @Test func `validates SELF_TYPE as parameter type`() throws {
        let source = """
        class Point {
            compare(other : SELF_TYPE) : Point {
                other
            };
        };
        """
        
        try analyze(source)
    }
    
    @Test func `validates calling method with SELF_TYPE parameter`() throws {
        let source = """
        class Point {
            compare(other : SELF_TYPE) : Bool {
                true
            };
            test() : Bool {
                compare(new SELF_TYPE)
            };
        };
        """
        
        try analyze(source)
    }
}
