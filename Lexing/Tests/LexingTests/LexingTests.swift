import Testing
import Foundation
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
    
    while !lexer.reachedEnd {
        guard let token = try? lexer.next() else { continue }
        if case TokenKind.unknown = token.kind {
            continue
        }
        tokens.append(token)
    }
    
    let expected = [
        Token(kind: .stringLiteral("123 456")),
        Token(kind: .stringLiteral("123456")),
        Token(kind: .stringLiteral("123 456")),
        Token(kind: .stringLiteral("123\\n456")),
    ]
    
    #expect(tokens == expected)
}
