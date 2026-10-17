//
//  AttributesIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Sema

struct AttributesIRGenerator {
    let decl: ResolvedClassDecl
    let layout: ClassLayout
    let context: IRContext
    
    func generate() -> String {
        let function = IRFunction("define void \(IRName.attributes(layout.name))(ptr %self)")
        var exprGenerator = ExprIRGenerator(
            function: function,
            context: context,
            selfType: layout.name
        )
        
        if let parent = layout.parent, context.classes[parent].decl != nil {
            function.emit("call void \(IRName.attributes(parent))(ptr %self)")
        }
        
        for property in decl.properties {
            guard let initializer = property.initializer else { continue }
            let value = exprGenerator.generate(initializer)
            let index = layout.fieldIndex(of: property.name)
            let address = function.fieldAddress(of: "%self", in: layout, index: index)
            function.emit("store ptr \(value), ptr \(address)")
        }
        
        function.emit("ret void")
        return function.generate()
    }
}
