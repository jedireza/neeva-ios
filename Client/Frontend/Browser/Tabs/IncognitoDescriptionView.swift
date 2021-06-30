// Copyright Neeva. All rights reserved.

import SwiftUI

struct IncognitoDescriptionView: View {
    let circleDiameter: CGFloat = 48
    let iconSize: CGFloat = 24
    let lineSpacing: CGFloat = 12
    let borderPadding: CGFloat = 14
    let maxTextWidth: CGFloat = 380
    let descriptionFontSmall = Font.system(size: 12)

    // TODO: Refactor to share code with BoldSpanView
    struct BoldSpan: View {
        private let string: String

        init(_ string: String) {
            self.string = string
        }

        private struct TextSpan {
            let string: Substring
            let bolded: Bool
        }

        // Takes as input strings of the form "foo *bar* baz" with a goal of
        // marking asterisk-bounded substrings as bolded.
        private func textSpans(for string: String) -> [TextSpan] {
            let substrings = string.split(separator: "*")
            var spans: [TextSpan] = []
            var bolded: Bool = false
            for s in substrings {
                spans.append(TextSpan(string: s, bolded: bolded))
                bolded.toggle()
            }
            return spans
        }

        var body: some View {
            textSpans(for: string).enumerated().reduce(Text("")) {
                return $0 + Text($1.element.string).fontWeight($1.element.bolded ? .bold : .regular)
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                Circle()
                    .frame(width: circleDiameter, height: circleDiameter)
                    .overlay(
                        Image("incognito")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black)
                            .frame(width: iconSize))

                Text(verbatim: .IncognitoOnTitle)
                    .withFont(.headingMedium)
                    .foregroundColor(Color(UIColor.label.darkVariant))
                    .padding([.top, .bottom], lineSpacing)

                VStack(alignment: .leading, spacing: lineSpacing) {
                    BoldSpan(.IncognitoDescriptionParagraph1)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(alignment: .leading)
                        .withFont(unkerned: .bodyLarge)
                    BoldSpan(.IncognitoDescriptionParagraph2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(alignment: .leading)
                        .withFont(unkerned: .bodyLarge)
                    BoldSpan(.IncognitoDescriptionParagraph3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(alignment: .leading)
                        .withFont(unkerned: .bodyXSmall)
                }
                .foregroundColor(.secondaryLabel)
                .frame(maxWidth: maxTextWidth)
                .padding([.leading, .trailing], borderPadding)
                Spacer()
            }
            .padding(.top, borderPadding)
            .padding(.bottom, borderPadding + 8)
            Spacer()
        }
        .background(Color.elevatedDarkBackground)
        .colorScheme(.dark)
    }
}

struct IncognitoDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        IncognitoDescriptionView()
            .previewLayout(.sizeThatFits)
    }
}
