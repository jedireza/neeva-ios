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

    static let HeaderLeadPadding: CGFloat = 13
    static let HeaderTopPadding: CGFloat = 2
}

struct SuggestionsDivider: View {
    let height: CGFloat

    var body: some View {
        Color.secondaryBackground.frame(height: height)
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
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: SuggestionBlockUX.ChipBlockSpacing) {
                LazyHStack(spacing: SuggestionBlockUX.ChipBlockSpacing) {
                    ForEach(
                        stride(from: 0, to: suggestions.count, by: 2)
                            .map { suggestions[$0] }
                    ) { suggestion in
                        if suggestionModel.shouldShowSuggestions {
                            SearchSuggestionView(suggestion)
                                .environment(\.suggestionConfig, .chip)
                        }
                    }
                }
                LazyHStack(spacing: SuggestionBlockUX.ChipBlockSpacing) {
                    ForEach(
                        stride(from: 1, to: suggestions.count, by: 2)
                            .map { suggestions[$0] }
                    ) { suggestion in
                        if suggestionModel.shouldShowSuggestions {
                            SearchSuggestionView(suggestion)
                                .environment(\.suggestionConfig, .chip)
                        }
                    }
                }
            }.padding(.horizontal, SuggestionBlockUX.ChipBlockSpacing)
                .padding(.vertical, SuggestionBlockUX.ChipBlockPadding)
                .frame(height: SuggestionBlockUX.ChipBlockHeight)
        }.useEffect(deps: suggestionModel.chipQuerySuggestions) { _ in
            if !suggestionModel.chipQuerySuggestions.isEmpty {
                suggestions = suggestionModel.chipQuerySuggestions
            }
        }
    }
}

struct TabSuggestionsList: View {
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        if !suggestionModel.topSuggestions.isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.TopSpacing)
            ForEach(suggestionModel.tabSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }.padding(.vertical, SuggestionBlockUX.TopBlockVerticalPadding)
        }
    }
}

struct TopSuggestionsList: View {
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        if !suggestionModel.topSuggestions.isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.TopSpacing)
            ForEach(suggestionModel.topSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }.padding(.vertical, SuggestionBlockUX.TopBlockVerticalPadding)
        }
    }
}

struct QuerySuggestionsList: View {
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        if !(suggestionModel.chipQuerySuggestions + suggestionModel.rowQuerySuggestions).isEmpty {

            if FeatureFlag[.suggestionLayoutWithHeader] {
                Text("Neeva Suggestions")
                    .withFont(.bodyMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(
                        EdgeInsets(
                            top: SuggestionBlockUX.HeaderTopPadding,
                            leading: SuggestionBlockUX.HeaderLeadPadding,
                            bottom: SuggestionBlockUX.HeaderTopPadding,
                            trailing: 0)
                    )
                    .background(Color.secondaryBackground)
            }
            
            if FeatureFlag[.suggestionLayoutV2] {
                ForEach(Array(suggestionModel.rowQuerySuggestions.enumerated()), id: \.0) {
                    index, suggestion in
                    SearchSuggestionView(suggestion)
                    if case Suggestion.url(_) = suggestion {
                        SuggestionsDivider(height: 8)
                    }
                }
            } else {
                SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)

                if !suggestionModel.chipQuerySuggestions.isEmpty {
                    SuggestionChipView()
                        .padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
                }

                ForEach(suggestionModel.rowQuerySuggestions) { suggestion in
                    SearchSuggestionView(suggestion)
                }.padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
            }
        }
    }
}

struct UrlSuggestionsList: View {
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        if !suggestionModel.urlSuggestions.isEmpty {
            SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
            ForEach(suggestionModel.urlSuggestions) { suggestion in
                SearchSuggestionView(suggestion)
            }.padding(.vertical, SuggestionBlockUX.BlockVerticalPadding)
        }
    }
}

struct NavSuggestionsList: View {
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        if FeatureFlag[.suggestionLayoutWithHeader]
            && suggestionModel.navCombinedSuggestions.count > 0
        {
            Text("History")
                .withFont(.bodyMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(
                    EdgeInsets(
                        top: SuggestionBlockUX.HeaderTopPadding,
                        leading: SuggestionBlockUX.HeaderLeadPadding,
                        bottom: SuggestionBlockUX.HeaderTopPadding,
                        trailing: 0)
                )
                .background(Color.secondaryBackground)
        } else {
            SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
        }
        ForEach(suggestionModel.navCombinedSuggestions) { suggestion in
            SearchSuggestionView(suggestion)
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
