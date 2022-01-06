// Copyright Neeva. All rights reserved.

import Shared
import SnapKit
import SwiftUI
import UIKit

public enum QueuedViewLocation {
    case first
    case last
}

open class QueuedViewManager<View: SwiftUI.View> {
    let windowManager: WindowManager
    /// For use with BrowserView only
    lazy var overlayManager: OverlayManager = {
        SceneDelegate.getBVC(with: windowManager.parentWindow.windowScene).overlayManager
    }()
    var queuedViews = [View]()

    let animationTime = 0.5
    var currentView: View?
    var currentViewTimer: Timer?
    var currentViewIsDragging = false

    func enqueue(view: View, at location: QueuedViewLocation = .last) {
        switch location {
        case .first:
            queuedViews.insert(view, at: 0)
        case .last:
            queuedViews.append(view)
        }

        // if no other Views are lined up, present the one just created
        if queuedViews.count == 1 {
            present(view)
        }
    }

    /// Removes all queued View views, and immediately displays the requested View
    func clearQueueAndDisplay(_ view: View) {
        queuedViews.removeAll()

        if currentView != nil {
            dismissCurrentView(moveToNext: false, overrideDrag: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                self.present(view)
            }
        } else {
            present(view)
        }
    }

    /// Opens new UIWindow and displays View inside, creates Timer to remove View
    func present(_ view: View, height: CGFloat = 80) {
        currentView = view

        let viewHostingController = UIHostingController(rootView: view)
        viewHostingController.view.backgroundColor = .clear

        // creates new window to display View in
        windowManager.createWindow(
            with: viewHostingController, placement: .bottomToolbarPadding, height: height
        ) { [weak self] in
            guard let self = self else { return }
            self.startViewDismissTimer(for: view)
        }
    }

    func startViewDismissTimer(for view: View) {
        currentViewTimer = Timer.scheduledTimer(
            withTimeInterval: getDisplayTime(for: view), repeats: false,
            block: { _ in
                self.dismissCurrentView()
            })
    }

    func dismissCurrentView(
        moveToNext: Bool = true, overrideDrag: Bool = false, animate: Bool = true
    ) {
        guard !currentViewIsDragging || overrideDrag else {
            return
        }

        currentViewTimer?.invalidate()

        if FeatureFlag[.enableBrowserView] {
            overlayManager.hideCurrentOverlay(animate: animate)
        } else {
            // removes View from window
            windowManager.removeCurrentWindow()
        }

        self.currentView = nil
        self.currentViewTimer = nil
        self.currentViewIsDragging = false

        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
            if moveToNext {
                self.nextView()
            }
        }
    }

    /// Presents the next queued View if it exists
    func nextView() {
        if queuedViews.count > 0 {
            queuedViews.removeFirst()

            if let nextView = queuedViews.first {
                present(nextView)
            }
        }
    }

    func getDisplayTime(for view: View) -> Double {
        return ToastViewUX.defaultDisplayTime
    }

    init(window: UIWindow) {
        self.windowManager = WindowManager(parentWindow: window)
    }
}

// MARK: QueuedViewManager
extension QueuedViewManager: BannerViewDelegate {
    func draggingUpdated() {
        currentViewIsDragging = true
    }

    func draggingEnded(dismissing: Bool) {
        currentViewIsDragging = false

        if dismissing || !(currentViewTimer?.isValid ?? true) {
            dismissCurrentView(animate: !dismissing)
        }
    }

    func dismiss() {
        dismissCurrentView(animate: false)
    }
}
