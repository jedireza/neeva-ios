// Copyright Neeva. All rights reserved.

import Foundation

@testable import Client

class KeyboardShortcutTests: KIFTestCase {
    var bvc: BrowserViewController!

    override func setUp() {
        BrowserUtils.dismissFirstRunUI(tester())
        bvc = BrowserViewController.foregroundBVC()
    }

    func reset(tester: KIFUITestActor) {
        let tabManager = bvc.tabManager

        if bvc.tabManager.selectedTab?.isPrivate ?? false {
            _ = tabManager.switchPrivacyMode()
        }

        tabManager.removeTabsAndAddNormalTab(tabManager.tabs, showToast: false)
    }

    func openTab(tester: KIFUITestActor) {
        tester.waitForAnimationsToFinish()

        if tester.viewExistsWithLabel("Cancel") {
            tester.tapView(withAccessibilityLabel: "Cancel")
        }

        if tester.tryFindingView(withAccessibilityIdentifier: "Tour.Button.Okay") {
            tester.tapView(withAccessibilityIdentifier: "Tour.Button.Okay")
        }

        tester.waitForView(withAccessibilityLabel: "Show Tabs")
        tester.longPressView(withAccessibilityLabel: "Show Tabs", duration: 1)

        tester.waitForView(withAccessibilityLabel: "New Tab")
        tester.tapView(withAccessibilityLabel: "New Tab")

        BrowserUtils.enterUrlAddressBar(tester)
    }

    func openMultipleTabs(tester: KIFUITestActor) {
        for _ in 0...3 {
            openTab(tester: tester)
        }
    }

    func previousTab(tester: KIFUITestActor) {
        openTab(tester: tester)
        bvc.previousTabKeyCommand()
    }

    func testReloadTab() {
        reset(tester: tester())
        openTab(tester: tester())
        bvc.reloadTabKeyCommand()
    }

    // MARK: Navigation Tests
    func goBack() {
        openTab(tester: tester())
        BrowserUtils.enterUrlAddressBar(tester(), typeUrl: "apple.com")
        bvc.goBackKeyCommand()
    }

    func testGoBack() {
        reset(tester: tester())
        goBack()
    }

    func testGoForward() {
        reset(tester: tester())
        goBack()
        bvc.goForwardKeyCommand()
    }

    // MARK: Find in Page
    func testFindInPageKeyCommand() {
        reset(tester: tester())
        openTab(tester: tester())
        bvc.findInPageKeyCommand()
    }

    // MARK: UI
    func testSelectLocationBarKeyCommand() {
        reset(tester: tester())
        bvc.selectLocationBarKeyCommand()
    }

    func testShowTabTrayKeyCommand() {
        reset(tester: tester())
        bvc.showTabTrayKeyCommand()

        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
    }

    // MARK: Tab Mangement
    func testNewTabKeyCommand() {
        reset(tester: tester())
        BrowserUtils.enterUrlAddressBar(tester())
        bvc.newTabKeyCommand()

        // turn lazy tab into real tab by opening URL
        BrowserUtils.enterUrlAddressBar(tester())
    }

    func testNewPrivateTabKeyCommand() {
        reset(tester: tester())
        bvc.newPrivateTabKeyCommand()

        // turn lazy tab into real tab by opening URL
        BrowserUtils.enterUrlAddressBar(tester())

        XCTAssert(bvc.tabManager.selectedTab?.isPrivate == true)
    }

    func testCloseTabKeyCommand() {
        reset(tester: tester())
        BrowserUtils.enterUrlAddressBar(tester())
        openTab(tester: tester())

        XCTAssert(bvc.tabManager.tabs.count == 2)
        bvc.closeTabKeyCommand()
        XCTAssert(bvc.tabManager.tabs.count == 1)
    }

    func testNextTabKeyCommand() {
        reset(tester: tester())
        BrowserUtils.enterUrlAddressBar(tester())
        previousTab(tester: tester())
        bvc.nextTabKeyCommand()
        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[1])
    }

    func testPreviousTabCommand() {
        reset(tester: tester())
        previousTab(tester: tester())
        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[0])
    }

    func testCloseAllTabKeyCommand() {
        reset(tester: tester())
        openTab(tester: tester())
        bvc.closeTabKeyCommand()
        XCTAssert(bvc.tabManager.tabs.count == 1)
    }

    func testCloseAllTabsCommand() {
        reset(tester: tester())
        openMultipleTabs(tester: tester())
        bvc.closeAllTabsCommand()
        XCTAssert(bvc.tabManager.tabs.count == 1)
    }

    func testRestoreTabKeyCommand() {
        reset(tester: tester())
        openMultipleTabs(tester: tester())

        BrowserUtils.closeAllTabs(tester())
        tester().waitForAnimationsToFinish()

        bvc.restoreTabKeyCommand()

        XCTAssert(bvc.tabManager.tabs.count > 1)
    }
}
