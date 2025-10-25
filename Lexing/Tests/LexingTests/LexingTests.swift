import Testing
@testable import Lexing

@Test func example() async throws {
    let string = """
    8328239823992 "heriuwhehriuwhwiorw"
    """
    
    let chars = Array(string)
    
    var lexer = CoolLexer()
    var tokens = [Token]()
    
    for i in 0..<chars.count {
        let char = chars[i]
        let result = lexer.lexing(
            char,
            at: SourceLocation(line: 1, column: i + 1, file: "")
        )
        
        switch result {
            case .continue, .failed:
                continue
            case .found(let token):
                tokens.append(token)
        }
    }
    
    #expect(
        tokens == [
            Token(
                kind: .integerLiteral("8328239823992"),
                location: SourceLocation(line: 1, column: 1, file: "")
            ),
            Token(
                kind: .stringLiteral("\"heriuwhehriuwhwiorw\""),
                location: SourceLocation(line: 1, column: 15, file: "")
            )
        ]
    )
}
