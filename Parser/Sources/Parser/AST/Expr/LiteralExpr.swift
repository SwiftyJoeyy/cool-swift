//
//  LiteralExpr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct StringLiteralExpr: Expr {
    public let value: String
    public let location: SourceLocation
}

public struct IntegerLiteralExpr: Expr {
    public let value: String
    public let location: SourceLocation
}

public struct BoolLiteralExpr: Expr {
    public let value: String
    public let location: SourceLocation
}

public struct DeclRefExpr: Expr {
    public let name: String
    public let location: SourceLocation
}

struct MemberAccessExpr: Expr {
    public let base: any Expr
    public let member: any Expr
    public let location: SourceLocation
}
