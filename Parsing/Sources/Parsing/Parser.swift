////
////  Parser.swift
////  Parsing
////
////  Created by Joe Maghzal on 13/11/2025.
////
//
//import Foundation
//import Lexing
//
//
//struct Parser {
//    var lexer: CoolLexer
//    
//    mutating func parse() throws {
//        while let token = try? lexer.next() {
//            if ClassDeclParser.matches(token) {
//                try ClassDeclParser.parse(at: token, using: &lexer)
//            }
//        }
//    }
//}
//
//protocol ASTParser {
//    static func matches(_ token: Token) -> Bool
//    associatedtype Node: ASTNode
//    static func parse(at token: Token, using lexer: inout CoolLexer) throws -> Self.Node
//}
//
//extension ASTParser {
//    static func parse(at token: Token, using lexer: inout CoolLexer) throws -> Self.Node? {
//        guard matches(token) else {
//            return nil
//        }
//        return try parse(at: token, using: &lexer)
//    }
//}
//
//struct ClassDeclParser: ASTParser {
//    static func matches(_ token: Token) -> Bool {
//        return token.kind == .keyword(.class)
//    }
//    
//    static func parse(at token: Token, using lexer: inout CoolLexer) throws -> ClassDecl {
//        let identifierToken = try lexer.next()
//        guard case .identifier(let name) = identifierToken.kind else {
//            throw NSError() // handle later
//        }
//        
//        let next = try lexer.next()
//        let inheritance: InheritanceClause? = try InheritanceClauseParser.parse(at: next, using: &lexer)
//        
//        if next.kind != .leftBrace {
//            throw NSError() // handle later
//        }
//        // continue handling members
//        return ClassDecl(name: name, location: token.location, inheritance: inheritance, members: [/*handle later*/])
//    }
//}
//
//struct InheritanceClauseParser: ASTParser {
//    static func matches(_ token: Token) -> Bool {
//        return token.kind == .keyword(.inherits)
//    }
//    
//    static func parse(at token: Token, using lexer: inout CoolLexer) throws -> InheritanceClause {
//        let identifierToken = try lexer.next()
//        guard case .identifier(let inheritted) = identifierToken.kind else {
//            throw NSError() // handle later
//        }
//        
//        return InheritanceClause(
//            inheritedType: IdentifierType(
//                name: inheritted,
//                location: identifierToken.location
//            ),
//            location: token.location
//        )
//    }
//}
