// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import UIKit
import SwiftUI

struct SimulateForwardAnimationParameters {
    let totalRotationInDegrees: Double
    let deleteThreshold: CGFloat
    let totalScale: CGFloat
    let totalAlpha: CGFloat
    let minExitVelocity: CGFloat
    let recenterAnimationDuration: TimeInterval
    let cancelAnimationDuration: TimeInterval
}

private let DefaultParameters =
    SimulateForwardAnimationParameters(
        totalRotationInDegrees: 10,
        deleteThreshold: 80,
        totalScale: 0.9,
        totalAlpha: 0,
        minExitVelocity: 800,
        recenterAnimationDuration: 0.3,
        cancelAnimationDuration: 0.3)

protocol SimulateForwardAnimatorDelegate: AnyObject {
    func simulateForwardAnimatorStartedSwipe(_ animator: SimulatedSwipeAnimator)
    func simulateForwardAnimatorFinishedSwipe(_ animator: SimulatedSwipeAnimator)
}

class SimulatedSwipeAnimator: NSObject {
    weak var delegate: SimulateForwardAnimatorDelegate?
    weak var simulatedSwipeControllerView: UIView?
    weak var model: SimulatedSwipeModel?

    fileprivate var prevOffset: CGPoint?
    fileprivate let params: SimulateForwardAnimationParameters

    fileprivate var panGestureRecogniser: UIPanGestureRecognizer!

    var containerCenter: CGPoint {
        guard let animatingView = self.animatingView else {
            return .zero
        }
        return CGPoint(x: animatingView.frame.width / 2, y: animatingView.frame.height / 2)
    }

    var contentView: UIView? {
        model?.tabManager.selectedTab?.webView
    }

    var animatingView: UIView? {
        return simulatedSwipeControllerView
    }

    init(
        model: SimulatedSwipeModel, simulatedSwipeControllerView: UIView,
        params: SimulateForwardAnimationParameters = DefaultParameters
    ) {
        self.model = model
        self.params = params
        self.simulatedSwipeControllerView = simulatedSwipeControllerView

        super.init()

        self.panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        simulatedSwipeControllerView.addGestureRecognizer(self.panGestureRecogniser)
    }
}

//MARK: Private Helpers
extension SimulatedSwipeAnimator {
    fileprivate func animateBackToCenter(canceledSwipe: Bool) {
        if !canceledSwipe {
            self.delegate?.simulateForwardAnimatorFinishedSwipe(self)
        }

        if canceledSwipe {
            UIView.animate(
                withDuration: params.cancelAnimationDuration,
                animations: {
                    self.contentView?.transform = .identity
                    self.animatingView?.transform = .identity
                }, completion: { _ in })
        } else {
            self.contentView?.transform = .identity
            UIView.animate(
                withDuration: params.recenterAnimationDuration,
                animations: {
                    self.animatingView?.alpha = 0
                },
                completion: { finished in
                    if finished {
                        self.animatingView?.transform = .identity
                        self.animatingView?.alpha = 1
                    }
                })
        }
    }

    fileprivate func animateAwayWithVelocity(_ velocity: CGPoint, speed: CGFloat) {
        guard let animatingView = self.animatingView,
            let webViewContainer = self.contentView
        else {
            return
        }

        // Calculate the edge to calculate distance from
        let translation =
            (-animatingView.frame.width + SwipeUX.EdgeWidth)
            * (model?.swipeDirection == .back ? -1 : 1)
        let timeStep = TimeInterval(abs(translation) / speed)

        if FeatureFlag[.enableBrowserView] {
            self.model?.offset = -20

            withAnimation(.easeOut(duration: timeStep)) {
                self.model?.offset = 0
                self.animateBackToCenter(canceledSwipe: false)
            }
        } else {
            self.delegate?.simulateForwardAnimatorStartedSwipe(self)
            UIView.animate(
                withDuration: timeStep,
                animations: {
                    animatingView.transform = self.transformForTranslation(translation)
                    webViewContainer.transform = self.transformForTranslation(translation / 2)
                },
                completion: { finished in
                    if finished {
                        self.animateBackToCenter(canceledSwipe: false)
                    }
                })
        }
    }

    fileprivate func transformForTranslation(_ translation: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: translation, y: 0)
    }

    fileprivate func alphaForDistanceFromCenter(_ distance: CGFloat) -> CGFloat {
        let swipeWidth = animatingView?.frame.size.width ?? 1
        return 1 - (distance / swipeWidth) * (1 - params.totalAlpha)
    }
}

//MARK: Selectors
extension SimulatedSwipeAnimator {
    @objc func didPan(_ recognizer: UIPanGestureRecognizer!) {
        let translation = recognizer.translation(in: animatingView)

        switch recognizer.state {
        case .began:
            prevOffset = containerCenter
        case .changed:
            if FeatureFlag[.enableBrowserView] {
                model?.offset = translation.x
            } else {
                animatingView?.transform = transformForTranslation(translation.x)
                contentView?.transform = self.transformForTranslation(translation.x / 2)
            }

            prevOffset = CGPoint(x: translation.x, y: 0)
        case .cancelled:
            animateBackToCenter(canceledSwipe: true)
        case .ended:
            let velocity = recognizer.velocity(in: animatingView)
            // Bounce back if the velocity is too low or if we have not reached the threshold yet
            let speed = max(abs(velocity.x), params.minExitVelocity)
            if speed < params.minExitVelocity || abs(prevOffset?.x ?? 0) < params.deleteThreshold {
                animateBackToCenter(canceledSwipe: true)
            } else {
                animateAwayWithVelocity(velocity, speed: speed)
            }
        default:
            break
        }
    }
}
