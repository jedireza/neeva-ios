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

private let spyDidSelectedTabChange =
    "tabManager(_:didSelectedTabChange:previous:isRestoring:updateZeroQuery:)"
private let spyRestoredTabs = "tabManagerDidRestoreTabs(_:)"

open class MockTabManagerDelegate: TabManagerDelegate {
    // This array represents the order in which delegate methods should be called.
    // Each delegate method will pop the first struct from the array. If the method
    // name doesn't match the struct then the order is incorrect. Then it evaluates
    // the method closure which will return true/false depending on if the tabs are
    // correct.
    var methodCatchers: [MethodSpy] = []

    func expect(_ methods: [MethodSpy]) {
        self.methodCatchers = methods
    }

    func verify(_ message: String) {
        XCTAssertTrue(methodCatchers.isEmpty, message)
    }

    func testDelegateMethodWithName(_ name: String, tabs: [Tab?]) {
        guard let spy = self.methodCatchers.first else {
            // delegate call is sent from method but test fails anyways
            // XCTAssert(false, "No method was availible in the queue. For the delegate method \(name) to use")
            return
        }
        XCTAssertEqual(spy.functionName, name)
        if let methodCheck = spy.method {
            methodCheck(tabs)
        }
        methodCatchers.removeFirst()
    }

    public func tabManager(
        _ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?,
        isRestoring: Bool, updateZeroQuery: Bool
    ) {
        testDelegateMethodWithName(#function, tabs: [selected, previous])
    }
}

class TabManagerTests: XCTestCase {
    var profile: TabManagerMockProfile!
    var manager: TabManager!
    var delegate: MockTabManagerDelegate!
    var tabsUpdated: Bool = false
    var subscription: AnyCancellable? = nil

    override func setUp() {
        super.setUp()

        profile = TabManagerMockProfile()
        manager = TabManager(profile: profile, imageStore: nil)
        delegate = MockTabManagerDelegate()

        subscription = manager.tabsUpdatedPublisher.sink { [weak self] in
            self?.tabsUpdated = true
        }
    }

    override func tearDown() {
        subscription = nil

        profile._shutdown()
        manager.removeDelegate(delegate)
        manager.removeAllTabs()

        super.tearDown()
    }

    func testAddTabShouldAddOneNormalTab() {
        tabsUpdated = false
        manager.addTab()
        XCTAssertTrue(tabsUpdated)
        XCTAssertEqual(manager.normalTabs.count, 1, "There should be one normal tab")
    }

    func testAddTabShouldAddOnePrivateTab() {
        tabsUpdated = false
        manager.addTab(isPrivate: true)
        XCTAssertTrue(tabsUpdated)
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should be one private tab")
    }

    func testAddTabAndSelect() {
        let tab = manager.addTab()
        manager.selectTab(tab)

        XCTAssertEqual(manager.selectedTab, tab, "There should be selected first tab")
    }

    func testDeletePrivateTabsOnExit() {
        Defaults[.closePrivateTabs] = true

        // create one private and one normal tab
        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab(isPrivate: true))

        XCTAssertEqual(
            manager.selectedTab?.isIncognito, true, "The selected tab should be the private tab")
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should only be one private tab")

        manager.selectTab(tab)
        XCTAssertEqual(
            manager.incognitoTabs.count, 0,
            "If the normal tab is selected the private tab should have been deleted")
        XCTAssertEqual(manager.normalTabs.count, 1, "The regular tab should stil be around")

        manager.selectTab(manager.addTab(isPrivate: true))
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should be one new private tab")
        manager.willSwitchTabMode(leavingPBM: true)
        XCTAssertEqual(
            manager.incognitoTabs.count, 0,
            "After willSwitchTabMode there should be no more private tabs")

        manager.selectTab(manager.addTab(isPrivate: true))
        manager.selectTab(manager.addTab(isPrivate: true))
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

        Defaults[.closePrivateTabs] = false
        manager.selectTab(manager.addTab(isPrivate: true))
        manager.selectTab(tab)
        XCTAssertEqual(
            manager.selectedTab?.isIncognito, false, "The selected tab should not be private")
        XCTAssertEqual(
            manager.incognitoTabs.count, 1,
            "If the flag is false then private tabs should still exist")
    }

    func testTogglePBMDelete() {
        Defaults[.closePrivateTabs] = true

        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab())
        manager.selectTab(manager.addTab(isPrivate: true))

