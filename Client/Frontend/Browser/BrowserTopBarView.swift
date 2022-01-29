// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct BrowserTopBarView: View {
    let bvc: BrowserViewController

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridModel: GridModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var useTopToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    @ViewBuilder var switcherTopBar: some View {
        if useTopToolbar {
            SwitcherToolbarView(top: true)
        } else {
            GridPicker()
        }
    }

    var body: some View {
        if browserModel.showGrid {
            switcherTopBar
                .modifier(
                    SwipeToSwitchToSpacesGesture(
                        gridModel: gridModel, tabModel: gridModel.tabCardModel,
                        horizontalOffsetChanged: {
                            offset in
                            gridModel.dragOffset = offset
                        }, fromPicker: true))
        } else {
            TopBarContent(
                browserModel: browserModel,
                suggestionModel: bvc.suggestionModel,
                model: bvc.locationModel,
                queryModel: bvc.searchQueryModel,
                gridModel: gridModel,
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
        }
    }
}
