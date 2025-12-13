//
//  MemberAccessExpr.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 02/12/2025.
//

import Foundation
import Basic

public struct MemberAccessExpr: Expr {
    public let base: any Expr
    public let member: any Expr
    public let location: SourceLocation
    
    public var description: String {
        return "\(base.description).\(member.description)"
    }
    
    public init(base: some Expr, member: some Expr, location: SourceLocation) {
        self.base = base
        self.member = member
        self.location = location
    }
}

public struct StaticDispatchExpr: Expr {
    public let base: any Expr
    public let type: any TypeRef
    public let location: SourceLocation
    
    public var description: String {
        return "\(base.description)@\(type.description)"
    }
    
    public init(base: some Expr, type: some TypeRef, location: SourceLocation) {
        self.base = base
        self.type = type
        self.location = location
    }
}
