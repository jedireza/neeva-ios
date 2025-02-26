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
            tester.waitForWebViewElementWithAccessibilityLabel("Example Domain")
        }
    }

    func previousTab(tester: KIFUITestActor) {
        openNewTab()
        tester.waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.previousTabKeyCommand()
    }

    // MARK: Find in Page
    func testFindInPageKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.findInPageKeyCommand()
        tester().waitForView(withAccessibilityIdentifier: "FindInPage_Done")

        reset()
    }

    // MARK: UI
    func testSelectLocationBarKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()

        bvc.selectLocationBarKeyCommand()
        openURL()

        reset()
    }

    func testShowTabTrayKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.showTabTrayKeyCommand()
        tester().waitForView(withAccessibilityLabel: "Normal Tabs")

        reset()
    }

    // MARK: Tab Mangement
    func testNewTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        bvc.newTabKeyCommand()

        // Make sure Lazy Tab popped up
        tester().waitForView(withAccessibilityLabel: "Cancel")
        reset()
    }

    func testNewIncognitoTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openNewTab()
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

        bvc.newIncognitoTabKeyCommand()

        // Make sure Lazy Tab popped up
        tester().waitForView(withAccessibilityLabel: "Cancel")

        XCTAssert(bvc.tabManager.selectedTab?.isIncognito == true)
        reset()
    }

    func testNextTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        previousTab(tester: tester())
        bvc.nextTabKeyCommand()

        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[1])
        reset()
    }

    func testPreviousTabCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        previousTab(tester: tester())

        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[0])
        reset()
    }

    func testCloseAllTabsCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openMultipleTabs(tester: tester())
        bvc.closeAllTabsCommand()

        tester().waitForView(withAccessibilityIdentifier: "EmptyTabTray")
        reset()
    }

    func testRestoreTabKeyCommand() throws {
        if !isiPad() {
            try skipTest(issue: 0, "Keyboard shorcuts are only supported on iPad")
        }

        openMultipleTabs(tester: tester())
        closeAllTabs()
        tester().waitForAnimationsToFinish()

        bvc.restoreTabKeyCommand()

        XCTAssert(bvc.tabManager.tabs.count > 1)
        reset()
    }
}
