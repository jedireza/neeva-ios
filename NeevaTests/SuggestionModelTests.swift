// Copyright Neeva. All rights reserved.

import Shared
import Storage
import UIKit
import WebKit
import XCTest

@testable import Client

class SuggestionModelTests: XCTestCase {
    var profile: MockProfile!

    static let sampleQuerySuggestion = SuggestionsQuery.Data.Suggest.QuerySuggestion(
        type: .standard,
        suggestedQuery: "neeva",
        boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
        source: .bing
    )
    static let sampleCalculatorQuerySuggestion = SuggestionsQuery.Data.Suggest.QuerySuggestion(
        type: .standard,
        suggestedQuery: "5+5",
        boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
        source: .calculator,
        annotation: .init(annotationType: "Calculator", description: "10")
    )
    static let sampleQuery = Suggestion.query(sampleQuerySuggestion)

    static let sampleQuerySuggestion2 = SuggestionsQuery.Data.Suggest.QuerySuggestion(
        type: .standard,
        suggestedQuery: "neeva2",
        boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
        source: .bing
    )

    static let sampleQuery2 = Suggestion.query(sampleQuerySuggestion2)
    static let sampleCalculatorQuery = Suggestion.query(sampleCalculatorQuerySuggestion)
    static let sampleURLSuggestion = SuggestionsQuery.Data.Suggest.UrlSuggestion(
        icon: .init(labels: ["google-email", "email"]),
        suggestedUrl: "https://mail.google.com/mail/u/jed@neeva.co/#inbox/1766c8357ae540a5",
        title: "How was your Neeva onboarding?",
        author: "feedback@neeva.co",
        timestamp: "2020-12-16T17:05:12Z",
        boldSpan: [.init(startInclusive: 13, endExclusive: 29)]
    )
    static let sampleURL = Suggestion.url(sampleURLSuggestion)
    static let sampleNavUrlSuggestion = SuggestionsQuery.Data.Suggest.UrlSuggestion(
        icon: .init(labels: [""]),
        suggestedUrl: "https://neeva.com",
        title: "neeva.com",
        subtitle: "Neeva Search",
        boldSpan: [.init(startInclusive: 0, endExclusive: 0)]
    )
    static let sampleNavURL = Suggestion.url(sampleNavUrlSuggestion)
    static let sampleNav = NavSuggestion(url: "https://neeva.com", title: "Neeva")
    static let sampleNavSuggestion = Suggestion.navigation(sampleNav)
    static let sampleSite = Site(url: "https://neeva.com", title: "Neeva")

    override func setUp() {
        super.setUp()
        self.profile = MockProfile()
    }

    override func tearDown() {
        self.profile._shutdown()
        super.tearDown()
    }

    func testSuggestionSnapshot() {
        let site = Site(url: "https://neeva.com2", title: "Neeva2")

        let model = SuggestionModel(
            bvc: SceneDelegate.getBVC(for: nil),
            previewSites: [site],
            previewLensBang: nil,
            topSuggestions: [SuggestionModelTests.sampleNavURL],
            chipQuerySuggestions: [
                SuggestionModelTests.sampleQuery,
                SuggestionModelTests.sampleQuery2,
            ],
            rowQuerySuggestions: [
                SuggestionModelTests.sampleQuery2,
                SuggestionModelTests.sampleCalculatorQuery,
            ])

        model.navSuggestions = [SuggestionModelTests.sampleNavURL]
        model.urlSuggestions = [SuggestionModelTests.sampleURL]

        let attributes = model.suggestionSnapshotAttributes()

        XCTAssertNotNil(attributes)

        XCTAssertEqual(attributes.count, 14)

        let expectedResult =
            [
                LogConfig.SuggestionAttribute.numberOfChipSuggestions: "2",
                LogConfig.SuggestionAttribute.numberOfMemorizedSuggestions: "2",
                LogConfig.SuggestionAttribute.numberOfHistorySuggestions: "1",
                LogConfig.SuggestionAttribute.numberOfPersonalSuggestions: "1",
                LogConfig.SuggestionAttribute.numberOfCalculatorAnnotations: "1",
                LogConfig.SuggestionAttribute.numberOfWikiAnnotations: "0",
                LogConfig.SuggestionAttribute.numberOfStockAnnotations: "0",
                LogConfig.SuggestionAttribute.suggestionTypePosition + "0":
                    SuggestionModel.SuggestionLoggingType.memorizedSuggestion.rawValue,
                LogConfig.SuggestionAttribute.suggestionTypePosition + "1":
                    SuggestionModel.SuggestionLoggingType.chipSuggestion.rawValue,
                LogConfig.SuggestionAttribute.suggestionTypePosition + "2":
                    SuggestionModel.SuggestionLoggingType.rowQuerySuggestion.rawValue,
                LogConfig.SuggestionAttribute.suggestionTypePosition + "3":
                    SuggestionModel.SuggestionLoggingType.rowQuerySuggestion.rawValue,
                LogConfig.SuggestionAttribute.annotationTypeAtPosition + "3":
                    "Calculator",
                LogConfig.SuggestionAttribute.suggestionTypePosition + "4":
                    SuggestionModel.SuggestionLoggingType.personalSuggestion.rawValue,
                LogConfig.SuggestionAttribute.suggestionTypePosition + "5":
                    SuggestionModel.SuggestionLoggingType.memorizedSuggestion.rawValue,
            ]

        for attribute in attributes {
            guard let attributeKey = attribute.key else {
                XCTAssertNotNil(attribute.key!)
                return
            }
            XCTAssertNotNil(expectedResult[attributeKey ?? ""])
            if let expectedValue = expectedResult[attributeKey ?? ""] {
                XCTAssertEqual(attribute.value, expectedValue)
            } else {
                XCTAssertNotNil(expectedResult[attributeKey ?? ""])
            }
        }
    }

}
