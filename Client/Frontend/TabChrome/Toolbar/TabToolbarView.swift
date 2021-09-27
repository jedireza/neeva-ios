// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

struct TabToolbarView: View {
    let performAction: (ToolbarAction) -> Void
    let buildTabsMenu: () -> UIMenu?
    let onNeevaMenu: () -> Void

    @EnvironmentObject var chromeModel: TabChromeModel

    var body: some View {
        VStack(spacing: 0) {
            Color.ui.adaptive.separator
                .frame(height: 0.5)
                .ignoresSafeArea()

            HStack(spacing: 0) {
                TabToolbarButtons.BackButton(
                    weight: .medium,
                    onBack: { performAction(.back) },
                    onLongPress: { performAction(.longPressBackForward) }
                )
                TabToolbarButtons.OverflowMenu(
                    weight: .medium,
                    action: {
                        performAction(.overflow)
                    },
                    onLongPress: {
                        performAction(.longPressOverflow)
                    })
                TabToolbarButtons.NeevaMenu(iconWidth: 22, action: onNeevaMenu)
                TabToolbarButtons.AddToSpace(
                    weight: .medium, action: { performAction(.addToSpace) })
                TabToolbarButtons.ShowTabs(
                    weight: .medium,
                    action: { performAction(.showTabs) },
                    buildMenu: buildTabsMenu
                ).frame(height: 44)
            }
            .padding(.top, 2)
            .opacity(chromeModel.controlOpacity)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("TabToolbar")

            Spacer()
        }
        .background(Color.DefaultBackground.ignoresSafeArea())
        .accentColor(.label)
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
