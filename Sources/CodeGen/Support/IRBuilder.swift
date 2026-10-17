//
//  IRBuilder.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 10/10/2026.
//

import Foundation

@resultBuilder struct IRBuilder {
    typealias Item = String
    static func buildBlock(_ components: [Item]...) -> [Item] {
        return components.flatMap({$0})
    }
    static func buildArray(_ components: [[Item]]) -> [Item] {
        return components.flatMap({$0})
    }
    static func buildLimitedAvailability(_ component: [Item]) -> [Item] {
        return component
    }
    static func buildExpression(_ expression: Item) -> [Item] {
        return [expression]
    }
    static func buildExpression(_ expression: [Item]) -> [Item] {
        return expression
    }
    static func buildOptional(_ component: [Item]?) -> [Item] {
        return component ?? []
    }
    static func buildEither(first component: [Item]) -> [Item] {
        return component
    }
    static func buildEither(second component: [Item]) -> [Item] {
        return component
    }
}

func buildIR(@IRBuilder _ builder: () -> [String]) -> String {
    let lines = builder()
    return lines.filter({!$0.isEmpty}).joined(separator: "\n")
}

func Indented(_ count: Int, @IRBuilder _ builder: () -> [String]) -> String {
    let indentation = String(repeating: " ", count: count)
    let lines = builder()
    
    return lines.compactMap {
        guard !$0.isEmpty else {
            return nil
        }
        return indentation + $0
    }.joined(separator: "\n")
}

func CommaSeparated(@IRBuilder _ builder: () -> [String]) -> [String] {
    let items = builder()
    return items.enumerated().map { index, item in
        index < items.count - 1 ? item + ",": item
    }
}
