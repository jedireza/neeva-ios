/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage
import UIKit
import ViewInspector
import XCTest

@testable import Client

extension TabContentHost.Content: Inspectable {}
extension WebViewContainer: Inspectable {}
extension ZeroQueryContent: Inspectable {}
extension ZeroQueryView: Inspectable {}

class ZeroQueryTests: XCTestCase {
    var profile: MockProfile!
    var zQM: ZeroQueryModel!
    var ssm = SuggestedSearchesModel(suggestedQueries: [])
    var tabManager: TabManager!
    var tabContentHost: TabContentHost!

    override func setUp() {
        super.setUp()
        self.profile = MockProfile()
        self.zQM = ZeroQueryModel(profile: self.profile, shareURLHandler: { _ in })
        self.tabManager = TabManager(profile: profile, imageStore: nil)
        self.tabContentHost = TabContentHost(tabManager: tabManager, zeroQueryModel: zQM)
    }

    override func tearDown() {
        self.profile._shutdown()
        super.tearDown()
    }

    func testZeroQueryInsideContentHost() throws {
        let tab = tabManager.addTab()
        tab.loadRequest(URLRequest(url: .aboutBlank))
        tabManager.selectTab(tab)
        waitForCondition(condition: { tabContentHost.rootView.webView != nil })
        var webviewContainer: WebViewContainer? =
            try tabContentHost.rootView.inspect().zStack().view(WebViewContainer.self, 0)
            .actualView()
        XCTAssertNotNil(webviewContainer)
        zQM.isHidden = false
        var zeroQuery =
            try tabContentHost.rootView.inspect().zStack().last?.find(ZeroQueryView.self)
        XCTAssertNotNil(zeroQuery)
        do {
            let _ = try tabContentHost.rootView.inspect().find(WebViewContainer.self).actualView()
        } catch {
            webviewContainer = nil
        }
        XCTAssertNil(webviewContainer)

        zQM.isHidden = true
        do {
            let _ = try tabContentHost.rootView.inspect().zStack().last?.find(ZeroQueryView.self)
        } catch {
            zeroQuery = nil
        }
        XCTAssertNil(zeroQuery)
    }

    func testLazyTabPromotion() throws {
        let tab = tabManager.addTab()
        tabManager.selectTab(tab)
        tab.loadRequest(URLRequest(url: .aboutBlank))
        let webviewContainer = try tabContentHost.rootView.inspect().find(WebViewContainer.self)
        XCTAssertNotNil(webviewContainer)
        zQM.isLazyTab = true
        zQM.openedFrom = .tabTray
        zQM.isHidden = false
        var zeroQuery =
            try tabContentHost.rootView.inspect().zStack().last?.find(ZeroQueryView.self)
        XCTAssertNotNil(zeroQuery)
        zQM.promoteToRealTabIfNecessary(url: .aboutBlank, tabManager: tabManager)
        waitForCondition(condition: { tabManager.tabs.count == 2 })
        do {
            let _ = try tabContentHost.rootView.inspect().zStack().last?.find(ZeroQueryView.self)
        } catch {
            zeroQuery = nil
        }
        XCTAssertNil(zeroQuery)
        XCTAssertNil(zQM.openedFrom)
    }

    func testLazyTabCancel() throws {
        let tab = tabManager.addTab()
        tabManager.selectTab(tab)
        tab.loadRequest(URLRequest(url: .aboutBlank))
        let webviewContainer = try tabContentHost.rootView.inspect().find(WebViewContainer.self)
        XCTAssertNotNil(webviewContainer)
        zQM.isLazyTab = true
        zQM.openedFrom = .tabTray
        zQM.isHidden = false
        var zeroQuery =
            try tabContentHost.rootView.inspect().zStack().last?.find(ZeroQueryView.self)
        XCTAssertNotNil(zeroQuery)
        zQM.reset()
        do {
            let _ = try tabContentHost.rootView.inspect().zStack().last?.find(ZeroQueryView.self)
        } catch {
            zeroQuery = nil
        }
        XCTAssertNil(zeroQuery)
        XCTAssertNil(zQM.openedFrom)
    }

    func testDeletionOfSingleSuggestedSite() {
        let siteToDelete = TopSitesHandler.defaultTopSites()[0]

        zQM.hideURLFromTopSites(siteToDelete)
        let newSites = TopSitesHandler.defaultTopSites()

        XCTAssertNil(newSites.first { $0.url == siteToDelete.url })
    }

