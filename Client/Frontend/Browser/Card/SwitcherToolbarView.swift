// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct IncognitoButton: View {
    let offTint = UIColor.label
    let onTint = UIColor.label.swappedForStyle

    @EnvironmentObject var toolbarModel: SwitcherToolbarModel
    @EnvironmentObject var gridModel: GridModel

    var body: some View {
        ToggleButtonView(action: {
            let shouldHide = toolbarModel.onToggleIncognito()
            if shouldHide {
                gridModel.updateVisibility(true)
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

                $0.accessibilityValue = toolbarModel.isIncognito
                    ? .TabTrayToggleAccessibilityValueOn : .TabTrayToggleAccessibilityValueOff
            }
            .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
    }
}

class SwitcherToolbarModel: ObservableObject {
    let tabManager: TabManager
    @Published var isIncognito: Bool

    init(tabManager: TabManager) {
        self.tabManager = tabManager
        isIncognito = tabManager.selectedTab?.isPrivate ?? false
    }

    func onNewTab() {
        tabManager.selectTab(tabManager.addTab(nil, isPrivate: isIncognito))
    }

    func onToggleIncognito() -> Bool {
        let result = tabManager.switchPrivacyMode()
        isIncognito = tabManager.selectedTab?.isPrivate ?? false
        objectWillChange.send()
        return result == .createdNewTab
    }
}

struct SwitcherToolbarView: View {
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel

    var body: some View {
        VStack(spacing: 0) {
            Color(UIColor.Browser.urlBarDivider).frame(height: 1)
            HStack(spacing: 0) {
                IncognitoButton()
                    .environmentObject(toolbarModel)
                Spacer()
                TabToolbarButton(label: Symbol(.plusApp, size: 20,
                                               label: .TabTrayAddTabAccessibilityLabel)) {
                    toolbarModel.onNewTab()
                    gridModel.updateVisibility(true)
                }
                Spacer()
                UIKitButton(action:  { gridModel.showAnimationThumbnail = true }) {
                    let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                    let title = NSAttributedString(string: "Done",
                                                   attributes: [NSAttributedString.Key.font: font])
                    $0.setAttributedTitle(title, for: .normal)
                    $0.setTitleColor(.label, for: .normal)
                    $0.setDynamicMenu(gridModel.buildMenu)
                }.frame(width: 44, height: 44)
                .accessibilityLabel(String.TabTrayDoneAccessibilityLabel)
                .accessibilityIdentifier("TabTrayController.doneButton")
            }.padding(.horizontal, 16)
            Spacer()
        }.background(Color.DefaultBackground)
        .offset(y: gridModel.isHidden ? 90 : 0).animation(.easeOut)
    }
}
