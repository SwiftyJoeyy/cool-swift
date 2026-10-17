//
//  EntryPointTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 17/10/2026.
//

import Testing
import Foundation
import Basic
import Diagnostics
import TestSupport
@testable import Sema

@Suite struct EntryPointTests {
// MARK: - Functions
    private func checkEntryPoint(_ source: String) throws {
        let sema = Sema(diagnostics: MockDiagEngine(), interfaceSymbols: .test)
        try sema.checkEntryPoint(resolve(source))
    }
    
    private func entryPointError(_ source: String) -> Diagnostic? {
        return #expect(throws: Diagnostic.self) {
            try checkEntryPoint(source)
        }
    }
    
// MARK: - Tests
    @Test func `accepts Main with main`() throws {
        try checkEntryPoint("""
        class Main { main() : Object { 0 }; };
        """)
    }
    
    @Test func `accepts main inherited from a parent`() throws {
        try checkEntryPoint("""
        class Base { main() : Object { 0 }; };
        class Main inherits Base { };
        """)
    }
    
    @Test func `detects missing Main class`() throws {
        let error = entryPointError("class A { main() : Object { 0 }; };")
        
        #expect(error?.message == "program must contain a 'Main' class")
    }
    
    @Test func `detects Main without main`() throws {
        let error = entryPointError("""
        class Main { run() : Object { 0 }; };
        """)
        
        #expect(error?.message == "'Main' class must contain a 'main()' method")
        #expect(error?.location?.line == 1)
    }
    
    @Test func `detects main with parameters`() throws {
        let error = entryPointError("""
        class Main {
            main(x : Int) : Object { x };
        };
        """)
        
        #expect(error?.message == "'main()' method cannot have parameters")
        #expect(error?.location?.line == 2)
    }
    
    @Test func `detects inherited main with parameters`() throws {
        let error = entryPointError("""
        class Base { main(x : Int) : Object { x }; };
        class Main inherits Base { };
        """)
        
        #expect(error?.message == "'main()' method cannot have parameters")
    }
}
