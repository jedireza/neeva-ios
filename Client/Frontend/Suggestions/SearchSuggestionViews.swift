// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage
import SDWebImageSwiftUI

enum SuggestionViewUX {
    static let ThumbnailSize: CGFloat = 36
    static let CornerRadius: CGFloat = 4
    static let Padding: CGFloat = 12
    static let ChipPadding: CGFloat = 4
    static let RowHeight: CGFloat = 58
}

/// Renders a provided suggestion
public struct SearchSuggestionView: View {
    let suggestion: Suggestion

    public init(_ suggestion: Suggestion) {
        self.suggestion = suggestion
    }

    @ViewBuilder public var body: some View {
        switch suggestion {
        case .query(let suggestion):
            QuerySuggestionView(suggestion: suggestion)
        case .url(let suggestion):
            URLSuggestionView(suggestion: suggestion)
        case .bang(let suggestion):
            BangSuggestionView(suggestion: suggestion)
        case .lens(let suggestion):
            LensSuggestionView(suggestion: suggestion)
        }
    }
}

public enum SuggestionConfig {
    case row
    case chip
}

struct SuggestionSpec: ViewModifier {
    let config: SuggestionConfig

    func body(content: Content) -> some View {
        switch config {
        case .row:
            content
                .frame(height: SuggestionViewUX.RowHeight)
                .padding(.horizontal, SuggestionViewUX.Padding)
        case .chip:
            content.padding(6)
                .background(Color.DefaultBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color(UIColor.Browser.urlBarDivider), lineWidth: 1))
        }
    }
}

private extension View {
    func apply(config: SuggestionConfig) -> some View {
        self.modifier(SuggestionSpec(config: config))
    }
}

struct SuggestionView<Icon: View, Label: View, SecondaryLabel: View, Detail: View>: View {
    let action: () -> ()
    let icon: () -> Icon
    let label: () -> Label
    let secondaryLabel: () -> SecondaryLabel
    let detail: () -> Detail

    @Environment(\.suggestionConfig) private var config

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
                icon().foregroundColor(.secondaryLabel)
                VStack(alignment: .leading, spacing: 0) {
                    label()
                    secondaryLabel()
                }.padding(.leading, config == .row ?
                            SuggestionViewUX.Padding : SuggestionViewUX.ChipPadding)
                if case .row = config {
                    Spacer(minLength: 0)
                    detail()
                        .foregroundColor(.secondaryLabel)
                        .font(.callout)
                }
            }.apply(config: config)
        }.accentColor(.primary)
        .buttonStyle(TableCellButtonStyle())
    }
}

/// Renders a query suggestion
struct QuerySuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.QuerySuggestion

    @EnvironmentObject private var model: NeevaSuggestionModel
    @Environment(\.setSearchInput) private var setInput
    @Environment(\.onOpenURL) private var openURL
    @Environment(\.suggestionConfig) private var config

    var suggestedQuery: String {
        if let lensOrBang = model.activeLensBang,
           let shortcut = lensOrBang.shortcut,
           let sigil = lensOrBang.type?.sigil {
            return sigil + shortcut + " " + suggestion.suggestedQuery
        } else {
            return suggestion.suggestedQuery
        }
    }

    var body: some View {
        SuggestionView {
            let interaction: LogConfig.Interaction = model.activeLensBang != nil
                ? .BangSuggestion : .QuerySuggestion
            ClientLogger.shared.logCounter(interaction)
            openURL(neevaSearchEngine.searchURLForQuery(suggestedQuery)!)
        } icon: {
            if let activeType = model.activeLensBang?.type {
                Symbol(activeType.defaultSymbol)
            } else if let annotation = suggestion.annotation, let imageUrl = annotation.imageUrl {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .placeholder {
                        Color.tertiarySystemFill
                    }.aspectRatio(contentMode: .fit)
                    .frame(width: SuggestionViewUX.ThumbnailSize,
                           height: SuggestionViewUX.ThumbnailSize)
                    .cornerRadius(SuggestionViewUX.CornerRadius)
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
            Text(suggestion.suggestedQuery)
                .withFont(.bodyLarge)
                .lineLimit(1)
        } secondaryLabel: {
            if let annotation = suggestion.annotation, let description = annotation.description {
                Text(description).withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel).lineLimit(1)
            } else {
                EmptyView()
            }
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
struct URLSuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion

    @Environment(\.onOpenURL) private var openURL

    var body: some View {
        SuggestionView {
            let interaction: LogConfig.Interaction = suggestion.title?.isEmpty ?? false ?
                .NavSuggestion : .URLSuggestion
            ClientLogger.shared.logCounter(interaction)

            openURL(URL(string: suggestion.suggestedUrl)!)
        } icon: {
            if let labels = suggestion.icon.labels,
               let image = Image(icons: labels) {
                image
            } else if let subtitle = suggestion.subtitle, !subtitle.isEmpty,
                      let url = URL(string: suggestion.suggestedUrl) {
                FaviconView(url: url,
                            size: SearchViewControllerUX.IconSize,
                            bordered: true)
                    .frame(
                        width: SearchViewControllerUX.IconSize,
                        height: SearchViewControllerUX.IconSize
                    )
                    .cornerRadius(SuggestionViewUX.CornerRadius)
            } else {
                Symbol(.questionmarkDiamondFill)
                    .foregroundColor(.red)
            }
        } label: {
            if let subtitle = suggestion.subtitle, !subtitle.isEmpty {
                Text(subtitle).withFont(.bodyLarge).foregroundColor(.primary).lineLimit(1)
            } else if let title = suggestion.title {
                Text(title).withFont(.bodyLarge).lineLimit(1)
            } else {
                Text(suggestion.suggestedUrl).withFont(.bodyLarge).lineLimit(1)
            }
        } secondaryLabel: {
            if !(suggestion.subtitle?.isEmpty ?? true), let title = suggestion.title,
               let url = suggestion.suggestedUrl {
                Text(URL(string: url)?.normalizedHostAndPathForDisplay ?? title)
                    .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
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
        SuggestionView {
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
        SuggestionView {
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
                QuerySuggestionView(suggestion: spaceQuery)
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(NeevaSuggestionModel(previewLensBang: nil))
            Section(header: Text("Query — Bang active").textCase(nil)) {
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(NeevaSuggestionModel(previewLensBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .bang)))
            Section(header: Text("Query — Lens active").textCase(nil)) {
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(NeevaSuggestionModel(previewLensBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .lens)))
            Section(header: Text("URL, Bang, and Lens").textCase(nil)) {
                URLSuggestionView(suggestion: url)
                BangSuggestionView(suggestion: bang)
                BangSuggestionView(suggestion: noDomainBang)
                LensSuggestionView(suggestion: lens)
            }
        }
        .environment(\.setSearchInput) { _ in }
    }
}
