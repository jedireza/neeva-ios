// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

private enum OverflowMenuUX {
    static let innerSectionPadding: CGFloat = 8
    static let squareButtonSize: CGFloat = 83
    static let squareButtonSpacing: CGFloat = 4
    static let squareButtonIconSize: CGFloat = 20
}

public struct OverflowMenuButtonView: View {
    let label: String
    let symbol: SFSymbol
    let action: () -> Void
    let longPressAction: (() -> Void)?

    @Environment(\.isEnabled) private var isEnabled

    public init(
        label: String, symbol: SFSymbol,
        longPressAction: (() -> Void)? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.symbol = symbol
        self.action = action
        self.longPressAction = longPressAction
    }

    public var body: some View {
        GroupedCellButton(action: action, longPressAction: longPressAction) {
            VStack(spacing: OverflowMenuUX.squareButtonSpacing) {
                Symbol(decorative: symbol, size: OverflowMenuUX.squareButtonIconSize)
                Text(label).withFont(.bodyLarge)
            }.frame(height: OverflowMenuUX.squareButtonSize)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
    }
}

public struct OverflowMenuView: View {
    private let menuAction: (OverflowMenuAction) -> Void
    private let changedUserAgent: Bool

    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var locationModel: LocationViewModel

    public init(
        changedUserAgent: Bool = false,
        menuAction: @escaping (OverflowMenuAction) -> Void
    ) {
        self.menuAction = menuAction
        self.changedUserAgent = changedUserAgent
    }

    public var body: some View {
        GroupedStack {
            HStack(spacing: OverflowMenuUX.innerSectionPadding) {
                OverflowMenuButtonView(
                    label: .TabToolbarForwardAccessibilityLabel,
                    symbol: .arrowForward,
                    longPressAction: {
                        menuAction(.longPressForward)
                    },
                    action: {
                        menuAction(.forward)
                    }
                )
                .accessibilityIdentifier("OverflowMenu.Forward")
                .disabled(!chromeModel.canGoForward)

                OverflowMenuButtonView(label: "New Tab", symbol: .plus) {
                    menuAction(.newTab)
                }
                .accessibilityIdentifier("OverflowMenu.NewTab")
                OverflowMenuButtonView(
                    label: "Share",
                    symbol: .squareAndArrowUp
                ) {
                    menuAction(.share)
                }
                .accessibilityIdentifier("OverflowMenu.Share")
            }

            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    NeevaMenuRowButtonView(
                        label: "Find on Page",
                        symbol: .docTextMagnifyingglass
                    ) {
                        menuAction(.findOnPage)
                    }
                    .accessibilityIdentifier("OverflowMenu.FindOnPage")

                    Color.groupedBackground.frame(height: 1)

                    NeevaMenuRowButtonView(
                        label: "Text Size",
                        symbol: .textformatSize
                    ) {
                        menuAction(.textSize)
                    }
                    .accessibilityIdentifier("OverflowMenu.TextSize")

                    Color.groupedBackground.frame(height: 1)

                    /* TODO: Renable reading mode in the Overflow Menu
                    if locationModel.readerMode != .unavailable && FeatureFlag[.readingMode] {
                        NeevaMenuRowButtonView(
                            label: locationModel.readerMode == .available
                                ? "Open Reading Mode" : "Close Reading Mode",
                            symbol: .docPlaintext
                        ) {
                            menuAction(.readingMode)
                        }
                        .accessibilityIdentifier(
                            locationModel.readerMode == .available
                                ? "OverflowMenu.OpenReadingMode"
                                : "OverflowMenu.CloseReadingMode"
                        )

                        Color.groupedBackground.frame(height: 1)
                    } */

                    let hasHomeButton = UIConstants.safeArea.bottom == 0
                    NeevaMenuRowButtonView(
                        label: changedUserAgent == true
                            ? Strings.AppMenuViewMobileSiteTitleString
                            : Strings.AppMenuViewDesktopSiteTitleString,
                        symbol: changedUserAgent == true
                            ? (hasHomeButton ? .iphoneHomebutton : .iphone)
                            : .desktopcomputer
                    ) {
                        menuAction(.desktopSite)
                    }
                    .accessibilityIdentifier("OverflowMenu.RequestDesktopSite")

                    Color.groupedBackground.frame(height: 1)

                    NeevaMenuRowButtonView(
                        label: "Download Page",
                        symbol: .squareAndArrowDown
                    ) {
                        menuAction(.downloadPage)
                    }
                    .accessibilityIdentifier("OverflowMenu.DownloadPage")
                }
                .accentColor(.label)
            }
        }.padding(.bottom, -12)
    }
}

struct OverflowMenuView_Previews: PreviewProvider {
    static var previews: some View {
        OverflowMenuView(menuAction: { _ in }).previewDevice("iPod touch (7th generation)")
            .environment(
                \.sizeCategory, .extraExtraExtraLarge)
        OverflowMenuView(menuAction: { _ in })
    }
}
