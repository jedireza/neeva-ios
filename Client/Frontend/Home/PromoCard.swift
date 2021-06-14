// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

private enum PromoCardUX {
    static let CornerRadius: CGFloat = 24
    static let ButtonFontSize: CGFloat = 17
    static let TextFontSize: CGFloat = 21
    static let TextColor: UIColor = UIColor(rgb: 0x131415)
}

struct PromoCardConfig {
    let firstLine: String
    let secondLine: String
    let buttonLabel: String
    let buttonImage: Image?
    let backgroundColor: Color
    let showDismissButton: Bool
}

enum PromoCardType {
    case neevaSignIn
    case defaultBrowser

    static func getConfig(for type: PromoCardType) -> PromoCardConfig {
        switch type {
        case .neevaSignIn:
            return PromoCardConfig(firstLine: "Get safer, richer and better",
                                   secondLine: "search when you sign in",
                                   buttonLabel: "Sign in or Join Neeva",
                                   buttonImage: Image("neevaMenuIcon"),
                                   backgroundColor: .neeva.brand.polar,
                                   showDismissButton: false)
        case .defaultBrowser:
            return PromoCardConfig(firstLine: "Browse in peace,",
                                   secondLine: "always",
                                   buttonLabel: "Set as Default Browser",
                                   buttonImage: nil,
                                   backgroundColor: .neeva.brand.pistachio,
                                   showDismissButton: true)
        }
    }
}

struct PromoCard: View {
    @ObservedObject var model: HomeViewModel

    var isTabletOrLandscape:Bool {
        return UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation.isLandscape
    }

    var button: some View {
        Button(action: {
            model.buttonClickHandler()
        }, label: {
            HStack(spacing: 20) {
                if let image = model.currentConfig.buttonImage {
                    image.renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 18, height: 16)
                }
                Text(model.currentConfig.buttonLabel)
                    .font(Font(UIFont.systemFont(ofSize: PromoCardUX.ButtonFontSize, weight: .semibold)))
                    .foregroundColor(Color.white)
            }.padding(.vertical).padding(.horizontal, 20).frame(maxWidth: .infinity, alignment: .center)
            .background(Color.neeva.brand.blue.colorScheme(.light))
            .clipShape(RoundedRectangle(cornerRadius: PromoCardUX.CornerRadius))
            .padding(.horizontal, 10)
        })
    }

    var label: some View {
        VStack(alignment: .leading, spacing: NeevaHomeUX.Padding) {
            Text(model.currentConfig.firstLine)
                .font(.roobert(.light, size: PromoCardUX.TextFontSize))
                .foregroundColor(Color(PromoCardUX.TextColor))
            Text(model.currentConfig.secondLine)
                .font(.roobert(.light, size: PromoCardUX.TextFontSize))
                .foregroundColor(Color(PromoCardUX.TextColor))
        }.frame(maxWidth: .infinity, alignment: .leading).padding()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: PromoCardUX.CornerRadius)
                .fill(model.currentConfig.backgroundColor).shadow(radius: 2)
            if isTabletOrLandscape {
                HStack {
                    label
                    button
                }.padding().padding(.bottom, 10)
            } else {
                VStack {
                    label
                    button
                }.padding().padding(.bottom, 10)
            }
            if (model.currentConfig.showDismissButton) {
                Button(action: {
                    model.toggleShowCard()
                } ,label: {
                    Symbol(.xmark, weight: .semibold, label: "Dismiss")
                        .foregroundColor(Color.neeva.ui.gray70).frame(width: 16, height: 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }).padding()
            }
        }.fixedSize(horizontal: false, vertical: true).frame(maxWidth: 650).padding()
    }
}

struct PromoCard_Previews: PreviewProvider {
    static var previews: some View {
        PromoCard(model: HomeViewModel())
    }
}
