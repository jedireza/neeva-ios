// Copyright Neeva. All rights reserved.

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

    func reset(tester: KIFUITestActor) {
        let tabManager = bvc.tabManager

        if bvc.tabManager.selectedTab?.isIncognito ?? false {
            tabManager.toggleIncognitoMode()
        }

        tabManager.removeTabs(tabManager.tabs, showToast: false, addNormalTab: true)
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
        openURL(openAddressBar: false)
        
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
        openURL()
        reset(tester: tester())
    }

    func testNewPrivateTabKeyCommand() {
        bvc.newPrivateTabKeyCommand()

        // turn lazy tab into real tab by opening URL
        openURL()

        XCTAssert(bvc.tabManager.selectedTab?.isIncognito == true)
        reset(tester: tester())
    }

    func testCloseTabKeyCommand() {
        openURL()
        openNewTab(to: "\(webRoot!)/numberedPage.html?page=1")
        XCTAssert(bvc.tabManager.tabs.count == 2)
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        bvc.closeTabKeyCommand()
        XCTAssert(bvc.tabManager.tabs.count == 1)
        tester().waitForWebViewElementWithAccessibilityLabel("Example Domain")

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
