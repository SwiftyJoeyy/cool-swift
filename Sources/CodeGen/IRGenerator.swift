//
//  IRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

public import Sema
import Foundation

/// Generates an LLVM IR module from a type-checked program.
///
/// See ``RuntimeABI`` for the object layout and what the runtime must provide.
public struct IRGenerator {
    private let source: ResolvedSource
    private let context: IRContext
    
    /// - Parameter source: The program returned by `Sema.analyze(_:)`.
    public init(source: ResolvedSource) {
        self.source = source
        self.context = IRContext(
            classes: ClassTable(source: source),
            strings: StringsRegistry()
        )
    }
    
    public func generate() -> String {
        let classes = context.classes.all
        
        let definitions = classes.map {
            ClassDefinitionIRGenerator(layout: $0).generate()
        }
        let vtables = classes.map {
            VTableIRGenerator(layout: $0, context: context).generate()
        }
        var functions = classes.flatMap(functions(for:))
        if let entryPoint = EntryPointIRGenerator(context: context).generate() {
            functions.append(entryPoint)
        }
        
        // Generated last, once every function and vtable has added its strings.
        let strings = context.strings.generate()
        
        let sections = [
            definitions.joined(separator: "\n"),
            RuntimeIRGenerator(declarations: source.interfaceDeclarations).generate(),
            vtables.joined(separator: "\n"),
            strings
        ] + functions
        return sections.joined(separator: "\n\n") + "\n"
    }
    
    private func functions(for layout: ClassLayout) -> [String] {
        var functions = [ConstructorIRGenerator(layout: layout, context: context).generate()]
        guard let decl = layout.decl else {
            return functions
        }
        functions.append(
            AttributesIRGenerator(decl: decl, layout: layout, context: context).generate()
        )
        functions += decl.methods.map {
            FuncIRGenerator(decl: $0, layout: layout, context: context).generate()
        }
        return functions
    }
}
