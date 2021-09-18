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
    func testQuerySuggestion() throws {
        let model = SuggestionModel(
            bvc: SceneDelegate.getBVC(for: nil),
            previewLensBang: nil,
            chipQuerySuggestions: [SuggestionModelTests.sampleQuery])
        let suggestionView = SearchSuggestionView(SuggestionModelTests.sampleQuery)
            .environmentObject(model)
        let query = try suggestionView.inspect().find(QuerySuggestionView.self).actualView()
        XCTAssertNotNil(query)
        let querySuggestion =
            QuerySuggestionView(suggestion: SuggestionModelTests.sampleQuerySuggestion)
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
            bvc: SceneDelegate.getBVC(for: nil),
            previewLensBang: nil,
            topSuggestions: [SuggestionModelTests.sampleNavURL])
        let suggestionView = SearchSuggestionView(SuggestionModelTests.sampleNavURL).environmentObject(
            model)
        let nav = try suggestionView.inspect().find(URLSuggestionView.self).actualView()
        XCTAssertNotNil(nav)
        let navSuggestion = URLSuggestionView(
            suggestion:
                SuggestionModelTests.sampleNavUrlSuggestion
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
        let suggestionModel = SuggestionModel(
            bvc: SceneDelegate.getBVC(for: nil),
            searchQueryForTesting: "query",
            previewLensBang: nil)
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
            bvc: SceneDelegate.getBVC(for: nil),
            previewLensBang: nil,
            topSuggestions: [SuggestionModelTests.sampleNavURL],
            chipQuerySuggestions: [SuggestionModelTests.sampleQuery])
        let suggestionList = SuggestionsList().environmentObject(suggestionModel)
        let hStacks = try suggestionList.inspect().findAll(ViewType.HStack.self)
        XCTAssertNotNil(hStacks)
        XCTAssertEqual(1, hStacks.count)
        let labels0 = try hStacks[0].vStack(1).findAll(ViewType.Text.self)
        let label0 = try labels0[0].string(locale: Locale(identifier: "en"))
        XCTAssertEqual("Neeva Search", label0)
    }

    func testSuggestionsListNoNeevaSuggestions() throws {
        let suggestionModel = SuggestionModel(
            bvc: SceneDelegate.getBVC(for: nil),
            searchQueryForTesting: "query",
            previewLensBang: nil)
        let suggestionList = SuggestionsList().environmentObject(suggestionModel)
        let list = try suggestionList.inspect().find(ViewType.LazyVStack.self)
        XCTAssertNotNil(list)

        // We should be showing a placeholder with 1 actual suggestion, and 6 placeholders:
        // 1 history suggestion and 5 query suggestions
        XCTAssertEqual(3, list.count)
        XCTAssertEqual(1, list.findAll(NavSuggestionView.self).count)
        XCTAssertEqual(3, list.findAll(QuerySuggestionView.self).count)
    }

    func testSuggestionsListNoNeevaSuggestionsForIncognito() throws {
        try skipTest(issue: 1383, "Did not actually test incognito mode")
        let suggestionModel = SuggestionModel(
            bvc: SceneDelegate.getBVC(for: nil),
            previewLensBang: nil)
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

        let suggestionModel = SuggestionModel(bvc: SceneDelegate.getBVC(for: nil), previewSites: [
            SuggestionModelTests.sampleSite, site, duplicateSite1, duplicateSite2, siteB,
        ])
        suggestionModel.navSuggestions = [SuggestionModelTests.sampleNavURL, suggestion]

        let suggestionList = SuggestionsList().environmentObject(suggestionModel)
        let list = try suggestionList.inspect().find(ViewType.LazyVStack.self)
        XCTAssertNotNil(list)

        // We should be showing a placeholder with 1 actual suggestion, and 6 placeholders:
        // 1 history suggestion and 5 query suggestions
        XCTAssertEqual(3, list.count)
        XCTAssertEqual(4, list.findAll(NavSuggestionView.self).count)
        XCTAssertEqual(0, list.findAll(QuerySuggestionView.self).count)
        XCTAssertEqual(0, list.findAll(URLSuggestionView.self).count)
    }

    func testSuggestionWithCalculatorSayt() throws {
        let model = SuggestionModel(
            bvc: SceneDelegate.getBVC(for: nil), previewLensBang: nil,
            rowQuerySuggestions: [SuggestionModelTests.sampleCalculatorQuery])
        let suggestionView = SearchSuggestionView(SuggestionModelTests.sampleQuery)
            .environmentObject(model)
        let query = try suggestionView.inspect().find(QuerySuggestionView.self).actualView()
        XCTAssertNotNil(query)
        let querySuggestion =
            QuerySuggestionView(suggestion: SuggestionModelTests.sampleCalculatorQuerySuggestion)
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
