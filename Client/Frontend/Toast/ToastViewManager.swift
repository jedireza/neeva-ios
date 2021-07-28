// Copyright Neeva. All rights reserved.

import Shared
import SnapKit
import SwiftUI
import UIKit

enum ToastQueueLocation {
    case first
    case last
}

class ToastViewManager {
    public static let shared = ToastViewManager()
    private let toastWindowManager = ToastWindowManager()
    private var queuedToasts = [ToastView]()

    // current toast varibles
    private let toastAnimationTime = 0.5
    private var currentToast: ToastView?
    private var currentToastTimer: Timer?
    private var currentToastIsDragging = false

    /// Creates Toast that can then be displayed
    public func makeToast(
        text: String, buttonText: String? = nil,
        toastProgressViewModel: ToastProgressViewModel? = nil, displayTime: Double = 4.5,
        autoDismiss: Bool = true, buttonAction: (() -> Void)? = nil
    ) -> ToastView {
        let content = ToastViewContent(
            normalContent: ToastStateContent(
                text: text, buttonText: buttonText, buttonAction: buttonAction))
        return ToastView(
            displayTime: displayTime, autoDismiss: autoDismiss, content: content,
            toastProgressViewModel: toastProgressViewModel)
    }

    public func makeToast(
        content: ToastViewContent, toastProgressViewModel: ToastProgressViewModel? = nil,
        displayTime: Double = 4.5, autoDismiss: Bool = true
    ) -> ToastView {
        return ToastView(
            displayTime: displayTime, autoDismiss: autoDismiss, content: content,
            toastProgressViewModel: toastProgressViewModel)
    }

    /// Adds Toast view to queue of Toasts to be displayed in linear order
    /// - Parameters:
    ///   - toastView: The Toast view to be displayed, call makeToast() to make one
    ///   - location: ToastQueueLocation.first to be next Toast to be displayed or ToastQueueLocation.last (default) to be displayed after other in front
    public func enqueue(toast: ToastView, at location: ToastQueueLocation = .last) {
        switch location {
        case .first:
            queuedToasts.insert(toast, at: 0)
        case .last:
            queuedToasts.append(toast)
        }

        // if no other toasts are lined up, present the one just created
        if queuedToasts.count == 1 {
            present(toast)
        }
    }

    /// Removes all queued Toast views, and immediately displays the requested Toast
    public func clearQueueAndDisplay(_ toast: ToastView) {
        queuedToasts.removeAll()

        if currentToast != nil {
            dismissCurrentToast(moveToNext: false, overrideDrag: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + toastAnimationTime) {
                self.present(toast)
            }
        } else {
            present(toast)
        }
    }

    /// Opens new UIWindow and displays Toast inside, creates Timer to remove Toast
    private func present(_ toast: ToastView) {
        currentToast = toast
        currentToast?.viewDelegate = self

        let toastViewHostingController = UIHostingController(rootView: currentToast)
        toastViewHostingController.view.backgroundColor = .clear

        // creates new window to display Toast in
        toastWindowManager.createWindow(with: toastViewHostingController)

        // add timer if Toast should auto dismiss or if download completed by the time the Toast is displayed
        if let toastProgressViewModel = toast.toastProgressViewModel,
            toastProgressViewModel.status != .inProgress
        {
            startToastDismissTimer(for: toast)
        } else if toast.autoDismiss {
            startToastDismissTimer(for: toast)
        }
    }

    private func startToastDismissTimer(for toast: ToastView) {
        currentToastTimer = Timer.scheduledTimer(
            withTimeInterval: toast.displayTime, repeats: false,
            block: { _ in
                self.dismissCurrentToast()
            })
    }

    public func dismissCurrentToast(moveToNext: Bool = true, overrideDrag: Bool = false) {
        guard !currentToastIsDragging || overrideDrag else {
            return
        }

        currentToastTimer?.invalidate()

        // removes Toast from view
        toastWindowManager.removeCurrentWindow()

        self.currentToast = nil
        self.currentToastTimer = nil
        self.currentToastIsDragging = false

        DispatchQueue.main.asyncAfter(deadline: .now() + toastAnimationTime) {
            if moveToNext {
                self.nextToast()
            }
        }
    }

    /// Presents the next queued Toast if it exists
    private func nextToast() {
        if queuedToasts.count > 0 {
            queuedToasts.removeFirst()

            if let nextToast = queuedToasts.first {
                present(nextToast)
            }
        }
    }
}

// MARK: ToastViewDelegate
extension ToastViewManager: ToastViewDelegate {
    func draggingUpdated() {
        currentToastIsDragging = true
    }

    func draggingEnded(dismissing: Bool) {
        currentToastIsDragging = false

        if dismissing || !(currentToastTimer?.isValid ?? true) {
            dismissCurrentToast()
        }
    }

    func dismiss() {
        dismissCurrentToast()
    }
}
