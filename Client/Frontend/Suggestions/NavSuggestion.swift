// Copyright Neeva. All rights reserved.

import Shared
import Storage

public struct NavSuggestion {
    let url: URL
    let title: String?
    let subtitle: String?

    init?(suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion) {
        guard let url = suggestion.suggestedUrl.asURL else { return nil }
        self.url = url
        title = suggestion.title
        subtitle = suggestion.subtitle
    }

    init(site: Site) {
        url = site.url
        title = site.title
        subtitle = nil
    }

    init(url: URL, title: String) {
        self.url = url
        self.title = title
        subtitle = nil
    }
}

extension NavSuggestion : Equatable {
    public static func == (lhs: NavSuggestion, rhs: NavSuggestion) -> Bool {
        lhs.url.normalizedHostAndPathForDisplay == rhs.url.normalizedHostAndPathForDisplay
    }
}

extension NavSuggestion : Identifiable {
    public var id: String {
        return "nav-\(url)"
    }
}
