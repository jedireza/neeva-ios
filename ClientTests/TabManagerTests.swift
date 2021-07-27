/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@testable import Client
import Shared
import Storage
import UIKit
import WebKit
import Defaults

import XCTest

open class TabManagerMockProfile: MockProfile {
    var numberOfTabsStored = 0
    override public func storeTabs(_ tabs: [RemoteTab]) -> Deferred<Maybe<Int>> {
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

fileprivate let spyDidSelectedTabChange = "tabManager(_:didSelectedTabChange:previous:isRestoring:)"
fileprivate let spyRestoredTabs = "tabManagerDidRestoreTabs(_:)"


open class MockTabManagerDelegate: TabManagerDelegate {
    //this array represents the order in which delegate methods should be called.
    //each delegate method will pop the first struct from the array. If the method name doesn't match the struct then the order is incorrect
    //Then it evaluates the method closure which will return true/false depending on if the tabs are correct
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

    public func tabManager(_ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?, isRestoring: Bool) {
        testDelegateMethodWithName(#function, tabs: [selected, previous])
    }

    public func tabManager(_ tabManager: TabManager, didAddTab tab: Tab, isRestoring: Bool) {
        testDelegateMethodWithName(#function, tabs: [tab])
    }

    public func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) {
        testDelegateMethodWithName(#function, tabs: [tab])
    }

    public func tabManagerDidRestoreTabs(_ tabManager: TabManager) {
        testDelegateMethodWithName(#function, tabs: [])
    }

    public func tabManagerDidAddTabs(_ tabManager: TabManager) {
        testDelegateMethodWithName(#function, tabs: [])
    }

    public func tabManagerDidRemoveAllTabs(_ tabManager: TabManager) {
        testDelegateMethodWithName(#function, tabs: [])
    }
}

class TabManagerTests: XCTestCase {

    let didRemove = MethodSpy(functionName: "tabManager(_:didRemoveTab:isRestoring:)")
    let didAdd = MethodSpy(functionName: "tabManager(_:didAddTab:isRestoring:)")

    var profile: TabManagerMockProfile!
    var manager: TabManager!
    var delegate: MockTabManagerDelegate!

    override func setUp() {
        super.setUp()

        profile = TabManagerMockProfile()
        manager = TabManager(profile: profile, imageStore: nil)
        delegate = MockTabManagerDelegate()
    }

    override func tearDown() {
        profile._shutdown()
        manager.removeDelegate(delegate)
        manager.removeAll()

        super.tearDown()
    }

    func testAddTabShouldAddOneNormalTab() {
        manager.addDelegate(delegate)
        delegate.expect([didAdd])
        manager.addTab()
        delegate.verify("Not all delegate methods were called")
        XCTAssertEqual(manager.normalTabs.count, 1, "There should be one normal tab")
    }

    func testAddTabShouldAddOnePrivateTab() {
        manager.addDelegate(delegate)
        delegate.expect([didAdd])
        manager.addTab(isPrivate: true)
        delegate.verify("Not all delegate methods were called")
        XCTAssertEqual(manager.privateTabs.count, 1, "There should be one private tab")
    }

    func testAddTabAndSelect() {
        let tab = manager.addTab()
        manager.selectTab(tab)

        XCTAssertEqual(manager.selectedTab, tab, "There should be selected first tab")
    }

    func testDidDeleteLastTab() {
        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            XCTAssertNotNil(tabs[0])
            XCTAssertNotNil(tabs[1])
        }

        // create the tab before adding the mock delegate. So we don't have to check delegate calls we dont care about
        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.addDelegate(delegate)
        // it wont call didSelect because addTabAndSelect did not pass last removed tab
        delegate.expect([didRemove, didAdd, didSelect])
        manager.removeTabAndUpdateSelectedTab(tab)
        delegate.verify("Not all delegate methods were called")
    }

    func testDidDeleteLastPrivateTab() {
        //create the tab before adding the mock delegate. So we don't have to check delegate calls we dont care about
        let tab = manager.addTab()
        manager.selectTab(tab)
        let privateTab = manager.addTab(isPrivate: true)
        manager.selectTab(privateTab)
        manager.addDelegate(delegate)

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertTrue(previous != next)
            XCTAssertTrue(previous == privateTab)
            XCTAssertTrue(next == tab)
            XCTAssertTrue(previous.isPrivate)
            XCTAssertTrue(self.manager.selectedTab == next)
        }
        delegate.expect([didRemove, didSelect])
        manager.removeTabAndUpdateSelectedTab(privateTab)
        delegate.verify("Not all delegate methods were called")
    }

    func testDidCreateNormalTabWhenDeletingAll() {
        let removeAllTabs = MethodSpy(functionName: "tabManagerDidRemoveAllTabs(_:)")

        //create the tab before adding the mock delegate. So we don't have to check delegate calls we dont care about
        let tab = manager.addTab()
        manager.selectTab(tab)
        let privateTab = manager.addTab(isPrivate: true)
        manager.selectTab(privateTab)
        manager.addDelegate(delegate)

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { _ in
            // test fails if this not called
        }

        // This test makes sure that a normal tab is always added even when a normal tab is not selected when calling removeAll
        delegate.expect([didRemove, didAdd, didSelect, removeAllTabs])
        manager.removeTabsWithToast(manager.normalTabs)

        delegate.verify("Not all delegate methods were called")
    }

    func testDeletePrivateTabsOnExit() {
        Defaults[.closePrivateTabs] = true

        // create one private and one normal tab
        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab(isPrivate: true))

        XCTAssertEqual(manager.selectedTab?.isPrivate, true, "The selected tab should be the private tab")
        XCTAssertEqual(manager.privateTabs.count, 1, "There should only be one private tab")

        manager.selectTab(tab)
        XCTAssertEqual(manager.privateTabs.count, 0, "If the normal tab is selected the private tab should have been deleted")
        XCTAssertEqual(manager.normalTabs.count, 1, "The regular tab should stil be around")

        manager.selectTab(manager.addTab(isPrivate: true))
        XCTAssertEqual(manager.privateTabs.count, 1, "There should be one new private tab")
        manager.willSwitchTabMode(leavingPBM: true)
        XCTAssertEqual(manager.privateTabs.count, 0, "After willSwitchTabMode there should be no more private tabs")

        manager.selectTab(manager.addTab(isPrivate: true))
        manager.selectTab(manager.addTab(isPrivate: true))
        XCTAssertEqual(manager.privateTabs.count, 2, "Private tabs should not be deleted when another one is added")
        manager.selectTab(manager.addTab())
        XCTAssertEqual(manager.privateTabs.count, 0, "But once we add a normal tab we've switched out of private mode. Private tabs should be deleted")
        XCTAssertEqual(manager.normalTabs.count, 2, "The original normal tab and the new one should both still exist")

        Defaults[.closePrivateTabs] = false
        manager.selectTab(manager.addTab(isPrivate: true))
        manager.selectTab(tab)
        XCTAssertEqual(manager.selectedTab?.isPrivate, false, "The selected tab should not be private")
        XCTAssertEqual(manager.privateTabs.count, 1, "If the flag is false then private tabs should still exist")
    }

    func testTogglePBMDelete() {
        Defaults[.closePrivateTabs] = true

        let tab = manager.addTab()
        manager.selectTab(tab)
        manager.selectTab(manager.addTab())
        manager.selectTab(manager.addTab(isPrivate: true))

        manager.willSwitchTabMode(leavingPBM: false)
        XCTAssertEqual(manager.privateTabs.count, 1, "There should be 1 private tab")
        manager.willSwitchTabMode(leavingPBM: true)
        XCTAssertEqual(manager.privateTabs.count, 0, "There should be 0 private tab")
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

        let tab0 = addTab(false) // not visited
        let tab1 = addTab(true)
        let tab2 = addTab(true)
        let tab3 = addTab(true)
        let tab4 = addTab(false) // not visited

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

        //create the tab before adding the mock delegate. So we don't have to check delegate calls we dont care about
        (0..<10).forEach {_ in manager.addTab() }
        manager.selectTab(manager.tabs.last)
        let deleteTab = manager.tabs.last
        let newSelectedTab = manager.tabs[8]
        manager.addDelegate(delegate)

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(deleteTab, previous)
            XCTAssertEqual(next, newSelectedTab)
        }
        delegate.expect([didRemove, didSelect])
        manager.removeTabAndUpdateSelectedTab(manager.tabs.last!)

        delegate.verify("Not all delegate methods were called")
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
        XCTAssertEqual(manager.selectedTab?.isPrivate, true, "The selected tab should be the private tab")
        XCTAssertEqual(manager.privateTabs.count, 1, "There should only be one private tab")

        // switch to normal mode. Which should delete the private tabs
        manager.select(tab)

        //make sure tabs are cleared properly and indexes are reset
        XCTAssertEqual(manager.privateTabs.count, 0, "Private tab should have been deleted")

        // didSelect should still be called when switching between a nil tab
        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            XCTAssertFalse(next.isPrivate)
        }

        // make sure delegate method is actually called
        delegate.expect([didSelect])

        // select the new tab to trigger the delegate methods
        manager.selectTab(newTab)

        // check
        delegate.verify("Not all delegate methods were called")
    }

    func testDeleteFirstTab() {
        //create the tab before adding the mock delegate. So we don't have to check delegate calls we dont care about
        (0..<10).forEach {_ in manager.addTab() }
        manager.selectTab(manager.tabs.first)
        let deleteTab = manager.tabs.first
        let newSelectedTab = manager.tabs[1]
        manager.addDelegate(delegate)

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(deleteTab, previous)
            XCTAssertEqual(next, newSelectedTab)
        }
        delegate.expect([didRemove, didSelect])

        manager.removeTabAndUpdateSelectedTab(manager.tabs.first!)
        delegate.verify("Not all delegate methods were called")
    }

    func testRemoveTabRemovingLastNormalTabShouldNotSwitchToPrivateTab() {
        let tab0 = manager.addTab()
        let tab1 = manager.addTab(isPrivate: true)

        manager.selectTab(tab0)
        // select private tab, so we are in privateMode
        manager.selectTab(tab1, previous: tab0)
        // if we are able to remove normal tab this means we are no longer in private mode
        manager.removeTabAndUpdateSelectedTab(tab0)

        // manager should create new tab and select it
        XCTAssertNotEqual(manager.selectedTab, tab1)
    }

    func testRemoveAllShouldRemoveAllTabs() {

        let tab0 = manager.addTab()
        let tab1 = manager.addTab()

        manager.removeAll()
        XCTAssert(nil == manager.tabs.firstIndex(of: tab0))
        XCTAssert(nil == manager.tabs.firstIndex(of: tab1))
    }

    // Private tabs and regular tabs are in the same tabs array.
    // Make sure that when a private tab is added inbetween regular tabs it isnt accidently selected when removing a regular tab
    func testTabsIndex() {
        // We add 2 tabs. Then a private one before adding another normal tab and selecting it.
        // Make sure that when the last one is deleted we dont switch to the private tab
        let (_, _, privateOne, last) = (manager.addTab(), manager.addTab(), manager.addTab(isPrivate: true), manager.addTab())
        manager.selectTab(last)
        manager.addDelegate(delegate)

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(last, previous)
            XCTAssert(next != privateOne && !next.isPrivate)
        }
        delegate.expect([didRemove, didSelect])
        manager.removeTabAndUpdateSelectedTab(last)

        delegate.verify("Not all delegate methods were called")
    }

