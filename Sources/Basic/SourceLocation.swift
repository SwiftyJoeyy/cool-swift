//
//  SourceLocation.swift
//  Basic
//
//  Created by Joe Maghzal on 11/11/2025.
//

import Foundation

public struct SourceLocation: Equatable, Hashable, Sendable {
    public static let empty = SourceLocation(line: 0, column: 0, file: "")
    
    public let line: Int
    public let column: Int
    public let file: String
    
    public init(line: Int, column: Int, file: String) {
        self.line = line
        self.column = column
        self.file = file
    }
}
