//
//  ClassDecl.swift
//  Parsing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Foundation
import Basic

public struct ClassDecl: Decl {
    public let name: Identifier
    public let inheritance: InheritanceClause?
    public let membersBlock: MembersBlock
    public let location: SourceLocation
    
    public var description: String {
        return """
        class \(name)\(inheritance.map({" " + $0.description}) ?? "") {
            \(membersBlock.description)
        };
        """
    }
    
    public init(
        name: Identifier,
        inheritance: InheritanceClause?,
        membersBlock: MembersBlock,
        location: SourceLocation
    ) {
        self.name = name
        self.inheritance = inheritance
        self.membersBlock = membersBlock
        self.location = location
    }
}

public struct InheritanceClause: ASTNode {
    public let inheritedType: any TypeRef
    public let location: SourceLocation
    
    public var description: String {
        return "inherits \(inheritedType.description)"
    }
    
    public init(inheritedType: some TypeRef, location: SourceLocation) {
        self.inheritedType = inheritedType
        self.location = location
    }
}

public struct MembersBlock: ASTNode {
    public let members: [any Decl]
    public let location: SourceLocation
    
    public var description: String {
        return members.map(\.description).joined(separator: ";\n")
    }
    
    public init(members: [any Decl], location: SourceLocation) {
        self.members = members
        self.location = location
    }
}
