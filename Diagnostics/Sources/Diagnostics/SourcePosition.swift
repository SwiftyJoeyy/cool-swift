//
//  SourcePosition.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public protocol SourcePositionRepresentible {
    var position: SourcePosition { get }
}

public struct SourcePosition: Equatable, Hashable, Sendable {
    public let offset: Int
    
    public init(offset: Int) {
        self.offset = offset
    }
}
