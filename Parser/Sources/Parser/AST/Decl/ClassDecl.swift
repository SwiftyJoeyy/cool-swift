//
//  ClassDecl.swift
//  Parsing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Foundation
import Basic

public struct ClassDecl: Decl {
    public let name: String
    public let inheritance: InheritanceClause?
    public let membersBlock: MembersBlock
    public let location: SourceLocation
}

public struct InheritanceClause: ASTNode {
    public let inheritedType: any TypeRef
    public let location: SourceLocation
}

public struct MembersBlock: ASTNode {
    public let members: [any Decl]
    public let location: SourceLocation
}
