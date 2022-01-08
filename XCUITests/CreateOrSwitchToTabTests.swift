// Copyright Neeva. All rights reserved.

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
            element.tap()
        }
        openURL(path(forTestPage: "test-mozilla-org.html"))

        let numTabs = getNumberOfTabs()
        XCTAssertEqual(numTabs, 3)
    }
}
