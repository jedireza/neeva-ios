// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

private enum CompactNeevaMenuUX {
    static let innerSectionPadding: CGFloat = 4
    static let buttonWidth: CGFloat = 120
    static let containerPadding: CGFloat = 16
}

struct CompactNeevaMenuView: View {
    @Environment(\.isIncognito) private var isIncognito
    private let menuAction: (NeevaMenuAction) -> Void

    init(menuAction: @escaping (NeevaMenuAction) -> Void) {
        self.menuAction = menuAction
    }

    // TODO: Refactor CompactNeevaMenuView to take visualSpec as .compact
    // or .wide to show 4 button + list of rows (wide) or horizontal
    // carousel with fixed height (compact), which avoid duplicating
    // code with NeevaMenuView
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: CompactNeevaMenuUX.innerSectionPadding) {
                CompactNeevaMenuButtonView(label: "Home", nicon: .house) {
                    self.menuAction(.home)
                }
                .accessibilityIdentifier("NeevaMenu.Home")
                .disabled(isIncognito)
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                CompactNeevaMenuButtonView(label: "Spaces", nicon: .bookmarkOnBookmark) {
                    self.menuAction(.spaces)
                }
                .accessibilityIdentifier("NeevaMenu.Spaces")
                .disabled(isIncognito)
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                CompactNeevaMenuButtonView(label: "Settings", nicon: .gear) {
                    self.menuAction(.settings)
                }
                .accessibilityIdentifier("NeevaMenu.Settings")
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                CompactNeevaMenuButtonView(label: "Feedback", symbol: .bubbleLeft) {
                    self.menuAction(.feedback)
                }
                .accessibilityIdentifier("NeevaMenu.Feedback")
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                CompactNeevaMenuButtonView(label: "History", symbol: .clock) {
                    self.menuAction(.feedback)
                }
                .accessibilityIdentifier("NeevaMenu.History")
                .frame(width: CompactNeevaMenuUX.buttonWidth)

                CompactNeevaMenuButtonView(label: "Downloads", symbol: .squareAndArrowDown) {
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
        CompactNeevaMenuView(menuAction: { _ in })
            .previewDevice("iPod touch (7th generation)")
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .environment(\.isIncognito, false)
        CompactNeevaMenuView(menuAction: { _ in })
            .environment(\.isIncognito, true)
    }
}
