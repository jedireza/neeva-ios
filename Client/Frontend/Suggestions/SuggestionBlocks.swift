// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

private enum SuggestionBlockUX {
    static let TopSpacing:CGFloat = 2
    static let SeparatorSpacing:CGFloat = 8
    static let ChipBlockSpacing:CGFloat = 10
    static let ChipBlockPadding:CGFloat = 8
    static let TopBlockVerticalPadding:CGFloat = 6
    static let BlockVerticalPadding:CGFloat = 4
    static let ChipBlockHeight:CGFloat = 108
}

struct SuggestionsDivider: View {
    let height: CGFloat

    var body: some View {
        Color.TrayBackground.frame(height: height)
    }
}

struct SuggestionChipView: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: SuggestionBlockUX.ChipBlockSpacing) {
                LazyHStack(spacing: SuggestionBlockUX.ChipBlockSpacing) {
                    ForEach(stride(from: 0, to: neevaModel.chipQuerySuggestions.count, by: 2)
                                .map{ neevaModel.chipQuerySuggestions[$0] }) { suggestion in
                        SearchSuggestionView(suggestion)
                            .environment(\.suggestionConfig, .chip)
                            .environmentObject(neevaModel)
                    }
                }
                LazyHStack(spacing: SuggestionBlockUX.ChipBlockSpacing) {
                    ForEach(stride(from: 1, to: neevaModel.chipQuerySuggestions.count, by: 2)
                                .map{ neevaModel.chipQuerySuggestions[$0] }) { suggestion in
                        SearchSuggestionView(suggestion)
                            .environment(\.suggestionConfig, .chip)
                            .environmentObject(neevaModel)
                    }
                }
            }.padding(.horizontal, SuggestionBlockUX.ChipBlockSpacing)
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
                    .environmentObject(neevaModel)
            }.padding(.vertical, SuggestionBlockUX.TopBlockVerticalPadding)
        }
    }
}

struct QuerySuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        if !(neevaModel.chipQuerySuggestions + neevaModel.rowQuerySuggestions).isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
            
            if !neevaModel.chipQuerySuggestions.isEmpty {
                SuggestionChipView()
                    .environmentObject(neevaModel)
                    .padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
            }

            ForEach(neevaModel.rowQuerySuggestions) { suggestion in
                SearchSuggestionView(suggestion)
                    .environmentObject(neevaModel)
            }.padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
        }
    }
}


struct UrlSuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        if !neevaModel.urlSuggestions.isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
            ForEach(neevaModel.urlSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
                    .environmentObject(neevaModel)
            }.padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
        }
    }
}

struct NavSuggestionsList: View {
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel
    @EnvironmentObject private var navModel: NavSuggestionModel
    @Environment(\.isIncognito) private var isIncognito

    var body: some View {
        ForEach(neevaModel.navSuggestions + navModel.combinedSuggestions) { suggestion in
            SearchSuggestionView(suggestion)
                .environmentObject(neevaModel)
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
        NavSuggestionView(suggestion: SuggestionsList.placeholderNavSuggestion)
            .redacted(reason: .placeholder)
            .disabled(true).padding(.vertical, SuggestionBlockUX.TopBlockVerticalPadding)
        SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
    }
}
