// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

fileprivate enum LocationTextFieldIconUX {
    static let size: CGFloat = 24
    static let faviconSize: CGFloat = 20
}

struct LocationTextFieldIcon: View {
    let currentUrl: URL?

    @EnvironmentObject private var neevaModel: NeevaSuggestionModel
    @EnvironmentObject private var historyModel: HistorySuggestionModel

    var body: some View {
        Group {
            let suggestion = historyModel.autocompleteSuggestion
            if let type = neevaModel.activeLensBang?.type {
                Image(systemSymbol: type.defaultSymbol)
            } else if let url = suggestion.contains("://") ? URL(string: suggestion) : URL(string: "https://\(suggestion)") {
                FaviconView(url: url, size: LocationTextFieldIconUX.faviconSize, bordered: false, defaultBackground: .clear)
                    .cornerRadius(4)
            } else if
                suggestion == NeevaConstants.appHost ||
                    suggestion == "https://\(NeevaConstants.appHost)" ||
                    (suggestion == "" && currentUrl?.host == NeevaConstants.appHost) {
                Image("neevaMenuIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: LocationTextFieldIconUX.size, height: LocationTextFieldIconUX.size)
    }
}

struct LocationTextFieldIcon_Previews: PreviewProvider {
    static var previews: some View {
        LocationTextFieldIcon(currentUrl: nil)
    }
}