        manager.willSwitchTabMode(leavingPBM: false)
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should be 1 private tab")
        manager.willSwitchTabMode(leavingPBM: true)
        XCTAssertEqual(manager.incognitoTabs.count, 0, "There should be 0 private tab")
        manager.removeTabAndUpdateSelectedTab(tab)
        XCTAssertEqual(manager.normalTabs.count, 1, "There should be 1 normal tab")
    }

    func testRemoveNonSelectedTab() {

        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.addTab()
        let deleteTab = manager.addTab()

        manager.removeTabAndUpdateSelectedTab(deleteTab)
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
        manager.removeTabAndUpdateSelectedTab(manager.selectedTab!)
        // Rule: parent tab if it was the most recently visited
        XCTAssertEqual(manager.selectedTab, tab3)

        manager.removeTabAndUpdateSelectedTab(manager.selectedTab!)
        // Rule: next to the right.
        XCTAssertEqual(manager.selectedTab, tab4)

        manager.removeTabAndUpdateSelectedTab(manager.selectedTab!)
        // Rule: next to the left, when none to the right
        XCTAssertEqual(manager.selectedTab, tab2)

        manager.removeTabAndUpdateSelectedTab(manager.selectedTab!)
        // Rule: last one left.
        XCTAssertEqual(manager.selectedTab, tab0)
    }

    func testDeleteLastTab() {
        // Create the tab before adding the mock delegate. So we don't have to check
        // delegate calls we dont care about
        (0..<10).forEach { _ in manager.addTab() }
        manager.selectTab(manager.tabs.last)
        let deleteTab = manager.tabs.last
        let newSelectedTab = manager.tabs[8]
        manager.addDelegate(delegate)
        tabsUpdated = false

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(deleteTab, previous)
            XCTAssertEqual(next, newSelectedTab)
        }
        delegate.expect([didSelect])
        manager.removeTabAndUpdateSelectedTab(manager.tabs.last!)

        delegate.verify("Not all delegate methods were called")
        XCTAssertTrue(tabsUpdated)
    }

    func testDelegatesCalledWhenRemovingPrivateTabs() {
        //setup
        Defaults[.closePrivateTabs] = true

        // create one private and one normal tab
        let tab = manager.addTab()
        let newTab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab(isPrivate: true))
        manager.addDelegate(delegate)

        // Double check a few things
        XCTAssertEqual(
            manager.selectedTab?.isIncognito, true, "The selected tab should be the private tab")
        XCTAssertEqual(manager.incognitoTabs.count, 1, "There should only be one private tab")

        // switch to normal mode. Which should delete the private tabs
        manager.select(tab)

        //make sure tabs are cleared properly and indexes are reset
        XCTAssertEqual(manager.incognitoTabs.count, 0, "Private tab should have been deleted")

        // didSelect should still be called when switching between a nil tab
        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            XCTAssertFalse(next.isIncognito)
        }

        // make sure delegate method is actually called
        delegate.expect([didSelect])

        // select the new tab to trigger the delegate methods
        manager.selectTab(newTab)

        // check
        delegate.verify("Not all delegate methods were called")
    }

    func testDeleteFirstTab() {
        // Create the tab before adding the mock delegate. So we don't have to check
        // delegate calls we dont care about
        (0..<10).forEach { _ in manager.addTab() }
        manager.selectTab(manager.tabs.first)
        let deleteTab = manager.tabs.first
        let newSelectedTab = manager.tabs[1]
        manager.addDelegate(delegate)
        tabsUpdated = false

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(deleteTab, previous)
            XCTAssertEqual(next, newSelectedTab)
        }
        delegate.expect([didSelect])

        manager.removeTabAndUpdateSelectedTab(manager.tabs.first!)

        delegate.verify("Not all delegate methods were called")
        XCTAssertTrue(tabsUpdated)
    }

    func testRemoveAllShouldRemoveAllTabs() {

        let tab0 = manager.addTab()
        let tab1 = manager.addTab()

        manager.removeAllTabs()
        XCTAssert(nil == manager.tabs.firstIndex(of: tab0))
        XCTAssert(nil == manager.tabs.firstIndex(of: tab1))
    }

    // Private tabs and regular tabs are in the same tabs array.
    // Make sure that when a private tab is added inbetween regular tabs it isnt accidently selected when removing a regular tab
    func testTabsIndex() {
        // We add 2 tabs. Then a private one before adding another normal tab and selecting it.
        // Make sure that when the last one is deleted we dont switch to the private tab
        let (_, _, privateOne, last) = (
            manager.addTab(), manager.addTab(), manager.addTab(isPrivate: true), manager.addTab()
        )
        manager.selectTab(last)
        manager.addDelegate(delegate)
        tabsUpdated = false

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(last, previous)
            XCTAssert(next != privateOne && !next.isIncognito)
        }
        delegate.expect([didSelect])
        manager.removeTabAndUpdateSelectedTab(last)

        delegate.verify("Not all delegate methods were called")
        XCTAssertTrue(tabsUpdated)
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
        manager.removeTabAndUpdateSelectedTab(tab1)

        XCTAssertEqual(manager.selectedTab, tab3)
    }

    func testTabsIndexClosingFirst() {

        // We add 2 tabs. Then a private one before adding another normal tab and selecting the first.
        // Make sure that when the last one is deleted we dont switch to the private tab
        let deleted = manager.addTab()
        let newSelected = manager.addTab()
        manager.addTab(isPrivate: true)
        manager.addTab()
        manager.selectTab(manager.tabs.first)
        manager.addDelegate(delegate)
        tabsUpdated = false

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(deleted, previous)
            XCTAssertEqual(next, newSelected)
        }
        delegate.expect([didSelect])
        manager.removeTabAndUpdateSelectedTab(manager.tabs.first!)

        delegate.verify("Not all delegate methods were called")
        XCTAssertTrue(tabsUpdated)
    }

    func testUndoCloseTabsRemovesAutomaticallyCreatedNonPrivateTab() {
        let tab = manager.addTab()
        let tabToSave = Tab(
            bvc: SceneDelegate.getBVC(for: nil), configuration: WKWebViewConfiguration())
        tabToSave.sessionData = SessionData(
            currentPage: 0, urls: [URL(string: "url")!],
            queries: [nil], suggestedQueries: [nil],
            lastUsedTime: Date.nowMilliseconds()
        )

        manager.removeTabs([tab], updatingSelectedTab: true)
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

        manager.removeTabs([tab1, tab2], updatingSelectedTab: true)
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

        manager.removeTabs([tab1, tab2], updatingSelectedTab: true)
        manager.restoreAllClosedTabs()

        let _ = MethodSpy(functionName: spyRestoredTabs) { tabs in
            XCTAssertEqual(tabs.count, 2)
            XCTAssertNil(tabs.first??.parentUUID)
            XCTAssertEqual(tabs.last??.parentUUID, initialParentUUID)
            XCTAssertEqual(tabs.last??.parent, tabs.first)
        }
    }
}
