// Copyright Neeva. All rights reserved.

import Foundation
import XCTest

@testable import Client

class SessionDataTests: XCTestCase {
    func testEncodeDecode() {
        let testUrls = [
            "https://neeva.com/",
            "https://news.ycombinator.com/",
            "https://www.wikipedia.org/",
        ].map({ URL(string: $0)! })

        let input = SessionData(
            currentPage: -1, urls: testUrls, lastUsedTime: Date.nowMilliseconds())

        let data = try! NSKeyedArchiver.archivedData(
            withRootObject: input, requiringSecureCoding: false)

        let output = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! SessionData

        XCTAssertEqual(input.currentPage, output.currentPage)
        XCTAssertEqual(input.urls, output.urls)
        XCTAssertEqual(input.lastUsedTime, output.lastUsedTime)
    }
}
