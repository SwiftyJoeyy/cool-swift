//
//  ParserError.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 22/11/2025.
//

import Foundation
public import Diagnostics
public import Lexer

public enum ParserError {
// MARK: - ClassDecl
    case unexpectedTopLevelDeclaration
    case expectedClassName
    case unexpectedDeclaration
    
// MARK: - VarDecl
    case expectedVarName
    case expectedTypeAnnotation
    
// MARK: - FuncDecl
    case expectedFuncName
    case expectedParamName
    
// MARK: - Expr
    case unexpectedExpression
    case expectedMemberName
    case expectedType
    case expectedSymbol(SyntaxSymbol)
    case expectedKeyword(Keyword)
}

extension ParserError: DiagnosticConvertible {
    public var id: String {
        return "ParserError-\(self)"
    }
    
    public var severity: DiagnosticSeverity {
        return .error
    }
    
    public var message: String {
        switch self {
        case .unexpectedTopLevelDeclaration:
            return "Unexpected top-level declaration"
        case .expectedClassName:
            return "Expected class name"
        case .unexpectedDeclaration:
            return "Unexpected declaration"
        case .expectedVarName:
            return "Expected variable name"
        case .expectedTypeAnnotation:
            return "Expected type annotation"
        case .expectedFuncName:
            return "Expected function name"
        case .expectedParamName:
            return "Expected parameter name"
        case .unexpectedExpression:
            return "Unexpected expression"
        case .expectedMemberName:
            return "Expected member name"
        case .expectedType:
            return "Expected type"
        case .expectedSymbol(let symbol):
                return "Expected '\(symbol.rawValue)'"
        case .expectedKeyword(let keyword):
            return "Expected '\(keyword.rawValue)' keyword"
        }
    }
}

public enum SyntaxSymbol: String {
    case arrow = "=>"
    case colon = "."
    case comma = ","
    case leftBrace = "{"
    case leftParen = "("
    case rightBrace = "}"
    case rightParen = ")"
    case semicolon = ";"
}
