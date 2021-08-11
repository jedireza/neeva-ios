// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI
import ViewInspector
import XCTest

@testable import Client

extension TrackingMenuView: Inspectable {}
extension TrackingMenuFirstRowElement: Inspectable {}
extension HallOfShameElement: Inspectable {}
extension HallOfShameView: Inspectable {}
extension TrackingMenuProtectionRowButton: Inspectable {}
extension Text: Inspectable {}
extension Toggle: Inspectable {}
extension GroupedStack: Inspectable {}
extension GroupedCell: Inspectable {}
extension GroupedCellButton: Inspectable {}
extension GroupedCell.Decoration: Inspectable {}
extension GroupedCell.ContentContainer: Inspectable {}

class TrackingUITests: XCTestCase {
    let domainsGoogle = [
        "1emn.com",
        "2mdn.net",
        "admeld.com", "admeld.com", "admeld.com", "admeld.com", "admeld.com",
        "admob.com", "admob.com", "admob.com", "admob.com", "admob.com", "admob.com", "admob.com",
        "app-measurement.com",
    ]
    let domainsAmazon = [
        "alexa.com", "alexa.com", "alexa.com", "alexa.com",
        "alexametrics.com",
        "amazon-adsystem.com",
        "assoc-amazon.com",
        "assoc-amazon.jp",
    ]
    let domainsOutbrain = ["ligatus.com", "outbrain.com", "veeseo.com", "zemanta.com"]
    let domainsUnknownSource = ["unknown.com", "random.com"]

    var stats: TPPageStats = TPPageStats()
    var trackingData: TrackingData!
    var expectedEntities: [TrackingEntity]!
    var model: TrackingStatsViewModel!

    override func setUp() {
        super.setUp()

        domainsGoogle.forEach { stats = stats.create(matchingBlocklist: .neeva, host: $0) }
        domainsAmazon.forEach { stats = stats.create(matchingBlocklist: .neeva, host: $0) }
        domainsOutbrain.forEach { stats = stats.create(matchingBlocklist: .neeva, host: $0) }
        domainsUnknownSource.forEach { stats = stats.create(matchingBlocklist: .neeva, host: $0) }

        expectedEntities =
            Array.init(repeating: TrackingEntity.Google, count: domainsGoogle.count)
            + Array.init(repeating: TrackingEntity.Amazon, count: domainsAmazon.count)
            + Array.init(repeating: TrackingEntity.Outbrain, count: domainsOutbrain.count)
        trackingData = TrackingEntity.getTrackingDataForCurrentTab(stats: stats)
    }

    func testTrackingEntity() throws {
        XCTAssertEqual(
            trackingData.numTrackers,
            (domainsOutbrain + domainsGoogle + domainsAmazon + domainsUnknownSource).count)
        XCTAssertEqual(trackingData.numDomains, 16)
        XCTAssertEqual(trackingData.trackingEntities, expectedEntities)
    }

    func testTrackingStatsViewModel() throws {
        model = TrackingStatsViewModel(testingData: trackingData)
        XCTAssertEqual(
            model.numTrackers,
            (domainsOutbrain + domainsGoogle + domainsAmazon + domainsUnknownSource).count)
        XCTAssertEqual(model.numDomains, 16)
        XCTAssertEqual(model.trackers, expectedEntities)

        XCTAssertEqual(model.hallOfShameDomains.count, 3)
        XCTAssertEqual(model.hallOfShameDomains[0].domain, TrackingEntity.Google)
        XCTAssertEqual(model.hallOfShameDomains[0].count, 15)
        XCTAssertEqual(model.hallOfShameDomains[1].domain, TrackingEntity.Amazon)
        XCTAssertEqual(model.hallOfShameDomains[1].count, 8)
        XCTAssertEqual(model.hallOfShameDomains[2].domain, TrackingEntity.Outbrain)
        XCTAssertEqual(model.hallOfShameDomains[2].count, 4)
    }

