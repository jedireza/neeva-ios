/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Defaults
import Shared
import Storage
import UIKit
import WebKit
import XCTest

@testable import Client

open class TabManagerMockProfile: MockProfile {
    var numberOfTabsStored = 0
    override public func storeTabs(_ tabs: [RemoteTab]) -> Shared.Deferred<Maybe<Int>> {
        numberOfTabsStored = tabs.count
        return deferMaybe(tabs.count)
    }
}

struct MethodSpy {
    let functionName: String
    let method: ((_ tabs: [Tab?]) -> Void)?

    init(functionName: String) {
        self.functionName = functionName
        self.method = nil
    }

    init(functionName: String, method: ((_ tabs: [Tab?]) -> Void)?) {
        self.functionName = functionName
        self.method = method
    }
}

private let spyRestoredTabs = "tabManagerDidRestoreTabs(_:)"

class TabManagerTests: XCTestCase {
    var profile: TabManagerMockProfile!
    var manager: TabManager!
    var tabsUpdated: Bool = false
    var selectedTabUpdated: Bool = false
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()

        profile = TabManagerMockProfile()
        manager = TabManager(profile: profile, imageStore: nil)

        manager.tabsUpdatedPublisher.sink { [weak self] in
            self?.tabsUpdated = true
        }.store(in: &subscriptions)

