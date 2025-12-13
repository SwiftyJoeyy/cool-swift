//
//  SourceRange.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 24/11/2025.
//

import Foundation

public struct SourceRange {
    public let start: SourceLocation
    public let end: SourceLocation
    
    public init(start: SourceLocation, end: SourceLocation) {
        self.start = start
        self.end = end
    }
}
