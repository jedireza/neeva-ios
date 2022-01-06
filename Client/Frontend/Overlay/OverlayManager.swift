// Copyright Neeva. All rights reserved.

import SwiftUI

enum OverlayType {
    case findInPage(FindInPageView)
    case notification(NotificationRow)
    case popover(PopoverRootView)
    case sheet(OverlaySheetRootView)
    case toast(ToastView)
}

class OverlayManager: ObservableObject {
    @Published private(set) var currentOverlay: OverlayType?
    @Published private(set) var animating = false
    @Published var offset: CGFloat = 0
    @Published var opacity: CGFloat = 1
    @Published var animationCompleted: (() -> Void)? = nil

    public func show(overlay: OverlayType, animate: Bool = true) {
        hideCurrentOverlay { [self] in
            currentOverlay = overlay

            if animate {
                animating = true

                // Used to make sure animation completes succesfully.
                animationCompleted = {
                    animationCompleted = nil
                }

                switch overlay {
                case .notification:
                    slideAndFadeIn(offset: -ToastViewUX.height)
                case .toast:
                    slideAndFadeIn(offset: ToastViewUX.height)
                default:
                    withAnimation {
                        animating = false
                    }
                }
            }
        }

        func slideAndFadeIn(offset: CGFloat) {
            self.offset = offset
            self.opacity = 0

            withAnimation {
                resetUIModifiers()
                animating = false
            }
        }
    }

    public func hideCurrentOverlay(
        animate: Bool = true, completion: (() -> Void)? = nil
    ) {
        guard let overlay = currentOverlay else {
            completion?()
            return
        }

        if animate {
            animationCompleted = { [self] in
                currentOverlay = nil
                resetUIModifiers()
                animationCompleted = nil
                completion?()
            }

            animating = true

            switch overlay {
            case .notification:
                slideAndFadeOut(offset: -ToastViewUX.height)
            case .toast:
                slideAndFadeOut(offset: ToastViewUX.height)
            default:
                withAnimation {
                    animating = false
                }
            }
        } else {
            currentOverlay = nil
            resetUIModifiers()
            completion?()
        }

        func slideAndFadeOut(offset: CGFloat) {
            withAnimation {
                self.offset = offset
                opacity = 0
                animating = false
            }
        }
    }

    private func resetUIModifiers() {
        offset = 0
        opacity = 1
    }
}
