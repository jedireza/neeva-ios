// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

struct TabToolbarView: View {
    let onBack: () -> Void
    let onForward: () -> Void
    let onLongPressBackForward: () -> Void
    let onNeevaMenu: () -> Void
    let onSaveToSpace: () -> Void
    let onShowTabs: () -> Void
    let tabsMenu: () -> UIMenu?

    @EnvironmentObject private var model: TabToolbarModel

    var body: some View {
        VStack(spacing: 0) {
            Color.ui.adaptive.separator
                .frame(height: 0.5)
                .ignoresSafeArea()
            HStack(spacing: 0) {
                TabToolbarButtons.BackForward(
                    model: model,
                    onBack: onBack, onForward: onForward,
                    onLongPress: onLongPressBackForward
                )
                TabToolbarButtons.NeevaMenu(action: onNeevaMenu)
                TabToolbarButtons.AddToSpace(action: onSaveToSpace)
                TabToolbarButtons.ShowTabs(action: onShowTabs, buildMenu: tabsMenu)
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
        let make = { (model: TabToolbarModel) in
            TabToolbarView(
                onBack: {}, onForward: {}, onLongPressBackForward: {}, onNeevaMenu: {},
                onSaveToSpace: {}, onShowTabs: {}, tabsMenu: { nil }
            )
            .environmentObject(model)
        }
        VStack {
            Spacer()
            make(TabToolbarModel(canGoBack: true, canGoForward: false))
        }
        VStack {
            Spacer()
            make(TabToolbarModel(canGoBack: true, canGoForward: false))
        }.preferredColorScheme(.dark)
        VStack {
            Spacer()
            make(TabToolbarModel(canGoBack: true, canGoForward: false))
                .environment(\.isIncognito, true)
        }
        VStack {
            Spacer()
            make(TabToolbarModel(canGoBack: true, canGoForward: false))
                .environment(\.isIncognito, true)
        }.preferredColorScheme(.dark)
    }
}