        manager.selectedTabPublisher.sink { [weak self] _ in
            self?.selectedTabUpdated = true
        }.store(in: &subscriptions)
    }

    override func tearDown() {
        subscriptions.removeAll()

        profile._shutdown()
        manager.removeAllTabs()

        super.tearDown()
    }

    func testAddTabShouldAddOneNormalTab() {
        tabsUpdated = false
        manager.addTab()
        XCTAssertTrue(tabsUpdated)
        XCTAssertEqual(manager.normalTabs.count, 1, "There should be one normal tab")
    }

    func testAddTabShouldAddOneIncognitoTab() {
        tabsUpdated = false
        manager.addTab(isIncognito: true)
        XCTAssertTrue(tabsUpdated)
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should be one private tab")
    }

    func testAddTabAndSelect() {
        let tab = manager.addTab()
        manager.selectTab(tab)

        XCTAssertEqual(manager.selectedTab, tab, "There should be selected first tab")
    }

    func testDeleteIncognitoTabsOnExit() {
        Defaults[.closeIncognitoTabs] = true

        // create one private and one normal tab
        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab(isIncognito: true))

        XCTAssertEqual(
            manager.selectedTab?.isIncognito, true, "The selected tab should be the private tab")
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should only be one private tab")

        manager.selectTab(tab)
        XCTAssertEqual(
            manager.incognitoTabs.count, 0,
            "If the normal tab is selected the private tab should have been deleted")
        XCTAssertEqual(manager.normalTabs.count, 1, "The regular tab should stil be around")

        manager.selectTab(manager.addTab(isIncognito: true))
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should be one new private tab")
        manager.willSwitchTabMode(leavingPBM: true)
        XCTAssertEqual(
            manager.incognitoTabs.count, 0,
            "After willSwitchTabMode there should be no more private tabs")

        manager.selectTab(manager.addTab(isIncognito: true))
        manager.selectTab(manager.addTab(isIncognito: true))
        XCTAssertEqual(
            manager.incognitoTabs.count, 2,
            "Private tabs should not be deleted when another one is added")
        manager.selectTab(manager.addTab())
        XCTAssertEqual(
            manager.incognitoTabs.count, 0,
            "But once we add a normal tab we've switched out of private mode. Private tabs should be deleted"
        )
        XCTAssertEqual(
            manager.normalTabs.count, 2,
            "The original normal tab and the new one should both still exist")

        Defaults[.closeIncognitoTabs] = false
        manager.selectTab(manager.addTab(isIncognito: true))
        manager.selectTab(tab)
        XCTAssertEqual(
            manager.selectedTab?.isIncognito, false, "The selected tab should not be private")
        XCTAssertEqual(
            manager.incognitoTabs.count, 1,
            "If the flag is false then private tabs should still exist")
    }

    func testTogglePBMDelete() {
        Defaults[.closeIncognitoTabs] = true

        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab())
        manager.selectTab(manager.addTab(isIncognito: true))

        manager.willSwitchTabMode(leavingPBM: false)
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should be 1 private tab")
        manager.willSwitchTabMode(leavingPBM: true)
        XCTAssertEqual(manager.incognitoTabs.count, 0, "There should be 0 private tab")
        manager.removeTab(tab)
        XCTAssertEqual(manager.normalTabs.count, 1, "There should be 1 normal tab")
    }

    func testRemoveNonSelectedTab() {
        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.addTab()
        let deleteTab = manager.addTab()

        manager.removeTab(deleteTab)
        XCTAssertEqual(tab, manager.selectedTab)
        XCTAssertFalse(manager.tabs.contains(deleteTab))
    }

    func testDeleteSelectedTab() {
        func addTab(_ visit: Bool) -> Tab {
            let tab = manager.addTab()
            if visit {
                tab.lastExecutedTime = Date.nowMilliseconds()
            }
            return tab
        }

        let tab0 = addTab(false)  // not visited
        let tab1 = addTab(true)
        let tab2 = addTab(true)
        let tab3 = addTab(true)
        let tab4 = addTab(false)  // not visited

        // starting at tab1, we should be selecting
        // [ tab3, tab4, tab2, tab0 ]

        manager.selectTab(tab1)
        tab1.parent = tab3
        manager.removeTab(manager.selectedTab!)
        // Rule: parent tab if it was the most recently visited
        XCTAssertEqual(manager.selectedTab, tab3)

        manager.removeTab(manager.selectedTab!)
        // Rule: next to the right.
        XCTAssertEqual(manager.selectedTab, tab4)

        manager.removeTab(manager.selectedTab!)
        // Rule: next to the left, when none to the right
        XCTAssertEqual(manager.selectedTab, tab2)

        manager.removeTab(manager.selectedTab!)
        // Rule: last one left.
        XCTAssertEqual(manager.selectedTab, tab0)
    }

    func testDeleteLastTab() {
        // Create the tab before adding the mock delegate. So we don't have to check
        // delegate calls we dont care about
        (0..<10).forEach { _ in manager.addTab() }
        manager.selectTab(manager.tabs.last)
        let newSelectedTab = manager.tabs[8]

        tabsUpdated = false
        selectedTabUpdated = false

        manager.removeTab(manager.tabs.last!)

        XCTAssertTrue(tabsUpdated)
        XCTAssertTrue(selectedTabUpdated)
        XCTAssertEqual(manager.selectedTab, newSelectedTab)
    }

    func testRemovingIncognitoTabs() {
        //setup
        Defaults[.closeIncognitoTabs] = true

        // create one private and one normal tab
        let tab = manager.addTab()
        let newTab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab(isIncognito: true))

        // Double check a few things
        XCTAssertEqual(
            manager.selectedTab?.isIncognito, true, "The selected tab should be the private tab")
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should only be one private tab")

        // switch to normal mode. Which should delete the private tabs
        manager.select(tab)

        // make sure tabs are cleared properly and indexes are reset
        XCTAssertEqual(manager.incognitoTabs.count, 0, "Private tab should have been deleted")

        selectedTabUpdated = false

        // select the new tab to trigger the delegate methods
        manager.selectTab(newTab)

        XCTAssertTrue(selectedTabUpdated)
    }

    func testDeleteFirstTab() {
        // Create the tab before adding the mock delegate. So we don't have to check
        // delegate calls we dont care about
        (0..<10).forEach { _ in manager.addTab() }
        manager.selectTab(manager.tabs.first)
        let newSelectedTab = manager.tabs[1]

        tabsUpdated = false
        selectedTabUpdated = false

        manager.removeTab(manager.tabs.first!)

        XCTAssertTrue(tabsUpdated)
        XCTAssertTrue(selectedTabUpdated)
        XCTAssertEqual(manager.selectedTab, newSelectedTab)
    }

    func testRemoveAllShouldRemoveAllTabs() {
        let tab0 = manager.addTab()
        let tab1 = manager.addTab()

        manager.removeAllTabs()
        XCTAssert(nil == manager.tabs.firstIndex(of: tab0))
        XCTAssert(nil == manager.tabs.firstIndex(of: tab1))
    }

    // Incognito tabs and regular tabs are in the same tabs array.
    // Make sure that when an incognito tab is added inbetween regular tabs it isnt accidently selected when removing a regular tab
    func testTabsIndex() {
        // We add 2 tabs. Then a private one before adding another normal tab and selecting it.
        // Make sure that when the last one is deleted we dont switch to the private tab
        let (_, _, incognitoOne, last) = (
            manager.addTab(), manager.addTab(), manager.addTab(isIncognito: true), manager.addTab()
        )
        manager.selectTab(last)

        tabsUpdated = false
        selectedTabUpdated = false

        manager.removeTab(last)

        XCTAssertTrue(tabsUpdated)
        XCTAssertTrue(selectedTabUpdated)
        XCTAssertNotEqual(manager.selectedTab, incognitoOne)
    }

    func testRemoveTabAndUpdateSelectedIndexIsSelectedParentTabAfterRemoval() {
        func addTab(_ visit: Bool) -> Tab {
            let tab = manager.addTab()
            if visit {
                tab.lastExecutedTime = Date.nowMilliseconds()
            }
            return tab
        }
        let _ = addTab(false)  // not visited
        let tab1 = addTab(true)
        let _ = addTab(true)
        let tab3 = addTab(true)
        let _ = addTab(false)  // not visited

        manager.selectTab(tab1)
        tab1.parent = tab3
        manager.removeTab(tab1)

        XCTAssertEqual(manager.selectedTab, tab3)
    }

    func testTabsIndexClosingFirst() {
        // We add 2 tabs. Then an incognito one before adding another normal tab and selecting the first.
        // Make sure that when the last one is deleted we dont switch to the private tab
        manager.addTab()
        let newSelectedTab = manager.addTab()
        manager.addTab(isIncognito: true)
        manager.addTab()
        manager.selectTab(manager.tabs.first)

        tabsUpdated = false
        selectedTabUpdated = false

        manager.removeTab(manager.tabs.first!)

        XCTAssertTrue(tabsUpdated)
        XCTAssertTrue(selectedTabUpdated)
        XCTAssertEqual(manager.selectedTab, newSelectedTab)
    }

    func testUndoCloseTabsRemovesAutomaticallyCreatedNonIncognitoTab() {
        let tab = manager.addTab()
        let tabToSave = Tab(
            bvc: SceneDelegate.getBVC(for: nil), configuration: WKWebViewConfiguration())
        tabToSave.sessionData = SessionData(
            currentPage: 0, urls: [URL(string: "url")!],
            queries: [nil], suggestedQueries: [nil],
            lastUsedTime: Date.nowMilliseconds()
        )

        manager.removeTabs([tab], updateSelectedTab: true)
        manager.restoreAllClosedTabs()

        XCTAssertNotEqual(manager.tabs.first, tab)
    }

    func testRootUUIDNotEqualToUUID() {
        let tab = manager.addTab()
        XCTAssertNotEqual(tab.tabUUID, tab.rootUUID)
    }

    func testRootUUIDEqualToAncestorRootUUID() {
        let tab1 = manager.addTab()
        let tab2 = manager.addTab(afterTab: tab1)
        XCTAssertEqual(tab2.rootUUID, tab1.rootUUID)

        let tab3 = manager.addTab(afterTab: tab2)
        XCTAssertEqual(tab3.rootUUID, tab1.rootUUID)
    }

    func testRootUUIDIsPersisted() {
        let tab1 = manager.addTab()
        let tab2 = manager.addTab(afterTab: tab1)
        let initialRootUUID = tab1.rootUUID

        manager.removeTabs([tab1, tab2], updateSelectedTab: true)
        manager.restoreAllClosedTabs()

        let _ = MethodSpy(functionName: spyRestoredTabs) { tabs in
            XCTAssertEqual(tabs.count, 2)
            XCTAssertEqual(tabs.first??.rootUUID, initialRootUUID)
            XCTAssertEqual(tabs.last??.rootUUID, initialRootUUID)
        }
    }

    func testParentUUIDNilOnCreation() {
        let tab = manager.addTab()
        XCTAssertNil(tab.parentUUID)
    }

    func testParentUUIDEqualToAncestorParentUUID() {
        let tab1 = manager.addTab()
        let tab2 = manager.addTab(afterTab: tab1)
        XCTAssertEqual(tab2.parent, tab1)
        XCTAssertEqual(tab2.parentUUID, tab1.tabUUID)
        XCTAssertNil(tab1.parentUUID)

        let tab3 = manager.addTab(afterTab: tab2)
        XCTAssertEqual(tab3.parentUUID, tab2.tabUUID)
        XCTAssertEqual(tab3.parent, tab2)
        XCTAssertTrue(tab3.isDescendentOf(tab1))
        XCTAssertEqual(tab2.parentUUID, tab1.tabUUID)
    }

    func testParentUUIDIsPersisted() {
        let tab1 = manager.addTab()
        let tab2 = manager.addTab(afterTab: tab1)
        let initialParentUUID = tab2.parentUUID

        manager.removeTabs([tab1, tab2], updateSelectedTab: true)
        manager.restoreAllClosedTabs()

        let _ = MethodSpy(functionName: spyRestoredTabs) { tabs in
            XCTAssertEqual(tabs.count, 2)
            XCTAssertNil(tabs.first??.parentUUID)
            XCTAssertEqual(tabs.last??.parentUUID, initialParentUUID)
            XCTAssertEqual(tabs.last??.parent, tabs.first)
        }
    }
}
