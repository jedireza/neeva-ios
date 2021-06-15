// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

/// Renders a provided suggestion
public struct SuggestionView: View {
    let suggestion: Suggestion
    let activeLensOrBang: ActiveLensBangInfo?

    /// - Parameters:
    ///   - suggestion: The suggestion to display
    ///   - setInput: Set the user’s input to the provided string (called when tapping the 􀄮 (`arrow.up.left`) icon)
    public init(_ suggestion: Suggestion, activeLensOrBang: ActiveLensBangInfo?) {
        self.suggestion = suggestion
        self.activeLensOrBang = activeLensOrBang
    }

    @ViewBuilder public var body: some View {
        switch suggestion {
        case .query(let suggestion):
            QuerySuggestionView(suggestion: suggestion, activeLensOrBang: activeLensOrBang)
        case .url(let suggestion):
            URLSuggestionView(suggestion: suggestion)
        case .bang(let suggestion):
            BangSuggestionView(suggestion: suggestion)
        case .lens(let suggestion):
            LensSuggestionView(suggestion: suggestion)
        }
    }
}

fileprivate struct SuggestionRow<Icon: View, Label: View, SecondaryLabel: View, Detail: View>: View {
    let action: () -> ()
    let icon: () -> Icon
    let label: () -> Label
    let secondaryLabel: () -> SecondaryLabel
    let detail: () -> Detail

    init(
        action: @escaping () -> (),
        @ViewBuilder icon: @escaping () -> Icon,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder secondaryLabel: @escaping () -> SecondaryLabel,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.action = action
        self.icon = icon
        self.label = label
        self.secondaryLabel = secondaryLabel
        self.detail = detail
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                icon()
                    .foregroundColor(.secondaryLabel)
                    .frame(width: 32, alignment: .leading)
                VStack(alignment: .leading) {
                    label()
                    secondaryLabel()
                }.padding(.leading, 4)
                Spacer()
                detail()
                    .foregroundColor(.secondaryLabel)
                    .font(.callout)
            }
        }
    }
}

