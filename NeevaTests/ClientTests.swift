/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage
import UIKit
import WebKit
import XCTest

@testable import Client

class ClientTests: XCTestCase {

    func testMobileUserAgent() {
        let compare: (String) -> Bool = { ua in
            let range = ua.range(
                of: "^Mozilla/5\\.0 \\(.+\\) AppleWebKit/[0-9\\.]+ \\(KHTML, like Gecko\\)",
                options: .regularExpression)
            return range != nil
        }
        XCTAssertTrue(compare(UserAgent.mobileUserAgent()), "User agent computes correctly.")
    }
}

// see also `skipTest` in StorageTests, UITests, and XCUITests
func skipTest(issue: Int, _ message: String) throws {
    throw XCTSkip("#\(issue): \(message)")
}
