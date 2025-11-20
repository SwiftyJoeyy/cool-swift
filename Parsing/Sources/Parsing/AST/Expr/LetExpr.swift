//
//  LetExpr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct LetExpr: Expr {
    public let bindings: [VarDecl]
    public let body: any Expr
    public let location: SourceLocation
}
