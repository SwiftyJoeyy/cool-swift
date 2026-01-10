//
//  ControlExprs.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct IfExpr: Expr {
    public let condition: any Expr
    public let thenBody: any Expr
    public let elseBody: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return """
        if \(condition.description) then
            \(thenBody.description)
        else
            \(elseBody.description)
        fi
        """
    }
    
    public init(
        condition: some Expr,
        thenBody: some Expr,
        elseBody: some Expr,
        location: SourceLocation
    ) {
        self.condition = condition
        self.thenBody = thenBody
        self.elseBody = elseBody
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct WhileExpr: Expr {
    public let condition: any Expr
    public let body: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return """
        while \(condition.description) loop
            \(body.description)
        pool
        """
    }
    
    public init(
        condition: some Expr,
        body: some Expr,
        location: SourceLocation
    ) {
        self.condition = condition
        self.body = body
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct CaseExpr: Expr {
    public let expr: any Expr
    public let branches: [CaseBranch]
    public let location: SourceLocation
    
    public var description: String {
        let branchesDescription = branches.map({"    " + $0.description})
            .joined(separator: ";\n")
        return """
        case \(expr.description) of
        \(branchesDescription)
        esac
        """
    }
    
    public init(
        expr: some Expr,
        branches: [CaseBranch],
        location: SourceLocation
    ) {
        self.expr = expr
        self.branches = branches
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct CaseBranch: ASTNode {
    public let binding: Binding
    public let body: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "\(binding.description) => \(body.description)"
    }
    
    public init(binding: Binding, body: some Expr, location: SourceLocation) {
        self.binding = binding
        self.body = body
        self.location = location
    }
    
    public struct Binding: BindingDecl {
        public let name: Identifier
        public let typeAnnotation: TypeAnnotation
        public let location: SourceLocation
        
        public var type: any TypeRef {
            return typeAnnotation.type
        }
        public var description: String {
            return "\(name): \(typeAnnotation.description)"
        }
        
        public init(
            name: Identifier,
            typeAnnotation: TypeAnnotation,
            location: SourceLocation
        ) {
            self.name = name
            self.typeAnnotation = typeAnnotation
            self.location = location
        }
    }
}

public struct BlockExpr: Expr {
    public let expressions: [any Expr]
    public let location: SourceLocation
    
    public var description: String {
        let bindingsDescription = expressions
            .map({"    " + $0.description})
            .joined(separator: ";\n")
        return """
        {
        \(bindingsDescription)
        }
        """
    }
    
    public init(expressions: [any Expr], location: SourceLocation) {
        self.expressions = expressions
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct LetExpr: Expr {
    public let bindings: [VarDecl]
    public let body: any Expr
    public let location: SourceLocation
    
    public var description: String {
        let bindingsDescription = bindings.map(\.description)
            .joined(separator: ",\n")
        return """
        let \(bindingsDescription) in
            \(body.description)
        pool
        """
    }
    
    public init(
        bindings: [VarDecl],
        body: some Expr,
        location: SourceLocation
    ) {
        self.bindings = bindings
        self.body = body
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}
