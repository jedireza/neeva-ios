// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SwiftUI

private enum SuggestionBlockUX {
    static let TopSpacing: CGFloat = 2
    static let SeparatorSpacing: CGFloat = 8
    static let ChipBlockSpacing: CGFloat = 10
    static let ChipBlockPadding: CGFloat = 8
    static let TopBlockVerticalPadding: CGFloat = 6
    static let BlockVerticalPadding: CGFloat = 4
    static let ChipBlockHeight: CGFloat = 108
}

struct SuggestionsDivider: View {
    let height: CGFloat

    var body: some View {
        Color.TrayBackground.frame(height: height)
    }
}

struct ChipPlaceholderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .disabled(true).padding(
                .vertical, SuggestionBlockUX.BlockVerticalPadding)
    }
}

struct SuggestionChipView: View {
    @State var suggestions = [Suggestion]()
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: SuggestionBlockUX.ChipBlockSpacing) {
                LazyHStack(spacing: SuggestionBlockUX.ChipBlockSpacing) {
                    ForEach(
                        stride(from: 0, to: suggestions.count, by: 2)
                            .map { suggestions[$0] }
                    ) { suggestion in
                        if neevaModel.shouldShowSuggestions {
                            SearchSuggestionView(suggestion)
                                .environment(\.suggestionConfig, .chip)
                                .environmentObject(neevaModel)
                        }
                    }
                }
                LazyHStack(spacing: SuggestionBlockUX.ChipBlockSpacing) {
                    ForEach(
                        stride(from: 1, to: suggestions.count, by: 2)
                            .map { suggestions[$0] }
                    ) { suggestion in
                        if neevaModel.shouldShowSuggestions {
                            SearchSuggestionView(suggestion)
                                .environment(\.suggestionConfig, .chip)
                                .environmentObject(neevaModel)
                        }
                    }
                }
            }.padding(.horizontal, SuggestionBlockUX.ChipBlockSpacing)
                .padding(.vertical, SuggestionBlockUX.ChipBlockPadding)
                .frame(height: SuggestionBlockUX.ChipBlockHeight)
        }.useEffect(deps: neevaModel.chipQuerySuggestions) { _ in
            if !neevaModel.chipQuerySuggestions.isEmpty {
                suggestions = neevaModel.chipQuerySuggestions
            }
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

            SuggestionChipView()
                .environmentObject(neevaModel)
                .padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)

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
        SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
        ForEach(navModel.combinedSuggestions) { suggestion in
            SearchSuggestionView(suggestion)
                .environmentObject(neevaModel)
        }
    }
}

struct PlaceholderSuggestions: View {
    let placeholderSuggestions = [
        Suggestion.query(Suggestion.placeholderQuery("chip1")),
        Suggestion.query(Suggestion.placeholderQuery("chip2")),
        Suggestion.query(Suggestion.placeholderQuery("chip3")),
        Suggestion.query(Suggestion.placeholderQuery("chip4")),
        Suggestion.query(Suggestion.placeholderQuery("chip5")),
    ]

    var body: some View {
        SuggestionsDivider(height: SuggestionBlockUX.TopSpacing)
        NavSuggestionView(suggestion: SuggestionsList.placeholderNavSuggestion)
            .redacted(reason: .placeholder)
            .disabled(true).padding(.vertical, SuggestionBlockUX.TopBlockVerticalPadding)
        SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
        SuggestionChipView(suggestions: placeholderSuggestions)
            .modifier(
                ChipPlaceholderModifier())
    }
}
