// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

struct TabToolbarView: View {
    let performAction: (ToolbarAction) -> Void
    let buildTabsMenu: () -> UIMenu?
    let onNeevaMenu: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Color.ui.adaptive.separator
                .frame(height: 0.5)
                .ignoresSafeArea()
            HStack(spacing: 0) {
                TabToolbarButtons.BackForward(
                    weight: .medium,
                    onBack: { performAction(.back) },
                    onForward: { performAction(.forward) },
                    onOverflow: { performAction(.overflow) },
                    onLongPress: { performAction(.longPressBackForward) }
                )
                TabToolbarButtons.NeevaMenu(iconWidth: 22, action: onNeevaMenu)
                TabToolbarButtons.AddToSpace(
                    weight: .medium, action: { performAction(.addToSpace) })
                TabToolbarButtons.ShowTabs(
                    weight: .medium,
                    action: { performAction(.showTabs) },
                    buildMenu: buildTabsMenu
                )
            }
            .padding(.top, 2)
            .background(Color.chrome.ignoresSafeArea())
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("TabToolbar")
        }.accentColor(.label)
    }
}

struct TabToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        let make = { (model: TabChromeModel) in
            TabToolbarView(performAction: { _ in }, buildTabsMenu: { nil }, onNeevaMenu: {})
                .environmentObject(model)
        }
        VStack {
            Spacer()
            make(TabChromeModel(canGoBack: true, canGoForward: false))
        }
        VStack {
            Spacer()
            make(TabChromeModel(canGoBack: true, canGoForward: false))
        }.preferredColorScheme(.dark)
        VStack {
            Spacer()
            make(TabChromeModel(canGoBack: true, canGoForward: false))
                .environment(\.isIncognito, true)
        }
        VStack {
            Spacer()
            make(TabChromeModel(canGoBack: true, canGoForward: false))
                .environment(\.isIncognito, true)
        }.preferredColorScheme(.dark)
    }
}
