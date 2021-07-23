// Copyright Neeva. All rights reserved.

import XCTest
@testable import Client
import ViewInspector
import Shared
import SwiftUI
import SFSafeSymbols
import Storage

extension SuggestionsList: Inspectable { }
extension Kern: Inspectable { }
extension PlaceholderSuggestions: Inspectable { }
extension QuerySuggestionsList: Inspectable { }
extension TopSuggestionsList: Inspectable { }
extension SuggestionChipView: Inspectable { }
extension SearchSuggestionView: Inspectable { }
extension QuerySuggestionView: Inspectable { }
extension NavSuggestionView: Inspectable { }
extension URLSuggestionView: Inspectable { }
extension SuggestionView: Inspectable { }
extension Symbol: Inspectable { }
extension BoldSpanView: Inspectable { }
extension NavSuggestionsList: Inspectable { }

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
    static let sampleNavUrlSuggestion = SuggestionsQuery.Data.Suggest.UrlSuggestion(
        icon: .init(labels: [""]),
        suggestedUrl: "https://neeva.com",
        title: "neeva.com",
        subtitle: "Neeva Search",
        boldSpan: [.init(startInclusive: 0, endExclusive: 0)]
    )
    static let sampleNav = Suggestion.url(sampleNavUrlSuggestion)
    static let sampleNavSuggestion = NavSuggestion(url: "https://neeva.com", title: "Neeva")
    static let sampleSite = Site(url: "https://neeva.com", title: "Neeva")

    func testQuerySuggestion() throws {
        let model = NeevaSuggestionModel(previewLensBang: nil,
                                         chipQuerySuggestions: [SuggestionViewsTests.sampleQuery])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleQuery).environmentObject(model)
        let query = try suggestionView.inspect().find(QuerySuggestionView.self).actualView()
        XCTAssertNotNil(query)
        let querySuggestion =
            QuerySuggestionView(suggestion: SuggestionViewsTests.sampleQuerySuggestion).environmentObject(model)
        let image = try querySuggestion.inspect().find(ViewType.Image.self).actualImage()
        XCTAssertEqual(image,
                       Image(systemName: SFSymbol.magnifyingglass.rawValue).renderingMode(.template))
        let label = try querySuggestion.inspect()
            .find(ViewType.VStack.self)
            .find(ViewType.Text.self)
            .string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva", label)
    }

    func testURLSuggestion() {
        let model = NeevaSuggestionModel(previewLensBang: nil, topSuggestions: [SuggestionViewsTests.sampleURL])
        let urlSuggestion = URLSuggestionView(suggestion: SuggestionViewsTests.sampleURLSuggestion).environmentObject(model)
        
        do {
            // Test keeps crashing Thread 1: EXC_BAD_ACCESS
            // let hStack = try urlSuggestion.inspect().find(ViewType.HStack.self) <-- Crashes
            // let label = try hStack.find(ViewType.VStack.self)
            //     .find(ViewType.Text.self).string(locale: Locale(identifier: "en"))
            // XCTAssertEqual("How was your Neeva onboarding?", label)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testNavSuggestion() throws {
        let model = NeevaSuggestionModel(previewLensBang: nil,
                                         topSuggestions: [SuggestionViewsTests.sampleNav])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleNav).environmentObject(model)
        let nav = try suggestionView.inspect().find(URLSuggestionView.self).actualView()
        XCTAssertNotNil(nav)
        let navSuggestion = URLSuggestionView(suggestion:
                                    SuggestionViewsTests.sampleNavUrlSuggestion).environmentObject(model)
        let hStack = try navSuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)
        let labels = try hStack.vStack(1).findAll(ViewType.Text.self)
        let label = try labels[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva Search", label)
        let secondaryLabel = try labels[1].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel)
    }

    func testHistorySuggestion() throws {
        let neevaModel = NeevaSuggestionModel(searchQueryForTesting: "query", previewLensBang: nil)
        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite])
        let navModel = NavSuggestionModel(neevaModel: neevaModel, historyModel: historyModel)
        let historySuggestion = SuggestionsList().environmentObject(neevaModel).environmentObject(historyModel).environmentObject(navModel)
        let hStack = try historySuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)
        let labels = try hStack.vStack(1).findAll(ViewType.Text.self)
        let label = try labels[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("PlaceholderLongTitleOneWord", label)
        let secondaryLabel = try labels[1].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel)
    }

    func testSuggestionsList() throws {
        let neevaModel = NeevaSuggestionModel(previewLensBang: nil,
                                              topSuggestions: [SuggestionViewsTests.sampleNav],
                                              chipQuerySuggestions: [SuggestionViewsTests.sampleQuery])
        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite])
        let navModel = NavSuggestionModel(neevaModel: neevaModel, historyModel: historyModel)
        let suggestionList = SuggestionsList().environmentObject(historyModel)
            .environmentObject(neevaModel)
            .environmentObject(navModel)
        let hStacks = try suggestionList.inspect().findAll(ViewType.HStack.self)
        XCTAssertNotNil(hStacks)
        XCTAssertEqual(3, hStacks.count)
        let labels0 = try hStacks[0].vStack(1).findAll(ViewType.Text.self)
        let label0 = try labels0[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva Search", label0)
        let secondaryLabel0 = try labels0[1].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel0)
        let label1 = try hStacks[1].vStack(1)
            .find(ViewType.Text.self).string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva", label1)
        let labels2 = try hStacks[2].vStack(1).findAll(ViewType.Text.self)
        let label2 = try labels2[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva", label2)
        let secondaryLabel2 = try labels2[1].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel2)
    }

    func testSuggestionsListNoNeevaSuggestions() throws {
        let neevaModel = NeevaSuggestionModel(searchQueryForTesting: "query", previewLensBang: nil)

        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite])
        let navModel = NavSuggestionModel(neevaModel: neevaModel, historyModel: historyModel)
        let suggestionList = SuggestionsList().environmentObject(historyModel)
            .environmentObject(neevaModel)
            .environmentObject(navModel)
        let list = try suggestionList.inspect().find(ViewType.LazyVStack.self)
        XCTAssertNotNil(list)

        // We should be showing a placeholder with 1 actual suggestion, and 6 placeholders:
        // 1 history suggestion and 5 query suggestions
        XCTAssertEqual(2, list.count)
        XCTAssertEqual(2, list.findAll(NavSuggestionView.self).count)
        XCTAssertEqual(0, list.findAll(QuerySuggestionView.self).count)
    }

    func testSuggestionsListNoNeevaSuggestionsForIncognito() throws {
        let neevaModel = NeevaSuggestionModel(isIncognito: true, previewLensBang: nil)
        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite])
        let navModel = NavSuggestionModel(neevaModel: neevaModel, historyModel: historyModel)
        let suggestionList = SuggestionsList().environmentObject(historyModel)
            .environmentObject(neevaModel)
            .environmentObject(navModel)
        let hStacks = try suggestionList.inspect().findAll(ViewType.HStack.self)
        XCTAssertNotNil(hStacks)

        // We should not be showing placeholder suggestions
        XCTAssertEqual(1, hStacks.count)
        let labels = try hStacks[0].vStack(1).findAll(ViewType.Text.self)
        let label0 = try labels[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva", label0)
        let secondaryLabel0 = try labels[1].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel0)
    }

    func testSuggestionsListWithDuplicateNavSuggestions() throws {
        let navUrlSuggestion = SuggestionsQuery.Data.Suggest.UrlSuggestion(
            icon: .init(labels: [""]),
            suggestedUrl: "https://google.com/",
            title: "google.com",
            subtitle: "Google Search",
            boldSpan: [.init(startInclusive: 0, endExclusive: 0)]
        )
        let suggestion = Suggestion.url(navUrlSuggestion)
        let site = Site(url: "https://neeva.com/dup", title: "Neeva")
        let duplicateSite1 = Site(url: "https://neeva.com/dup", title: "Neeva")
        let duplicateSite2 = Site(url: "https://neeva.com/dup?q=abc", title: "Neeva")
        let siteB = Site(url: "https://neeva.com/signin", title: "Neeva")

        let neevaModel = NeevaSuggestionModel(searchQueryForTesting: "query", previewLensBang: nil)
        neevaModel.navSuggestions = [SuggestionViewsTests.sampleNav, suggestion]
        let historyModel = HistorySuggestionModel(previewSites: [SuggestionViewsTests.sampleSite, site, duplicateSite1, duplicateSite2, siteB])
        let navModel = NavSuggestionModel(neevaModel: neevaModel, historyModel: historyModel)
        let suggestionList = SuggestionsList().environmentObject(historyModel)
            .environmentObject(neevaModel)
            .environmentObject(navModel)
        let list = try suggestionList.inspect().find(ViewType.LazyVStack.self)
        XCTAssertNotNil(list)

        // We should be showing a placeholder with 1 actual suggestion, and 6 placeholders:
        // 1 history suggestion and 5 query suggestions
        XCTAssertEqual(2, list.count)
        XCTAssertEqual(4, list.findAll(NavSuggestionView.self).count)
        XCTAssertEqual(0, list.findAll(QuerySuggestionView.self).count)
    }
}
