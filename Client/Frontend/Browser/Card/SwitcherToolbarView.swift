// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

class SwitcherToolbarModel: ObservableObject {
    let tabManager: TabManager
    let openLazyTab: () -> Void
    let createNewSpace: () -> Void
    let onNeevaMenuAction: (NeevaMenuAction) -> Void
    @Published var isIncognito: Bool

    init(
        tabManager: TabManager,
        openLazyTab: @escaping () -> Void,
        createNewSpace: @escaping () -> Void,
        onNeevaMenuAction: @escaping (NeevaMenuAction) -> Void
    ) {
        self.tabManager = tabManager
        self.openLazyTab = openLazyTab
        self.createNewSpace = createNewSpace
        self.onNeevaMenuAction = onNeevaMenuAction

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
    @State var presentingMenu: Bool = false
    @State private var action: NeevaMenuAction? = nil

    var body: some View {
        let divider = Color.ui.adaptive.separator.frame(height: 1).ignoresSafeArea()
        VStack(spacing: 0) {
            if !top { divider }

            HStack(spacing: 0) {
                if top {
                    TabToolbarButtons.NeevaMenu(iconWidth: 24) {
                        presentingMenu = true
                    }
                    .tapTargetFrame()
                    .presentAsPopover(
                        isPresented: $presentingMenu,
                        backgroundColor: .systemGroupedBackground,
                        arrowDirections: .up,
                        dismissOnTransition: true,
                        onDismiss: {
                            if let action = action {
                                toolbarModel.onNeevaMenuAction(action)
                                self.action = nil
                            }
                        }
                    ) {
                        VerticalScrollViewIfNeeded {
                            NeevaMenuView(menuAction: {
                                action = $0
                                presentingMenu = false
                            })
                            .padding(.bottom, 16)
                            .environment(\.isIncognito, toolbarModel.isIncognito)
                        }
                        .frame(minWidth: 340, minHeight: 323)
                        .padding(.top, 13)  // height of the arrow
                    }
                    .tapTargetFrame()
                    GridPicker()
                }
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
                        toolbarModel.createNewSpace()
                    }
                }) {
                    $0.setImage(Symbol.uiImage(.plusApp, size: 20), for: .normal)
                    $0.tintColor = UIColor.label
                    $0.accessibilityIdentifier = "TabTrayController.addTabButton"
                    $0.setDynamicMenu(gridModel.buildRecentlyClosedTabsMenu)
                    $0.isEnabled =
                        gridModel.switcherState == .tabs || NeevaUserInfo.shared.isUserLoggedIn
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
