//
//  ConstantExprs.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public struct StringLiteralExpr: Expr {
    public let value: String
    public let location: SourceLocation
    
    public var description: String {
        return value
    }
    
    public init(value: String, location: SourceLocation) {
        self.value = value
        self.location = location
    }
}

public struct IntegerLiteralExpr: Expr {
    public let value: String
    public let location: SourceLocation
    
    public var description: String {
        return value
    }
    
    public init(value: String, location: SourceLocation) {
        self.value = value
        self.location = location
    }
}

public struct BoolLiteralExpr: Expr {
    public let value: String
    public let location: SourceLocation
    
    public var description: String {
        return value
    }
    
    public init(value: String, location: SourceLocation) {
        self.value = value
        self.location = location
    }
}

public struct DeclRefExpr: Expr {
    public let name: String
    public let location: SourceLocation
    
    public var description: String {
        return name
    }
    
    public init(name: String, location: SourceLocation) {
        self.name = name
        self.location = location
    }
}
