//
//  ParserTestSuite.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation
import Diagnostics
import TestSupport
@testable import Parser

/// A suite that tests a single parser entry point.
///
/// Conforming suites only provide ``parseNode(from:)`` and get
/// `parse(_:)` and `parseWithDiags(_:)` for free.
protocol ParserTestSuite {
    associatedtype Node

    func parseNode(from parser: inout CoolParser) throws(Diagnostic) -> Node
}

extension ParserTestSuite {
    func parse(_ source: String) throws -> Node {
        var parser = try CoolParser.new(source: source).parser
        return try parseNode(from: &parser)
    }

    func parseWithDiags(
        _ source: String
    ) throws -> (node: Node, diags: [Diagnostic]) {
        var (parser, diagEngine) = try CoolParser.new(source: source)
        return (try parseNode(from: &parser), diagEngine.diags)
    }
}
