import SwiftUI

public struct BoldSpan {
    let start: Int
    let end: Int
    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}

public struct BoldSpanView: View {
    let text: String
    let boldSpan: [BoldSpan]
    public init(_ text: String, bolding spans: [BoldSpan]) {
        self.text = text
        self.boldSpan = spans
    }

    func buildText() -> Text {
        if boldSpan.isEmpty {
            return Text(text)
        } else {
            let start = String.Index(utf16Offset: boldSpan[0].start, in: text)
            return boldSpan.enumerated().reduce(Text(text[..<start])) {
                let (i, span) = $1
                let start = String.Index(utf16Offset: span.start, in: text)
                let end = String.Index(utf16Offset: span.end, in: text)
                let nextStart = i == boldSpan.endIndex - 1
                    ? text.endIndex
                    : String.Index(utf16Offset: boldSpan[i + 1].start, in: text)
                print(start, end)
                return $0
                    + Text(text[start..<end]).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    + Text(text[end..<nextStart])
            }
        }
    }
    public var body: some View {
        buildText()
    }
}

struct BoldSpanView_Previews: PreviewProvider {
    static var previews: some View {
        BoldSpanView(
            "How was your Neeva onboarding?",
            bolding: [.init(start: 13, end: 29)]
        )
    }
}
