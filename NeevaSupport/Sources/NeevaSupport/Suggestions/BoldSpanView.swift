import SwiftUI

/// A range in a string.
/// The offsets represent indexes into the UTF-16 representation of the string
/// which matches JavaScript’s string indices
protocol BoldSpan {
    var startInclusive: Int { get }
    var endExclusive: Int { get }
}
extension SuggestionsQuery.Data.Suggest.QuerySuggestion.BoldSpan: BoldSpan {}
extension SuggestionsQuery.Data.Suggest.UrlSuggestion.BoldSpan: BoldSpan {}

/// Highlights prtions of a provided string
struct BoldSpanView: View {
    let text: String
    let boldSpan: [BoldSpan]

    /// - Parameters:
    ///   - text: the text to highlight
    ///   - spans: the spans to render in boldface
    init(_ text: String, bolding spans: [BoldSpan]) {
        self.text = text
        self.boldSpan = spans
    }

    var body: some View {
        if boldSpan.isEmpty {
            Text(text)
        } else {
            let start = String.Index(utf16Offset: boldSpan[0].startInclusive, in: text)
            boldSpan.enumerated().reduce(Text(text[..<start])) {
                let (i, span) = $1
                let start = String.Index(utf16Offset: span.startInclusive, in: text)
                let endExclusive = String.Index(utf16Offset: span.endExclusive, in: text)
                let nextStart = i == boldSpan.endIndex - 1
                    ? text.endIndex
                    : String.Index(utf16Offset: boldSpan[i + 1].startInclusive, in: text)
                return $0
                    + Text(text[start..<endExclusive]).fontWeight(.bold)
                    + Text(text[endExclusive..<nextStart])
            }
        }
    }
}

struct BoldSpanView_Previews: PreviewProvider {
    static var previews: some View {
        BoldSpanView(
            "How was your Neeva onboarding?",
            bolding: [SuggestionsQuery.Data.Suggest.QuerySuggestion.BoldSpan(startInclusive: 13, endExclusive: 29)]
        )
    }
}
