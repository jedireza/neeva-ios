// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

protocol ToolbarDelegate: AnyObject {
    var performTabToolbarAction: (ToolbarAction) -> Void { get }
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?)
    func tabToolbarTabsMenu(sourceView: UIView) -> UIMenu?
}

struct TabToolbarContent: View {
    let chromeModel: TabChromeModel
    let showNeevaMenuSheet: () -> Void

    var body: some View {
        TabToolbarView(
            performAction: { chromeModel.toolbarDelegate?.performTabToolbarAction($0) },
            buildTabsMenu: { chromeModel.toolbarDelegate?.tabToolbarTabsMenu(sourceView: $0) },
            onNeevaMenu: {
                ClientLogger.shared.logCounter(
                    .OpenNeevaMenu, attributes: EnvironmentHelper.shared.getAttributes())
                showNeevaMenuSheet()
            }
        )
        .environmentObject(chromeModel)
    }
}
