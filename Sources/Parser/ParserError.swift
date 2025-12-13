//
//  ParserError.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 22/11/2025.
//

import Foundation
import Diagnostics
import Lexer

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
        return "\(self)"
    }
}

public enum SyntaxSymbol {
    case arrow
    case colon
    case comma
    case leftBrace
    case leftParen
    case rightBrace
    case rightParen
    case semicolon
}
