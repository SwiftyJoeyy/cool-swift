//
//  TypeRef.swift
//  Parsing
//
//  Created by Joe Maghzal on 11/11/2025.
//

import Foundation
import Basic

public protocol TypeRef: ASTNode {
    
}

public struct TypeIdentifier: TypeRef {
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
