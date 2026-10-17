//
//  FuncIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Sema

struct FuncIRGenerator {
    let decl: ResolvedFuncDecl
    let layout: ClassLayout
    let context: IRContext
    
    func generate() -> String {
        let slot = MethodSlot(name: decl.name, owner: layout.name, isBuiltin: false)
        let parameters = ["ptr %self"] + decl.parameters.map {
            "ptr \(argument($0))"
        }
        let function = IRFunction(
            "define ptr \(IRName.method(slot))(\(parameters.joined(separator: ", ")))"
        )
        
        var locals = [String: String]()
        for parameter in decl.parameters {
            let local = function.alloca()
            function.emit("store ptr \(argument(parameter)), ptr \(local)")
            locals[parameter.name] = local
        }
        
        var exprGenerator = ExprIRGenerator(
            function: function,
            context: context,
            selfType: layout.name,
            locals: locals
        )
        let result = exprGenerator.generate(decl.body)
        function.emit("ret ptr \(result)")
        return function.generate()
    }
    
    private func argument(_ parameter: ResolvedParameterDecl) -> String {
        return "%arg.\(parameter.name)"
    }
}
