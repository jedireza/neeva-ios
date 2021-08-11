// Copyright Neeva. All rights reserved.

import Foundation

@testable import Client

class KeyboardShortcutTests: UITestBase {
    var bvc: BrowserViewController!

    override func setUp() {
        super.setUp()
        bvc = SceneDelegate.getBVC()
    }

    func reset(tester: KIFUITestActor) {
        let tabManager = bvc.tabManager

        if bvc.tabManager.selectedTab?.isPrivate ?? false {
            _ = tabManager.switchPrivacyMode()
        }

        tabManager.removeTabsAndAddNormalTab(tabManager.tabs, showToast: false)
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

    func testReloadTab() {
        openNewTab()
        bvc.reloadTabKeyCommand()
        reset(tester: tester())
    }

    // MARK: Navigation Tests
    func goBack() {
        openNewTab()
        bvc.goBackKeyCommand()
    }

    func testGoBack() {
        goBack()
        reset(tester: tester())
    }

    func testGoForward() {
        goBack()
        bvc.goForwardKeyCommand()
        reset(tester: tester())
    }

    // MARK: Find in Page
    func testFindInPageKeyCommand() {
        openNewTab()
        bvc.findInPageKeyCommand()
        reset(tester: tester())
    }

    // MARK: UI
    func testSelectLocationBarKeyCommand() {
        openURL()
        bvc.selectLocationBarKeyCommand()

        openURL("neeva.com", openAddressBar: false)
        reset(tester: tester())
    }

    func testShowTabTrayKeyCommand() {
        bvc.showTabTrayKeyCommand()

        tester().wait(forTimeInterval: 5)
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        reset(tester: tester())
    }

    // MARK: Tab Mangement
    func testNewTabKeyCommand() {
        bvc.newTabKeyCommand()

        // turn lazy tab into real tab by opening URL
        openURL("example.com")
        reset(tester: tester())
    }

    func testNewPrivateTabKeyCommand() {
        bvc.newPrivateTabKeyCommand()

        // turn lazy tab into real tab by opening URL
        openURL("example.com")

        XCTAssert(bvc.tabManager.selectedTab?.isPrivate == true)
        reset(tester: tester())
    }

    func testCloseTabKeyCommand() {
        openNewTab()

        XCTAssert(bvc.tabManager.tabs.count == 2)
        bvc.closeTabKeyCommand()
        XCTAssert(bvc.tabManager.tabs.count == 1)
        reset(tester: tester())
    }

    func testNextTabKeyCommand() {
        previousTab(tester: tester())
        bvc.nextTabKeyCommand()
        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[1])
        reset(tester: tester())
    }

    func testPreviousTabCommand() {
        previousTab(tester: tester())
        XCTAssert(bvc.tabManager.selectedTab == bvc.tabManager.tabs[0])
        reset(tester: tester())
    }

    func testCloseAllTabKeyCommand() {
        openNewTab()
        bvc.closeTabKeyCommand()
        XCTAssert(bvc.tabManager.tabs.count == 1)
        reset(tester: tester())
    }

    func testCloseAllTabsCommand() {
        openMultipleTabs(tester: tester())
        bvc.closeAllTabsCommand()
        XCTAssert(bvc.tabManager.tabs.count == 1)
        reset(tester: tester())
    }

    func testRestoreTabKeyCommand() {
        openMultipleTabs(tester: tester())
        closeAllTabs()
        tester().waitForAnimationsToFinish()

        bvc.restoreTabKeyCommand()

        XCTAssert(bvc.tabManager.tabs.count > 1)
        reset(tester: tester())
    }
}