    func testTrackingStatsViewModelTwoEntities() throws {
        var tempStats = TPPageStats()
        domainsGoogle.forEach { tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0) }
        domainsAmazon.forEach { tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0) }
        domainsUnknownSource.forEach {
            tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)
        }

        let tempData = TrackingEntity.getTrackingDataForCurrentTab(stats: tempStats)
        model = TrackingStatsViewModel(testingData: tempData)
        XCTAssertEqual(
            model.numTrackers,
            (domainsGoogle + domainsAmazon + domainsUnknownSource).count)
        XCTAssertEqual(model.numDomains, 12)

        XCTAssertEqual(model.hallOfShameDomains.count, 2)
        XCTAssertEqual(model.hallOfShameDomains[0].domain, TrackingEntity.Google)
        XCTAssertEqual(model.hallOfShameDomains[0].count, 15)
        XCTAssertEqual(model.hallOfShameDomains[1].domain, TrackingEntity.Amazon)
        XCTAssertEqual(model.hallOfShameDomains[1].count, 8)
    }

    func testTrackingUIFirstRow() throws {
        let ui = TrackingMenuView().environmentObject(
            TrackingStatsViewModel(testingData: trackingData))
        let firstRowElements = try ui.inspect().findAll(TrackingMenuFirstRowElement.self)
        XCTAssertEqual(firstRowElements.count, 2)

        XCTAssertEqual(
            try firstRowElements[0].findAll(Kern.self)[1].text()
                .string(locale: Locale(identifier: "en")), "29")
        XCTAssertEqual(
            try firstRowElements[1].findAll(Kern.self)[1].text()
                .string(locale: Locale(identifier: "en")), "16")
    }

    func testTrackingHallOfShame() throws {
        let ui = TrackingMenuView().environmentObject(
            TrackingStatsViewModel(testingData: trackingData))
        let hallOfShameElements = try ui.inspect().findAll(HallOfShameElement.self)
        XCTAssertEqual(hallOfShameElements.count, 3)

        XCTAssertEqual(
            try hallOfShameElements[0].find(Kern.self).text()
                .string(locale: Locale(identifier: "en")), "15")
        XCTAssertEqual(
            try hallOfShameElements[1].find(Kern.self).text()
                .string(locale: Locale(identifier: "en")), "8")
        XCTAssertEqual(
            try hallOfShameElements[2].find(Kern.self).text()
                .string(locale: Locale(identifier: "en")), "4")
    }

    func testTrackingHallOfShameTwoEntities() throws {
        var tempStats = TPPageStats()
        domainsGoogle.forEach { tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0) }
        domainsAmazon.forEach { tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0) }
        domainsUnknownSource.forEach {
            tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)
        }
        let ui = TrackingMenuView().environmentObject(
            TrackingStatsViewModel(
                testingData:
                    TrackingEntity.getTrackingDataForCurrentTab(stats: tempStats)))
        let hallOfShameElements = try ui.inspect().findAll(HallOfShameElement.self)
        XCTAssertEqual(hallOfShameElements.count, 2)

        XCTAssertEqual(
            try hallOfShameElements[0].find(Kern.self).text()
                .string(locale: Locale(identifier: "en")), "15")
        XCTAssertEqual(
            try hallOfShameElements[1].find(Kern.self).text()
                .string(locale: Locale(identifier: "en")), "8")
    }

    func testToggleInModel() throws {
        let profile = TabManagerMockProfile()
        let manager = TabManager(profile: profile, imageStore: nil)
        let tab = manager.addTab()
        manager.selectTab(tab)
        tab.setURL("https://neeva.com")
        model = TrackingStatsViewModel(tabManager: manager)
        model.preventTrackersForCurrentPage = false
        XCTAssertTrue(Defaults[.unblockedDomains].contains("neeva.com"))
        model.preventTrackersForCurrentPage = true
        XCTAssertFalse(Defaults[.unblockedDomains].contains("neeva.com"))
    }

    func testToggleInUI() throws {
        let profile = TabManagerMockProfile()
        let manager = TabManager(profile: profile, imageStore: nil)
        let tab = manager.addTab()
        manager.selectTab(tab)
        tab.setURL("https://neeva.com")
        model = TrackingStatsViewModel(tabManager: manager)
        let ui = TrackingMenuView().environmentObject(model)
        let rowButton = try ui.inspect().find(TrackingMenuProtectionRowButton.self).actualView()
        XCTAssertNotNil(rowButton)
        let toggle = try rowButton.inspect().find(ViewType.Toggle.self)
        XCTAssertNotNil(toggle)
        rowButton.preventTrackers = false
        XCTAssertTrue(Defaults[.unblockedDomains].contains("neeva.com"))
        XCTAssertFalse(try toggle.isOn())
        rowButton.preventTrackers = true
        XCTAssertFalse(Defaults[.unblockedDomains].contains("neeva.com"))
        XCTAssertTrue(try toggle.isOn())
    }
}