    func testDeletionOfAllDefaultSites() {
        let defaultSites = TopSitesHandler.defaultTopSites()
        defaultSites.forEach({
            zQM.hideURLFromTopSites($0)
        })

        let newSites = TopSitesHandler.defaultTopSites()
        XCTAssertTrue(newSites.isEmpty)
    }

    func testZeroQueryModelSuggestedSite() {
        let getSitesExpectation = expectation(description: "reload profile")

        let mostFrecentSite =
            Site(
                url: "https://www.neeva.com/search?q=mostFrecentSite&src=nvobar",
                title: "mostFrecentSite")
        let mostFrecentSiteVisit1 = SiteVisit(
            site: mostFrecentSite,
            date: Date.nowMicroseconds() + 1000,
            type: VisitType.link)
        let mostFrecentSiteVisit2 = SiteVisit(
            site: mostFrecentSite,
            date: Date.nowMicroseconds() + 2000,
            type: VisitType.link)
        let mostFrecentSiteVisit3 = SiteVisit(
            site: mostFrecentSite,
            date: Date.nowMicroseconds() + 3000,
            type: VisitType.link)

        let mostRecentSite =
            Site(
                url: "https://www.neeva.com/search?q=mostRecentSite&src=nvobar",
                title: "mostRecentSite")
        let mostRecentSiteVisit = SiteVisit(
            site: mostRecentSite,
            date: Date.nowMicroseconds() + 6000,
            type: VisitType.link)

        let secondMostRecentSite =
            Site(
                url: "https://www.neeva.com/search?q=secondMostRecentSite&src=nvobar",
                title: "secondMostRecentSite")
        let secondMostRecentSiteVisit = SiteVisit(
            site: secondMostRecentSite,
            date: Date.nowMicroseconds() + 5000,
            type: VisitType.link)

        let thirdMostRecentSite =
            Site(
                url: "https://www.neeva.com/search?q=thirdMostRecentSite&src=nvobar",
                title: "thirdMostRecentSite")
        let thirdMostRecentSiteVisit = SiteVisit(
            site: thirdMostRecentSite,
            date: Date.nowMicroseconds() + 4000,
            type: VisitType.link)

        let expectation = self.expectation(description: "First.")
        func done() -> Success {
            expectation.fulfill()
            return succeed()
        }
        profile.history.clearHistory()
            >>> { self.profile.history.addLocalVisit(secondMostRecentSiteVisit) }
            >>> { self.profile.history.addLocalVisit(mostRecentSiteVisit) }
            >>> { self.profile.history.addLocalVisit(mostFrecentSiteVisit1) }
            >>> { self.profile.history.addLocalVisit(thirdMostRecentSiteVisit) }
            >>> { self.profile.history.addLocalVisit(mostFrecentSiteVisit2) }
            >>> { self.profile.history.addLocalVisit(mostFrecentSiteVisit3) }
            >>> { done() }

        let _ = XCTWaiter().wait(for: [expectation], timeout: 100)

        ssm.reload(from: profile) {
            XCTAssertEqual(self.ssm.suggestedQueries.count, 4)
            XCTAssertEqual(
                self.ssm.suggestedQueries[0].site.url.absoluteURL,
                mostFrecentSite.url.absoluteURL)
            XCTAssertEqual(
                self.ssm.suggestedQueries[1].site.url.absoluteURL,
                mostRecentSite.url.absoluteURL)
            XCTAssertEqual(
                self.ssm.suggestedQueries[2].site.url.absoluteURL,
                secondMostRecentSite.url.absoluteURL)
            XCTAssertEqual(
                self.ssm.suggestedQueries[3].site.url.absoluteURL,
                thirdMostRecentSite.url.absoluteURL)
            getSitesExpectation.fulfill()
        }

        let _ = XCTWaiter().wait(for: [getSitesExpectation], timeout: 100)
    }
}

private class MockTopSitesHistory: MockableHistory {
    let mockTopSites: [Site]

    init(sites: [Site]) {
        mockTopSites = sites
    }

    override func getTopSitesWithLimit(_ limit: Int) -> Deferred<Maybe<Cursor<Site?>>> {
        return deferMaybe(ArrayCursor(data: mockTopSites))
    }

    override func getPinnedTopSites() -> Deferred<Maybe<Cursor<Site?>>> {
        return deferMaybe(ArrayCursor(data: []))
    }

    override func updateTopSitesCacheIfInvalidated() -> Deferred<Maybe<Bool>> {
        return deferMaybe(true)
    }
}
