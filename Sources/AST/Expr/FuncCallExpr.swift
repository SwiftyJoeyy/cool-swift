//
//  FuncCallExpr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct FuncCallExpr: Expr {
    public let calledExpression: any Expr
    public let arguments: [any Expr]
    public let location: SourceLocation
    
    public var description: String {
        let args = arguments.map(\.description).joined(separator: ", ")
        return "\(calledExpression.description)(\(args))"
    }
    
    public init(
        calledExpression: some Expr,
        arguments: [any Expr],
        location: SourceLocation
    ) {
        self.calledExpression = calledExpression
        self.arguments = arguments
        self.location = location
    }
}
