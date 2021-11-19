// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct QueryChip: View {
    let query: String
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        Button(action: onClick) {
            HStack(alignment: .center) {
                Label {
                    Text(query)
                        .foregroundColor(Color.ui.gray20)
                } icon: {
                    Symbol(decorative: .magnifyingglass)
                        .foregroundColor(Color.ui.gray70)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20).stroke(Color.ui.gray80, lineWidth: 1).padding(-10)
        )
        .padding(10)
        .withFont(unkerned: .bodyMedium)
        .lineLimit(1)
    }

    func onClick() {
        if let target = neevaSearchEngine.searchURLForQuery(query) {
            onOpenURL(target)
        }
    }
}

struct QueryChipList: View {
    let list = ["Best Headphones", "Lemon Bar Recipe", "React Hooks"]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center) {
                ForEach(list, id: \.self) { query in
                    QueryChip(query: query)
                }
            }
        }
        .frame(maxWidth: 475)
    }
}

struct PreviewHomeView: View {
    let bvc: BrowserViewController

    @State private var opacity: Double = 1.0
    @State private var offsetY: CGFloat = 0.0
    @State private var offsetX: CGFloat = 0.0

    let coordinateSpaceName = UUID().uuidString

    var background: some View {
        Color.PreviewHomeBackground
            .overlay(
                RadialGradient(
                    gradient: Gradient(
                        colors: [
                            Color(light: Color(hex: 0xD8E7FF), dark: Color(hex: 0x253373)),
                            Color(light: .white, dark: Color.brand.charcoal),
                        ]
                    ),
                    center: .center,
                    startRadius: 1,
                    endRadius: bvc.chromeModel.inlineToolbar ? 150 : 300
                ),
                alignment: .center
            )
    }

    var signInButton: some View {
        Button(action: { bvc.presentIntroViewController(true) }) {
            HStack {
                Spacer()
                Text("Sign in")
                    .foregroundColor(Color.ui.adaptive.blue)
                    .font(.roobert(size: 16))
            }
        }
    }

    var header: some View {
        VStack(spacing: 20) {
            Image("neeva-letter-only")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .colorMultiply(
                    Color(light: Color.brand.charcoal, dark: Color.brand.white)
                )
            VStack(spacing: 8) {
                Text("The World's First")
                Text("Ad-Free, Private")
                Text("Search Engine")
            }
            .foregroundColor(Color(light: Color.brand.charcoal, dark: Color.brand.white))
            .font(.roobert(size: 32))
        }
    }

    var fakeBox: some View {
        HStack {
            Symbol(decorative: .magnifyingglass, style: .labelLarge)
            Text("Search")
                .font(.system(size: 17))
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.ui.gray70)
        .background(Color(light: Color.brand.white, dark: Color.brand.charcoal))
        .cornerRadius(26)
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.ui.gray80, lineWidth: 1)
        )
    }

    var body: some View {
        ZStack {
            background
            VStack(alignment: .center, spacing: 0) {
                signInButton
                    .opacity(opacity)
                    .padding(.top, 20)
                Spacer()
                header
                    .opacity(opacity)
                    .padding(.bottom, 30)
                GeometryReader { geom in
                    Button(action: {
                        let frame = geom.frame(in: .named(coordinateSpaceName))
                        withAnimation(.easeInOut(duration: 0.25)) {
                            offsetX = -frame.minX
                            offsetY = -frame.minY
                            opacity = 0
                        }
                    }) {
                        fakeBox
                            .opacity(opacity * 2)
                            .offset(x: offsetX, y: 0)
                    }
                    .buttonStyle(NoAnim())
                }
                .frame(height: 46)
                QueryChipList()
                    .opacity(opacity)
                    .padding(.top, 20)
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 20)
            .offset(x: 0, y: offsetY)
        }
        .coordinateSpace(name: coordinateSpaceName)
        .modifier(
            DismissalObserverModifier(opacity: opacity) {
                bvc.chromeModel.triggerOverlay()
            }
        )
    }
}

private struct NoAnim: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

private struct DismissalObserverModifier: AnimatableModifier {
    var opacity: Double
    let completion: () -> Void

    var animatableData: Double {
        get { opacity }
        set {
            opacity = newValue
            if opacity == 0 {
                // Run after the call stack has unwound as |completion| may tear down
                // the overlay sheet, which could cause issues for SwiftUI processing.
                // See issue #401.
                DispatchQueue.main.async(execute: self.completion)
            }
        }
    }

    func body(content: Content) -> some View {
        return content
    }
}
