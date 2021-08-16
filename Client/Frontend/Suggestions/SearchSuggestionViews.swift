// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

enum SuggestionViewUX {
    static let ThumbnailSize: CGFloat = 36
    static let CornerRadius: CGFloat = 4
    static let Padding: CGFloat = 12
    static let ChipPadding: CGFloat = 8
    static let ChipInnerPadding: CGFloat = 10
    static let RowHeight: CGFloat = 58
}

enum SuggestionState {
    case normal
    case focused

    var color: Color {
        switch self {
        case .normal:
            return .clear
        case .focused:
            return .selectedCell
        }
    }
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
        case .navigation(let nav):
            NavSuggestionView(suggestion: nav)
        case .tabSuggestion(let tab):
            TabSuggestionView(suggestion: tab)
        }
    }
}

public enum SuggestionConfig {
    case row
    case chip
}

struct SuggestionSpec: ViewModifier {
    let config: SuggestionConfig
    var suggestionState: SuggestionState

    func body(content: Content) -> some View {
        switch config {
        case .row:
            content
                .frame(height: SuggestionViewUX.RowHeight)
                .padding(.horizontal, SuggestionViewUX.Padding)
                .background(suggestionState.color)
                .hoverEffect()
        case .chip:
            content.padding(SuggestionViewUX.ChipInnerPadding)
                .background(suggestionState.color)
                .overlay(Capsule().stroke(Color(UIColor.Browser.urlBarDivider), lineWidth: 1))
                .contentShape(Capsule())
                .hoverEffect()
        }
    }
}

struct ClipShape: ViewModifier {
    let config: SuggestionConfig

    func body(content: Content) -> some View {
        switch config {
        case .row:
            content.clipped()
        case .chip:
            content.clipShape(Capsule())
        }
    }
}

extension View {
    fileprivate func apply(config: SuggestionConfig, suggestionState: SuggestionState) -> some View
    {
        self.modifier(SuggestionSpec(config: config, suggestionState: suggestionState))
    }
}

struct SuggestionView<Icon: View, Label: View, SecondaryLabel: View, Detail: View>: View {
    let action: (() -> Void)?
    let icon: Icon
    let label: Label
    let secondaryLabel: SecondaryLabel
    let detail: Detail
    let suggestion: Suggestion?

    @State var suggestionState: SuggestionState = .normal
    @EnvironmentObject public var suggestionModel: SuggestionModel
    @Environment(\.suggestionConfig) private var config

    var body: some View {
        Button {
            if let suggestion = suggestion {
                suggestionModel.handleSuggestionSelected(suggestion)
            }

            action?()
        } label: {
            HStack(spacing: 0) {
                icon.foregroundColor(.tertiaryLabel)
                    .frame(
                        width: SearchViewControllerUX.IconSize,
                        height: SearchViewControllerUX.IconSize)
                VStack(alignment: .leading, spacing: 0) {
                    label
                    secondaryLabel
                }.padding(
                    .leading,
                    config == .row ? SuggestionViewUX.Padding : SuggestionViewUX.ChipPadding)
                if case .row = config {
                    Spacer(minLength: 0)
                    detail
                        .foregroundColor(.secondaryLabel)
                        .font(.callout)
                }
            }.apply(config: config, suggestionState: suggestionState)
        }
        .buttonStyle(TableCellButtonStyle())
        .modifier(ClipShape(config: config))
        .accentColor(.primary)
        .useEffect(deps: suggestionModel.keyboardFocusedSuggestion) { _ in
            if let suggestion = suggestion, suggestionModel.isFocused(suggestion) {
                suggestionState = .focused
            } else {
                suggestionState = .normal
            }
        }
    }
}

