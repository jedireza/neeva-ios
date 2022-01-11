// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SwiftUI

struct BrowserView: View {
    // MARK: - Parameters
    // TODO: Eliminate this dependency
    let bvc: BrowserViewController
    let shareURL: (URL, UIView) -> Void

    @State var keyboardShowing = false

    @ObservedObject var browserModel: BrowserModel
    @ObservedObject var gridModel: GridModel
    @ObservedObject var chromeModel: TabChromeModel
    @ObservedObject var scrollingControlModel: ScrollingControlModel
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
        topBarHeight + scrollingControlModel.headerTopOffset
    }

    private var detailViewVisible: Bool {
        gridModel.showingDetailView
    }

    // MARK: - Views
    var topBar: some View {
        BrowserTopBarView(bvc: bvc, browserModel: browserModel)
            .transition(.opacity)
            .frame(height: topBarHeight)
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
        if browserModel.currentState == .tab {
            if case ContentUIType.webPage(_) = bvc.tabContainerModel.currentContentUI {
                tabContainerContent
                    .transition(.scale)
            } else {
                tabContainerContent
            }
        } else {
            CardGrid()
                .environmentObject(bvc.toolbarModel)
                .environmentObject(gridModel.tabCardModel)
                .environmentObject(gridModel.spaceCardModel)
                .environmentObject(gridModel.tabGroupCardModel)
                .environmentObject(gridModel)
                .environmentObject(bvc.web3Model)
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
        }
    }

    var bottomBar: some View {
        BrowserBottomBarView(bvc: bvc, chromeModel: chromeModel, browserModel: browserModel)
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
                            detailViewVisible ? 0 : topBarPadding)

                    // Top Bar
                    VStack {
                        if UIConstants.enableBottomURLBar { Spacer() }

                        topBar
                            .offset(
                                x: detailViewVisible ? -geom.size.width : 0,
                                y: scrollingControlModel.headerTopOffset
                                    * (UIConstants.enableBottomURLBar ? -1 : 1)
                            )
                            .animation(.easeOut)

                        if !UIConstants.enableBottomURLBar { Spacer() }
                    }
                }.padding(.bottom, -scrollingControlModel.footerBottomOffset)

                // Bottom Bar
                if !chromeModel.inlineToolbar && !chromeModel.isEditingLocation
                    && !detailViewVisible && !keyboardShowing
                {
                    bottomBar
                        .offset(
                            x: detailViewVisible ? -geom.size.width : 0,
                            y: scrollingControlModel.footerBottomOffset
                        )
                        .animation(.easeOut)
                }
            }.useEffect(deps: topBarHeight) { _ in
                scrollingControlModel.setHeaderFooterHeight(
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
        }
    }

    // MARK: - Init
    init(bvc: BrowserViewController) {
        self.bvc = bvc
        self.shareURL = { url, view in
            bvc.shareURL(url: url, view: view)
        }
        self.gridModel = bvc.gridModel
        self.browserModel = bvc.browserModel
        self.chromeModel = bvc.chromeModel
        self.scrollingControlModel = ScrollingControlModel(
            tabManager: bvc.tabManager, chromeModel: bvc.chromeModel)
        self.overlayManager = bvc.overlayManager
        self.tabGroupModel = bvc.gridModel.tabGroupCardModel
        self.spaceModel = bvc.gridModel.spaceCardModel
    }
}
