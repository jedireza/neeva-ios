// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

extension BrowserViewController {
    func showQuestNeevaMenuPrompt() {
        guard TourManager.shared.hasActiveStep() else { return }

        browserModel.scrollingControlModel.showToolbars(animated: true)
        chromeModel.showNeevaMenuTourPrompt = true
    }
}
