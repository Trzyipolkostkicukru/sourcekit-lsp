//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import LanguageServerProtocol
import SKTestSupport
import XCTest
import ISDBTestSupport

final class FormattingTests: XCTestCase {
  var workspace: SKTibsTestWorkspace! = nil

  func initialize() throws {
    workspace = try staticSourceKitTibsWorkspace(name: "Formatting")!
    try workspace.buildAndIndex()
    try workspace.openDocument(workspace.testLoc("a.swift").url, language: .swift)
  }
  override func tearDown() {
    workspace = nil
  }

  func performFormattingRequest(file url: URL, options: FormattingOptions) -> [TextEdit]? {
    let request = DocumentFormattingRequest(
      textDocument: TextDocumentIdentifier(url), 
      options: options
    )
    return try! workspace.sk.sendSync(request)!
  }

  func testSpaces() throws {
    XCTAssertNoThrow(try initialize())
    let url = workspace.testLoc("a.swift").url
    let options = FormattingOptions(tabSize: 3, insertSpaces: true)
    let edits = try XCTUnwrap(performFormattingRequest(file: url, options: options))
    XCTAssertEqual(edits.count, 1)
    let firstEdit = try XCTUnwrap(edits.first)
    XCTAssertEqual(firstEdit.range.lowerBound, Position(line: 0, utf16index: 0))
    XCTAssertEqual(firstEdit.range.upperBound, Position(line: 3, utf16index: 1))
    // var bar needs to be indented with three spaces
    XCTAssertEqual(firstEdit.newText, #"""
    /*a.swift*/
    struct Foo {
       var bar = 123
    }

    """#)
  }

  func testTabs() throws {
    try initialize()
    let url = workspace.testLoc("a.swift").url
    let options = FormattingOptions(tabSize: 3, insertSpaces: false)
    let edits = try XCTUnwrap(performFormattingRequest(file: url, options: options))
    XCTAssertEqual(edits.count, 1)
    let firstEdit = try XCTUnwrap(edits.first)
    XCTAssertEqual(firstEdit.range.lowerBound, Position(line: 0, utf16index: 0))
    XCTAssertEqual(firstEdit.range.upperBound, Position(line: 3, utf16index: 1))
    // var bar needs to be indented with a tab
    XCTAssertEqual(firstEdit.newText, #"""
    /*a.swift*/
    struct Foo {
    \#tvar bar = 123
    }

    """#)
  }
}
