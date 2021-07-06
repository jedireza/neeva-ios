// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct PromoCardConfig {
    let title: String
    let buttonLabel: String
    let buttonImage: Image?
    let backgroundColor: Color
}

enum PromoCardType {
    case neevaSignIn(action: () -> ())
    case defaultBrowser(action: () -> (), onClose: () -> ())

    var action: () -> () {
        switch self {
        case .neevaSignIn(let action):
            return action
        case .defaultBrowser(let action, _):
            return action
        }
    }

    var title: String {
        switch self {
        case .neevaSignIn:
            return "Get safer, richer and better\nsearch when you sign in"
        case .defaultBrowser:
            return "Browse in peace,\nalways"
        }
    }

    @ViewBuilder
    var buttonLabel: some View {
        switch self {
        case .neevaSignIn:
            HStack(spacing: 8) {
                Image("neevaMenuIcon")
                    .renderingMode(.template)
                    .frame(width: 18, height: 16)
                Text("Sign in or Join Neeva")
                    .padding(.horizontal, 20)
            }
        case .defaultBrowser:
            Text("Set as Default Browser")
        }
    }

    var color: Color {
        switch self {
        case .neevaSignIn:
            return .brand.adaptive.polar
        case .defaultBrowser:
            return .brand.adaptive.pistachio
        }
    }
}

struct PromoCard: View {
    let type: PromoCardType

    var isTabletOrLandscape: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation.isLandscape
    }

    var button: some View {
        Button(action: type.action) {
            HStack {
                Spacer()
                type.buttonLabel
                Spacer()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(height: 48)
            .background(Capsule().fill(Color.brand.blue))
        }
    }

    @ViewBuilder
    var label: some View {
        let size: CGFloat = 24
        let lineSpacing = 32 - size
        Text(type.title)
            .font(.roobert(.regular, size: size))
            .lineSpacing(lineSpacing)
            .foregroundColor(.hex(0x131415))
            .padding(.vertical, lineSpacing)
    }

    @ViewBuilder
    var closeButton: some View {
        if case .defaultBrowser(_, let onClose) = type {
            Button(action: onClose) {
                Symbol(.xmark, weight: .semibold, label: "Dismiss")
                    .foregroundColor(Color.ui.gray70)
                    .padding()
            }
        }
    }

    var background: some View {
        let shape = RoundedRectangle(cornerRadius: 12)
        let innerShadowAmount: CGFloat = 1.25
        return shape
            .fill(type.color)
            .background(
                shape
                    .fill(Color.black.opacity(0.03))
                    .blur(radius: 0.5)
                    .offset(y: -0.5)
            )
            .overlay(
                // Reference: https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
                shape
                    .inset(by: -innerShadowAmount)
                    .stroke(Color.black.opacity(0.2), lineWidth: innerShadowAmount * 2)
                    .blur(radius: 0.5)
                    .offset(y: -innerShadowAmount)
                    .mask(shape)
            )

    }

    var body: some View {
        Group {
            if isTabletOrLandscape {
                HStack {
                    label
                    Spacer()
                    button
                    closeButton
                }
            } else {
                VStack(spacing: 16) {
                    HStack(alignment: .top) {
                        label
                        Spacer()
                        closeButton
                    }
                    button
                }
            }
        }
        .padding(25)
        .background(background)
        .frame(maxWidth: 650)
        .padding()
    }
}

struct PromoCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PromoCard(type: .neevaSignIn(action: {}))
            PromoCard(type: .defaultBrowser(action: {}, onClose: {}))
        }.previewLayout(.sizeThatFits)
    }
}
