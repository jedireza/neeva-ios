// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

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
    // Represents a substring that may be bolded.
    private struct TextSpan {
        let text: Substring
        let bolded: Bool
    }
    private let textSpans: [TextSpan]

    /// - Parameters:
    ///   - text: the text to highlight
    ///   - boldSpans: the spans to render in boldface
    init(_ text: String, unboldedSpans: [BoldSpan]) {
        textSpans = BoldSpanView.generateTextSpans(text: text, unboldedSpans: BoldSpanView.getValidSpans(unboldedSpans, in: text))
    }

    var body: some View {
        textSpans.enumerated().reduce(Text("")) {
            return $0 + createText(forSpan: $1.element)
        }
    }

    private static func isValidSpan(_ span: BoldSpan, in text: String) -> Bool {
        if span.startInclusive >= span.endExclusive {
            return false
        }
        if String.Index(utf16Offset: span.startInclusive, in: text) >= text.endIndex {
            return false
        }
        if String.Index(utf16Offset: span.endExclusive, in: text) > text.endIndex {
            return false
        }
        return true
    }

    private static func getValidSpans(_ spans: [BoldSpan], in text: String) -> [BoldSpan] {
        var validSpans: [BoldSpan] = []
        for span in spans {
            if isValidSpan(span, in: text) {
                validSpans.append(span)
            } else {
                // TODO: log bad input from the server
                print("WARNING: ignoring invalid bold span [\(span.startInclusive), \(span.endExclusive)]")
            }
        }
        return validSpans
    }

    private static func generateTextSpans(text: String, unboldedSpans: [BoldSpan]) -> [TextSpan] {
        var spans: [TextSpan] = []
        var textStart = text.startIndex
        for unboldedSpan in unboldedSpans {
            let unBoldStart = String.Index(utf16Offset: unboldedSpan.startInclusive, in: text)
            let unBoldEndExclusive = String.Index(utf16Offset: unboldedSpan.endExclusive, in: text)
            
            if textStart < unBoldStart {
                spans.append(TextSpan(text: text[textStart..<unBoldStart], bolded: true))
            }
            
            spans.append(TextSpan(text: text[unBoldStart..<unBoldEndExclusive], bolded: false))
            textStart = unBoldEndExclusive
        }
        if textStart < text.endIndex {
            spans.append(TextSpan(text: text[textStart..<text.endIndex], bolded: true))
        }
        return spans
    }

    private func createText(forSpan span: TextSpan) -> Text {
        var text = Text(span.text)
        if span.bolded {
            text = text.fontWeight(.bold)
        }
        return text
    }
}

struct BoldSpanView_Previews: PreviewProvider {
    static var previews: some View {
        BoldSpanView(
            "How was your Neeva onboarding?",
            unboldedSpans: [SuggestionsQuery.Data.Suggest.QuerySuggestion.BoldSpan(startInclusive: 13, endExclusive: 29)]
        )
    }
}
