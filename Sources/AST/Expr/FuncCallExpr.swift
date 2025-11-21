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
}
