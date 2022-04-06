// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

// UIKit wrapper for `HistoryPanelView`.
class HistoryPanelViewController: UIHostingController<AnyView> {
    init(tabManager: TabManager) {
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            HistoryPanelView(model: HistoryPanelModel(tabManager: tabManager)) {
                self.dismiss(animated: true)
            })
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
