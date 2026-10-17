//
//  ConstructorIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

struct ConstructorIRGenerator {
    let layout: ClassLayout
    let context: IRContext
    
    func generate() -> String {
        let function = IRFunction("define ptr \(IRName.constructor(layout.name))()")
        let boxing = BoxingIRGenerator(function: function, strings: context.strings)
        
        if let boxed = RuntimeABI.boxedType(named: layout.name) {
            function.emit("ret ptr \(boxing.defaultValue(for: boxed.type))")
            return function.generate()
        }
        
        let object = function.value("call ptr @malloc(i64 \(layout.size))")
        function.emit("store ptr \(IRName.vtable(layout)), ptr \(object)")
        
        for (index, field) in layout.fields.enumerated() {
            let value = boxing.defaultValue(for: field.type)
            let address = function.fieldAddress(of: object, in: layout, index: index)
            function.emit("store ptr \(value), ptr \(address)")
        }
        
        if layout.decl != nil {
            function.emit("call void \(IRName.attributes(layout.name))(ptr \(object))")
        }
        function.emit("ret ptr \(object)")
        return function.generate()
    }
}
