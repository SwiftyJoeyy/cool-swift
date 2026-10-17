//
//  IRFunction.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

final class IRFunction {
    private let signature: String
    private var allocas = [String]()
    private var instructions = [String]()
    private var counter = 0
    private(set) var block = "entry"
    
    init(_ signature: String) {
        self.signature = signature
    }
    
    func generate() -> String {
        return buildIR {
            "\(signature) {"
            "entry:"
            allocas
            instructions
            "}"
        }
    }
    
    func emit(_ instruction: String) {
        instructions.append("  " + instruction)
    }
    
    func value(_ instruction: String) -> String {
        counter += 1
        let register = "%t\(counter)"
        emit("\(register) = \(instruction)")
        return register
    }
    
    func alloca() -> String {
        let register = "%local\(allocas.count)"
        allocas.append("  \(register) = alloca ptr")
        return register
    }
    
    func label(_ name: String) -> String {
        counter += 1
        return "\(name).\(counter)"
    }
    
    func startBlock(_ label: String) {
        instructions.append("\(label):")
        block = label
    }
}
