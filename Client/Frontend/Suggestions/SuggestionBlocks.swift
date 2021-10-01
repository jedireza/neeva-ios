// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SwiftUI

enum SuggestionBlockUX {
    static let TopSpacing: CGFloat = 2
    static let SeparatorSpacing: CGFloat = 8
    static let ChipBlockSpacing: CGFloat = 10
    static let ChipBlockPadding: CGFloat = 8
    static let TopBlockVerticalPadding: CGFloat = 6
    static let BlockVerticalPadding: CGFloat = 4
    static let ChipBlockHeight: CGFloat = 108

    static let HeaderLeadPadding: CGFloat = 13
    static let HeaderTopPadding: CGFloat = 6
    static let HeaderBottomPadding: CGFloat = 3
}

struct SuggestionsDivider: View {
    let height: CGFloat

    var body: some View {
        Color.secondaryBackground.frame(height: height)
    }
}

struct SuggestionsHeader: View {
    let header: String

    var body: some View {
        Text(header)
            .withFont(.bodyMedium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(
                EdgeInsets(
                    top: SuggestionBlockUX.HeaderTopPadding,
                    leading: SuggestionBlockUX.HeaderLeadPadding,
                    bottom: SuggestionBlockUX.HeaderBottomPadding,
                    trailing: 0)
            )
            .background(Color.secondaryBackground)
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

struct AutocompleteSuggestionView: View {
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        if let autocompleteSuggestion = suggestionModel.autocompleteSuggestion {
            SearchSuggestionView(autocompleteSuggestion)
                .padding(.vertical, SuggestionBlockUX.TopBlockVerticalPadding)
        }
    }
}

struct QuerySuggestionsList: View {
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        if !(suggestionModel.chipQuerySuggestions + suggestionModel.rowQuerySuggestions).isEmpty {

            if !FeatureFlag[.enableOldSuggestUI] {
                SuggestionsHeader(header: "Neeva Search")
            }
            if !FeatureFlag[.enableOldSuggestUI] {
                ForEach(Array(suggestionModel.rowQuerySuggestions.enumerated()), id: \.0) {
                    index, suggestion in
                    SearchSuggestionView(suggestion)

                    if case Suggestion.url = suggestion,
                        index != suggestionModel.rowQuerySuggestions.count - 1
                    {
                        // insert separator only if two rows later is another query suggestion
                        if index + 1 < suggestionModel.rowQuerySuggestions.count,
                            case Suggestion.query =
                                suggestionModel.rowQuerySuggestions[index + 1]
                        {
                            SuggestionsDivider(height: 8)
                        }
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
                }
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
        if !FeatureFlag[.enableOldSuggestUI] {
            if suggestionModel.navCombinedSuggestions.count > 0 {
                SuggestionsHeader(header: "History")
            }
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
        if !FeatureFlag[.enableOldSuggestUI] {
            SuggestionsHeader(header: "Neeva Search")
            ForEach(0..<4) { i in
                if i > 0 && i % 2 == 0 {
                    SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
                }
                QuerySuggestionView(
                    suggestion:
                        Suggestion.placeholderQuery("PlaceholderLongTitleOneWord")
                )
                .redacted(reason: .placeholder)
                .disabled(true)
            }
        } else {
            SuggestionsDivider(height: SuggestionBlockUX.TopSpacing)
            NavSuggestionView(suggestion: SuggestionsList.placeholderNavSuggestion)
                .redacted(reason: .placeholder)
                .disabled(true).padding(.vertical, SuggestionBlockUX.TopBlockVerticalPadding)
            SuggestionsDivider(height: SuggestionBlockUX.SeparatorSpacing)
            if FeatureFlag[.enableOldSuggestUI] {
                SuggestionChipView(suggestions: placeholderSuggestions)
                    .modifier(
                        ChipPlaceholderModifier())
            } else {
                ForEach(0..<3) { _ in
                    QuerySuggestionView(
                        suggestion:
                            Suggestion.placeholderQuery("PlaceholderLongTitleOneWord")
                    )
                    .redacted(reason: .placeholder)
                    .disabled(true)
                }
            }
        }
    }
}
