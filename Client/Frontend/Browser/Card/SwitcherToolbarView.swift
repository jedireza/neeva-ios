// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct IncognitoButton: View {
    let offTint = UIColor.label
    let onTint = UIColor.label.swappedForStyle

    @EnvironmentObject var toolbarModel: SwitcherToolbarModel
    @EnvironmentObject var gridModel: GridModel

    var body: some View {
        ToggleButtonView(action: {
            let shouldHide = toolbarModel.onToggleIncognito()
            if shouldHide {
                gridModel.hideWithNoAnimation()
            }
        }) {
            $0.accessibilityLabel = .TabTrayToggleAccessibilityLabel
            $0.accessibilityHint = .TabTrayToggleAccessibilityHint
            let maskImage = UIImage(named: "incognito")?.withRenderingMode(.alwaysTemplate)
            $0.setImage(maskImage, for: [])
            $0.isPointerInteractionEnabled = true
            $0.setSelected(toolbarModel.isIncognito)

            $0.tintColor = toolbarModel.isIncognito ? onTint : offTint
            $0.imageView?.tintColor = $0.tintColor

            $0.accessibilityValue =
                toolbarModel.isIncognito
                ? .TabTrayToggleAccessibilityValueOn : .TabTrayToggleAccessibilityValueOff
        }
        .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
    }
}

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

struct SwitcherToolbarView: View {
    let top: Bool
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel

    var body: some View {
        let divider = Color(UIColor.Browser.urlBarDivider).frame(height: 1).ignoresSafeArea()
        VStack(spacing: 0) {
            if !top { divider }
            HStack(spacing: 0) {
                IncognitoButton()
                Spacer()
                UIKitButton(action: {
                    toolbarModel.onNewTab()
                    gridModel.hideWithNoAnimation()
                }) {
                    $0.setImage(Symbol.uiImage(.plusApp, size: 20), for: .normal)
                    $0.tintColor = UIColor.label
                    $0.accessibilityIdentifier = "TabTrayController.addTabButton"
                    $0.setDynamicMenu(gridModel.buildRecentlyClosedTabsMenu)
                }.frame(width: 44, height: 44)
                    .accessibilityLabel(String.TabTrayAddTabAccessibilityLabel)
                Spacer()
                UIKitButton(action: { gridModel.animationThumbnailState = .visibleForTrayHidden }) {
                    let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                    let title = NSAttributedString(
                        string: "Done",
                        attributes: [NSAttributedString.Key.font: font])
                    $0.setAttributedTitle(title, for: .normal)
                    $0.setTitleColor(.label, for: .normal)
                    $0.setDynamicMenu(gridModel.buildCloseAllTabsMenu)
                }.frame(width: 44, height: 44)
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
