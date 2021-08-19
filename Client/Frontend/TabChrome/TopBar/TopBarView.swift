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
    let newTab: () -> Void
    let closeLazyTab: () -> Void
    let onOverflowMenuAction: (OverflowMenuAction, UIView) -> Void
    let changedUserAgent: Bool?

    @State private var shouldInsetHorizontally = false

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
                        onLongPress: { performTabToolbarAction(.longPressBackForward) }
                    ).tapTargetFrame()
                    if FeatureFlag[.overflowMenu] {
                        TopBarOverflowMenuButton(
                            changedUserAgent: changedUserAgent,
                            onOverflowMenuAction: onOverflowMenuAction)
                    }
                    TopBarNeevaMenuButton(
                        onTap: didTapNeevaMenu, onNeevaMenuAction: onNeevaMenuAction)
                }
                TabLocationView(
                    onReload: onReload, onSubmit: onSubmit, onShare: onShare,
                    buildReloadMenu: buildReloadMenu, closeLazyTab: closeLazyTab
                )
                .padding(.horizontal, chrome.inlineToolbar ? 0 : 8)
                .padding(.top, chrome.inlineToolbar ? 8 : 3)
                // -1 for the progress bar
                .padding(.bottom, (chrome.inlineToolbar ? 8 : 10) - 1)
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
                        Button(action: newTab) {
                            Symbol(.plusApp, label: "New Tab")
                        }
                    }
                }
            }
            .opacity(chrome.controlOpacity)
            .padding(.horizontal, shouldInsetHorizontally ? 12 : 0)
            .padding(.bottom, chrome.estimatedProgress == nil ? 0 : -1)

            Group {
                if let progress = chrome.estimatedProgress {
                    ProgressView(value: progress)
                        .progressViewStyle(PageProgressBarStyle())
                        .padding(.bottom, -1)
                        .zIndex(1)
                        .ignoresSafeArea(edges: .horizontal)
                }
            }
            .transition(.opacity)

            Color.ui.adaptive.separator.frame(height: 0.5).ignoresSafeArea()
        }
        .background(
            GeometryReader { geom in
                let shouldInsetHorizontally =
                    geom.safeAreaInsets.leading == 0 && geom.safeAreaInsets.trailing == 0
                    && chrome.inlineToolbar
                Color.clear
                    .useEffect(deps: shouldInsetHorizontally) { self.shouldInsetHorizontally = $0 }
            }
        )
        .animation(.default, value: chrome.estimatedProgress)
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
                    onNeevaMenuAction: { _ in }, didTapNeevaMenu: {}, newTab: {}, closeLazyTab: {},
                    onOverflowMenuAction: { _, _ in }, changedUserAgent: false)
                Spacer()
            }.background(Color.red.ignoresSafeArea())

            VStack {
                TopBarView(
                    performTabToolbarAction: { _ in }, buildTabsMenu: { nil }, onReload: {},
                    onSubmit: { _ in }, onShare: { _ in }, buildReloadMenu: { nil },
                    onNeevaMenuAction: { _ in }, didTapNeevaMenu: {}, newTab: {}, closeLazyTab: {},
                    onOverflowMenuAction: { _, _ in }, changedUserAgent: false)
                Spacer()
            }
            .preferredColorScheme(.dark)
        }
        .environmentObject(LocationViewModel(previewURL: nil, isSecure: true))
        .environmentObject(GridModel())
        .environmentObject(TabChromeModel(estimatedProgress: 0.5))
    }
}
