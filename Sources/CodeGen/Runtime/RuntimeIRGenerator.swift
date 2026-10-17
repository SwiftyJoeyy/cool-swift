//
//  RuntimeIRGenerator.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Sema

/// Declares what the runtime and libc provide, and defines the helpers the
/// generated code calls into.
struct RuntimeIRGenerator {
    let declarations: [ResolvedInterfaceClassDecl]
    
    func generate() -> String {
        return [
            externalDeclarations(),
            builtinMethods(),
            errorHelper(),
            equalsHelper()
        ].joined(separator: "\n\n")
    }
    
    private func externalDeclarations() -> String {
        return buildIR {
            "declare ptr @malloc(i64)"
            "declare i32 @puts(ptr)"
            "declare i32 @strcmp(ptr, ptr)"
            "declare void @exit(i32) noreturn"
            "declare ptr @Int_new(i32)"
            "declare ptr @Bool_new(i1 zeroext)"
            "declare ptr @String_new(ptr)"
        }
    }
    
    private func builtinMethods() -> String {
        return buildIR {
            for decl in declarations {
                for method in decl.methods {
                    declaration(of: method, in: decl.name)
                }
            }
        }
    }
    
    private func declaration(of method: ResolvedInterfaceFuncDecl, in owner: String) -> String {
        let slot = MethodSlot(name: method.name, owner: owner, isBuiltin: true)
        let parameters = Array(repeating: "ptr", count: method.parameters.count + 1)
        return "declare ptr \(IRName.method(slot))(\(parameters.joined(separator: ", ")))"
    }
    
    /// Prints a message and exits, used for runtime errors.
    private func errorHelper() -> String {
        return buildIR {
            "define private void @cool.error(ptr %message) noreturn {"
            "entry:"
            Indented(2) {
                "call i32 @puts(ptr %message)"
                "call void @exit(i32 1)"
                "unreachable"
            }
            "}"
        }
    }
    
    /// Cool `=`: `Int`, `Bool` and `String` compare by value, everything else
    /// by identity.
    private func equalsHelper() -> String {
        return buildIR {
            "define private i1 @cool.equals(ptr %lhs, ptr %rhs) {"
            "entry:"
            Indented(2) {
                "%same = icmp eq ptr %lhs, %rhs"
                "br i1 %same, label %true, label %check.void"
            }
            "check.void:"
            Indented(2) {
                "%lhs.void = icmp eq ptr %lhs, null"
                "%rhs.void = icmp eq ptr %rhs, null"
                "%any.void = or i1 %lhs.void, %rhs.void"
                "br i1 %any.void, label %false, label %check.type"
            }
            "check.type:"
            Indented(2) {
                "%lhs.vtable = load ptr, ptr %lhs"
                "%rhs.vtable = load ptr, ptr %rhs"
                "%same.type = icmp eq ptr %lhs.vtable, %rhs.vtable"
                "br i1 %same.type, label %check.int, label %false"
            }
            valueComparison(of: .int, as: "i32", next: "check.bool")
            valueComparison(of: .bool, as: "i8", next: "check.string")
            "check.string:"
            Indented(2) {
                "%is.string = icmp eq ptr %lhs.vtable, @String_vtable_instance"
                "br i1 %is.string, label %string, label %false"
            }
            "string:"
            Indented(2) {
                "%lhs.chars.ptr = getelementptr inbounds %String, ptr %lhs, i32 0, i32 1"
                "%rhs.chars.ptr = getelementptr inbounds %String, ptr %rhs, i32 0, i32 1"
                "%lhs.chars = load ptr, ptr %lhs.chars.ptr"
                "%rhs.chars = load ptr, ptr %rhs.chars.ptr"
                "%order = call i32 @strcmp(ptr %lhs.chars, ptr %rhs.chars)"
                "%string.equal = icmp eq i32 %order, 0"
                "ret i1 %string.equal"
            }
            "true:"
            Indented(2) {
                "ret i1 true"
            }
            "false:"
            Indented(2) {
                "ret i1 false"
            }
            "}"
        }
    }
    
    private func valueComparison(of type: ResolvedType, as valueType: String, next: String) -> String {
        let name = type.name.lowercased()
        return buildIR {
            "check.\(name):"
            Indented(2) {
                "%is.\(name) = icmp eq ptr %lhs.vtable, @\(type.name)_vtable_instance"
                "br i1 %is.\(name), label %\(name), label %\(next)"
            }
            "\(name):"
            Indented(2) {
                "%lhs.\(name).ptr = getelementptr inbounds %\(type.name), ptr %lhs, i32 0, i32 1"
                "%rhs.\(name).ptr = getelementptr inbounds %\(type.name), ptr %rhs, i32 0, i32 1"
                "%lhs.\(name) = load \(valueType), ptr %lhs.\(name).ptr"
                "%rhs.\(name) = load \(valueType), ptr %rhs.\(name).ptr"
                "%\(name).equal = icmp eq \(valueType) %lhs.\(name), %rhs.\(name)"
                "ret i1 %\(name).equal"
            }
        }
    }
}
