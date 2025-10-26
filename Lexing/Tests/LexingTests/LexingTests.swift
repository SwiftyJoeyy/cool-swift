import Testing
import Foundation
import Diagnostics
@testable import Lexing

@Test func example() async throws {
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
    
    let expected = [
        Token(kind: .stringLiteral("123 456"), location: SourceLocation(line: 12, column: 1, file: "")),
        Token(kind: .stringLiteral("123456"), location: SourceLocation(line: 15, column: 1, file: "")),
        Token(kind: .stringLiteral("123 456"), location: SourceLocation(line: 18, column: 1, file: "")),
        Token(kind: .stringLiteral("123\n456"), location: SourceLocation(line: 23, column: 1, file: "")),
        Token(kind: .endOfFile, location: SourceLocation(line: 24, column: 0, file: ""))
    ]
    
    #expect(tokens == expected)
    #expect(diagnostics.map(\.id) == [Diagnostic(.unescapedNewline)].map(\.id))
}
