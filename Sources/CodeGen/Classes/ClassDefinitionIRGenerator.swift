//
//  ClassDefinitionIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

struct ClassDefinitionIRGenerator {
    let layout: ClassLayout
    
    func generate() -> String {
        let fields = ["ptr"] + layout.fields.map { _ in "ptr" }
        let body = RuntimeABI.boxedType(named: layout.name)?.body
        ?? "{ \(fields.joined(separator: ", ")) }"
        
        let header = ["ptr", "ptr", "i64", "ptr"]
        let slots = header + layout.methods.map { _ in "ptr" }
        
        return buildIR {
            "\(IRName.type(layout.name)) = type \(body)"
            "\(IRName.vtableType(layout.name)) = type { \(slots.joined(separator: ", ")) }"
        }
    }
}
