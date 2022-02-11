// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import Client

class KeyboardShortcutTests: UITestBase {
    var bvc: BrowserViewController!
    fileprivate var webRoot: String!

    override func setUp() {
        super.setUp()
        bvc = SceneDelegate.getBVC(for: nil)
        webRoot = SimplePageServer.start()
    }

    func reset() {
        bvc.closeAllTabsCommand()
    }

    func openMultipleTabs(tester: KIFUITestActor) {
        for _ in 0...3 {
            openNewTab()
        }
    }

    func previousTab(tester: KIFUITestActor) {
        openNewTab()
        bvc.previousTabKeyCommand()
    }

    // MARK: Find in Page
    func testFindInPageKeyCommand() {
        openNewTab()
        bvc.findInPageKeyCommand()
        tester().tryFindingView(withAccessibilityIdentifier: "FindInPage_Done")

        reset()
    }

    // MARK: UI
    func testSelectLocationBarKeyCommand() {
        openNewTab()

        bvc.selectLocationBarKeyCommand()
        openURL(openAddressBar: false)

        reset()
    }

    func testShowTabTrayKeyCommand() {
        openNewTab()
        bvc.showTabTrayKeyCommand()
        tester().waitForView(withAccessibilityLabel: "Normal Tabs")
        reset()
    }

    // MARK: Tab Mangement
    func testNewTabKeyCommand() {
        bvc.newTabKeyCommand()

        // Make sure Lazy Tab popped up
        tester().waitForView(withAccessibilityLabel: "Cancel")
        reset()
    }

    func testNewPrivateTabKeyCommand() {
        bvc.newPrivateTabKeyCommand()

        // Make sure Lazy Tab popped up
        tester().waitForView(withAccessibilityLabel: "Cancel")

        XCTAssert(bvc.tabManager.selectedTab?.isIncognito == true)
        reset()
    }

    func testNextTabKeyCommand() {
        previousTab(tester: tester())
        bvc.nextTabKeyCommand()
        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[1])
        reset()
    }

    func testPreviousTabCommand() {
        previousTab(tester: tester())
        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[0])
        reset()
    }

    func testCloseAllTabsCommand() {
        openMultipleTabs(tester: tester())
        bvc.closeAllTabsCommand()
        XCTAssertTrue(bvc.tabManager.tabs.count == 0)
        reset()
    }

    func testRestoreTabKeyCommand() {
        openMultipleTabs(tester: tester())
        closeAllTabs()
        tester().waitForAnimationsToFinish()

        bvc.restoreTabKeyCommand()

        XCTAssert(bvc.tabManager.tabs.count > 1)
        reset()
    }
}
