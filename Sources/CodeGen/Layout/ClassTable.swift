//
//  ClassTable.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Sema

/// The layout of every class in the program, built-in classes included.
struct ClassTable {
    private var layouts = [String: ClassLayout]()
    
    /// Every parent comes before its children.
    private(set) var order = [String]()
    
    var all: [ClassLayout] {
        return order.map { self[$0] }
    }
    
    init(source: ResolvedSource) {
        var definitions = [String: Definition]()
        var names = [String]()
        for decl in source.interfaceDeclarations {
            definitions[decl.name] = .builtin(decl)
            names.append(decl.name)
        }
        for decl in source.declarations {
            definitions[decl.name] = .user(decl)
            names.append(decl.name)
        }
        for name in names {
            layout(of: name, definitions: definitions)
        }
    }
    
    subscript(name: String) -> ClassLayout {
        guard let layout = layouts[name] else {
            fatalError("Unknown class '\(name)', Sema should have rejected it")
        }
        return layout
    }
    
    func contains(_ name: String) -> Bool {
        return layouts[name] != nil
    }
    
    @discardableResult
    private mutating func layout(
        of name: String,
        definitions: [String: Definition]
    ) -> ClassLayout {
        if let layout = layouts[name] {
            return layout
        }
        guard let definition = definitions[name] else {
            fatalError("Unknown class '\(name)', Sema should have rejected it")
        }
        
        let parent = definition.parent.map {
            layout(of: $0, definitions: definitions)
        }
        var fields = parent?.fields ?? []
        var methods = parent?.methods ?? []
        
        func add(_ method: MethodSlot) {
            if let index = methods.firstIndex(where: {$0.name == method.name}) {
                methods[index] = method
            } else {
                methods.append(method)
            }
        }
        
        switch definition {
            case .builtin(let decl):
                for method in decl.methods {
                    add(MethodSlot(name: method.name, owner: name, isBuiltin: true))
                }
            case .user(let decl):
                fields += decl.properties.map {
                    Field(name: $0.name, type: $0.type)
                }
                for method in decl.methods {
                    add(MethodSlot(name: method.name, owner: name, isBuiltin: false))
                }
        }
        
        let layout = ClassLayout(
            name: name,
            parent: parent?.name,
            isBuiltin: definition.isBuiltin,
            fields: fields,
            methods: methods,
            decl: definition.decl
        )
        layouts[name] = layout
        order.append(name)
        return layout
    }
}

extension ClassTable {
    private enum Definition {
        case builtin(ResolvedInterfaceClassDecl)
        case user(ResolvedClassDecl)
        
        var parent: String? {
            switch self {
                case .builtin(let decl):
                    return decl.parent?.name
                case .user(let decl):
                    return decl.parent.name
            }
        }
        var isBuiltin: Bool {
            if case .builtin = self {
                return true
            }
            return false
        }
        var decl: ResolvedClassDecl? {
            if case .user(let decl) = self {
                return decl
            }
            return nil
        }
    }
}