    func testRemoveTabAndUpdateSelectedIndexIsSelectedParentTabAfterRemoval() {

        func addTab(_ visit: Bool) -> Tab {
            let tab = manager.addTab()
            if visit {
                tab.lastExecutedTime = Date.nowMilliseconds()
            }
            return tab
        }
        let _ = addTab(false) // not visited
        let tab1 = addTab(true)
        let _ = addTab(true)
        let tab3 = addTab(true)
        let _ = addTab(false) // not visited

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

        let didSelect = MethodSpy(functionName: spyDidSelectedTabChange) { tabs in
            let next = tabs[0]!
            let previous = tabs[1]!
            XCTAssertEqual(deleted, previous)
            XCTAssertEqual(next, newSelected)
        }
        delegate.expect([didRemove, didSelect])
        manager.removeTabAndUpdateSelectedTab(manager.tabs.first!)
        delegate.verify("Not all delegate methods were called")
    }

    func testUndoCloseTabsRemovesAutomaticallyCreatedNonPrivateTab() {
        let tab = manager.addTab()
        let tabToSave = Tab(bvc: BrowserViewController.foregroundBVC(), configuration: WKWebViewConfiguration())
        tabToSave.sessionData = SessionData(currentPage: 0, urls: [URL(string: "url")!], lastUsedTime: Date.nowMilliseconds())

        manager.removeTabs([tab])
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

        manager.removeTabs([tab1, tab2])
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

        manager.removeTabs([tab1, tab2])
        manager.restoreAllClosedTabs()

        let _ = MethodSpy(functionName: spyRestoredTabs) { tabs in
            XCTAssertEqual(tabs.count, 2)
            XCTAssertNil(tabs.first??.parentUUID)
            XCTAssertEqual(tabs.last??.parentUUID, initialParentUUID)
            XCTAssertEqual(tabs.last??.parent, tabs.first)
        }
    }
}
