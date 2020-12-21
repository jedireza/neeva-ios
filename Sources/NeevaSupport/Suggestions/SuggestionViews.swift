import SwiftUI

public struct SuggestionView: View {
    let suggestion: Suggestion
    let setInput: (String) -> ()
    let onTap: () -> ()

    public init(
        _ suggestion: Suggestion,
        setInput: @escaping (String) -> (),
        onTap: @escaping () -> ()
    ) {
        self.suggestion = suggestion
        self.setInput = setInput
        self.onTap = onTap
    }

    @ViewBuilder public var body: some View {
        switch suggestion {
        case .query(let suggestion):
            QuerySuggestionView(suggestion: suggestion, setInput: setInput, onTap: onTap)
        case .url(let suggestion):
            URLSuggestionView(suggestion: suggestion, onTap: onTap)
        }
    }
}

struct QuerySuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.QuerySuggestion
    let setInput: (String) -> ()
    let onTap: () -> ()

    var textColor: Color {
        switch suggestion.type {
        case .searchHistory:
            return .purpleVariant
        default:
            return .primary
        }
    }

    @ViewBuilder var icon: some View {
        switch suggestion.type {
        case .searchHistory:
            Image(systemName: "clock").foregroundColor(.secondary)
        case .space:
            SpaceIconView()
        default:
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                icon
                BoldSpanView(
                    suggestion.suggestedQuery,
                    bolding: suggestion.boldSpan.map {
                        BoldSpan(start: $0.startInclusive, end: $0.endExclusive)
                    }
                )
                    .lineLimit(1)
                    .foregroundColor(textColor)
                Spacer()
                if suggestion.type != .space {
                    Button(action: { setInput(suggestion.suggestedQuery) }) {
                        Image(systemName: "arrow.up.left")
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }
}

struct URLSuggestionView: View {
    let suggestion: SuggestionsQuery.Data.Suggest.UrlSuggestion
    let onTap: () -> ()

    var body: some View {
        Button(action: onTap) {
            HStack {
                if let labels = suggestion.icon.labels,
                   let image = Image(icons: labels) {
                    image
                } else {
                    Image(systemName: "questionmark.diamond.fill")
                        .foregroundColor(.red)
                }
                if let title = suggestion.title {
                    BoldSpanView(
                        title,
                        bolding: suggestion.boldSpan.map {
                            BoldSpan(start: $0.startInclusive, end: $0.endExclusive)
                        }
                    ).lineLimit(1)
                } else {
                    Text(suggestion.suggestedUrl).lineLimit(1)
                }
                Spacer()
                if let formatted = format(suggestion.timestamp, as: .full) {
                    Text(formatted).foregroundColor(.secondary)
                }
            }
        }
    }
}

struct SuggestionView_Previews: PreviewProvider {
    static let query =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            suggestedQuery: "neeva",
            type: .standard,
            boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
            source: .bing
        )
    static let historyQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            suggestedQuery: "swift set sysroot",
            type: .searchHistory,
            boldSpan: [.init(startInclusive: 6, endExclusive: 9), .init(startInclusive: 12, endExclusive: 15)],
            source: .elastic
        )
    static let spaceQuery =
        SuggestionsQuery.Data.Suggest.QuerySuggestion(
            suggestedQuery: "SavedForLater",
            type: .space,
            boldSpan: [.init(startInclusive: 0, endExclusive: 5)],
            source: .elastic
        )

    static let url =
        SuggestionsQuery.Data.Suggest.UrlSuggestion(
            icon: .init(labels: ["google-email", "email"]),
            suggestedUrl: "https://mail.google.com/mail/u/jed@neeva.co/#inbox/1766c8357ae540a5",
            author: "feedback@neeva.co",
            timestamp: "2020-12-16T17:05:12Z",
            title: "How was your Neeva onboarding?",
            boldSpan: [.init(startInclusive: 13, endExclusive: 29)]
        )

    static var previews: some View {
            List {
                QuerySuggestionView(suggestion: query, setInput: { _ in }, onTap: {})
                QuerySuggestionView(suggestion: historyQuery, setInput: { _ in }, onTap: {})
                QuerySuggestionView(suggestion: spaceQuery, setInput: { _ in }, onTap: {})
                URLSuggestionView(suggestion: url, onTap: {})
            }
    }
}
