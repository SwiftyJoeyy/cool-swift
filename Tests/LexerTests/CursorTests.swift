//
//  CursorTests.swift
//  Lexing
//
//  Created by Joe Maghzal on 08/11/2025.
//

import Testing
@testable import Lexer

@Suite struct CursorTests {
    @Test func `cursor can be initialized with empty string`() {
        let cursor = Cursor("", file: "")
        #expect(cursor.reachedEnd == true)
    }
    
    @Test func `cursor can be initialized with non-empty string`() {
        let cursor = Cursor("hello", file: "")
        #expect(cursor.reachedEnd == false)
    }
    
    @Test func `peek returns first character without advancing`() {
        let cursor = Cursor("abc", file: "")
        #expect(cursor.peek() == UInt8(ascii: "a"))
    }
    
    @Test func `peek with offset returns correct character`() {
        let cursor = Cursor("abc", file: "")
        #expect(cursor.peek(aheadBy: 1) == UInt8(ascii: "b"))
        #expect(cursor.peek(aheadBy: 2) == UInt8(ascii: "c"))
    }
    
    @Test func `peek beyond end returns nil`() {
        let cursor = Cursor("a", file: "")
        #expect(cursor.peek(aheadBy: 5) == nil)
    }
    
    @Test func `advance moves cursor position`() {
        var cursor = Cursor("abc", file: "")
        #expect(cursor.peek() == UInt8(ascii: "a"))
        cursor.advance()
        #expect(cursor.peek() == UInt8(ascii: "b"))
    }
    
    @Test func `advance by offset moves cursor multiple positions`() {
        var cursor = Cursor("abcdef", file: "")
        cursor.advance(by: 3)
        #expect(cursor.peek() == UInt8(ascii: "d"))
    }
    
    @Test func `advance by offset beyond length moves cursor to end of file`() {
        var cursor = Cursor("abcdef", file: "")
        cursor.advance(by: .max)
        #expect(cursor.peek() == nil)
    }
    
    @Test func `advance updates line and column on newline`() {
        var cursor = Cursor("a\nb", file: "")
        #expect(cursor.location.line == 1)
        #expect(cursor.location.column == 1)
        
        cursor.advance()
        #expect(cursor.location.line == 2)
        #expect(cursor.location.column == 0)
        
        cursor.advance()
        #expect(cursor.location.line == 2)
        #expect(cursor.location.column == 1)
    }
    
    @Test func `advance until stops at predicate match`() {
        var cursor = Cursor("abc def", file: "")
        cursor.advance(until: { $0 == UInt8(ascii: " ") })
        #expect(cursor.peek() == UInt8(ascii: " "))
    }
    
    @Test func `next advances and returns next character`() {
        var cursor = Cursor("ab", file: "")
        let next = cursor.next()
        #expect(next == UInt8(ascii: "b"))
    }
    
    @Test func `next does not advance and returns nill when cursor reaches end`() {
        var cursor = Cursor("ab", file: "")
        cursor.advance(by: 2)
        let next = cursor.next()
        #expect(next == nil)
    }
    
    @Test func `reachedEnd is true when cursor is at end`() {
        var cursor = Cursor("a", file: "")
        #expect(cursor.reachedEnd == false)
        cursor.advance()
        #expect(cursor.reachedEnd == true)
    }
    
    @Test func `location has correct file name`() {
        let cursor = Cursor("test", file: "test.cool")
        #expect(cursor.location.file == "test.cool")
    }
}
