//
//  SemaError.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 20/12/2025.
//

import Foundation
import AST
import Diagnostics

public enum SemaError {
    case duplicateClass(String)
    case undefinedParentClass(String)
    case cyclicInheritance(String)
    case selfInheritance(String)
    case duplicateDeclaration(String)
    case cannotOverrideProperty(String)
    case funcOverrideMismatch([FuncOverrideDiff])
    case propertyCannotOverrideFunc(String)
    case undefinedType(String)
    case undefinedIdentifier(String)
    case funcUsedAsValue(String)
    case initializerTypeMismatch(expected: String, got: String)
    case assignmentTypeMismatch(expected: String, got: String)
    case undefinedMember(member: String, baseType: String)
    case instanceMemberInPropertyInitializer(String)
    case invalidStaticDispatch(type: String, parent: String)
    case cannotCallNonFunction(String)
    case argumentCountMismatch(expected: Int, got: Int)
    case argumentTypeMismatch(expected: String, got: String)
    case binaryOperatorTypeMismatch(op: String, lhs: String, rhs: String)
    case conditionTypeMismatch(String)
    case typeMismatch(expected: String, got: String)
    case cannotAssignToFunc(String)
    case invalidAssignment(String)
    case unaryOperatorInvalidType(op: String, expected: String)
    case binaryOperatorInvalidType(op: String, expected: String)
    case missingMainClass
    case missingMainMethod
    case mainMethodCannotHaveParameters
}

public enum FuncOverrideDiff {
    case returnTypeMismatch(expected: String, got: any TypeRef)
    case paramNameMismatch(expected: String, got: Identifier)
    case paramTypeMismatch(expected: String, got: any TypeRef)
    case extraParam(ParameterDecl)
    case missingParam(ParameterDecl)
    case wrongIndex(param: ParameterDecl, expected: Int, got: Int)
}

extension SemaError: DiagnosticConvertible {
    public var id: String {
        return "SemaError-\(self)"
    }
    
    public var severity: DiagnosticSeverity {
        return .error
    }
    
    public var message: String {
        switch self {
            case .duplicateClass(let name):
                return "duplicate class '\(name)'"
            case .undefinedParentClass(let name):
                return "parent class '\(name)' is not defined"
            case .cyclicInheritance(let name):
                return "class '\(name)' has cyclic inheritance"
            case .selfInheritance(let name):
                return "class '\(name)' inherits from itself"
            case .duplicateDeclaration(let name):
                return "invalid redeclaration of '\(name)'"
            case .cannotOverrideProperty(let name):
                return "overriding a property is not allowed: '\(name)'"
            case .funcOverrideMismatch:
                return "func override mismatch"
            case .propertyCannotOverrideFunc(let name):
                return "Property '\(name)' cannot override func '\(name)'"
            case .undefinedType(let name):
                return "use of undeclared type '\(name)'"
            case .undefinedIdentifier(let name):
                return "cannot find '\(name)' in scope"
            case .funcUsedAsValue(let name):
                return "cannot use method '\(name)' without calling it"
            case .initializerTypeMismatch(let expected, let got):
                return "cannot convert value of type '\(got)' to specified type '\(expected)'"
            case .assignmentTypeMismatch(let expected, let got):
                return "cannot assign value of type '\(got)' to type '\(expected)'"
            case .undefinedMember(let member, let baseType):
                return "value of type '\(baseType)' has no member '\(member)'"
            case .instanceMemberInPropertyInitializer(let name):
                return "cannot use instance member '\(name)' within property initializer; property initializers run before 'self' is available"
            case .invalidStaticDispatch(let type, let parent):
                return "type '\(type)' does not inherit from '\(parent)'"
            case .cannotCallNonFunction(let name):
                return "cannot call non-function '\(name)'"
            case .argumentCountMismatch(let expected, let got):
                if got < expected {
                    return "missing argument for parameter in call"
                } else {
                    return "extra argument in call"
                }
            case .argumentTypeMismatch(let expected, let got):
                return "cannot convert value of type '\(got)' to expected argument type '\(expected)'"
            case .binaryOperatorTypeMismatch(let op, let lhs, let rhs):
                return "binary operator '\(op)' cannot be applied to operands of type '\(lhs)' and '\(rhs)'"
            case .conditionTypeMismatch(let type):
                return "Cannot convert value of type '\(type)' to expected condition type 'Bool'"
            case .typeMismatch(let expected, let got):
                return "cannot convert value of type '\(got)' to expected type '\(expected)'"
            case .cannotAssignToFunc(let name):
                return "cannot assign to method '\(name)'"
            case .invalidAssignment(let expr):
                return "cannot assign to '\(expr)'"
            case .unaryOperatorInvalidType(let op, let expected):
                return "'\(op)' can only be applied to an operand of type '\(expected)'"
            case .binaryOperatorInvalidType(let op, let expected):
                return "binary operator '\(op)' can only be applied to operands of type '\(expected)'"
            case .missingMainClass:
                return "program must contain a 'Main' class"
            case .missingMainMethod:
                return "'Main' class must contain a 'main()' method"
            case .mainMethodCannotHaveParameters:
                return "'main()' method cannot have parameters"
        }
    }
}
