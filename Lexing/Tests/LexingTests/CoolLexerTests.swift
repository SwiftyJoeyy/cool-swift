import Testing
import Diagnostics
@testable import Lexing

@Suite struct CoolLexerTests {
// MARK: - Init tests
    @Test func `lexer can be initialized with string`() {
        let lexer = CoolLexer("test")
        #expect(lexer.reachedEnd == false)
    }
    
    @Test func `lexer reachedEnd is true for empty string`() {
        let lexer = CoolLexer("")
        #expect(lexer.reachedEnd == true)
    }
    
// MARK: - White space tests
    @Test func `lexer skips whitespace before tokens`() throws {
        var lexer = CoolLexer("   \"hello\"")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips tabs before tokens`() throws {
        var lexer = CoolLexer("\t\t\"hello\"")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips newlines before tokens`() throws {
        var lexer = CoolLexer("\n\n\"hello\"")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
// MARK: - Comments tests
    @Test func `lexer skips single-line comments`() throws {
        var lexer = CoolLexer("-- this is a comment\n\"hello\"")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips multi-line comments`() throws {
        var lexer = CoolLexer("(* this is a\nmulti-line comment *)\n\"hello\"")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer skips nested multi-line comments`() throws {
        var lexer = CoolLexer("(* outer (* inner *) outer *)\n\"hello\"")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("hello"))
    }
    
    @Test func `lexer throws on unterminated multi-line comment`() throws {
        var lexer = CoolLexer("(* unterminated comment")
        let diag = try #require(throws: Diagnostic.self) {
            _ = try lexer.next()
        }
        #expect(diag.id == Diagnostic(.unterminatedComment).id)
    }
    
// MARK: - End of file tests
    @Test func `lexer returns endOfFile token when at end`() throws {
        var lexer = CoolLexer("   ")
        let token = try lexer.next()
        #expect(token.kind == .endOfFile)
    }
    
    @Test func `lexer throws when calling next after end`() {
        var lexer = CoolLexer("")
        do {
            _ = try lexer.next()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error.id == Diagnostic(.reachedEndOfFile).id)
        }
    }
    
// MARK: - Lexing tests
    @Test func `lexer correctly lexes string literals`() throws {
        var lexer = CoolLexer("\"test\"")
        let token = try lexer.next()
        #expect(token.kind == .stringLiteral("test"))
    }
    
    @Test func `lexer correctly lexes integer literals`() throws {
        var lexer = CoolLexer("42")
        let token = try lexer.next()
        #expect(token.kind == .integerLiteral("42"))
    }
    
    @Test func `lexer returns unknown token for unrecognized characters`() throws {
        var lexer = CoolLexer("?")
        let token = try lexer.next()
        #expect(token.kind == .unknown("?"))
    }
    
    @Test func `lexer can lex multiple tokens in sequence`() throws {
        var lexer = CoolLexer("123 \"hello\"")
        let token1 = try lexer.next()
        #expect(token1.kind == .integerLiteral("123"))
        let token2 = try lexer.next()
        #expect(token2.kind == .stringLiteral("hello"))
    }
}
