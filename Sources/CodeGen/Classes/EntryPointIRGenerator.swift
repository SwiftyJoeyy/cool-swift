//
//  EntryPointIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

struct EntryPointIRGenerator {
    let context: IRContext
    
    func generate() -> String? {
        let name = "Main"
        guard context.classes.contains(name) else {
            return nil
        }
        let layout = context.classes[name]
        guard layout.methods.contains(where: {$0.name == "main"}) else {
            return nil
        }
        
        let function = IRFunction("define i32 @main()")
        let object = function.value("call ptr \(IRName.constructor(name))()")
        _ = function.virtualCall("main", on: object, in: layout, arguments: [])
        function.emit("ret i32 0")
        return function.generate()
    }
}
