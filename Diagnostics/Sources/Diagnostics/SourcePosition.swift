//
//  SourcePosition.swift
//  Diagnostics
//
//  Created by Joe Maghzal on 25/10/2025.
//

import Foundation

public struct SourceLocation: Equatable, Hashable, Sendable {
    public let line: Int
    public let column: Int
    public let file: String
    
    public init(line: Int, column: Int, file: String) {
        self.line = line
        self.column = column
        self.file = file
    }
}
