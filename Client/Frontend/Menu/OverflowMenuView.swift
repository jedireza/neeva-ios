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

    @Environment(\.isEnabled) private var isEnabled

    public init(label: String, symbol: SFSymbol, action: @escaping () -> Void) {
        self.label = label
        self.symbol = symbol
        self.action = action
    }

    public var body: some View {
        GroupedCellButton(action: action) {
            VStack(spacing: OverflowMenuUX.squareButtonSpacing) {
                Symbol(decorative: symbol, size: OverflowMenuUX.squareButtonIconSize)
                Text(label).withFont(.bodyLarge)
            }.frame(height: OverflowMenuUX.squareButtonSize)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
    }
}

public struct OverflowMenuRowButtonView: View {
    let label: String
    let symbol: SFSymbol
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(label: String, symbol: SFSymbol, action: @escaping () -> Void) {
        self.label = label
        self.symbol = symbol
        self.action = action
    }

    public var body: some View {
        GroupedCellButton(action: action) {
            HStack {
                Text(label).withFont(.bodyLarge)
                Spacer()
                Symbol(decorative: symbol)
            }
            .foregroundColor(.label)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
    }
}

public struct OverflowMenuView: View {
    private let noTopPadding: Bool
    private let menuAction: ((OverflowMenuButtonActions) -> Void)?
    private let changedUserAgent: Bool

    @Environment(\.isIncognito) private var isIncognito
    @EnvironmentObject var tabToolBarModel: TabToolbarModel
    @EnvironmentObject var urlBarModel: URLBarModel

    public init(
        noTopPadding: Bool = false,
        changedUserAgent: Bool = false,
        menuAction:
            ((OverflowMenuButtonActions) -> Void)?
    ) {
        self.noTopPadding = noTopPadding
        self.menuAction = menuAction
        self.changedUserAgent = changedUserAgent
    }

    public var body: some View {
        GroupedStack {
            HStack(spacing: OverflowMenuUX.innerSectionPadding) {
                OverflowMenuButtonView(label: "Forward", symbol: .arrowForward) {
                    menuAction!(OverflowMenuButtonActions.forward)
                }
                .accessibilityIdentifier("NeevaMenu.Forward")
                .disabled(!tabToolBarModel.canGoForward)

                OverflowMenuButtonView(
                    label: urlBarModel.reloadButton == .reload ? "Reload" : "Stop",
                    symbol: urlBarModel.reloadButton == .reload ? .arrowClockwise : .xmark
                ) {
                    menuAction!(OverflowMenuButtonActions.reload)
                }
                .accessibilityIdentifier("NeevaMenu.Reload")

                OverflowMenuButtonView(label: "New Tab", symbol: .plus) {
                    menuAction!(OverflowMenuButtonActions.newTab)
                }
                .accessibilityIdentifier("NeevaMenu.NewTab")
            }

            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    OverflowMenuRowButtonView(
                        label: "Find on Page",
                        symbol: .docTextMagnifyingglass
                    ) {
                        menuAction!(OverflowMenuButtonActions.findOnPage)
                    }
                    .accessibilityIdentifier("NeevaMenu.FindOnPage")

                    Color.groupedBackground.frame(height: 1)

                    OverflowMenuRowButtonView(
                        label: "Text Size",
                        symbol: .textformatSize
                    ) {
                        menuAction!(OverflowMenuButtonActions.textSize)
                    }
                    .accessibilityIdentifier("NeevaMenu.TextSize")

                    Color.groupedBackground.frame(height: 1)

                    OverflowMenuRowButtonView(
                        label: changedUserAgent == true
                            ? Strings.AppMenuViewMobileSiteTitleString
                            : Strings.AppMenuViewDesktopSiteTitleString,
                        symbol: .desktopcomputer
                    ) {
                        menuAction!(OverflowMenuButtonActions.desktopSite)
                    }
                    .accessibilityIdentifier("NeevaMenu.RequestDesktopSite")

                    Color.groupedBackground.frame(height: 1)
                }
            }
        }
    }
}

struct OverflowMenuView_Previews: PreviewProvider {
    static var previews: some View {
        OverflowMenuView(menuAction: nil).previewDevice("iPod touch (7th generation)").environment(
            \.sizeCategory, .extraExtraExtraLarge)
        OverflowMenuView(menuAction: nil).environment(\.isIncognito, true)
    }
}
