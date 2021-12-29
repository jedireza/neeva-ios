// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SwiftUI

struct SuggestionsList: View {
    static let placeholderNavSuggestion = NavSuggestion(
        url: "https://neeva.com", title: "PlaceholderLongTitleOneWord")

    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if let lensOrBang = suggestionModel.activeLensBang,
                    let description = lensOrBang.description
                {
                    Section(
                        header: Group {
                            switch lensOrBang.type {
                            case .bang:
                                Text("Search on \(description)")
                                    .withFont(.bodyMedium)

                            default:
                                Text(description)
                                    .withFont(.bodyMedium)
                            }
                        }.textCase(nil).padding(.vertical, 8)
                    ) {
                        QuerySuggestionsList()
                    }
                } else {
                    TabSuggestionsList()
                    AutocompleteSuggestionView()

                    if suggestionModel.shouldShowPlaceholderSuggestions {
                        PlaceholderSuggestions()
                    } else {
                        QuerySuggestionsList()
                        UrlSuggestionsList()
                    }
                }

                NavSuggestionsList()

                if let findInPageSuggestion = suggestionModel.findInPageSuggestion {
                    SuggestionsHeader(header: "Find on this page")
                    SearchSuggestionView(findInPageSuggestion)
                }
            }
        }
    }
}

struct SuggestionsList_Previews: PreviewProvider {
    static var previews: some View {
        let history = [
            Site(url: "https://neeva.com", title: "Neeva", id: 1),
            Site(url: "https://neeva.com", title: "", id: 2),
            Site(url: "https://google.com", title: "Google", id: 3),
        ]
        Group {
            SuggestionsList()
            SuggestionsList()
            SuggestionsList()
        }
        .environmentObject(
            SuggestionModel(
                bvc: SceneDelegate.getBVC(for: nil),
                previewSites: history)
        )
        .previewLayout(.fixed(width: 375, height: 250))
    }
}
