// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import Storage
import SwiftUI
import ViewInspector
import XCTest

@testable import Client

extension SuggestionsList: Inspectable {}
extension Kern: Inspectable {}
extension PlaceholderSuggestions: Inspectable {}
extension QuerySuggestionsList: Inspectable {}
extension TopSuggestionsList: Inspectable {}
extension SuggestionChipView: Inspectable {}
extension SearchSuggestionView: Inspectable {}
extension QuerySuggestionView: Inspectable {}
extension NavSuggestionView: Inspectable {}
extension URLSuggestionView: Inspectable {}
extension SuggestionView: Inspectable {}
extension Symbol: Inspectable {}
extension BoldSpanView: Inspectable {}
extension NavSuggestionsList: Inspectable {}

class SuggestionViewsTests: XCTestCase {
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
    static let sampleNav = Suggestion.url(sampleNavUrlSuggestion)
    static let sampleNavSuggestion = NavSuggestion(url: "https://neeva.com", title: "Neeva")
    static let sampleSite = Site(url: "https://neeva.com", title: "Neeva")

    func testQuerySuggestion() throws {
        let model = SuggestionModel(
            previewLensBang: nil,
            chipQuerySuggestions: [SuggestionViewsTests.sampleQuery])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleQuery)
            .environmentObject(model)
        let query = try suggestionView.inspect().find(QuerySuggestionView.self).actualView()
        XCTAssertNotNil(query)
        let querySuggestion =
            QuerySuggestionView(suggestion: SuggestionViewsTests.sampleQuerySuggestion)
            .environmentObject(model)
        let image = try querySuggestion.inspect().find(ViewType.Image.self).actualImage()
        XCTAssertEqual(
            image,
            Image(systemName: SFSymbol.magnifyingglass.rawValue).renderingMode(.template))
        let label = try querySuggestion.inspect()
            .find(ViewType.VStack.self)
            .find(ViewType.Text.self)
            .string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva", label)
    }

    /* Test keeps crashing Thread 1: EXC_BAD_ACCESS
    func testURLSuggestion() {
        let model = NeevaSuggestionModel(
            previewLensBang: nil, topSuggestions: [SuggestionViewsTests.sampleURL])
        let urlSuggestion = URLSuggestionView(suggestion: SuggestionViewsTests.sampleURLSuggestion)
            .environmentObject(model)

        do {
            // let hStack = try urlSuggestion.inspect().find(ViewType.HStack.self) <-- Crashes
            // let label = try hStack.find(ViewType.VStack.self)
            //     .find(ViewType.Text.self).string(locale: Locale(identifier: "en"))
            // XCTAssertEqual("How was your Neeva onboarding?", label)
        } catch {
            XCTFail(error.localizedDescription)
        }
    } */

    func testNavSuggestion() throws {
        let model = SuggestionModel(
            previewLensBang: nil,
            topSuggestions: [SuggestionViewsTests.sampleNav])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleNav).environmentObject(
            model)
        let nav = try suggestionView.inspect().find(URLSuggestionView.self).actualView()
        XCTAssertNotNil(nav)
        let navSuggestion = URLSuggestionView(
            suggestion:
                SuggestionViewsTests.sampleNavUrlSuggestion
        ).environmentObject(model)
        let hStack = try navSuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)
        let labels = try hStack.vStack(1).findAll(ViewType.Text.self)
        let label = try labels[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva Search", label)
        let secondaryLabel = try labels[1].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel)
    }

    func testHistorySuggestion() throws {
        let suggestionModel = SuggestionModel(searchQueryForTesting: "query", previewLensBang: nil)
        let historySuggestion = SuggestionsList().environmentObject(suggestionModel)
        let hStack = try historySuggestion.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hStack)

        let labels = try hStack.vStack(1).findAll(ViewType.Text.self)
        let label = try labels[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("PlaceholderLongTitleOneWord", label)

        let secondaryLabel = try labels[1].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("neeva.com", secondaryLabel)
    }

    func testSuggestionsList() throws {
        let suggestionModel = SuggestionModel(
            previewLensBang: nil,
            topSuggestions: [SuggestionViewsTests.sampleNav],
            chipQuerySuggestions: [SuggestionViewsTests.sampleQuery])
        let suggestionList = SuggestionsList().environmentObject(suggestionModel)
        let hStacks = try suggestionList.inspect().findAll(ViewType.HStack.self)
        XCTAssertNotNil(hStacks)
        XCTAssertEqual(1, hStacks.count)
        let labels0 = try hStacks[0].vStack(1).findAll(ViewType.Text.self)
        let label0 = try labels0[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva Search", label0)
    }

    func testSuggestionsListNoNeevaSuggestions() throws {
        let suggestionModel = SuggestionModel(searchQueryForTesting: "query", previewLensBang: nil)
        let suggestionList = SuggestionsList().environmentObject(suggestionModel)
        let list = try suggestionList.inspect().find(ViewType.LazyVStack.self)
        XCTAssertNotNil(list)

        // We should be showing a placeholder with 1 actual suggestion, and 6 placeholders:
        // 1 history suggestion and 5 query suggestions
        XCTAssertEqual(2, list.count)
        XCTAssertEqual(1, list.findAll(NavSuggestionView.self).count)
        XCTAssertEqual(5, list.findAll(QuerySuggestionView.self).count)
    }

    func testSuggestionsListNoNeevaSuggestionsForIncognito() throws {
        let suggestionModel = SuggestionModel(isIncognito: true, previewLensBang: nil)
        let suggestionList = SuggestionsList().environmentObject(suggestionModel)
        let hStacks = try suggestionList.inspect().findAll(ViewType.HStack.self)
        XCTAssertNotNil(hStacks)
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

        let suggestionModel = SuggestionModel(previewSites: [SuggestionViewsTests.sampleSite, site, duplicateSite1, duplicateSite2, siteB])
        suggestionModel.navSuggestions = [SuggestionViewsTests.sampleNav, suggestion]

        let suggestionList = SuggestionsList().environmentObject(suggestionModel)
        let list = try suggestionList.inspect().find(ViewType.LazyVStack.self)
        XCTAssertNotNil(list)

        // We should be showing a placeholder with 1 actual suggestion, and 6 placeholders:
        // 1 history suggestion and 5 query suggestions
        XCTAssertEqual(2, list.count)
        XCTAssertEqual(4, list.findAll(NavSuggestionView.self).count)
        XCTAssertEqual(0, list.findAll(QuerySuggestionView.self).count)
        XCTAssertEqual(0, list.findAll(URLSuggestionView.self).count)
    }

    func testSuggestionWithCalculatorSayt() throws {
        let model = SuggestionModel(
            previewLensBang: nil,
            rowQuerySuggestions: [SuggestionViewsTests.sampleCalculatorQuery])
        let suggestionView = SearchSuggestionView(SuggestionViewsTests.sampleQuery)
            .environmentObject(model)
        let query = try suggestionView.inspect().find(QuerySuggestionView.self).actualView()
        XCTAssertNotNil(query)
        let querySuggestion =
            QuerySuggestionView(suggestion: SuggestionViewsTests.sampleCalculatorQuerySuggestion)
            .environmentObject(model)
        let label = try querySuggestion.inspect()
            .find(ViewType.VStack.self)
            .find(ViewType.Text.self)
            .string(locale: Locale(identifier: "en"))
        let secondaryLabel = try querySuggestion.inspect()
            .find(ViewType.VStack.self)
            .find(ViewType.Text.self, skipFound: 1)
            .string(locale: Locale(identifier: "en"))
        XCTAssertEqual("10", label)
        XCTAssertEqual("5+5 =", secondaryLabel)
    }
}
