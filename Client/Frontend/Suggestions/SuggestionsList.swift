// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared


struct SuggestionsList: View {
    static let placeholderQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .standard,
            suggestedQuery: "placeholder_query",
            boldSpan: [],
            source: .bing
        )
    static let placeholderSite = Site(url: "https://neeva.com", title: "PlaceholderLongTitleOneWord")

    @EnvironmentObject private var historyModel: HistorySuggestionModel
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel
    @Environment(\.isIncognito) private var isIncognito

    var body: some View {
        List {
            let suggestionList = ForEach(neevaModel.suggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }

            if let lensOrBang = neevaModel.activeLensBang,
               let description = lensOrBang.description {
                Section(header: Group {
                    switch lensOrBang.type {
                    case .bang:
                        Text("Search on \(description)")
                    default:
                        Text(description)
                    }
                }.textCase(nil)) {
                    suggestionList
                }
            } else {
                if neevaModel.suggestions.isEmpty && neevaModel.shouldShowSuggestions {
                    HistorySuggestionView(site: SuggestionsList.placeholderSite)
                        .redacted(reason: .placeholder)
                        .disabled(true)
                    ForEach(0..<5) { _ in
                        QuerySuggestionView(suggestion: SuggestionsList.placeholderQuery)
                        .redacted(reason: .placeholder)
                        .disabled(true)
                    }
                } else {
                    suggestionList
                }
            }

            if let history = historyModel.sites, !history.isEmpty {
                Section(header: isIncognito ? nil : Text("History")) {
                    ForEach(history) { site in
                        HistorySuggestionView(site: site)
                    }
                }
            }
        }
    }
}

struct SuggestionsList_Previews: PreviewProvider {
    static var previews: some View {
        let suggestions =  [Suggestion.query(.init(type: .standard, suggestedQuery: "hello world", boldSpan: [], source: .unknown))]
        let history = [
            Site(url: "https://neeva.com", title: "Neeva", id: 1),
            Site(url: "https://neeva.com", title: "", id: 2),
            Site(url: "https://google.com", title: "Google", id: 3)
        ]
        Group {
            SuggestionsList()
                .environmentObject(HistorySuggestionModel(previewSites: history))
                .environmentObject(NeevaSuggestionModel(previewLensBang: nil, suggestions: suggestions))
            SuggestionsList()
                .environmentObject(HistorySuggestionModel(previewSites: history))
                .environmentObject(NeevaSuggestionModel(previewLensBang: ActiveLensBangInfo(domain: "google.com", shortcut: "g", description: "Google", type: .bang), suggestions: suggestions))
            SuggestionsList()
                .environmentObject(HistorySuggestionModel(previewSites: history))
                .environmentObject(NeevaSuggestionModel(previewLensBang: ActiveLensBangInfo(shortcut: "my", description: "Search my connections", type: .lens), suggestions: suggestions))
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
