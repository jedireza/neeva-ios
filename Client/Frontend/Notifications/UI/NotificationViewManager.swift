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

        let viewHostingController = UIHostingController(rootView: currentView)
        viewHostingController.view.backgroundColor = .clear

        if FeatureFlag[.enableBrowserView] {
            overlayManager.show(overlay: .notification(currentView!))
            startViewDismissTimer(for: view)
        } else {
            // creates new window to display View in
            windowManager.createWindow(
                with: viewHostingController, placement: .top, height: height
            ) { [weak self] in
                guard let self = self else { return }
                self.startViewDismissTimer(for: view)
            }
        }
    }
}
