// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

public struct CardGridOverflowMenuView: View {
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
                    label: "Settings",
                    symbol: .gear,
                    action: {
                        menuAction(.goToSettings)
                    }
                )
                .accessibilityIdentifier("CardGridOverflowMenu.Settings")

                OverflowMenuButtonView(
                    label: "Incognito Mode", nicon: .incognito,
                    isIncognito: chromeModel.topBarDelegate?.tabManager.isIncognito ?? false
                ) {
                    menuAction(.toggleIncognitoMode)
                }
                .accessibilityIdentifier("CardGridOverflowMenu.ToogleIncognito")
            }

            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    NeevaMenuRowButtonView(label: "History", symbol: .clock) {
                        menuAction(.goToHistory)
                    }
                    .disabled(chromeModel.topBarDelegate?.tabManager.isIncognito ?? false)
                    .accessibilityIdentifier("CardGridOverflowMenu.History")

                    Color.groupedBackground.frame(height: 1)

                    NeevaMenuRowButtonView(label: "Downloads", symbol: .squareAndArrowDown) {
                        menuAction(.goToDownloads)
                    }
                    .accessibilityIdentifier("CardGridOverflowMenu.Downloads")
                }
                .accentColor(.label)
            }

            GroupedCell.Decoration {
                NeevaMenuRowButtonView(label: "Close All Tabs", symbol: .trash) {
                    menuAction(.closeAllTabs)
                }
                .accessibilityIdentifier("CardGridOverflowMenu.CloseAllTabs")
                .accentColor(.red)
                .disabled(chromeModel.topBarDelegate?.tabManager.getTabCountForCurrentType() == 0)
            }
        }.padding(.bottom, -12)
    }
}

struct CardGridOverflowMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CardGridOverflowMenuView(menuAction: { _ in })
    }
}
