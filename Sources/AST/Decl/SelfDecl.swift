//
//  SelfDecl.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 03/01/2026.
//

import Foundation
import Basic

public struct SelfDecl: BindingDecl {
    public let name: Identifier
    public let type: any TypeRef
    public let location: SourceLocation
    
    public var description: String {
        return name.description
    }
    
    public init(type: String) {
        self.name = Identifier(value: "self", location: .empty)
        self.type = TypeIdentifier(name: type, location: .empty)
        self.location = .empty
    }
}
