// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI
import UIKit

class ToastViewManager: QueuedViewManager<ToastView> {
    /// Creates Toast that can then be displayed
    public func makeToast(
        text: LocalizedStringKey, buttonText: LocalizedStringKey? = nil,
        toastProgressViewModel: ToastProgressViewModel? = nil, displayTime: Double = 4.5,
        autoDismiss: Bool = true, buttonAction: (() -> Void)? = nil
    ) -> ToastView {
        let content = ToastViewContent(
            normalContent: ToastStateContent(
                text: text, buttonText: buttonText, buttonAction: buttonAction))
        return ToastView(
            displayTime: displayTime, autoDismiss: autoDismiss,
            content: content, toastProgressViewModel: toastProgressViewModel)
    }

    public func makeToast(
        content: ToastViewContent,
        toastProgressViewModel: ToastProgressViewModel? = nil,
        displayTime: Double = 4.5, autoDismiss: Bool = true
    ) -> ToastView {
        return ToastView(
            displayTime: displayTime, autoDismiss: autoDismiss,
            content: content, toastProgressViewModel: toastProgressViewModel)
    }

    override func present(_ view: ToastView, height: CGFloat = 80) {
        currentView = view
        currentView?.viewDelegate = self

        let toastViewHostingController = UIHostingController(rootView: currentView)
        toastViewHostingController.view.backgroundColor = .clear

        // creates new window to display Toast in
        windowManager.createWindow(
            with: toastViewHostingController, placement: .bottomToolbarPadding, height: height
        ) { [weak self] in
            guard let self = self else { return }

            if let toastProgressViewModel = view.toastProgressViewModel,
                toastProgressViewModel.status != .inProgress
            {
                self.startViewDismissTimer(for: view)
            } else if view.autoDismiss {
                self.startViewDismissTimer(for: view)
            }
        }
    }

    override func getDisplayTime(for view: ToastView) -> Double {
        return view.displayTime
    }
}
