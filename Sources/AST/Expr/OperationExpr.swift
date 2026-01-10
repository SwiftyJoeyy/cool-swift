//
//  OperationExpr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct BinaryOperator: ASTNode {
    public let op: Operator
    public let location: SourceLocation
    
    public var description: String {
        return "\(op.description)"
    }
    
    public init(op: Operator, location: SourceLocation) {
        self.op = op
        self.location = location
    }
    
    public enum Operator: CustomStringConvertible {
        case lessThan, lessThanOrEqual, plus, minus, slash, star, equal
        
        public var description: String {
            switch self {
                case .lessThan:
                    return "<"
                case .lessThanOrEqual:
                    return "<="
                case .plus:
                    return "+"
                case .minus:
                    return "-"
                case .slash:
                    return "/"
                case .star:
                    return "*"
                case .equal:
                    return "="
            }
        }
    }
}

public struct OperationExpr: Expr {
    public let lhs: any Expr
    public let op: BinaryOperator
    public let rhs: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "\(lhs.description) \(op.description) \(rhs.description)"
    }
    
    public init(
        lhs: some Expr,
        op: BinaryOperator,
        rhs: some Expr,
        location: SourceLocation
    ) {
        self.lhs = lhs
        self.op = op
        self.rhs = rhs
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct AssignmentExpr: Expr {
    public let target: any Expr
    public let value: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "\(target.description) = \(value.description)"
    }
    
    public init(target: some Expr, value: some Expr, location: SourceLocation) {
        self.target = target
        self.location = location
        self.value = value
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct NewExpr: Expr {
    public let type: any TypeRef
    public let location: SourceLocation
    
    public var description: String {
        return "new \(type.description)"
    }
    
    public init(type: some TypeRef, location: SourceLocation) {
        self.type = type
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct NotExpr: Expr {
    public let expression: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "not \(expression.description)"
    }
    
    public init(expression: some Expr, location: SourceLocation) {
        self.expression = expression
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct IsVoidExpr: Expr {
    public let expression: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "isvoid \(expression.description)"
    }
    
    public init(expression: some Expr, location: SourceLocation) {
        self.expression = expression
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}

public struct ComplementExpr: Expr {
    public let expression: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "~\(expression.description)"
    }
    
    public init(expression: some Expr, location: SourceLocation) {
        self.expression = expression
        self.location = location
    }
    
    public func accept<V: ExprVisitor>(_ visitor: inout V) throws(V.Diag) {
        try visitor.visit(self)
    }
}
