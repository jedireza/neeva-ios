// Copyright Neeva. All rights reserved.

import XCTest
@testable import Client
import ViewInspector
import Shared
import SwiftUI
import SFSafeSymbols
import Storage

extension SuggestionsList: Inspectable { }
extension SearchSuggestionView: Inspectable { }
extension QuerySuggestionView: Inspectable { }
extension URLSuggestionView: Inspectable { }
extension HistorySuggestionView: Inspectable { }
extension SuggestionRow: Inspectable { }
extension Symbol: Inspectable { }
extension BoldSpanView: Inspectable { }

class SuggestionViewsTests: XCTestCase {
    static let sampleQuerySuggestion = SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .standard,
            suggestedQuery: "neeva",
            boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
            source: .bing
        )
    static let sampleQuery = Suggestion.query(sampleQuerySuggestion)
    static let sampleURLSuggestion = SuggestionsQuery.Data.Suggest.UrlSuggestion(
        icon: .init(labels: ["google-email", "email"]),
        suggestedUrl: "https://mail.google.com/mail/u/jed@neeva.co/#inbox/1766c8357ae540a5",
        title: "How was your Neeva onboarding?",
        author: "feedback@neeva.co",
        timestamp: "2020-12-16T17:05:12Z",
        boldSpan: [.init(startInclusive: 13, endExclusive: 29)]
    )
    static let sampleURL = Suggestion.url(sampleURLSuggestion)
    static let sampleNavSuggestion = SuggestionsQuery.Data.Suggest.UrlSuggestion(
        icon: .init(labels: [""]),
        suggestedUrl: "https://neeva.com",
        title: "neeva.com",
        subtitle: "Neeva Search",
        boldSpan: [.init(startInclusive: 0, endExclusive: 0)]
    )
    static let sampleNav = Suggestion.url(sampleNavSuggestion)
    static let sampleSite = Site(url: "https://neeva.com", title: "Neeva")

    func testQuerySuggestion() throws {
        let model = NeevaSuggestionModel(previewLensBang: nil,
                                         suggestions: [SuggestionViewsTests.sampleQuery])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleQuery)
        let query = try suggestionView.inspect().find(QuerySuggestionView.self).actualView()
        XCTAssertNotNil(query)
        let querySuggestion =
            QuerySuggestionView(suggestion:
                                    SuggestionViewsTests.sampleQuerySuggestion).environmentObject(model)
        let hStack = try querySuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)
        let image = try hStack.find(Symbol.self).group().image(0).actualImage()
        XCTAssertEqual(image,
                       Image(systemName: SFSymbol.magnifyingglass.rawValue).renderingMode(.template))
        let label = try hStack.find(BoldSpanView.self).text().string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva", label)
    }

    func testURLSuggestion() throws {
        let model = NeevaSuggestionModel(previewLensBang: nil,
                                         suggestions: [SuggestionViewsTests.sampleURL])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleURL)
        let url = try suggestionView.inspect().find(URLSuggestionView.self).actualView()
        XCTAssertNotNil(url)
        let urlSuggestion = URLSuggestionView(suggestion:
                                    SuggestionViewsTests.sampleURLSuggestion).environmentObject(model)
        let hStack = try urlSuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)
        let label = try hStack.find(BoldSpanView.self).text().string(locale: Locale(identifier: "en"))
        XCTAssertEqual("How was your Neeva onboarding?", label)
    }

    func testNavSuggestion() throws {
        let model = NeevaSuggestionModel(previewLensBang: nil,
                                         suggestions: [SuggestionViewsTests.sampleNav])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleNav)
        let nav = try suggestionView.inspect().find(URLSuggestionView.self).actualView()
        XCTAssertNotNil(nav)
        let navSuggestion = URLSuggestionView(suggestion:
                                    SuggestionViewsTests.sampleNavSuggestion).environmentObject(model)
        let hStack = try navSuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)
        let label = try hStack.vStack(1).text(0).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva Search", label)
        let secondaryLabel = try hStack.vStack(1).text(1).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel)
    }

    func testHistorySuggestion() throws {
        let historySuggestion = HistorySuggestionView(site: SuggestionViewsTests.sampleSite)
        let hStack = try historySuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)
        let label = try hStack.vStack(1).text(0).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva", label)
        let secondaryLabel = try hStack.vStack(1).text(1).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel)
    }

    func testSuggestionsList() throws {
        let neevaModel = NeevaSuggestionModel(previewLensBang: nil,
                                              suggestions: [SuggestionViewsTests.sampleNav,
                                                            SuggestionViewsTests.sampleQuery])
        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite])
        let suggestionList = SuggestionsList().environmentObject(historyModel)
            .environmentObject(neevaModel)
        let hStacks = try suggestionList.inspect().findAll(ViewType.HStack.self)
        XCTAssertNotNil(hStacks)
        XCTAssertEqual(3, hStacks.count)
        let label0 = try hStacks[0].vStack(1).text(0).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva Search", label0)
        let secondaryLabel0 = try hStacks[0].vStack(1).text(1).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel0)
        let label1 = try hStacks[1].vStack(1)
            .find(BoldSpanView.self).text().string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva", label1)
        let label2 = try hStacks[2].vStack(1).text(0).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva", label2)
        let secondaryLabel2 = try hStacks[2].vStack(1).text(1).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel2)
    }

    func testSuggestionsListNoNeevaSuggestions() throws {
        let neevaModel = NeevaSuggestionModel(searchQueryForTesting: "query", previewLensBang: nil,
                                              suggestions: [])

        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite])
        let suggestionList = SuggestionsList().environmentObject(historyModel)
            .environmentObject(neevaModel)
        let list = try suggestionList.inspect().find(ViewType.List.self)
        XCTAssertNotNil(list)

        // We should be showing a placeholder with 1 history suggestion and 5 query suggestions
        XCTAssertEqual(2, list.count)
        XCTAssertNotNil(try list.tupleView(0).find(HistorySuggestionView.self))
        XCTAssertEqual(5, try list.tupleView(0).forEach(1).count)
    }

    func testSuggestionsListNoNeevaSuggestionsForIncognito() throws {
        let neevaModel = NeevaSuggestionModel(isIncognito: true, previewLensBang: nil,
                                              suggestions: [])
        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite])
        let suggestionList = SuggestionsList().environmentObject(historyModel)
            .environmentObject(neevaModel)
        let hStacks = try suggestionList.inspect().findAll(ViewType.HStack.self)
        XCTAssertNotNil(hStacks)

        // We should not be showing placeholder suggestions
        XCTAssertEqual(1, hStacks.count)
        let label0 = try hStacks[0].vStack(1).text(0).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva", label0)
        let secondaryLabel0 = try hStacks[0].vStack(1).text(1).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel0)
    }
}
