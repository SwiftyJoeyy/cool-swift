//
//  Canonical.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 20/12/2025.
//

import Foundation

internal protocol Canonical: Equatable, Hashable {
    associatedtype ID: Equatable, Hashable
    
    var id: Self.ID { get }
}

extension Canonical {
    internal static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
