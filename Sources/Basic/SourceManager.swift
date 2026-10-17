 //
//  SourceManager.swift
//  CoolSwift
//
//  Created by Joe Maghzal on 24/11/2025.
//

import Foundation

public protocol SourceManageable {
    var sourceFiles: [(path: String, contents: String)] { get }
    
    func registerFile(_ filePath: String) throws(SourceError)
    func line(at location: SourceLocation) -> String?
}

public enum SourceError: Error {
    case failedToRegisterFile(any Error)
}

public class SourceManager: SourceManageable {
    private var files = [String: File]()
    
    public var sourceFiles: [(path: String, contents: String)] {
        return files.map({($0.key, $0.value.contents)})
    }
    
    public init() { }
    
    public func registerFile(_ filePath: String) throws(SourceError) {
        do {
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = contents
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map({String($0)})
            files[filePath] = File(path: filePath, contents: contents, lines: lines)
        } catch {
            throw .failedToRegisterFile(error)
        }
    }
    
    public func line(at location: SourceLocation) -> String? {
        guard let lines = files[location.file]?.lines,
              lines.indices.contains(location.line - 1)
        else {
            return nil
        }
        return lines[location.line - 1]
    }
}

extension SourceManager {
    private struct File {
        let path: String
        let contents: String
        let lines: [String]
    }
}
