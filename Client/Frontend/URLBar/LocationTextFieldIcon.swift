// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

fileprivate enum LocationTextFieldIconUX {
    static let size: CGFloat = 16
    static let faviconSize: CGFloat = 14
}

struct LocationTextFieldIcon: View {
    let currentUrl: URL?

    @EnvironmentObject private var searchQuery: SearchQueryModel
    @EnvironmentObject private var neevaModel: NeevaSuggestionModel
    @EnvironmentObject private var historyModel: HistorySuggestionModel

    var body: some View {
        Group {
            let suggestion = historyModel.autocompleteSuggestion
            if let type = neevaModel.activeLensBang?.type {
                Image(systemSymbol: type.defaultSymbol)
            } else if
                let suggestion = suggestion,
                let url = suggestion.contains("://") ? URL(string: suggestion) : URL(string: "https://\(suggestion)") {
                FaviconView(url: url, size: LocationTextFieldIconUX.faviconSize, bordered: false, defaultBackground: .clear)
                    .cornerRadius(4)
            } else if searchQuery.value.looksLikeAURL, let url = searchQuery.value.contains("://") ? URL(string: searchQuery.value) : URL(string: "https://\(searchQuery.value)")  {
                FaviconView(url: url, size: LocationTextFieldIconUX.faviconSize, bordered: false, defaultBackground: .clear)
                    .cornerRadius(4)
            } else {
                Image("neevaMenuIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: LocationTextFieldIconUX.size, height: LocationTextFieldIconUX.size)
        .frame(width: TabLocationViewUX.height)
        .transition(.identity)
    }
}

struct LocationTextFieldIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LocationTextFieldIcon(currentUrl: nil)
                .previewDisplayName("Empty")

            HStack(spacing: 0) {
                LocationTextFieldIcon(currentUrl: nil)
                    .environmentObject(NeevaSuggestionModel(previewLensBang: .previewBang, suggestions: []))
                LocationTextFieldIcon(currentUrl: nil)
                    .environmentObject(NeevaSuggestionModel(previewLensBang: .previewLens, suggestions: []))
            }.previewDisplayName("Lens/Bang")

            HStack(spacing: 0) {
                LocationTextFieldIcon(currentUrl: nil)
                    .environmentObject(HistorySuggestionModel(previewSuggestion: "example.com"))
                LocationTextFieldIcon(currentUrl: nil)
                    .environmentObject(HistorySuggestionModel(previewSuggestion: "apple.com"))
            }.previewDisplayName("Domain autocomplete suggestion")

            HStack(spacing: 0) {
                LocationTextFieldIcon(currentUrl: nil)
                    .environmentObject(SearchQueryModel(previewValue: "https://example.com"))
                LocationTextFieldIcon(currentUrl: nil)
                    .environmentObject(SearchQueryModel(previewValue: "https://apple.com"))
            }.previewDisplayName("Entered URL")

            LocationTextFieldIcon(currentUrl: nil)
                .environmentObject(SearchQueryModel(previewValue: "https://github.com projects"))
                .previewDisplayName("Entered Query")
        }
        .frame(height: TabLocationViewUX.height)
        .background(
            Capsule()
                .fill(Color.systemFill)
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .environmentObject(SearchQueryModel.shared)
        .environmentObject(NeevaSuggestionModel(previewLensBang: nil, suggestions: []))
        .environmentObject(HistorySuggestionModel(previewSites: []))
    }
}
