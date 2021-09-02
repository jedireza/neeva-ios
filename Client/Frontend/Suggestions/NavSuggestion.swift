// Copyright Neeva. All rights reserved.

import Shared
import Storage

public struct NavSuggestion {
    let url: URL
    let title: String?
    let subtitle: String?
    let isMemorizedNav: Bool

    init?(suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion) {
        guard let url = suggestion.suggestedUrl.asURL else { return nil }
        self.url = url
        title = suggestion.title
        subtitle = suggestion.subtitle
        isMemorizedNav = true
    }

    init(site: Site) {
        url = site.url
        title = site.title
        subtitle = nil
        isMemorizedNav = false
    }

    init(url: URL, title: String, isMemorizedNav: Bool = false) {
        self.url = url
        self.title = title
        subtitle = nil
        self.isMemorizedNav = isMemorizedNav
    }
}

extension NavSuggestion: Equatable {
    public static func == (lhs: NavSuggestion, rhs: NavSuggestion) -> Bool {
        lhs.url.normalizedHostAndPathForDisplay == rhs.url.normalizedHostAndPathForDisplay
    }
}

extension NavSuggestion: Identifiable {
    public var id: String {
        return "nav-\(url)"
    }
}
