// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import SFSafeSymbols

fileprivate enum TabToolbarUX {
    static let buttonSize: CGFloat = 44
}

struct TabToolbarView: View {
    @ObservedObject var model: TabToolbarModel
    let onBack: () -> ()
    let onForward: () -> ()
    let onLongPressBackForward: () -> ()
    let onNeevaMenu: () -> ()
    let onSaveToSpace: () -> ()
    let onShowTabs: () -> ()
    let tabsMenu: () -> UIMenu?

    var body: some View {
        VStack(spacing: 0) {
            Color(UIColor(light: UIColor(rgb: 0xE5E5EA), dark: .tertiarySystemBackground))
                .frame(height: 0.5)
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
        }.accentColor(.label)
    }
}

struct TabToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        let make = { (model: TabToolbarModel) in
            TabToolbarView(model: model, onBack: {}, onForward: {}, onLongPressBackForward: {}, onNeevaMenu: {}, onSaveToSpace: {}, onShowTabs: {}, tabsMenu: { nil })
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
