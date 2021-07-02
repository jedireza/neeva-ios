// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

private enum SuggestionChipUX {
    static let Spacing:CGFloat = 8
}

struct SuggestionChipView: View {
    let suggestions: [Suggestion]

    var body: some View {
        FadingHorizontalScrollView { size in
            VStack(alignment: .leading, spacing: SuggestionChipUX.Spacing) {
                LazyHStack(spacing: SuggestionChipUX.Spacing) {
                    ForEach(stride(from: 0, to: suggestions.count, by: 2)
                                .map{ suggestions[$0] }) { suggestion in
                        SearchSuggestionView(suggestion)
                            .environment(\.suggestionConfig, .chip)
                    }
                }
                LazyHStack(spacing: SuggestionChipUX.Spacing) {
                    ForEach(stride(from: 1, to: suggestions.count, by: 2)
                                .map{ suggestions[$0] }) { suggestion in
                        SearchSuggestionView(suggestion)
                            .environment(\.suggestionConfig, .chip)
                    }
                }
            }.padding(SuggestionChipUX.Spacing)
        }.frame(minHeight: 75).listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

struct NeevaSuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        if FeatureFlag[.mixedSuggestions] {
            SuggestionChipView(suggestions: neevaModel.suggestions)
        } else {
            ForEach(neevaModel.rowSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }
            ForEach(neevaModel.suggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }
        }
    }
}

struct NavSuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel
    @EnvironmentObject private var historyModel: HistorySuggestionModel
    @Environment(\.isIncognito) private var isIncognito

    var body: some View {
        if FeatureFlag[.mixedSuggestions] {
            ForEach(neevaModel.rowSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }
            if let history = historyModel.sites, !history.isEmpty {
                ForEach(history) { site in
                    HistorySuggestionView(site: site)
                }
            }
        } else {
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

struct PlaceholderSuggestions: View {
    func placeholderQuery(_ query: String = "placeholderQuery")
        -> SuggestionsQuery.Data.Suggest.QuerySuggestion {
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .standard,
            suggestedQuery: query,
            boldSpan: [],
            source: .bing
        )
    }

    var body: some View {
        if FeatureFlag[.mixedSuggestions] {
            SuggestionChipView(suggestions: [Suggestion.query(placeholderQuery("chip1")),
                                             Suggestion.query(placeholderQuery("chip2")),
                                             Suggestion.query(placeholderQuery("chip3")),
                                             Suggestion.query(placeholderQuery("chip4"))])
                .redacted(reason: .placeholder)
                .disabled(true)
            HistorySuggestionView(site: SuggestionsList.placeholderSite)
                .redacted(reason: .placeholder)
                .disabled(true)
        } else {
            HistorySuggestionView(site: SuggestionsList.placeholderSite)
                .redacted(reason: .placeholder)
                .disabled(true)
            ForEach(0..<5) { _ in
                QuerySuggestionView(suggestion: placeholderQuery())
                .redacted(reason: .placeholder)
                .disabled(true)
            }
        }
    }
}
