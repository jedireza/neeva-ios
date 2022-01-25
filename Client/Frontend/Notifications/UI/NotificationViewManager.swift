// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI
import UIKit

class NotificationViewManager: QueuedViewManager<NotificationRow> {
    override func present(_ view: NotificationRow, height: CGFloat = 80) {
        currentView = view
        currentView?.viewDelegate = self

        overlayManager.show(overlay: .notification(currentView!)) {
            self.startViewDismissTimer(for: view)
        }
    }
}
