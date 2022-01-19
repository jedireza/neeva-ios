// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI

private enum BrowserViewUX {
    static let ShowHeaderTapAreaHeight = 32.0
}

struct BrowserView: View {
    // MARK: - Parameters
    // TODO: Eliminate this dependency
    let bvc: BrowserViewController
    let shareURL: (URL, UIView) -> Void

    @State var keyboardShowing = false
    @State var bottomBarHeight: CGFloat = 0

    @ObservedObject var browserModel: BrowserModel
    @ObservedObject var gridModel: GridModel
    @ObservedObject var chromeModel: TabChromeModel
    @ObservedObject var overlayManager: OverlayManager
    @ObservedObject var tabGroupModel: TabGroupCardModel
    @ObservedObject var spaceModel: SpaceCardModel

    private var inlineToolbarHeight: CGFloat {
        return UIConstants.TopToolbarHeightWithToolbarButtonsShowing
            + (chromeModel.showTopCardStrip ? CardControllerUX.Height : 0)
    }

    private var portraitHeight: CGFloat {
        return UIConstants.PortraitToolbarHeight
            + (chromeModel.showTopCardStrip ? CardControllerUX.Height : 0)
    }

    private var topBarHeight: CGFloat {
        return chromeModel.inlineToolbar ? inlineToolbarHeight : portraitHeight
    }

    private var topBarPadding: CGFloat {
        // Prevents a bug where the page content gets stuck behind the TopBar
        let padding = topBarHeight + browserModel.scrollingControlModel.headerTopOffset
        return padding <= 0 ? 1 : padding
    }

    private var detailViewVisible: Bool {
        gridModel.showingDetailView
    }

    // MARK: - Views
    var topBar: some View {
        GeometryReader { geom in
            BrowserTopBarView(bvc: bvc)
                .transition(.opacity)
                .frame(height: topBarHeight)
                .offset(
                    x: detailViewVisible ? -geom.size.width : 0,
                    y: browserModel.scrollingControlModel.headerTopOffset
                        * (UIConstants.enableBottomURLBar ? -1 : 1)
                )
        }
    }

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

    @ViewBuilder
    var containerView: some View {
        ZStack {
            CardGrid()
                .environment(
                    \.onOpenURL, { gridModel.tabCardModel.manager.createOrSwitchToTab(for: $0) }
                )
                .environment(
                    \.onOpenURLForSpace,
                    {
                        gridModel.tabCardModel.manager.createOrSwitchToTabForSpace(
                            for: $0, spaceID: $1)
                    }
                )
                .environment(\.shareURL, shareURL)
                .opacity(browserModel.showContent ? 0 : 1)
                .onAppear {
                    gridModel.scrollToSelectedTab()
                }
                .accessibilityHidden(browserModel.showContent)

            tabContainerContent
                .opacity(browserModel.showContent ? 1 : 0)
                .accessibilityHidden(!browserModel.showContent)
        }
    }

    var bottomBar: some View {
        BrowserBottomBarView(bvc: bvc, chromeModel: chromeModel)
            .transition(.opacity)
            .frame(
                height: UIConstants.TopToolbarHeightWithToolbarButtonsShowing)
    }

    var mainContent: some View {
        GeometryReader { geom in
            VStack(spacing: 0) {
                ZStack {
                    // Tab content or CardGrid
                    containerView
                        .padding(
                            UIConstants.enableBottomURLBar ? .bottom : .top,
                            detailViewVisible ? 0 : topBarPadding
                        )

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
                }.padding(.bottom, -browserModel.scrollingControlModel.footerBottomOffset)

                // Bottom Bar
                if !chromeModel.inlineToolbar && !chromeModel.isEditingLocation
                    && !detailViewVisible && !keyboardShowing && !overlayManager.hideBottomBar
                {
                    bottomBar
                        .offset(
                            x: detailViewVisible ? -geom.size.width : 0,
                            y: browserModel.scrollingControlModel.footerBottomOffset
                        )
                        .onHeightOfViewChanged { height in
                            self.bottomBarHeight = height
                        }
                }
            }.useEffect(deps: topBarHeight) { _ in
                browserModel.scrollingControlModel.setHeaderFooterHeight(
                    header: topBarHeight,
                    footer: UIConstants.TopToolbarHeightWithToolbarButtonsShowing
                        + geom.safeAreaInsets.bottom)
            }.keyboardListener(adapt: false) { height in
                DispatchQueue.main.async {
                    keyboardShowing = height > 0
                }
            }
        }
    }

    var body: some View {
        ZStack {
            mainContent
            OverlayView(overlayManager: overlayManager)
                .padding(
                    .bottom,
                    overlayManager.offsetForBottomBar && !chromeModel.inlineToolbar
                        && !keyboardShowing
                        ? bottomBarHeight - browserModel.scrollingControlModel.footerBottomOffset
                        : 0)
        }
        .environmentObject(bvc.browserModel)
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
        self.tabGroupModel = bvc.gridModel.tabGroupCardModel
        self.spaceModel = bvc.gridModel.spaceCardModel
        self.browserModel = bvc.browserModel
    }
}
