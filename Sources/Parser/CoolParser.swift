//
//  CoolParser.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 22/11/2025.
//

import Foundation
import AST
import Basic
import Diagnostics
import Lexer

public struct CoolParser {
    private let diagnostics: DiagnosticsEngine
    
    internal private(set) var currentToken: Token
    private var lexemes: Lexemes
    
    public init(lexemes: Lexemes, diagnostics: some DiagnosticsEngine) throws(Diagnostic) {
        self.lexemes = lexemes
        self.currentToken = try self.lexemes.consume()
        self.diagnostics = diagnostics
    }
    
    public mutating func parse() throws(Diagnostic) -> SourceFile {
        var declarations = [ClassDecl]()
        
        while !lexemes.reachedEnd {
            do throws(Diagnostic) {
                guard currentToken.kind == .keyword(.class) else {
                    throw ParserError.unexpectedTopLevelDeclaration
                        .diagnostic(at: currentToken.location)
                }
                declarations.append(try ClassDeclParser.parse(from: &self))
                try advance()
            } catch {
                diagnostics.insert(error)
                try advance(until: {$0.kind == .keyword(.class)})
            }
        }
        
        return SourceFile(
            declarations: declarations,
            location: SourceLocation(line: 1, column: 1, file: lexemes.file)
        )
    }
}

extension CoolParser {
    @discardableResult
    internal mutating func advance() throws(Diagnostic) -> Token {
        currentToken = try lexemes.consume()
        return currentToken
    }
    
    @discardableResult
    internal mutating func advanced() throws(Diagnostic) -> Token {
        return try lexemes.peek()
    }
    
    @discardableResult internal mutating func advance(
        if predicate: (borrowing Token) -> Bool
    ) throws(Diagnostic) -> Token? {
        let next = try lexemes.peek()
        if predicate(next) {
            try lexemes.consume()
            currentToken = next
            return next
        }
        return nil
    }
    
    internal mutating func advance(
        until predicate: (borrowing Token) -> Bool
    ) throws(Diagnostic) {
        while !predicate(currentToken), currentToken.kind != .endOfFile {
            try advance()
        }
    }
}

extension CoolParser {
    @inline(__always) internal func at(
        _ predicate: (borrowing Token) -> Bool
    ) -> Bool {
        return predicate(currentToken)
    }
    
    @inline(__always) internal func at(
        _ kind: TokenKind
    ) -> Bool {
        return at({$0.kind == kind})
    }
}

extension CoolParser {
    internal func diagnose(_ diagnostic: Diagnostic) {
        diagnostics.insert(diagnostic)
    }
}
