//
//  ClassDecl.swift
//  Parsing
//
//  Created by Joe Maghzal on 08/11/2025.
//

public import Basic
import Foundation

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
    public let members: [MemberDecl]
    public let location: SourceLocation
    
    public var description: String {
        return members.map(\.description).joined(separator: ";\n")
    }
    
    public init(members: [MemberDecl], location: SourceLocation) {
        self.members = members
        self.location = location
    }
}

public struct MemberDecl: Decl {
    public enum Kind {
        case varDecl(VarDecl), funcDecl(FuncDecl)
        case interfaceVarDecl(InterfaceVarDecl), interfaceFuncDecl(InterfaceFuncDecl)
        
        public var decl: any Decl {
            switch self {
                case .varDecl(let decl): decl
                case .funcDecl(let decl): decl
                case .interfaceVarDecl(let decl): decl
                case .interfaceFuncDecl(let decl): decl
            }
        }
        
        public var type: any TypeRef {
            switch self {
                case .varDecl(let decl): decl.type
                case .funcDecl(let decl): decl.returnClause.type
                case .interfaceVarDecl(let decl): decl.type
                case .interfaceFuncDecl(let decl): decl.returnClause.type
            }
        }
    }
    
    public let kind: Kind
    
    public var name: Identifier {
        return kind.decl.name
    }
    public var location: SourceLocation {
        return kind.decl.location
    }
    public var description: String {
        return kind.decl.description
    }
    
    public var type: any TypeRef {
        return kind.type
    }
    
    public init(kind: Kind) {
        self.kind = kind
    }
    
    public init(_ varDecl: VarDecl) {
        self.init(kind: .varDecl(varDecl))
    }
    
    public init(_ funcDecl: FuncDecl) {
        self.init(kind: .funcDecl(funcDecl))
    }
    
    public init(_ interfaceVarDecl: InterfaceVarDecl) {
        self.init(kind: .interfaceVarDecl(interfaceVarDecl))
    }
    
    public init(_ interfaceFuncDecl: InterfaceFuncDecl) {
        self.init(kind: .interfaceFuncDecl(interfaceFuncDecl))
    }
}
