//
//  Identifier.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/12/2025.
//

public import Basic
import Foundation

public struct Identifier: ASTNode {
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
