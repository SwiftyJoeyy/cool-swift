import Testing
import Foundation
import Diagnostics
@testable import Lexing

@Suite struct IntegrationTests {
    @Test func `complete lexing workflow with file`() throws {
        let url = try #require(
            Bundle.module.url(
                forResource: "test",
                withExtension: "cl",
                subdirectory: "Resources"
            )
        )
        
        var lexer = CoolLexer(try String(contentsOf: url))
        var tokens = [Token]()
        var diagnostics = [Diagnostic]()
        
        while !lexer.reachedEnd {
            do {
                let token = try lexer.next()
                tokens.append(token)
            } catch {
                diagnostics.append(error)
            }
        }
        
        let expectedTokens = [
            Token(kind: .stringLiteral("123 456"), location: SourceLocation(line: 12, column: 1, file: "")),
            Token(kind: .stringLiteral("123456"), location: SourceLocation(line: 15, column: 1, file: "")),
            Token(kind: .integerLiteral("123"), location: SourceLocation(line: 18, column: 1, file: "")),
            Token(kind: .stringLiteral("123 456"), location: SourceLocation(line: 20, column: 1, file: "")),
            Token(kind: .stringLiteral("123\n456"), location: SourceLocation(line: 27, column: 1, file: "")),
            Token(kind: .integerLiteral("123456"), location: SourceLocation(line: 29, column: 1, file: "")),
            Token(kind: .endOfFile, location: SourceLocation(line: 30, column: 0, file: ""))
        ]
        
        let expectedDiags = [
            Diagnostic(.unescapedNewline),
            Diagnostic(.invalidInteger),
        ]
        
        #expect(tokens == expectedTokens)
        #expect(diagnostics.map(\.id) == expectedDiags.map(\.id))
    }
}
