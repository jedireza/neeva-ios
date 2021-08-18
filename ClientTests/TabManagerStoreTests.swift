/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage
import UIKit
import WebKit
import XCTest

@testable import Client

class TabManagerStoreTests: XCTestCase {
    let profile = TabManagerMockProfile()
    var manager: TabManager!
    let configuration = WKWebViewConfiguration()

    override func setUp() {
        super.setUp()

        manager = TabManager(profile: profile, imageStore: nil)
        configuration.processPool = WKProcessPool()

        if UIDevice.current.userInterfaceIdiom == .pad {
            // BVC.viewWillAppear() calls restoreTabs() which interferes with these tests. (On iPhone, ClientTests never dismiss the intro screen, on iPad the intro is a popover on the BVC).
            // Wait for this to happen (UIView.window only gets assigned after viewWillAppear()), then begin testing.
            let predicate = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "view.window != nil"),
                object: SceneDelegate.getBVC(for: nil))
            wait(for: [predicate], timeout: 20)
        }

        manager.testClearArchive()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Without session data, a Tab can't become a SavedTab and get archived
    func addTabWithSessionData(isPrivate: Bool = false) {
        let tab = Tab(
            bvc: SceneDelegate.getBVC(for: nil), configuration: configuration,
            isPrivate: isPrivate)
        tab.setURL("http://yahoo.com")
        manager.configureTab(
            tab, request: URLRequest(url: tab.url!), flushToDisk: false, zombie: false)
        tab.sessionData = SessionData(
            currentPage: 0, urls: [tab.url!], lastUsedTime: Date.nowMilliseconds())
    }

    func testNoData() {
        manager.testClearArchive()
        XCTAssertEqual(manager.testTabCountOnDisk(), 0, "Expected 0 tabs on disk")
        XCTAssertEqual(manager.testCountRestoredTabs(), 0)
    }

    func testPrivateTabsAreArchived() {
        for _ in 0..<2 {
            addTabWithSessionData(isPrivate: true)
        }
        waitForCondition {
            self.manager.testTabCountOnDisk() == 2
        }
    }

    func testAddedTabsAreStored() {
        // Add 2 tabs
        for _ in 0..<2 {
            addTabWithSessionData()
        }
        waitForCondition {
            self.manager.testTabCountOnDisk() == 2
        }

        // Add 2 more
        for _ in 0..<2 {
            addTabWithSessionData()
        }
        waitForCondition {
            self.manager.testTabCountOnDisk() == 4
        }

        // Remove all tabs, and add just 1 tab
        manager.removeAll()
        addTabWithSessionData()
        waitForCondition {
            self.manager.testTabCountOnDisk() == 1
        }
    }
}
