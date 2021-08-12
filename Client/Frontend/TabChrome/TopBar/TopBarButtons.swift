// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct TopBarNeevaMenuButton: View {
    let onTap: () -> Void
    let onNeevaMenuAction: (NeevaMenuAction) -> Void

    @Environment(\.isIncognito) private var isIncognito

    // TODO: sync this state variable with TabToolbarView somehow
    @State private var presenting = false
    @State private var action: NeevaMenuAction?

    var body: some View {
        TabToolbarButtons.NeevaMenu(iconWidth: 24) {
            onTap()
            presenting = true
        }
        .tapTargetFrame()
        .presentAsPopover(
            isPresented: $presenting,
            arrowDirections: .up,
            dismissOnTransition: true,
            onDismiss: {
                if let action = action {
                    onNeevaMenuAction(action)
                    self.action = nil
                }
            }
        ) {
            VerticalScrollViewIfNeeded {
                NeevaMenuView {
                    action = $0
                    presenting = false
                }
                .padding(.bottom, 16)
                .environment(\.isIncognito, isIncognito)
            }.frame(minWidth: 340, minHeight: 323)
        }
    }
}

/// see also `LocationViewShareButton`
struct TopBarShareButton: View {
    let url: URL?
    let onTap: (UIView) -> Void

    @State private var shareTargetView: UIView!
    @EnvironmentObject private var chromeModel: TabChromeModel

    var body: some View {
        TabToolbarButton(label: Symbol(.squareAndArrowUp, size: 20, label: "Share")) {
            onTap(shareTargetView)
        }
        .uiViewRef($shareTargetView)
        .disabled(url == nil || !chromeModel.isPage)
    }
}

struct TopBarShareButton_Previews: PreviewProvider {
    static var previews: some View {
        TopBarShareButton(url: nil, onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))
        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: false))

        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))

        TopBarNeevaMenuButton(onTap: {}, onNeevaMenuAction: { _ in })
    }
}
