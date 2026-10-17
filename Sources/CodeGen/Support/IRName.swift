//
//  IRName.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

enum IRName {
    static func type(_ name: String) -> String {
        return "%\(name)"
    }
    
    static func vtableType(_ name: String) -> String {
        return "%\(name).vtable"
    }
    
    static func vtable(_ layout: ClassLayout) -> String {
        return layout.isBuiltin
        ? "@\(layout.name)_vtable_instance"
        : "@vtable.\(layout.name)"
    }
    
    static func constructor(_ name: String) -> String {
        return "@new.\(name)"
    }
    
    static func attributes(_ name: String) -> String {
        return "@attributes.\(name)"
    }
    
    static func method(_ slot: MethodSlot) -> String {
        return slot.isBuiltin
        ? "@\(slot.owner)_\(slot.name)"
        : "@\(slot.owner).\(slot.name)"
    }
}
