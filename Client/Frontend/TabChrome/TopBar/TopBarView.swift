// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct TopBarView: View {
    let performTabToolbarAction: (ToolbarAction) -> Void
    let buildTabsMenu: () -> UIMenu?
    let onReload: () -> Void
    let onSubmit: (String) -> Void
    let onShare: (UIView) -> Void
    let buildReloadMenu: () -> UIMenu?
    let onNeevaMenuAction: (NeevaMenuAction) -> Void
    let didTapNeevaMenu: () -> Void

    @EnvironmentObject private var chrome: TabChromeModel
    @EnvironmentObject private var location: LocationViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: chrome.inlineToolbar ? 12 : 0) {
                if chrome.inlineToolbar {
                    TabToolbarButtons.BackForward(
                        weight: .regular,
                        onBack: { performTabToolbarAction(.back) },
                        onForward: { performTabToolbarAction(.forward) },
                        onOverflow: { performTabToolbarAction(.overflow) },
                        onLongPress: { performTabToolbarAction(.longPressBackForward) }
                    ).tapTargetFrame()
                    TopBarNeevaMenuButton(
                        onTap: didTapNeevaMenu, onNeevaMenuAction: onNeevaMenuAction)
                }
                TabLocationView(
                    onReload: onReload, onSubmit: onSubmit, onShare: onShare,
                    buildReloadMenu: buildReloadMenu
                )
                .padding(.horizontal, chrome.inlineToolbar ? 0 : 8)
                .padding(.top, chrome.inlineToolbar ? 8 : 3)
                .padding(.bottom, chrome.inlineToolbar ? 8 : 10)
                .layoutPriority(1)
                if chrome.inlineToolbar {
                    TopBarShareButton(url: location.url, onTap: onShare)
                        .tapTargetFrame()
                    TabToolbarButtons.AddToSpace(
                        weight: .regular, action: { performTabToolbarAction(.addToSpace) }
                    )
                    .tapTargetFrame()
                    TabToolbarButtons.ShowTabs(
                        weight: .regular, action: { performTabToolbarAction(.showTabs) },
                        buildMenu: buildTabsMenu
                    )
                    .tapTargetFrame()
                    if FeatureFlag[.cardStrip] {
                        Button(action: {
                            SceneDelegate.getBVC().openURLInNewTab(nil)
                        }) {
                            Symbol(.plusApp, label: "New Tab")
                        }
                    }
                }
            }
            Color.ui.adaptive.separator.frame(height: 0.5).ignoresSafeArea()
        }
        .background(Color.chrome.ignoresSafeArea())
        .accentColor(.label)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                TopBarView(
                    performTabToolbarAction: { _ in }, buildTabsMenu: { nil }, onReload: {},
                    onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil },
                    onNeevaMenuAction: { _ in }, didTapNeevaMenu: {})
                Spacer()
            }.background(Color.red.ignoresSafeArea())

            VStack {
                TopBarView(
                    performTabToolbarAction: { _ in }, buildTabsMenu: { nil }, onReload: {},
                    onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil },
                    onNeevaMenuAction: { _ in }, didTapNeevaMenu: {})
                Spacer()
            }
            .preferredColorScheme(.dark)
        }
        .environmentObject(LocationViewModel(previewURL: nil, hasOnlySecureContent: true))
        .environmentObject(GridModel())
        .environmentObject(TabChromeModel())
    }
}
