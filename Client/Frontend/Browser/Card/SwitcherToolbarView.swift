// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

class SwitcherToolbarModel: ObservableObject {
    let tabManager: TabManager
    let openLazyTab: () -> Void
    @Published var isIncognito: Bool

    init(tabManager: TabManager, openLazyTab: @escaping () -> Void) {
        self.tabManager = tabManager
        self.openLazyTab = openLazyTab

        isIncognito = tabManager.selectedTab?.isPrivate ?? false
        tabManager.selectedTabPublisher
            .map { $0?.isPrivate ?? false }
            .assign(to: &$isIncognito)
    }

    func onNewTab() {
        openLazyTab()
    }

    func onToggleIncognito() -> Bool {
        tabManager.switchPrivacyMode() == .createdNewTab
    }
}

/// The toolbar for the card grid/tab switcher
struct SwitcherToolbarView: View {
    let top: Bool
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel

    var body: some View {
        let divider = Color(UIColor.Browser.urlBarDivider).frame(height: 1).ignoresSafeArea()
        VStack(spacing: 0) {
            if !top { divider }
            HStack(spacing: 0) {
                IncognitoButton(
                    isIncognito: toolbarModel.isIncognito,
                    action: {
                        let shouldHide = toolbarModel.onToggleIncognito()
                        if shouldHide {
                            gridModel.hideWithNoAnimation()
                        }
                    }
                )
                Spacer()
                SecondaryMenuButton(action: {
                    toolbarModel.onNewTab()
                    gridModel.hideWithNoAnimation()
                }) {
                    $0.setImage(Symbol.uiImage(.plusApp, size: 20), for: .normal)
                    $0.tintColor = UIColor.label
                    $0.accessibilityIdentifier = "TabTrayController.addTabButton"
                    $0.setDynamicMenu(gridModel.buildRecentlyClosedTabsMenu)
                }
                .tapTargetFrame()
                .accessibilityLabel(String.TabTrayAddTabAccessibilityLabel)
                Spacer()
                SecondaryMenuButton(action: {
                    gridModel.animationThumbnailState = .visibleForTrayHidden
                }) {
                    let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                    let title = NSAttributedString(
                        string: "Done",
                        attributes: [NSAttributedString.Key.font: font])
                    $0.setAttributedTitle(title, for: .normal)
                    $0.setTitleColor(.label, for: .normal)
                    $0.setDynamicMenu(gridModel.buildCloseAllTabsMenu)
                }
                .tapTargetFrame()
                .accessibilityLabel(String.TabTrayDoneAccessibilityLabel)
                .accessibilityIdentifier("TabTrayController.doneButton")
            }.padding(.horizontal, 16)
                .frame(
                    height: top ? UIConstants.TopToolbarHeightWithToolbarButtonsShowing - 1 : nil)
            if top { divider }
        }
        .background(Color.DefaultBackground.ignoresSafeArea())
        .opacity(gridModel.isHidden ? 0 : 1)
        .animation(.easeOut)
    }
}
