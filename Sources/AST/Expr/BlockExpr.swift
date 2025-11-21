//
//  BlockExpr.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct BlockExpr: Expr {
    public let expressions: [any Expr]
    public let location: SourceLocation
}
