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
    
    var kind: DeclKind { get }
}

public protocol BindingDecl: Decl {
    var type: any TypeRef { get }
}

public enum DeclKind {
    case classDecl(ClassDecl)
    case varDecl(VarDecl)
    case funcDecl(FuncDecl)
    case paramDecl(ParameterDecl)
    case branchBinding(CaseBranch.Binding)
    case selfDecl(SelfDecl)
}

extension ClassDecl {
    public var kind: DeclKind {
        return .classDecl(self)
    }
}

extension VarDecl {
    public var kind: DeclKind {
        return .varDecl(self)
    }
}

extension FuncDecl {
    public var kind: DeclKind {
        return .funcDecl(self)
    }
}

extension ParameterDecl {
    public var kind: DeclKind {
        return .paramDecl(self)
    }
}

extension CaseBranch.Binding {
    public var kind: DeclKind {
        return .branchBinding(self)
    }
}

extension SelfDecl {
    public var kind: DeclKind {
        return .selfDecl(self)
    }
}
