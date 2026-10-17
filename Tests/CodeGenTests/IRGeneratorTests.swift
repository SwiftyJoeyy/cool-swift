//
//  IRGeneratorTests.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import AST
import CodeGen
import CoreModule
import Foundation
import Parser
import Sema
import TestSupport
import Testing

@Suite struct IRGeneratorTests {
// MARK: - Functions
    private func generate(_ source: String) throws -> String {
        let interface = try CoreModule.interface(using: MockDiagEngine())
        let symbols = ModuleInterfaceSymbols()
        try symbols.load(interface)

        var (parser, diagEngine) = try CoolParser.new(source: source)
        let sema = Sema(diagnostics: diagEngine, interfaceSymbols: symbols)
        let resolved = try sema.analyze(parser.parse())
        return IRGenerator(source: resolved).generate()
    }

    /// The vtable initializer entries of `name`, after the header.
    private func methodSlots(of name: String, in ir: String) throws -> [String] {
        let start = try #require(ir.range(of: "\(name) = constant"))
        let end = try #require(ir.range(of: "}", range: start.upperBound..<ir.endIndex))
        let entries = ir[start.upperBound..<end.lowerBound]
            .split(separator: "\n")
            .dropFirst()
            .map { $0.trimmingCharacters(in: .whitespaces.union(.init(charactersIn: ","))) }
        return Array(entries.dropFirst(4))
    }

// MARK: - Layout Tests
    @Test func `lays out inherited attributes first`() throws {
        let ir = try generate("""
        class A { x : Int; };
        class B inherits A { y : String; z : A; };
        """)

        #expect(ir.contains("%A = type { ptr, ptr }"))
        #expect(ir.contains("%B = type { ptr, ptr, ptr, ptr }"))
    }

    @Test func `emits builtin payload layouts`() throws {
        let ir = try generate("class A { };")

        #expect(ir.contains("%Int = type { ptr, i32 }"))
        #expect(ir.contains("%Bool = type { ptr, i8 }"))
        #expect(ir.contains("%String = type { ptr, ptr }"))
    }

    @Test func `override replaces the parent's vtable slot`() throws {
        let ir = try generate("""
        class A { foo() : Int { 0 }; bar() : Int { 1 }; };
        class B inherits A { foo() : Int { 2 }; baz() : Int { 3 }; };
        """)

        let objectSlots = ["ptr @Object_abort", "ptr @Object_type_name", "ptr @Object_copy"]
        #expect(try methodSlots(of: "@vtable.A", in: ir) == objectSlots + ["ptr @A.foo", "ptr @A.bar"])
        #expect(try methodSlots(of: "@vtable.B", in: ir) == objectSlots + ["ptr @B.foo", "ptr @A.bar", "ptr @B.baz"])
    }

    @Test func `builtin vtables are visible to the runtime`() throws {
        let ir = try generate("class A { };")

        for name in ["Object", "IO", "Int", "String", "Bool"] {
            #expect(ir.contains("@\(name)_vtable_instance = constant %\(name).vtable"))
        }
    }

    @Test func `vtable header links to the parent`() throws {
        let ir = try generate("class A inherits IO { };")

        #expect(ir.contains("@vtable.A = constant %A.vtable {\n  ptr @IO_vtable_instance,"))
        #expect(ir.contains("ptr @new.A"))
    }

// MARK: - Function Tests
    @Test func `methods take self followed by their arguments`() throws {
        let ir = try generate("class A { add(x : Int, y : Int) : Int { x + y }; };")

        #expect(ir.contains("define ptr @A.add(ptr %self, ptr %arg.x, ptr %arg.y)"))
    }

    @Test func `constructor runs attribute initializers`() throws {
        let ir = try generate("""
        class A { x : Int <- 5; };
        class B inherits A { y : Int <- x; };
        """)

        #expect(ir.contains("call void @attributes.B(ptr"))
        #expect(ir.contains("define void @attributes.B(ptr %self) {\nentry:\n  call void @attributes.A(ptr %self)"))
    }

    @Test func `entry point calls Main.main through the vtable`() throws {
        let ir = try generate("""
        class Main inherits IO { main() : Object { out_string("hi") }; };
        """)

        #expect(ir.contains("define i32 @main()"))
        #expect(ir.contains("call ptr @new.Main()"))
    }

    @Test func `no entry point without Main`() throws {
        let ir = try generate("class A { };")

        #expect(!ir.contains("define i32 @main()"))
    }

// MARK: - Expression Tests
    @Test func `static dispatch calls the implementation directly`() throws {
        let ir = try generate("""
        class A { foo() : Int { 0 }; };
        class B inherits A { foo() : Int { 1 }; bar() : Int { self@A.foo() }; };
        """)

        #expect(ir.contains("call ptr @A.foo(ptr %self)"))
    }

    @Test func `new SELF_TYPE uses the dynamic constructor`() throws {
        let ir = try generate("class A { make() : SELF_TYPE { new SELF_TYPE }; };")

        #expect(ir.contains("getelementptr inbounds %A.vtable, ptr %t1, i32 0, i32 3"))
    }

    @Test func `string literals are interned`() throws {
        let ir = try generate("""
        class A { a() : String { "hi" }; b() : String { "hi" }; };
        """)

        let definitions = ir.components(separatedBy: "c\"hi\\00\"").count - 1
        #expect(definitions == 1)
    }

    @Test func `escapes non printable characters in strings`() throws {
        let ir = try generate(#"class A { a() : String { "a\n\"b" }; };"#)

        #expect(ir.contains(#"c"a\0A\22b\00""#))
    }
}
