// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

private enum CompactNeevaMenuUX {
    static let innerSectionPadding: CGFloat = 8
    static let buttonWidth: CGFloat = 115
    static let containerPadding: CGFloat = 16
}

struct CompactNeevaMenuView: View {
    private let menuAction: (NeevaMenuAction) -> Void
    private var isIncognito: Bool

    init(menuAction: @escaping (NeevaMenuAction) -> Void, isIncognito: Bool) {
        self.menuAction = menuAction
        self.isIncognito = isIncognito
    }

    // TODO: Refactor CompactNeevaMenuView to take visualSpec as .compact
    // or .wide to show 4 button + list of rows (wide) or horizontal
    // carousel with fixed height (compact), which avoid duplicating
    // code with NeevaMenuView
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CompactNeevaMenuUX.innerSectionPadding) {
                NeevaMenuButtonView(label: "Home", nicon: .house) {
                    self.menuAction(.home)
                }
                .accessibilityIdentifier("NeevaMenu.Home")
                .disabled(isIncognito)
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                NeevaMenuButtonView(label: "Spaces", nicon: .bookmarkOnBookmark) {
                    self.menuAction(.spaces)
                }
                .accessibilityIdentifier("NeevaMenu.Spaces")
                .disabled(isIncognito)
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                NeevaMenuButtonView(label: "Settings", nicon: .gear) {
                    self.menuAction(.settings)
                }
                .accessibilityIdentifier("NeevaMenu.Settings")
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                NeevaMenuButtonView(label: "Feedback", symbol: .bubbleLeft) {
                    self.menuAction(.feedback)
                }
                .accessibilityIdentifier("NeevaMenu.Feedback")
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                NeevaMenuButtonView(label: "History", symbol: .clock) {
                    self.menuAction(.feedback)
                }
                .accessibilityIdentifier("NeevaMenu.History")
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                NeevaMenuButtonView(label: "Downloads", symbol: .squareAndArrowDown) {
                    self.menuAction(.feedback)
                }
                .accessibilityIdentifier("NeevaMenu.Downloads")
                .frame(width: CompactNeevaMenuUX.buttonWidth)
            }
        }
        .padding(CompactNeevaMenuUX.containerPadding)
    }
}

struct CompactNeevaMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CompactNeevaMenuView(
            menuAction: { _ in },
            isIncognito: false
        ).previewDevice("iPod touch (7th generation)")
            .environment(
                \.sizeCategory, .extraExtraExtraLarge)
        CompactNeevaMenuView(menuAction: { _ in }, isIncognito: true)
    }
}
