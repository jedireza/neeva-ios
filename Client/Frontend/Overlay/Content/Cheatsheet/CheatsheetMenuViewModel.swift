// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared
import SwiftUI

public class CheatsheetMenuViewModel: ObservableObject {
    private weak var tab: Tab?

    private(set) var currentPageURL: URL?
    private(set) var currentCheatsheetQuery: String?

    @Published private(set) var cheatsheetDataLoading: Bool
    private(set) var cheatsheetInfo: CheatsheetQueryController.CheatsheetInfo?
    private(set) var searchRichResults: [SearchController.RichResult]?
    private(set) var cheatsheetDataError: Error?
    private(set) var searchRichResultsError: Error?

    private var cheatsheetLoggerSubscription: AnyCancellable?

    var cheatSheetIsEmpty: Bool {
        if let cheatsheetInfo = cheatsheetInfo {
            if let recipe = cheatsheetInfo.recipe {
                // recipeView
                if let ingredients = recipe.ingredients,
                    let instructions = recipe.instructions,
                    ingredients.count > 0,
                    instructions.count > 0
                {
                    return false
                }
            }
            // priceHistorySection
            if let priceHistory = cheatsheetInfo.priceHistory,
                priceHistory.Max.Price.isEmpty || !priceHistory.Min.Price.isEmpty
            {
                return false
            }
            // reviewURLSection
            if cheatsheetInfo.reviewURL?.count ?? 0 > 0 {
                return false
            }
            // memorizedQuerySection
            if cheatsheetInfo.memorizedQuery?.count ?? 0 > 0 {
                return false
            }
        }
        // renderRichResult views
        if let searchRichResults = searchRichResults,
            !searchRichResults.isEmpty
        {
            return false
        }
        return true
    }

    /// Debug dispaly URL for Neeva Search URL from query
    /// this property is not used in the network request
    var currentCheatsheetQueryAsURL: URL? {
        guard let query = currentCheatsheetQuery,
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed),
            !encodedQuery.isEmpty
        else {
            return nil
        }
        return URL(string: "\(NeevaConstants.appSearchURL)?q=\(encodedQuery)")
    }

    var loggerAttributes: [ClientLogCounterAttribute] {
        [
            ClientLogCounterAttribute(
                key: LogConfig.CheatsheetAttribute.currentPageURL,
                value: currentPageURL?.absoluteString
            ),
            ClientLogCounterAttribute(
                key: LogConfig.CheatsheetAttribute.currentCheatsheetQuery,
                value: currentCheatsheetQuery
            ),
        ]
    }

    // MARK: - Init
    init(tab: Tab?) {
        self.tab = tab

        self.cheatsheetDataLoading = false
    }

    // MARK: - Load Methods
    func reload() {
        fetchCheatsheetInfo()
    }

    func fetchCheatsheetInfo() {
        guard !cheatsheetDataLoading else { return }

        setupCheatsheetLoaderLogger()

        clearCheatsheetData()

        currentPageURL = tab?.webView?.url
        self.cheatsheetDataLoading = true

        guard let url = currentPageURL,
            url.scheme == "https",
            !NeevaConstants.isInNeevaDomain(url)
        else {
            self.cheatsheetDataLoading = false
            return
        }

        CheatsheetQueryController.getCheatsheetInfo(url: url.absoluteString) { [self] result in
            switch result {
            case .success(let cheatsheetInfo):
                self.cheatsheetInfo = cheatsheetInfo.first

                // when cheatsheet data fetched successfully
                // fetch other rich result
                let query: String
                let querySource: LogConfig.CheatsheetAttribute.QuerySource

                if let queries = cheatsheetInfo.first?.memorizedQuery,
                    let firstQuery = queries.first
                {
                    // U2Q
                    querySource = .uToQ
                    query = firstQuery
                } else if let recentQuery = self.tab?.getMostRecentQuery(
                    restrictToCurrentNavigation: true)
                {
                    // Fallback
                    // if we don't have memorized query from the url
                    // use last tab query
                    if let suggested = recentQuery.suggested {
                        querySource = .fastTapQuery
                        query = suggested
                    } else {
                        querySource = .typedQuery
                        query = recentQuery.typed
                    }
                } else {
                    // Second Fallback
                    // use current url as query for fallback
                    querySource = .pageURL
                    query = url.absoluteString
                }

                // Log fallback level
                ClientLogger.shared.logCounter(
                    .CheatsheetQueryFallback,
                    attributes: EnvironmentHelper.shared.getAttributes() + [
                        ClientLogCounterAttribute(
                            key: LogConfig.CheatsheetAttribute.cheatsheetQuerySource,
                            value: querySource.rawValue
                        )
                    ]
                )

                self.currentCheatsheetQuery = query
                self.getRichResultByQuery(query)
            case .failure(let error):
                Logger.browser.error("Error: \(error)")
                self.cheatsheetDataError = error
                self.cheatsheetDataLoading = false
            }
        }
    }

    private func getRichResultByQuery(_ query: String) {
        SearchController.getRichResult(query: query) { searchResult in
            switch searchResult {
            case .success(let richResult):
                self.searchRichResults = richResult
            case .failure(let error):
                Logger.browser.error("Error: \(error)")
                self.searchRichResultsError = error
            }
            self.cheatsheetDataLoading = false
        }
    }

    // MARK: - Util Methods
    private func clearCheatsheetData() {
        cheatsheetInfo = nil
        searchRichResults = nil
        cheatsheetDataError = nil
        searchRichResultsError = nil
    }

    private func setupCheatsheetLoaderLogger() {
        guard cheatsheetLoggerSubscription == nil else { return }
        cheatsheetLoggerSubscription =
            $cheatsheetDataLoading
            .withPrevious()
            .sink { [weak self] (prev, next) in
                // only process cases where loading changed to false from a true
                // which indicates that a loading activity has finished
                guard prev, !next, let self = self else { return }
                if self.cheatSheetIsEmpty {
                    let errorString =
                        self.cheatsheetDataError?.localizedDescription
                        ?? self.searchRichResultsError?.localizedDescription
                    ClientLogger.shared.logCounter(
                        .CheatsheetEmpty,
                        attributes: EnvironmentHelper.shared.getAttributes()
                            + self.loggerAttributes
                            + [
                                ClientLogCounterAttribute(
                                    key: "Error",
                                    value: errorString
                                )
                            ]
                    )
                }
            }
    }
}
