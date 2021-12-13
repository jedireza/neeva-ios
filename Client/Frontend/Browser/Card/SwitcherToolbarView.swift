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
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel
    @State var presentingMenu: Bool = false
    @State private var action: NeevaMenuAction? = nil

    var bvc: BrowserViewController {
        SceneDelegate.getBVC(with: toolbarModel.tabManager.scene)
    }

    var body: some View {
        let divider = Color.ui.adaptive.separator.frame(height: 1).ignoresSafeArea()
        VStack(spacing: 0) {
            if !top { divider }

            HStack(spacing: 0) {
                if top {
                    GridPicker(isInToolbar: true).fixedSize()
                    Spacer()
                }

                if top {
                    TopBarOverflowMenuButton(
                        changedUserAgent: bvc.tabManager.selectedTab?.showRequestDesktop,
                        onOverflowMenuAction: { action, view in
                            bvc.perform(overflowMenuAction: action, targetButtonView: view)
                        },
                        onLongPress: { _ in
                        }, location: .cardGrid
                    )
                    .tapTargetFrame()
                    .environmentObject(bvc.chromeModel)
                    .environmentObject(bvc.locationModel)
                } else {
                    TabToolbarButtons.OverflowMenu(
                        weight: .medium,
                        action: {
                            bvc.showModal(style: .grouped) {
                                OverflowMenuOverlayContent(
                                    menuAction: { action in
                                        bvc.perform(
                                            overflowMenuAction: action,
                                            targetButtonView: nil)
                                    },
                                    changedUserAgent: bvc.tabManager.selectedTab?
                                        .showRequestDesktop,
                                    chromeModel: bvc.chromeModel,
                                    locationModel: bvc.locationModel,
                                    location: .cardGrid
                                )
                            }
                        },
                        onLongPress: {}
                    )
                    .tapTargetFrame()
                }

                if !top {
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
                    $0.setImage(Symbol.uiImage(.plus, size: 20), for: .normal)
                    $0.tintColor = UIColor.label
                    $0.accessibilityIdentifier = "TabTrayController.addTabButton"
                    $0.setDynamicMenu(gridModel.buildRecentlyClosedTabsMenu)
                    $0.isEnabled =
                        gridModel.switcherState == .tabs || NeevaUserInfo.shared.isUserLoggedIn
                }
                .tapTargetFrame()
                .accessibilityLabel(String.TabTrayAddTabAccessibilityLabel)

                if !top {
                    Spacer()
                }

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

            if top {
                divider
            } else {
                Spacer()
            }
        }
        .background(Color.DefaultBackground.ignoresSafeArea())
        .opacity(gridModel.isHidden ? 0 : 1)
        .animation(.easeOut)
        .modifier(SwipeToSwitchToSpacesGesture(gridModel: gridModel, tabModel: tabModel))
    }
}
