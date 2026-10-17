//
//  VTableIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

struct VTableIRGenerator {
    let layout: ClassLayout
    let context: IRContext
    
    func generate() -> String {
        let parent = layout.parent.map {
            IRName.vtable(context.classes[$0])
        } ?? "null"
        let typeName = context.strings.global(for: layout.name)
        
        let header = [
            "ptr \(parent)",
            "ptr \(typeName)",
            "i64 \(layout.size)",
            "ptr \(IRName.constructor(layout.name))"
        ]
        let methods = layout.methods.map {
            "ptr \(IRName.method($0))"
        }
        
        return buildIR {
            "\(IRName.vtable(layout)) = constant \(IRName.vtableType(layout.name)) {"
            Indented(2) {
                CommaSeparated {
                    header + methods
                }
            }
            "}"
        }
    }
}
