//
//  BoxingIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Sema

struct BoxingIRGenerator {
    let function: IRFunction
    let strings: StringsRegistry
    
    func defaultValue(for type: ResolvedType) -> String {
        switch type {
            case .int:
                return boxInt("0")
            case .bool:
                return boxBool("false")
            case .string:
                return boxString("")
            default:
                return "null"
        }
    }
    
    func boxInt(_ value: String) -> String {
        return function.value("call ptr @Int_new(i32 \(value))")
    }
    
    func boxBool(_ value: String) -> String {
        return function.value("call ptr @Bool_new(i1 zeroext \(value))")
    }
    
    func boxString(_ value: String) -> String {
        return function.value("call ptr @String_new(ptr \(strings.global(for: value)))")
    }
    
    func unboxInt(_ object: String) -> String {
        let field = payload(of: object, type: .int)
        return function.value("load i32, ptr \(field)")
    }
    
    func unboxBool(_ object: String) -> String {
        let field = payload(of: object, type: .bool)
        let byte = function.value("load i8, ptr \(field)")
        return function.value("icmp ne i8 \(byte), 0")
    }
    
    private func payload(of object: String, type: ResolvedType) -> String {
        return function.value(
            "getelementptr inbounds \(IRName.type(type.name)), ptr \(object), i32 0, i32 1"
        )
    }
}
