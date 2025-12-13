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

internal struct CoolParser {
    private let diagnostics: DiagnosticsEngine
    
    internal private(set) var currentToken: Token
    private var lexer: CoolLexer
    
    internal init(lexer: CoolLexer, diagnostics: some DiagnosticsEngine) throws {
        self.lexer = lexer
        self.currentToken = try self.lexer.next()
        self.diagnostics = diagnostics
    }
    
    internal mutating func parse() throws -> SourceFile {
        var declarations = [ClassDecl]()
        
        while !lexer.reachedEnd {
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
            location: SourceLocation(line: 1, column: 1, file: lexer.file)
        )
    }
}

extension CoolParser {
    @discardableResult
    internal mutating func advance() throws(Diagnostic) -> Token {
        currentToken = try lexer.next()
        return currentToken
    }
    
    @discardableResult
    internal func advanced() throws(Diagnostic) -> Token {
        var parser = self
        return try parser.advance()
    }
    
    @discardableResult internal mutating func advance(
        if predicate: (borrowing Token) -> Bool
    ) throws(Diagnostic) -> Token? {
        var parser = self
        let next = try parser.advance()
        if predicate(next) {
            self = parser
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
