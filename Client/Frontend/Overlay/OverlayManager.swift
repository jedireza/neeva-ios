// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

/// Vague categories of Overlay types.
/// For specific views, use `OverlayType`.
enum OverlayPriority {
    case transient
    case modal
    case fullScreen
}

/// Specific Overlay view type.
enum OverlayType: Equatable {
    case backForwardList(BackForwardListView?)
    case findInPage(FindInPageView?)
    case fullScreenModal(AnyView)
    case notification(NotificationRow?)
    case popover(PopoverRootView?)
    case sheet(OverlaySheetRootView?)
    case toast(ToastView?)

    var priority: OverlayPriority {
        switch self {
        case .fullScreenModal:
            return .fullScreen
        case .backForwardList, .findInPage, .popover, .sheet:
            return .modal
        case .notification, .toast:
            return .transient
        }
    }

    static func == (lhs: OverlayType, rhs: OverlayType) -> Bool {
        switch (lhs, rhs) {
        case (.backForwardList, .backForwardList):
            return true
        case (.findInPage, .findInPage):
            return true
        case (.fullScreenModal, .fullScreenModal):
            return true
        case (.notification, .notification):
            return true
        case (.popover, .popover):
            return true
        case (.sheet, .sheet):
            return true
        case (.toast, .toast):
            return true
        default:
            return false
        }
    }
}

class OverlayManager: ObservableObject {
    @Published private(set) var currentOverlay: OverlayType?
    @Published private(set) var animating = false
    @Published var offset: CGFloat = 0
    @Published var opacity: CGFloat = 1
    @Published var animationCompleted: (() -> Void)? = nil
    @Published var offsetForBottomBar = false
    @Published var hideBottomBar = false

    private let animation = Animation.easeInOut(duration: 0.2)
    /// (Overlay, Animate, Completion])
    var queuedOverlays = [(OverlayType, Bool, (() -> Void)?)]()

    public func presentFullScreenModal(content: AnyView, completion: (() -> Void)? = nil) {
        let content = AnyView(
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        )

        show(overlay: .fullScreenModal(content), completion: completion)
    }

    public func show(overlay: OverlayType, animate: Bool = true, completion: (() -> Void)? = nil) {
        guard animationCompleted == nil else {
            queuedOverlays.append((overlay, animate, completion))
            return
        }

        if overlay.priority == .transient {
            guard currentOverlay == nil else {
                queuedOverlays.append((overlay, animate, completion))
                return
            }

            presentOverlay(overlay: overlay, animate: animate)
            completion?()
        } else {
            hideCurrentOverlay { [self] in
                presentOverlay(overlay: overlay, animate: animate)
                completion?()
            }
        }
    }

    private func showNextOverlayIfNeeded() {
        guard queuedOverlays.count > 0 else {
            return
        }

        let (overlay, animate, completion) = queuedOverlays[0]
        presentOverlay(overlay: overlay, animate: animate)
        queuedOverlays.remove(at: 0)
        completion?()
    }

    private func presentOverlay(overlay: OverlayType, animate: Bool = true) {
        switch overlay {
        case .backForwardList, .toast:
            offsetForBottomBar = true
        default:
            offsetForBottomBar = false
        }

        switch overlay {
        case .findInPage:
            hideBottomBar = true
        default:
            hideBottomBar = false
        }

        currentOverlay = overlay

        if animate {
            animating = true

            // Used to make sure animation completes succesfully.
            animationCompleted = {
                self.animationCompleted = nil
            }

            switch overlay {
            case .backForwardList:
                slideAndFadeIn(offset: 100)
            case .notification:
                slideAndFadeIn(offset: -ToastViewUX.height)
            case .toast:
                slideAndFadeIn(offset: ToastViewUX.height)
            default:
                withAnimation(animation) {
                    animating = false
                }
            }
        }

        func slideAndFadeIn(offset: CGFloat) {
            self.offset = offset
            self.opacity = 0

            withAnimation(animation) {
                resetUIModifiers()
                animating = false
            }
        }
    }

    public func hideCurrentOverlay(
        ofPriority: OverlayPriority?,
        animate: Bool = true, showNext: Bool = true, completion: (() -> Void)? = nil
    ) {
        if let ofPriority = ofPriority {
            hideCurrentOverlay(
                ofPriorities: [ofPriority], animate: animate, showNext: showNext,
                completion: completion)
        } else {
            hideCurrentOverlay(
                ofPriorities: nil, animate: animate, showNext: showNext, completion: completion)
        }
    }

    public func hideCurrentOverlay(
        ofPriorities: [OverlayPriority]? = nil,
        animate: Bool = true, showNext: Bool = true, completion: (() -> Void)? = nil
    ) {
        guard let overlay = currentOverlay else {
            completion?()
            return
        }

        if let ofPriorities = ofPriorities, !ofPriorities.contains(overlay.priority) {
            completion?()
            return
        }

        let completion = {
            completion?()

            if showNext {
                self.showNextOverlayIfNeeded()
            }
        }

        if animate {
            animationCompleted = { [self] in
                currentOverlay = nil
                resetUIModifiers()
                animationCompleted = nil

                DispatchQueue.main.async {
                    completion()
                }
            }

            animating = true

            switch overlay {
            case .backForwardList:
                slideAndFadeOut(offset: 0)
            case .fullScreenModal:
                slideAndFadeOut(offset: 100)
            case .notification(let notification):
                notification?.viewDelegate?.dismiss()
                slideAndFadeOut(offset: -ToastViewUX.height)
            case .toast(let toast):
                toast?.viewDelegate?.dismiss()
                slideAndFadeOut(offset: ToastViewUX.height)
            default:
                withAnimation(animation) {
                    animating = false
                    offsetForBottomBar = false
                    hideBottomBar = false
                }
            }
        } else {
            currentOverlay = nil
            offsetForBottomBar = false
            hideBottomBar = false
            resetUIModifiers()
            completion()
        }

        func slideAndFadeOut(offset: CGFloat) {
            withAnimation(animation) {
                self.offset = offset
                opacity = 0
                animating = false
                offsetForBottomBar = false
                hideBottomBar = false
            }
        }
    }

    private func resetUIModifiers() {
        offset = 0
        opacity = 1
    }
}
