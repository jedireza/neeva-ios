// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct BrowserTopBarView: View {
    let bvc: BrowserViewController
    var gridModel: GridModel

    @ObservedObject var browserModel: BrowserModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var useTopToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    @ViewBuilder var switcherTopBar: some View {
        if useTopToolbar {
            SwitcherToolbarView(
                top: true, isEmpty: bvc.tabContainerModel.tabCardModel.isCardGridEmpty
            )
            .environmentObject(bvc.toolbarModel)
        } else {
            GridPicker()
        }
    }

    var body: some View {
        if browserModel.currentState == .tab {
            TopBarContent(
                suggestionModel: bvc.suggestionModel,
                model: bvc.locationModel,
                queryModel: bvc.searchQueryModel,
                gridModel: bvc.gridModel,
                trackingStatsViewModel: bvc.trackingStatsViewModel,
                chromeModel: bvc.chromeModel,
                readerModeModel: bvc.readerModeModel,
                web3Model: bvc.web3Model,
                newTab: {
                    bvc.openURLInNewTab(nil)
                },
                onCancel: {
                    if bvc.zeroQueryModel.isLazyTab {
                        bvc.closeLazyTab()
                    } else {
                        bvc.hideZeroQuery()
                    }
                }
            )
        } else if browserModel.currentState == .switcher {
            switcherTopBar
                .environmentObject(bvc.gridModel)
                .environmentObject(bvc.gridModel.tabCardModel)
                .modifier(
                    SwipeToSwitchToSpacesGesture(
                        gridModel: gridModel, tabModel: gridModel.tabCardModel, fromPicker: true
                    ) {
                        offset in
                        gridModel.dragOffset = offset
                    })
        }
    }
}
