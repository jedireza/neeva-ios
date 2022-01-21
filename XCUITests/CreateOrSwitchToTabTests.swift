// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class CreateOrSwitchToTabTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        super.setUp()
    }

    func testSwitchBackToTabFromURLBar() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        openURL(path(forTestPage: "test-mozilla-book.html"))
        openURL(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 2)
    }

    func testSwitchBackToTabFromTabSwitcher() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        openURL(path(forTestPage: "test-mozilla-book.html"))

        goToTabTray()
        openURL(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 2)
    }

    func testCreatesNewTabFromLongPressMenu() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        openURL(path(forTestPage: "test-mozilla-book.html"))

        openURLInNewTab(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 3)
    }

    func testCreatesNewTabFromOverflowMenu() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        openURL(path(forTestPage: "test-mozilla-book.html"))

        goToOverflowMenuButton(label: "New Tab", shouldDismissOverlay: false) { element in
            element.tap(force: true)
        }
        openURL(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 3)
    }
}
