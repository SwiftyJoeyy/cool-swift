//
//  CanonicalIdentifier.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 26/12/2025.
//

import Foundation
import AST

internal struct CanonicalIdentifier: Canonical, CustomStringConvertible {
    internal static let `self` = CanonicalIdentifier(name: "self")
    
    internal let name: String
    internal var id: String {
        return name
    }
    
    internal var description: String {
        return name
    }
}

extension Identifier {
    internal var canonical: CanonicalIdentifier {
        return CanonicalIdentifier(name: value)
    }
}

extension DeclRefExpr {
    internal var canonical: CanonicalIdentifier {
        return CanonicalIdentifier(name: name)
    }
}
