// Copyright Neeva. All rights reserved.

import Shared
import Storage

public struct NavSuggestion {
    let url: String
    let title: String?
    let subtitle: String?

    init(suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion) {
        url = suggestion.suggestedUrl
        title = suggestion.title
        subtitle = suggestion.subtitle
    }

    init(site: Site) {
        url = site.url
        title = site.title
        subtitle = nil
    }

    init(url: String, title: String) {
        self.url = url
        self.title = title
        subtitle = nil
    }
}

extension NavSuggestion : Equatable {
    public static func == (lhs: NavSuggestion, rhs: NavSuggestion) -> Bool {
        return URL(string: lhs.url)?.normalizedHostAndPathForDisplay ?? lhs.url ==
            URL(string: rhs.url)?.normalizedHostAndPathForDisplay ?? rhs.url
    }
}

extension NavSuggestion : Identifiable {
    public var id: String {
        return "nav-\(url)"
    }
}
