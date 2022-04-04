// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SFSafeSymbols
import Shared
import SwiftUI
import WalletCore

struct TabToolbarView: View {
    @EnvironmentObject var chromeModel: TabChromeModel
    @EnvironmentObject var scrollingControlModel: ScrollingControlModel
    @Default(.currentTheme) var currentTheme

    let performAction: (ToolbarAction) -> Void
    let buildTabsMenu: (_ sourceView: UIView) -> UIMenu?
    let onNeevaButtonPressed: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Color.ui.adaptive.separator
                .frame(height: 0.5)
                .ignoresSafeArea()

            if chromeModel.toolBarContentView == .recipeContent {
                cheatsheetToolbar
            } else if NeevaConstants.currentTarget == .xyz {
                Web3Toolbar(
                    opacity: scrollingControlModel.controlOpacity,
                    buildTabsMenu: buildTabsMenu,
                    onBack: { performAction(.back) },
                    onLongPress: { performAction(.longPressBackForward) },
                    overFlowMenuAction: { performAction(.overflow) },
                    showTabsAction: { performAction(.showTabs) },
                    openLazyTabAction: { performAction(.openLazyTab) }
                )
            } else {
                normalTabToolbar
            }
            Spacer()
        }
        .background(
            NeevaConstants.currentTarget == .xyz
                ? Web3Theme(with: currentTheme).backgroundColor.ignoresSafeArea()
                : Color.DefaultBackground.ignoresSafeArea()
        )
        .accentColor(.label)
        .offset(y: scrollingControlModel.footerBottomOffset)
    }

    @ViewBuilder
    var normalTabToolbar: some View {
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
                identifier: "TabOverflowButton"
            )
            neevaButton
            TabToolbarButtons.AddToSpace(
                weight: .medium, action: { performAction(.addToSpace) })
            TabToolbarButtons.ShowTabs(
                weight: .medium,
                action: { performAction(.showTabs) },
                buildMenu: buildTabsMenu
            ).frame(height: 44)
        }
        .padding(.top, 2)
        .opacity(scrollingControlModel.controlOpacity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TabToolbar")
        .accessibilityLabel("Toolbar")
    }

    @ViewBuilder
    var cheatsheetToolbar: some View {
        HStack(spacing: 0) {
            TabToolbarButtons.ShareButton(
                weight: .medium, action: { performAction(.share) })
            TabToolbarButtons.AddToSpace(
                weight: .medium, action: { performAction(.addToSpace) })
        }
        .padding(.top, 2)
        .opacity(scrollingControlModel.controlOpacity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("CheatsheetToolBar")
    }

    @ViewBuilder
    private var neevaButton: some View {
        TabToolbarButtons.Neeva(iconWidth: 22) {
            onNeevaButtonPressed()
        }
        .presentAsPopover(
            isPresented: $chromeModel.showTryCheatsheetPopover,
            backgroundColor: CheatsheetTooltipPopoverView.backgroundColor,
            dismissOnTransition: true
        ) {
            CheatsheetTooltipPopoverView()
                .frame(maxWidth: 270)
        }
    }
}

struct TabToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        let make = { (model: TabChromeModel) in
            TabToolbarView(
                performAction: { _ in }, buildTabsMenu: { _ in nil }, onNeevaButtonPressed: {}
            )
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
                .environmentObject(IncognitoModel(isIncognito: true))
        }
        VStack {
            Spacer()
            make(TabChromeModel(canGoBack: true, canGoForward: false))
                .environmentObject(IncognitoModel(isIncognito: true))
        }.preferredColorScheme(.dark)
    }
}
