//
//  IRFunction+Objects.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

extension IRFunction {
    func fieldAddress(of object: String, in layout: ClassLayout, index: Int) -> String {
        return value(
            "getelementptr inbounds \(IRName.type(layout.name)), ptr \(object), i32 0, i32 \(index + 1)"
        )
    }
    
    func loadVTableEntry(of object: String, in layout: ClassLayout, slot: Int) -> String {
        let vtable = value("load ptr, ptr \(object)")
        let entry = value(
            "getelementptr inbounds \(IRName.vtableType(layout.name)), ptr \(vtable), i32 0, i32 \(slot)"
        )
        return value("load ptr, ptr \(entry)")
    }
    
    func virtualCall(
        _ method: String,
        on object: String,
        in layout: ClassLayout,
        arguments: [String]
    ) -> String {
        let slot = layout.slot(of: method).index + RuntimeABI.VTableSlot.firstMethod
        let function = loadVTableEntry(of: object, in: layout, slot: slot)
        return value("call ptr \(function)(\(argumentList(object, arguments)))")
    }
    
    func argumentList(_ object: String, _ arguments: [String]) -> String {
        return ([object] + arguments).map({"ptr \($0)"}).joined(separator: ", ")
    }
}

extension ClassLayout {
    var size: String {
        return "ptrtoint (ptr getelementptr (\(IRName.type(name)), ptr null, i32 1) to i64)"
    }
}