/// Renders a query suggestion
struct QuerySuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.QuerySuggestion

    @EnvironmentObject public var model: SuggestionModel
    @Environment(\.setSearchInput) private var setInput
    @Environment(\.suggestionConfig) private var config

    var suggestedQuery: String {
        if let lensOrBang = model.activeLensBang,
            let shortcut = lensOrBang.shortcut,
            let sigil = lensOrBang.type?.sigil
        {
            return sigil + shortcut + " " + suggestion.suggestedQuery
        } else {
            return suggestion.suggestedQuery
        }
    }

    @ViewBuilder
    var icon: some View {
        if AnnotationType(annotation: suggestion.annotation) == .stock {
            if isPositiveStockChange(suggestion.annotation) {
                Symbol(decorative: .arrowtriangleUpFill)
                    .foregroundColor(.green)
                    .padding(.bottom, 18)
            } else {
                Symbol(decorative: .arrowtriangleDownFill)
                    .foregroundColor(.red)
                    .padding(.bottom, 18)
            }
        } else if AnnotationType(annotation: suggestion.annotation) == .calculator {
            Image("calculator")
        } else if let activeType = model.activeLensBang?.type {
            Symbol(decorative: activeType.defaultSymbol)
        } else if let annotation = suggestion.annotation, let imageUrl = annotation.imageUrl,
            AnnotationType(annotation: suggestion.annotation) == .wikipedia
        {
            WebImage(url: URL(string: imageUrl))
                .resizable()
                .placeholder {
                    Color.tertiarySystemFill
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(SuggestionViewUX.CornerRadius)
                .frame(
                    width: SuggestionViewUX.ThumbnailSize,
                    height: SuggestionViewUX.ThumbnailSize
                )
        } else {
            switch suggestion.type {
            case .searchHistory:
                Symbol(decorative: .clock)
            case .space:  // unused?
                SpaceIconView()
            case .standard:
                Symbol(decorative: .magnifyingglass)
            case .operator, .unknown, .__unknown(_):  // seemingly unused
                Symbol(decorative: .questionmarkCircle).foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    var label: some View {
        if AnnotationType(annotation: suggestion.annotation) == .stock {
            HStack {
                Text(String(suggestion.annotation?.stockInfo?.currentPrice ?? 0.0))
                    .withFont(.bodyLarge)
                if let changeFromPreivousClose =
                    suggestion.annotation?.stockInfo?.changeFromPreviousClose,
                    let percentChangeFromPreviousClose =
                        suggestion.annotation?.stockInfo?.percentChangeFromPreviousClose
                {
                    if isPositiveStockChange(suggestion.annotation) {
                        Text(
                            "+\(String(changeFromPreivousClose)) "
                                + "(\(String(percentChangeFromPreviousClose))%)"
                        )
                        .withFont(.bodyMedium)
                        .accentColor(.green)
                    } else {
                        Text(
                            "\(String(changeFromPreivousClose)) "
                                + "(\(String(percentChangeFromPreviousClose))%)"
                        )
                        .withFont(.bodyMedium)
                        .accentColor(.red)
                    }
                }
                Spacer()
                Text("\(suggestion.annotation?.stockInfo?.fetchedAtTime ?? "")")
                    .withFont(.bodySmall)
                    .accentColor(.gray)
                    .alignmentGuide(.trailing) { d in d[.trailing] }
                    .padding(.trailing, 5)
            }
            .lineLimit(1)
        } else if AnnotationType(annotation: suggestion.annotation) == .calculator {
            Text(suggestion.annotation?.description ?? "")
                .withFont(.bodyLarge)
                .lineLimit(1)
        } else if AnnotationType(annotation: suggestion.annotation) == .wikipedia {
            Text(suggestion.suggestedQuery.capitalized)
                .withFont(.bodyLarge)
                .lineLimit(1)
        } else {
            Text(suggestion.suggestedQuery)
                .withFont(.bodyLarge)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        if AnnotationType(annotation: suggestion.annotation) == .stock {
            HStack {
                Text("\(String(suggestion.annotation?.stockInfo?.companyName ?? ""))")
                    .withFont(.bodySmall)
                    .lineLimit(1)
                Text("\(String(suggestion.annotation?.stockInfo?.ticker ?? ""))")
                    .withFont(.bodySmall)
                    .lineLimit(1)
                    .accentColor(.gray)
            }
        } else if let suggestedCalculatorQuery = suggestion.suggestedCalculatorQuery(),
            AnnotationType(annotation: suggestion.annotation) == .calculator
        {
            Text(suggestedCalculatorQuery).withFont(.bodySmall)
                .foregroundColor(.secondaryLabel).lineLimit(1)
        } else if let annotation = suggestion.annotation, let description = annotation.description,
            AnnotationType(annotation: suggestion.annotation) == .wikipedia
        {
            Text(description).withFont(.bodySmall)
                .foregroundColor(.secondaryLabel).lineLimit(1)
        } else {
            EmptyView()
        }

    }

    @ViewBuilder
    var detail: some View {
        if suggestion.type != .space {
            Button(action: { setInput(suggestedQuery) }) {
                Symbol(decorative: .arrowUpLeft)
                    .foregroundColor(.tertiaryLabel)
            }.buttonStyle(BorderlessButtonStyle())
        }
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: detail,
            suggestion: Suggestion.query(suggestion)
        )
        .environmentObject(model)
    }

    func isPositiveStockChange(
        _ annotation: SuggestionsQuery.Data.Suggest.QuerySuggestion.Annotation?
    ) -> Bool {
        return annotation?.stockInfo?.changeFromPreviousClose ?? 0.0 > 0
    }
}

/// Renders a URL suggestion (and its associated icon)
struct URLSuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion

    @EnvironmentObject public var model: SuggestionModel

    @ViewBuilder
    var icon: some View {
        if let labels = suggestion.icon.labels,
            let image = Image(icons: labels)
        {
            image
        } else if let subtitle = suggestion.subtitle, !subtitle.isEmpty,
            let url = URL(string: suggestion.suggestedUrl)
        {
            FaviconView(
                url: url,
                size: SearchViewControllerUX.FaviconSize,
                bordered: false
            )
            .frame(
                width: SearchViewControllerUX.IconSize,
                height: SearchViewControllerUX.IconSize
            )
            .cornerRadius(SuggestionViewUX.CornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: SuggestionViewUX.CornerRadius)
                    .stroke(Color.quaternarySystemFill, lineWidth: 1))
        } else {
            Symbol(decorative: .questionmarkDiamondFill)
                .foregroundColor(.red)
        }
    }

    @ViewBuilder
    var label: some View {
        if let subtitle = suggestion.subtitle, !subtitle.isEmpty {
            Text(subtitle).withFont(.bodyLarge).foregroundColor(.primary).lineLimit(1)
        } else if let title = suggestion.title {
            Text(title).withFont(.bodyLarge).lineLimit(1)
        } else {
            Text(suggestion.suggestedUrl).withFont(.bodyLarge).lineLimit(1)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        if !(suggestion.subtitle?.isEmpty ?? true), let title = suggestion.title {
            Text(URL(string: suggestion.suggestedUrl)?.normalizedHostAndPathForDisplay ?? title)
                .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
        }
    }

    @ViewBuilder
    var detail: some View {
        if let formatted = format(suggestion.timestamp, as: .full) {
            Text(formatted)
        }
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: label,
            secondaryLabel: secondaryLabel,
            detail: detail,
            suggestion: Suggestion.url(suggestion)
        )
        .environmentObject(model)
    }
}

private struct BangSuggestionView: View {
    let suggestion: Suggestion.Bang

    @EnvironmentObject public var model: SuggestionModel

    var body: some View {
        SuggestionView(
            action: nil,
            icon: Symbol(decorative: ActiveLensBangType.bang.defaultSymbol),
            label: Text("!\(suggestion.shortcut)"),
            secondaryLabel: EmptyView(),
            detail: Text(suggestion.description),
            suggestion: Suggestion.bang(suggestion)
        )
        .environmentObject(model)
    }
}

private struct LensSuggestionView: View {
    let suggestion: Suggestion.Lens

    @EnvironmentObject public var model: SuggestionModel

    var body: some View {
        SuggestionView(
            action: nil,
            icon: Symbol(decorative: ActiveLensBangType.lens.defaultSymbol),
            label: Text("@\(suggestion.shortcut)"),
            secondaryLabel: EmptyView(),
            detail: Text(suggestion.description),
            suggestion: Suggestion.lens(suggestion)
        )
        .environmentObject(model)
    }
}

private struct TabSuggestionView: View {
    let suggestion: TabCardDetails

    @State var focused: Bool = false
    @EnvironmentObject public var model: SuggestionModel

    @ViewBuilder
    var icon: some View {
        if !suggestion.isSelected {
            Symbol(decorative: .squareOnSquare)
        }
    }

    @ViewBuilder
    var secondaryLabel: some View {
        Text(
            suggestion.isSelected
                ? suggestion.url?.absoluteString ?? ""
                : suggestion.title
        )
        .withFont(.bodySmall).foregroundColor(.secondaryLabel).lineLimit(1)
    }

    @ViewBuilder
    var detailView: some View {
        if suggestion.isSelected {
            HStack {
                Button {
                    UIPasteboard.general.string = suggestion.url?.absoluteString
                    ToastViewManager.shared.makeToast(text: "URL copied to clipboard").enqueue()
                } label: {
                    Symbol(decorative: .squareOnSquare)
                }

            }
        }
    }

    var body: some View {
        SuggestionView(
            action: nil,
            icon: icon,
            label: Text(
                suggestion.isSelected ? suggestion.title : "Switch to Tab"),
            secondaryLabel: secondaryLabel,
            detail: detailView,
            suggestion: Suggestion.tabSuggestion(suggestion)
        )
        .environmentObject(model)
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
            boldSpan: [
                .init(startInclusive: 6, endExclusive: 9),
                .init(startInclusive: 12, endExclusive: 15),
            ],
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
            }.environmentObject(SuggestionModel())

            Section(header: Text("Query — Bang active").textCase(nil)) {
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(SuggestionModel(previewLensBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .bang)))

            Section(header: Text("Query — Lens active").textCase(nil)) {
                QuerySuggestionView(suggestion: query)
                QuerySuggestionView(suggestion: historyQuery)
            }.environmentObject(SuggestionModel(previewLensBang: .init(domain: nil, shortcut: "w", description: "Wikipedia", type: .lens)))

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
