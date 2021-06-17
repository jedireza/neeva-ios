// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared


struct SuggestionsList: View {
    static let placeholderQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .standard,
            suggestedQuery: "placeholder_query",
            boldSpan: [.init(startInclusive: 0, endExclusive: 0)],
            source: .bing
        )
    static let placeholderSite = Site(url: "https://neeva.com", title: "PlaceholderLongTitleOneWord")

    let suggestions: [Suggestion]
    let lensOrBang: ActiveLensBangInfo?
    let history: Cursor<Site>?

    var body: some View {
        List {
            let suggestionList = ForEach(suggestions) { suggestion in
                SearchSuggestionView(suggestion, activeLensOrBang: lensOrBang)
            }

            if let lensOrBang = lensOrBang,
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
                if (suggestions.isEmpty) {
                    HistorySuggestionView(site: SuggestionsList.placeholderSite)
                        .redacted(reason: .placeholder)
                    ForEach(0..<5) { _ in
                        QuerySuggestionView(suggestion: SuggestionsList.placeholderQuery,
                                            activeLensOrBang: nil)
                            .redacted(reason: .placeholder)
                    }
                } else {
                    suggestionList
                }
            }

            if let history = history, history.count > 0 {
                Section(header: Text("History")) {
                    ForEach(history.asArray()) { site in
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
        let history = ArrayCursor(
            data: [
                Site(url: "https://neeva.com", title: "Neeva", id: 1),
                Site(url: "https://neeva.com", title: "", id: 2),
                Site(url: "https://google.com", title: "Google", id: 3)
            ]
        )
        Group {
            SuggestionsList(suggestions: suggestions, lensOrBang: nil, history: history)
            SuggestionsList(suggestions: suggestions, lensOrBang: ActiveLensBangInfo(domain: "google.com", shortcut: "g", description: "Google", type: .bang), history: history)
            SuggestionsList(suggestions: suggestions, lensOrBang: ActiveLensBangInfo(shortcut: "my", description: "Search my connections", type: .lens), history: history)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
