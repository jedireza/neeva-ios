// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct BrowserBottomBarView: View {
    let bvc: BrowserViewController

    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var chromeModel: TabChromeModel

    var body: some View {
        if !browserModel.showGrid && !chromeModel.inlineToolbar && !chromeModel.isEditingLocation {
            TabToolbarContent(
                onNeevaButtonPressed: {
                    if NeevaFeatureFlags[.cheatsheetQuery] {
                        ClientLogger.shared.logCounter(
                            .OpenCheatsheet,
                            attributes: EnvironmentHelper.shared.getAttributes()
                        )
                        chromeModel.clearCheatsheetPopoverFlags()
                        bvc.showCheatSheetOverlay()
                    } else {
                        ClientLogger.shared.logCounter(
                            .OpenNeevaMenu,
                            attributes: EnvironmentHelper.shared.getAttributes()
                        )
                        bvc.showNeevaMenuSheet()
                    }
                }
            )
        } else if browserModel.showGrid {
            SwitcherToolbarView(top: false)
        }
    }
}
