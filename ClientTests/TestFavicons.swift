/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import XCTest

@testable import Client

class TestFavicons: ProfileTest {
    func testDefaultFavicons() {
        // The amazon case tests a special case for multi-reguin domain lookups
        ["http://www.youtube.com", "https://www.taobao.com/", "https://www.amazon.ca"].forEach {
            let url = URL(string: $0)!
            let icon = FaviconFetcher.getBundledIcon(forUrl: url)
            XCTAssertNotNil(icon)
        }
    }
}
