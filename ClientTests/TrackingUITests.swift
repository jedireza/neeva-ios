// Copyright Neeva. All rights reserved.

import XCTest
@testable import Client
import ViewInspector
import Shared
import SwiftUI

extension TrackingMenuView: Inspectable { }
extension TrackingMenuFirstRowElement: Inspectable { }
extension HallOfShameElement: Inspectable { }
extension HallOfShameView: Inspectable { }
extension Kern: Inspectable { }
extension Text: Inspectable { }

class TrackingUITests: XCTestCase {
    let domainsGoogle = ["1emn.com",
                         "2mdn.net",
        "admeld.com", "admeld.com", "admeld.com", "admeld.com", "admeld.com",
        "admob.com", "admob.com", "admob.com", "admob.com", "admob.com", "admob.com", "admob.com",
        "app-measurement.com"]
    let domainsAmazon = ["alexa.com", "alexa.com", "alexa.com", "alexa.com",
        "alexametrics.com",
        "amazon-adsystem.com",
        "assoc-amazon.com",
        "assoc-amazon.jp"]
    let domainsOutbrain = ["ligatus.com", "outbrain.com", "veeseo.com", "zemanta.com"]
    let domainsUnknownSource = ["unknown.com", "random.com"]

    var stats: TPPageStats = TPPageStats()
    var trackingData: TrackingData!
    var expectedEntities: [TrackingEntity]!
    var model: TrackingStatsViewModel!

    override func setUp() {
        super.setUp()

        domainsGoogle.forEach {stats = stats.create(matchingBlocklist: .neeva, host: $0)}
        domainsAmazon.forEach {stats = stats.create(matchingBlocklist: .neeva, host: $0)}
        domainsOutbrain.forEach {stats = stats.create(matchingBlocklist: .neeva, host: $0)}
        domainsUnknownSource.forEach {stats = stats.create(matchingBlocklist: .neeva, host: $0)}

        expectedEntities = Array.init(repeating: TrackingEntity.Google, count: domainsGoogle.count)
        + Array.init(repeating: TrackingEntity.Amazon, count: domainsAmazon.count)
        + Array.init(repeating: TrackingEntity.Outbrain, count: domainsOutbrain.count)
        trackingData = TrackingEntity.getTrackingDataForCurrentTab(stats: stats)
    }

    func testTrackingEntity() throws {
        XCTAssertEqual(trackingData.numTrackers,
                       (domainsOutbrain + domainsGoogle + domainsAmazon + domainsUnknownSource).count)
        XCTAssertEqual(trackingData.numDomains, 16)
        XCTAssertEqual(trackingData.trackingEntities, expectedEntities)
    }

    func testTrackingStatsViewModel() throws {
        model = TrackingStatsViewModel(trackingData: trackingData)
        XCTAssertEqual(model.numTrackers,
                       (domainsOutbrain + domainsGoogle + domainsAmazon + domainsUnknownSource).count)
        XCTAssertEqual(model.numDomains, 16)
        XCTAssertEqual(model.trackers, expectedEntities)

        XCTAssertEqual(model.hallOfShameDomains.count, 3)
        XCTAssertEqual(model.hallOfShameDomains[0].key, TrackingEntity.Google)
        XCTAssertEqual(model.hallOfShameDomains[0].value, 15)
        XCTAssertEqual(model.hallOfShameDomains[1].key, TrackingEntity.Amazon)
        XCTAssertEqual(model.hallOfShameDomains[1].value, 8)
        XCTAssertEqual(model.hallOfShameDomains[2].key, TrackingEntity.Outbrain)
        XCTAssertEqual(model.hallOfShameDomains[2].value, 4)
    }

    func testTrackingStatsViewModelTwoEntities() throws {
        var tempStats = TPPageStats()
        domainsGoogle.forEach {tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)}
        domainsAmazon.forEach {tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)}
        domainsUnknownSource.forEach {tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)}

        let tempData = TrackingEntity.getTrackingDataForCurrentTab(stats: tempStats)
        model = TrackingStatsViewModel(trackingData: tempData)
        XCTAssertEqual(model.numTrackers,
                       (domainsGoogle + domainsAmazon + domainsUnknownSource).count)
        XCTAssertEqual(model.numDomains, 12)

        XCTAssertEqual(model.hallOfShameDomains.count, 2)
        XCTAssertEqual(model.hallOfShameDomains[0].key, TrackingEntity.Google)
        XCTAssertEqual(model.hallOfShameDomains[0].value, 15)
        XCTAssertEqual(model.hallOfShameDomains[1].key, TrackingEntity.Amazon)
        XCTAssertEqual(model.hallOfShameDomains[1].value, 8)
    }

    func testTrackingUIFirstRow() throws {
        TrackingEntity.statsForTesting = stats
        let ui = TrackingMenuView()
        let firstRowElements = try ui.inspect().findAll(TrackingMenuFirstRowElement.self)
        XCTAssertEqual(firstRowElements.count, 2)

        XCTAssertEqual(try firstRowElements[0].findAll(Kern.self)[1].text()
                        .string(locale: Locale(identifier: "en")), "29")
        XCTAssertEqual(try firstRowElements[1].findAll(Kern.self)[1].text()
                        .string(locale: Locale(identifier: "en")), "16")
    }

    func testTrackingHallOfShame() throws {
        TrackingEntity.statsForTesting = stats
        let ui = TrackingMenuView()
        let hallOfShameElements = try ui.inspect().findAll(HallOfShameElement.self)
        XCTAssertEqual(hallOfShameElements.count, 3)

        XCTAssertEqual(try hallOfShameElements[0].find(Kern.self).text()
                        .string(locale: Locale(identifier: "en")), "15")
        XCTAssertEqual(try hallOfShameElements[1].find(Kern.self).text()
                        .string(locale: Locale(identifier: "en")), "8")
        XCTAssertEqual(try hallOfShameElements[2].find(Kern.self).text()
                        .string(locale: Locale(identifier: "en")), "4")
    }

    func testTrackingHallOfShameTwoEntities() throws {
        var tempStats = TPPageStats()
        domainsGoogle.forEach {tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)}
        domainsAmazon.forEach {tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)}
        domainsUnknownSource.forEach {tempStats = tempStats.create(matchingBlocklist: .neeva, host: $0)}
        TrackingEntity.statsForTesting = tempStats
        let ui = TrackingMenuView()
        let hallOfShameElements = try ui.inspect().findAll(HallOfShameElement.self)
        XCTAssertEqual(hallOfShameElements.count, 2)

        XCTAssertEqual(try hallOfShameElements[0].find(Kern.self).text()
                        .string(locale: Locale(identifier: "en")), "15")
        XCTAssertEqual(try hallOfShameElements[1].find(Kern.self).text()
                        .string(locale: Locale(identifier: "en")), "8")
    }
}
