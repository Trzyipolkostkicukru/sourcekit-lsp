//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@testable import SourceKit
import LanguageServerProtocol
import XCTest

final class ImplementationTests: XCTestCase {
  func testImplementation() throws {
    guard let ws = try staticSourceKitTibsWorkspace(name: "Implementation") else { return }
    try ws.buildAndIndex()

    let protoDef = ws.testLoc("ProtoDef")
    let fooDef = ws.testLoc("FooDef")

    try ws.openDocument(protoDef.url, language: .swift)

    let textDocument = TextDocumentIdentifier(protoDef.url)
    let request = ImplementationRequest(textDocument: textDocument, position: Position(protoDef))
    let implementations = try ws.sk.sendSync(request)
    XCTAssertEqual(implementations, [Location(fooDef)])
  }
}