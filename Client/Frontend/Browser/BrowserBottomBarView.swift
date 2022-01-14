// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct BrowserBottomBarView: View {
    let bvc: BrowserViewController
    let chromeModel: TabChromeModel

    @EnvironmentObject var browserModel: BrowserModel

    var body: some View {
        if !browserModel.showGrid && !chromeModel.inlineToolbar && !chromeModel.isEditingLocation {
            TabToolbarContent(
                chromeModel: bvc.chromeModel,
                showNeevaMenuSheet: {
                    bvc.showNeevaMenuSheet()
                }
            )
        } else if browserModel.showGrid {
            SwitcherToolbarView(
                top: false, isEmpty: bvc.tabContainerModel.tabCardModel.isCardGridEmpty
            )
            .environmentObject(bvc.gridModel)
            .environmentObject(bvc.gridModel.tabCardModel)
            .environmentObject(bvc.toolbarModel)
        }
    }
}
