// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI

private enum BrowserViewUX {
    static let ShowHeaderTapAreaHeight = 32.0
}

// CardGrid is a parameter to this View so that we isolate it from updates
// to this View (specifically updates to BrowserModel.showContent).
struct BrowserContentView: View {
    let bvc: BrowserViewController
    let cardGrid: CardGrid

    @EnvironmentObject var browserModel: BrowserModel

    var tabContainerContent: some View {
        TabContainerContent(
            model: bvc.tabContainerModel,
            bvc: bvc,
            zeroQueryModel: bvc.zeroQueryModel,
            suggestionModel: bvc.suggestionModel,
            spaceContentSheetModel: FeatureFlag[.spaceComments]
                ? SpaceContentSheetModel(
                    tabManager: bvc.tabManager,
                    spaceModel: bvc.gridModel.spaceCardModel) : nil
        )
    }

    var body: some View {
        ZStack {
            cardGrid
                .environment(
                    \.onOpenURL, { bvc.gridModel.tabCardModel.manager.createOrSwitchToTab(for: $0) }
                )
                .environment(
                    \.onOpenURLForSpace,
                    {
                        bvc.gridModel.tabCardModel.manager.createOrSwitchToTabForSpace(
                            for: $0, spaceID: $1)
                    }
                )
                .opacity(browserModel.showContent ? 0 : 1)
                .onAppear {
                    bvc.gridModel.scrollToSelectedTab()
                }
                .accessibilityHidden(browserModel.showContent)
                .ignoresSafeArea(edges: [.bottom])

            tabContainerContent
                .opacity(browserModel.showContent ? 1 : 0)
                .accessibilityHidden(!browserModel.showContent)
        }
    }
}

struct BrowserView: View {
    // MARK: - Parameters
    // TODO: Eliminate this dependency
    let bvc: BrowserViewController
    let shareURL: (URL, UIView) -> Void

    // Explicitly not an observed object to avoid costly updates.
    let browserModel: BrowserModel

    @ObservedObject var gridModel: GridModel
    @ObservedObject var chromeModel: TabChromeModel
    @ObservedObject var overlayManager: OverlayManager

    private var detailViewVisible: Bool {
        gridModel.showingDetailView
    }

    // MARK: - Views
    var topBar: some View {
        GeometryReader { geom in
            BrowserTopBarView(bvc: bvc)
                .transition(.opacity)
                .frame(height: chromeModel.topBarHeight)
                .offset(
                    x: detailViewVisible
                        ? -geom.size.width - geom.safeAreaInsets.leading
                            - geom.safeAreaInsets.trailing : 0)
        }
    }

    var bottomBar: some View {
        BrowserBottomBarView(bvc: bvc)
            .transition(.opacity)
            .frame(
                height: UIConstants.TopToolbarHeightWithToolbarButtonsShowing
            )
            .ignoresSafeArea(.keyboard)
    }

    var mainContent: some View {
        GeometryReader { geom in
            VStack(spacing: 0) {
                ZStack {
                    // Tab content or CardGrid
                    BrowserContentView(bvc: bvc, cardGrid: CardGrid())
                        .environment(\.shareURL, shareURL)
                        .padding(
                            UIConstants.enableBottomURLBar ? .bottom : .top,
                            detailViewVisible ? 0 : chromeModel.topBarHeight
                        )
                        .background(Color.background)

                    // Top Bar
                    VStack {
                        if UIConstants.enableBottomURLBar { Spacer() }

                        if !UIConstants.enableBottomURLBar, chromeModel.inlineToolbar {
                            topBar
                                .background(
                                    Group {
                                        // invisible tap area to show the toolbars since modern iOS
                                        // does not have a status bar in landscape.
                                        Color.clear
                                            .ignoresSafeArea()
                                            .frame(height: BrowserViewUX.ShowHeaderTapAreaHeight)
                                            // without this, the area isn’t tappable because it’s invisible
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                browserModel.scrollingControlModel.showToolbars(
                                                    animated: true)
                                            }
                                    }, alignment: .top)
                        } else {
                            topBar
                        }

                        if !UIConstants.enableBottomURLBar { Spacer() }
                    }
                }

                // Bottom Bar
                if !chromeModel.inlineToolbar && !chromeModel.isEditingLocation
                    && !detailViewVisible && !chromeModel.keyboardShowing
                    && !overlayManager.hideBottomBar
                {
                    bottomBar
                        .offset(x: detailViewVisible ? -geom.size.width : 0)
                        .onHeightOfViewChanged { height in
                            self.chromeModel.bottomBarHeight = height
                        }
                }
            }.useEffect(deps: chromeModel.topBarHeight) { _ in
                browserModel.scrollingControlModel.setHeaderFooterHeight(
                    header: chromeModel.topBarHeight,
                    footer: UIConstants.TopToolbarHeightWithToolbarButtonsShowing
                        + geom.safeAreaInsets.bottom)
            }.keyboardListener(adapt: false) { height in
                DispatchQueue.main.async {
                    chromeModel.keyboardShowing = height > 0
                }
            }
        }
    }

    var body: some View {
        ZStack {
            mainContent
            OverlayView(overlayManager: overlayManager)
        }
        .environmentObject(browserModel)
        .environmentObject(browserModel.incognitoModel)
        .environmentObject(browserModel.cardTransitionModel)
        .environmentObject(browserModel.scrollingControlModel)
        .environmentObject(bvc.simulateBackModel)
        .environmentObject(chromeModel)
        .environmentObject(gridModel)
        .environmentObject(bvc.toolbarModel)
        .environmentObject(gridModel.tabCardModel)
        .environmentObject(gridModel.spaceCardModel)
        .environmentObject(gridModel.tabGroupCardModel)
        .environmentObject(bvc.web3Model)
    }

    // MARK: - Init
    init(bvc: BrowserViewController) {
        self.bvc = bvc
        self.shareURL = { url, view in
            bvc.shareURL(url: url, view: view)
        }
        self.gridModel = bvc.gridModel
        self.chromeModel = bvc.chromeModel
        self.overlayManager = bvc.overlayManager
        self.browserModel = bvc.browserModel
    }
}
