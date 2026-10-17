//
//  ClassLayout.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Sema

/// How instances of a class and its vtable are laid out in memory.
struct ClassLayout {
    let name: String
    let parent: String?
    let isBuiltin: Bool
    
    /// Inherited attributes first. Field `i` sits after the vtable pointer,
    /// at struct index `i + 1`.
    let fields: [Field]
    
    /// Inherited methods first. An override takes over its parent's slot.
    let methods: [MethodSlot]
    
    /// `nil` for built-in classes.
    let decl: ResolvedClassDecl?
    
    func fieldIndex(of name: String) -> Int {
        guard let index = fields.firstIndex(where: {$0.name == name}) else {
            fatalError("'\(self.name)' has no attribute '\(name)'")
        }
        return index
    }
    
    func slot(of name: String) -> (index: Int, method: MethodSlot) {
        guard let index = methods.firstIndex(where: {$0.name == name}) else {
            fatalError("'\(self.name)' has no method '\(name)'")
        }
        return (index, methods[index])
    }
}

struct Field {
    let name: String
    let type: ResolvedType
}

struct MethodSlot {
    let name: String
    
    /// The class whose implementation fills the slot.
    let owner: String
    
    /// Built-in methods are implemented by the runtime.
    let isBuiltin: Bool
}
