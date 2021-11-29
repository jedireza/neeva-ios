// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SwiftUI

enum SuggestionBlockUX {
    static let TopSpacing: CGFloat = 2
    static let SeparatorSpacing: CGFloat = 8
    static let TopBlockVerticalPadding: CGFloat = 6
    static let BlockVerticalPadding: CGFloat = 4

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
                if case let .query(querySuggestion) = suggestion,
                   AnnotationType(annotation: querySuggestion.annotation) == .dictionary {
                    SearchSuggestionView(suggestion)
                        .environment(\.suggestionConfig, .dictionary)
                } else {
                    SearchSuggestionView(suggestion)
                }
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
        if !suggestionModel.rowQuerySuggestions.isEmpty {
            SuggestionsHeader(header: "Neeva Search")

            ForEach(Array(suggestionModel.rowQuerySuggestions.enumerated()), id: \.0) {
                index, suggestion in
                SearchSuggestionView(suggestion)

                if index != suggestionModel.rowQuerySuggestions.count - 1,
                    suggestionModel.hasMemorizedResult
                {
                    // insert separator only if two rows later is another query suggestion
                    // and there is at least one memorized result
                    if index + 1 < suggestionModel.rowQuerySuggestions.count,
                        case let .query(querySuggestion) =
                            suggestionModel.rowQuerySuggestions[index + 1],
                        querySuggestion.type == .standard
                    {
                        SuggestionsDivider(height: 8)
                    }
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
        if suggestionModel.navCombinedSuggestions.count > 0 {
            SuggestionsHeader(header: "History")
        }
        ForEach(suggestionModel.navCombinedSuggestions) { suggestion in
            SearchSuggestionView(suggestion)
        }
    }
}

struct PlaceholderSuggestions: View {
    var body: some View {
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
    }
}
