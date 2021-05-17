import SwiftUI

struct IncognitoDescriptionView: View {
    let circleDiameter: CGFloat = 80
    let iconSize: CGFloat = 35
    let lineSpacing: CGFloat = 12
    let gutterWidth: CGFloat = 21
    let maxTextWidth: CGFloat = 380
    let titleFont = Font.system(size: 20, weight: .semibold)
    let descriptionFont = Font.system(size: 16)

    var paragraph3: some View {
        Text(verbatim: .IncognitoDescriptionParagraph3Part1) +
        Text(verbatim: .IncognitoDescriptionParagraph3Part2Bold).fontWeight(.bold) +
        Text(verbatim: .IncognitoDescriptionParagraph3Part3)
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
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize))

                Text(verbatim: .IncognitoOnTitle)
                    .font(titleFont)
                    .padding([.top, .bottom], lineSpacing)

                VStack(alignment: .leading, spacing: lineSpacing) {
                    Text(verbatim: .IncognitoDescriptionParagraph1)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(alignment: .leading)
                    Text(verbatim: .IncognitoDescriptionParagraph2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(alignment: .leading)
                    paragraph3
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(alignment: .leading)
                }
                .font(descriptionFont)
                .foregroundColor(Color(UIColor(rgba: 0xEBEBF599)))  // Dark variant of .secondaryLabel
                .frame(maxWidth: maxTextWidth)
                .padding([.leading, .trailing], gutterWidth)
                Spacer()
            }.padding([.top, .bottom], 20)
            Spacer()
        }
        .background(Color.Neeva.UI.Gray30)
        .foregroundColor(Color.Neeva.UI.Gray96)
        .navigationBarHidden(true)
    }
}

struct IncognitoDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        IncognitoDescriptionView()
    }
}
