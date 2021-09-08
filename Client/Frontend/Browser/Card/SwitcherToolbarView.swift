// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

class SwitcherToolbarModel: ObservableObject {
    let tabManager: TabManager
    let openLazyTab: () -> Void
    let createNewSpace: () -> Void
    @Published var isIncognito: Bool

    init(
        tabManager: TabManager,
        openLazyTab: @escaping () -> Void,
        createNewSpace: @escaping () -> Void
    ) {
        self.tabManager = tabManager
        self.openLazyTab = openLazyTab
        self.createNewSpace = createNewSpace

        isIncognito = tabManager.isIncognito
        tabManager.$isIncognito
            .map { $0 }
            .assign(to: &$isIncognito)
    }

    func onToggleIncognito() {
        tabManager.toggleIncognitoMode(clearSelectedTab: false)
    }
}

/// The toolbar for the card grid/tab switcher
struct SwitcherToolbarView: View {
    let top: Bool
    var isEmpty: Bool
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel

    var body: some View {
        let divider = Color.ui.adaptive.separator.frame(height: 1).ignoresSafeArea()
        VStack(spacing: 0) {
            if !top { divider }

            HStack(spacing: 0) {
                if case .tabs = gridModel.switcherState {
                    IncognitoButton(
                        isIncognito: toolbarModel.isIncognito,
                        action: {
                            toolbarModel.onToggleIncognito()
                        }
                    )
                    Spacer()
                }
                SecondaryMenuButton(action: {
                    switch gridModel.switcherState {
                    case .tabs:
                        toolbarModel.openLazyTab()
                        gridModel.hideWithNoAnimation()
                    case .spaces:
                        gridModel.hideWithNoAnimation()
                        toolbarModel.createNewSpace()
                    }
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
                    switch gridModel.switcherState {
                    case .tabs:
                        gridModel.hideWithAnimation()
                    case .spaces:
                        gridModel.hideWithNoAnimation()
                    }
                }) {
                    let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                    let title = NSAttributedString(
                        string: "Done",
                        attributes: [NSAttributedString.Key.font: font])
                    $0.setAttributedTitle(title, for: .normal)
                    $0.setTitleColor(isEmpty ? .secondaryLabel : .label, for: .normal)
                    $0.setDynamicMenu(gridModel.buildCloseAllTabsMenu)
                    $0.isEnabled = !isEmpty
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
