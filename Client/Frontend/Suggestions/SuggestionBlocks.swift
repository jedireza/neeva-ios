// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

private enum SuggestionBlockUX {
    static let TopSpacing:CGFloat = 2
    static let Spacing:CGFloat = 8
    static let ChipBlockPadding:CGFloat = 8
    static let BlockVerticalPadding:CGFloat = 4
    static let ChipBlockHeight:CGFloat = 92
}

struct SuggestionsDivider: View {
    let height: CGFloat

    var body: some View {
        Color(UIColor.Browser.urlBarDivider).frame(height: height)
    }
}


struct SuggestionChipView: View {
    let suggestions: [Suggestion]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: SuggestionBlockUX.Spacing) {
                LazyHStack(spacing: SuggestionBlockUX.Spacing) {
                    ForEach(stride(from: 0, to: suggestions.count, by: 2)
                                .map{ suggestions[$0] }) { suggestion in
                        SearchSuggestionView(suggestion)
                            .environment(\.suggestionConfig, .chip)
                    }
                }
                LazyHStack(spacing: SuggestionBlockUX.Spacing) {
                    ForEach(stride(from: 1, to: suggestions.count, by: 2)
                                .map{ suggestions[$0] }) { suggestion in
                        SearchSuggestionView(suggestion)
                            .environment(\.suggestionConfig, .chip)
                    }
                }
            }.padding(.horizontal, SuggestionBlockUX.Spacing)
            .padding(.vertical, SuggestionBlockUX.ChipBlockPadding)
            .frame(height: SuggestionBlockUX.ChipBlockHeight)
        }
    }
}

struct TopSuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        if !neevaModel.topSuggestions.isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.TopSpacing)
            ForEach(neevaModel.topSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }.padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
        }
    }
}

struct QuerySuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        if !(neevaModel.chipQuerySuggestions + neevaModel.rowQuerySuggestions).isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.Spacing)
            if !neevaModel.chipQuerySuggestions.isEmpty {
                SuggestionChipView(suggestions: neevaModel.chipQuerySuggestions)
                    .padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
            }
            ForEach(neevaModel.rowQuerySuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }.padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
        }
    }
}


struct UrlSuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        if !neevaModel.urlSuggestions.isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.Spacing)
            ForEach(neevaModel.urlSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }.padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
        }
    }
}

struct NavSuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel
    @EnvironmentObject private var historyModel: HistorySuggestionModel
    @Environment(\.isIncognito) private var isIncognito

    var body: some View {
        SuggestionsDivider(height: isIncognito ?
                            SuggestionBlockUX.TopSpacing : SuggestionBlockUX.Spacing)
        ForEach(neevaModel.navSuggestions) { suggestion in
            SearchSuggestionView(suggestion)
        }.padding(.top, SuggestionBlockUX.BlockVerticalPadding)
        if let history = historyModel.sites, !history.isEmpty {
            ForEach(history) { site in
                HistorySuggestionView(site: site)
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
        SuggestionsDivider(height: SuggestionBlockUX.TopSpacing)
        HistorySuggestionView(site: SuggestionsList.placeholderSite)
            .redacted(reason: .placeholder)
            .disabled(true).padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
        SuggestionsDivider(height: SuggestionBlockUX.Spacing)
        SuggestionChipView(suggestions: [Suggestion.query(placeholderQuery("chip1")),
                                         Suggestion.query(placeholderQuery("chip2")),
                                         Suggestion.query(placeholderQuery("chip3")),
                                         Suggestion.query(placeholderQuery("chip4")),
                                         Suggestion.query(placeholderQuery("chip5"))])
            .redacted(reason: .placeholder)
            .disabled(true).padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
    }
}
