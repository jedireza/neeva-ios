// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class TabGroupTests: BaseTestCase {
    // MARK: - NYTimes Test Case
    // The NYTimes case is where a URL is opened from say nytimes.com,
    // and a sublink i.e. nytimes.com/article is opened.
    //
    // Then the user would open up a new tab to the orignal URL (nytimes.com,
    // which in that case we should create a tab group with the two tabs.

    /// Tests the NYTimes case in an instance where the child tab (nytimes.com/article)
    /// is not currently in a Tab Group.
    func testNYTimesCaseCreatesTabGroup() {
        openURL()
        waitForExistence(app.links["More information..."], timeout: 30)
        app.links["More information..."].tap()

        openURLInNewTab()
        waitForExistence(app.links["More information..."], timeout: 30)

        goToTabTray()
        waitForExistence(app.buttons["Tab Group, https://example.com/"])
    }
}