/// Renders a query suggestion
fileprivate struct QuerySuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.QuerySuggestion
    let activeLensOrBang: ActiveLensBangInfo?

    @Environment(\.setSearchInput) private var setInput
    @Environment(\.onOpenURL) private var openURL

    var suggestedQuery: String {
        if let shortcut = activeLensOrBang?.shortcut,
           let sigil = activeLensOrBang?.type?.sigil {
            return sigil + shortcut + " " + suggestion.suggestedQuery
        } else {
            return suggestion.suggestedQuery
        }
    }

    var body: some View {
        SuggestionRow {
            openURL(neevaSearchEngine.searchURLForQuery(suggestedQuery)!)
        } icon: {
            if let activeType = activeLensOrBang?.type {
                Symbol(activeType.defaultSymbol)
            } else {
                switch suggestion.type {
                case .searchHistory:
                    Symbol(.clock)
                case .space: // unused?
                    SpaceIconView()
                case .standard:
                    Symbol(.magnifyingglass)
                case .operator, .unknown, .__unknown(_): // seemingly unused
                    Symbol(.questionmarkCircle).foregroundColor(.secondaryLabel)
                }
            }
        } label: {
            BoldSpanView(suggestion.suggestedQuery, unboldedSpans: suggestion.boldSpan)
                .lineLimit(1)
        } secondaryLabel: {
            EmptyView()
        } detail: {
            if suggestion.type != .space {
                Button(action: { setInput(suggestedQuery) }) {
                    Symbol(.arrowUpLeft)
                        .foregroundColor(.tertiaryLabel)
                }.buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

/// Renders a URL suggestion (and its associated icon)
fileprivate struct URLSuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion

    @Environment(\.onOpenURL) private var openURL

    var body: some View {
        SuggestionRow {
            openURL(URL(string: suggestion.suggestedUrl)!)
        } icon: {
            if let labels = suggestion.icon.labels,
               let image = Image(icons: labels) {
                image
            } else if let subtitle = suggestion.subtitle, !subtitle.isEmpty,
                      let url = suggestion.suggestedUrl {
                FaviconView(site: Site(url: url, title: subtitle),
                            size: SearchViewControllerUX.IconSize,
                            bordered: true)
                    .frame(
                        width: SearchViewControllerUX.ImageSize,
                        height: SearchViewControllerUX.ImageSize
                    )
                    .cornerRadius(4)
            } else {
                Symbol(.questionmarkDiamondFill)
                    .foregroundColor(.red)
            }
        } label: {
            if let subtitle = suggestion.subtitle, !subtitle.isEmpty {
                Text(subtitle).foregroundColor(.primary).font(.caption).lineLimit(1)
            } else if let title = suggestion.title {
                BoldSpanView(title, unboldedSpans: suggestion.boldSpan).lineLimit(1)
            } else {
                Text(suggestion.suggestedUrl).lineLimit(1)
            }
        } secondaryLabel: {
            if !(suggestion.subtitle?.isEmpty ?? true), let title = suggestion.title,
               let url = suggestion.suggestedUrl {
                Text(URL(string: url)?.baseDomain ?? title)
                    .foregroundColor(.secondaryLabel).font(.caption).lineLimit(1)
            }
        } detail: {
            if let formatted = format(suggestion.timestamp, as: .full) {
                Text(formatted)
            }
        }
    }
}

fileprivate struct BangSuggestionView: View {
    let suggestion: Suggestion.Bang

    @Environment(\.setSearchInput) private var setInput

    var body: some View {
        let query = "!\(suggestion.shortcut)"
        SuggestionRow {
            setInput(query + " ")
        } icon: {
            Symbol(ActiveLensBangType.bang.defaultSymbol)
        } label: {
            Text(query)
        } secondaryLabel: {
            EmptyView()
        } detail: {
            Text(suggestion.description)
        }
    }
}

fileprivate struct LensSuggestionView: View {
    let suggestion: Suggestion.Lens

    @Environment(\.setSearchInput) private var setInput

    var body: some View {
        let query = "@\(suggestion.shortcut)"
        SuggestionRow {
            setInput(query + " ")
        } icon: {
            Symbol(ActiveLensBangType.lens.defaultSymbol)
        } label: {
            Text(query)
        } secondaryLabel: {
            EmptyView()
        } detail: {
            Text(suggestion.description)
        }
    }
}


struct SuggestionView_Previews: PreviewProvider {
    static let query =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .standard,
            suggestedQuery: "neeva",
            boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
            source: .bing
        )
    static let historyQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .searchHistory,
            suggestedQuery: "swift set sysroot",
            boldSpan: [.init(startInclusive: 6, endExclusive: 9), .init(startInclusive: 12, endExclusive: 15)],
            source: .elastic
        )
    static let spaceQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            type: .space,
            suggestedQuery: "SavedForLater",
            boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
            source: .elastic
        )

    static let url =
        SuggestionsQuery.Data.Suggest.UrlSuggestion(
            icon: .init(labels: ["google-email", "email"]),
            suggestedUrl: "https://mail.google.com/mail/u/jed@neeva.co/#inbox/1766c8357ae540a5",
            title: "How was your Neeva onboarding?",
            author: "feedback@neeva.co",
            timestamp: "2020-12-16T17:05:12Z",
            boldSpan: [.init(startInclusive: 13, endExclusive: 29)]
        )

    static let bang = Suggestion.Bang(
        shortcut: "w",
        description: "Wikipedia",
        domain: "wikipedia.org"
    )

    static let logoBang = Suggestion.Bang(
        shortcut: "imdb",
        description: "IMDb",
        domain: "imdb.com"
    )

    static let noDomainBang = Suggestion.Bang(
        shortcut: "zillow",
        description: "Zillow",
        domain: nil
    )

    static let lens = Suggestion.Lens(
        shortcut: "my",
        description: "Search my personal data"
    )

    static var previews: some View {
        List {
            Section(header: Text("Query").textCase(nil)) {
                QuerySuggestionView(suggestion: spaceQuery, activeLensOrBang: nil)
                QuerySuggestionView(suggestion: query, activeLensOrBang: nil)
                QuerySuggestionView(suggestion: historyQuery, activeLensOrBang: nil)
            }
            Section(header: Text("Query — Bang active").textCase(nil)) {
                QuerySuggestionView(suggestion: query, activeLensOrBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .bang))
                QuerySuggestionView(suggestion: historyQuery, activeLensOrBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .bang))
            }
            Section(header: Text("Query — Lens active").textCase(nil)) {
                QuerySuggestionView(suggestion: query, activeLensOrBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .lens))
                QuerySuggestionView(suggestion: historyQuery, activeLensOrBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .lens))
            }
            Section(header: Text("URL, Bang, and Lens").textCase(nil)) {
                URLSuggestionView(suggestion: url)
                BangSuggestionView(suggestion: bang)
                BangSuggestionView(suggestion: noDomainBang)
                LensSuggestionView(suggestion: lens)
            }
        }.environment(\.setSearchInput) { _ in }
    }
}
