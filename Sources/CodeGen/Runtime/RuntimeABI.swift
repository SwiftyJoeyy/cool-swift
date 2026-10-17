//
//  RuntimeABI.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Sema

/// The contract between generated code and the C runtime.
///
/// Every Cool value is a pointer to an object whose first field is its
/// vtable. A vtable starts with a fixed header followed by method slots:
///
///     struct VTable {
///         const struct VTable* parent;  // NULL for Object
///         const char* type_name;
///         int64_t size;                 // instance size in bytes
///         Object* (*new)(void);         // default constructor
///         void* methods[];              // Object's methods first
///     };
///
/// Methods take `self` followed by their arguments and return an object,
/// all as pointers. `Int`, `Bool` and `String` box an `int32_t`, a `bool`
/// and a `char*` after the vtable pointer.
///
/// The runtime provides:
/// - The built-in methods, named `<Class>_<method>` (e.g. `IO_out_string`).
/// - `Int_new(int32_t)`, `Bool_new(bool)` and `String_new(char*)` to box values.
///
/// Generated code provides every vtable. The built-in ones are named
/// `<Class>_vtable_instance` so the runtime can reference them.
enum RuntimeABI {
    enum VTableSlot {
        static let parent = 0
        static let typeName = 1
        static let size = 2
        static let constructor = 3
        static let firstMethod = 4
    }
    
    /// The built-in classes that box a raw value, with their struct bodies.
    static let boxedTypes: [ResolvedType: String] = [
        .int: "{ ptr, i32 }",
        .bool: "{ ptr, i8 }",
        .string: "{ ptr, ptr }"
    ]
    
    static func boxedType(named name: String) -> (type: ResolvedType, body: String)? {
        return boxedTypes.first(where: {$0.key.name == name}).map {
            ($0.key, $0.value)
        }
    }
}
