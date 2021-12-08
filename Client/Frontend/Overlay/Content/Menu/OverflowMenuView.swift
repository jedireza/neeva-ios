// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

enum OverflowMenuUX {
    static let innerSectionPadding: CGFloat = 8
    static let squareButtonSize: CGFloat = 83
    static let squareButtonSpacing: CGFloat = 4
    static let squareButtonIconSize: CGFloat = 20
}

public struct OverflowMenuButtonView: View {
    let label: String
    var symbol: SFSymbol? = nil
    var nicon: Nicon? = nil
    let action: () -> Void
    let longPressAction: (() -> Void)?
    var isIncognito: Bool

    @Environment(\.isEnabled) private var isEnabled

    public init(
        label: String, symbol: SFSymbol,
        isIncognito: Bool = false,
        longPressAction: (() -> Void)? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.symbol = symbol
        self.action = action
        self.longPressAction = longPressAction
        self.isIncognito = isIncognito
    }

    public init(
        label: String, nicon: Nicon,
        longPressAction: (() -> Void)? = nil,
        isIncognito: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.nicon = nicon
        self.action = action
        self.longPressAction = longPressAction
        self.isIncognito = isIncognito
    }

    public var body: some View {
        GroupedCellButton(
            action: action, longPressAction: longPressAction,
            backgroundColor: isIncognito ? Color.black : Color.secondaryGroupedBackground
        ) {
            VStack(spacing: OverflowMenuUX.squareButtonSpacing) {
                if let symbol = symbol {
                    Symbol(
                        decorative: symbol, size: OverflowMenuUX.squareButtonIconSize,
                        weight: .medium)
                } else if let nicon = nicon {
                    Symbol(decorative: nicon, size: 20, weight: .medium)
                }

                Text(label).withFont(.bodyLarge)
            }.frame(height: OverflowMenuUX.squareButtonSize)
        }
        .accentColor(isIncognito ? .white : isEnabled ? .label : .quaternaryLabel)
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
            if !chromeModel.inlineToolbar {
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

                    OverflowMenuButtonView(
                        label: chromeModel.reloadButton == .reload ? "Reload" : "Stop",
                        symbol: chromeModel.reloadButton == .reload ? .arrowClockwise : .xmark
                    ) {
                        menuAction(.reloadStop)
                    }
                    .accessibilityIdentifier("OverflowMenu.Reload")

                    if !FeatureFlag[.overflowMenuInCardGrid] {
                        OverflowMenuButtonView(label: "New Tab", symbol: .plus) {
                            menuAction(.newTab)
                        }
                        .accessibilityIdentifier("OverflowMenu.NewTab")
                    } else {
                        OverflowMenuButtonView(label: "Support", symbol: .bubbleLeft) {
                            menuAction(.support)
                        }
                        .accessibilityIdentifier("OverflowMenu.Feedback")
                    }
                }
            }

            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    if chromeModel.inlineToolbar {
                        if !FeatureFlag[.overflowMenuInCardGrid] {
                            NeevaMenuRowButtonView(
                                label: "New Tab",
                                symbol: .plus
                            ) {
                                menuAction(.newTab)
                            }
                            .accessibilityIdentifier("OverflowMenu.NewTab")
                        }

                        Color.groupedBackground.frame(height: 1)

                        if FeatureFlag[.overflowMenuInCardGrid] {
                            NeevaMenuRowButtonView(
                                label: "Support",
                                symbol: .bubbleLeft
                            ) {
                                menuAction(.support)
                            }
                            .accessibilityIdentifier("OverflowMenu.Feedback")

                            Color.groupedBackground.frame(height: 1)
                        }
                    }

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
