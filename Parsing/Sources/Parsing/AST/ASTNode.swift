//
//  ASTNode.swift
//  Parsing
//
//  Created by Joe Maghzal on 20/11/2025.
//

import Foundation
import Basic

public protocol ASTNode {
    var location: SourceLocation { get }
}
