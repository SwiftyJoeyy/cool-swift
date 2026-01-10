//
//  Decl.swift
//  Parsing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Foundation
import Basic

public protocol Decl: ASTNode {
    var name: Identifier { get }
}

public protocol BindingDecl: Decl {
    var type: any TypeRef { get }
}
