//
//  HighlightableToken.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public protocol HighlightableToken: Sendable {
    var startPosition: SourcePosition { get }
    
    var endPosition: SourcePosition { get }
}
