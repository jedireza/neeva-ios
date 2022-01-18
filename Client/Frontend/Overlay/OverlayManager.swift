// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

enum OverlayType: Equatable {
    case backForwardList(BackForwardListView?)
    case findInPage(FindInPageView?)
    case notification(NotificationRow?)
    case popover(PopoverRootView?)
    case sheet(OverlaySheetRootView?)
    case toast(ToastView?)

    static func == (lhs: OverlayType, rhs: OverlayType) -> Bool {
        switch (lhs, rhs) {
        case (.backForwardList, .backForwardList):
            return true
        case (.findInPage, .findInPage):
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

    public func show(overlay: OverlayType, animate: Bool = true) {
        hideCurrentOverlay { [self] in
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
                    animationCompleted = nil
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
        ofType: OverlayType? = nil,
        animate: Bool = true, completion: (() -> Void)? = nil
    ) {
        guard let overlay = currentOverlay else {
            completion?()
            return
        }

        if let ofType = ofType, ofType != overlay {
            return
        }

        if animate {
            animationCompleted = { [self] in
                currentOverlay = nil
                resetUIModifiers()
                animationCompleted = nil

                DispatchQueue.main.async {
                    completion?()
                }
            }

            animating = true

            switch overlay {
            case .backForwardList:
                slideAndFadeOut(offset: 0)
            case .notification:
                slideAndFadeOut(offset: -ToastViewUX.height)
            case .toast:
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
            completion?()
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
