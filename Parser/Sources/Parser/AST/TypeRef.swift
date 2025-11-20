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

public struct IdentifierType: TypeRef {
    public let name: String
    public let location: SourceLocation
}
