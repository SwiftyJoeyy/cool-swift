//
//  ASTNode.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public protocol ASTNode: CustomStringConvertible {
    var location: SourceLocation { get }
}

public struct SourceFile: ASTNode {
    public let declarations: [ClassDecl]
    public let location: SourceLocation
    
    public var description: String {
        ""
    }
    
    public init(declarations: [ClassDecl], location: SourceLocation) {
        self.declarations = declarations
        self.location = location
    }
}
