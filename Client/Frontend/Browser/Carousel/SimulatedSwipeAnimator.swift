// Copyright Neeva. All rights reserved.

import Foundation

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
        recenterAnimationDuration: 1.5,
        cancelAnimationDuration: 0.5)

protocol SimulateForwardAnimatorDelegate: AnyObject {
    func simulateForwardAnimatorStartedSwipe(_ animator: SimulatedSwipeAnimator)
    func simulateForwardAnimatorFinishedSwipe(_ animator: SimulatedSwipeAnimator)
}

class SimulatedSwipeAnimator: NSObject {
    weak var delegate: SimulateForwardAnimatorDelegate?
    weak var animatingView: UIView?
    weak var contentView: UIView?
    var swipeDirection: SwipeDirection

    fileprivate var prevOffset: CGPoint?
    fileprivate let params: SimulateForwardAnimationParameters

    fileprivate var panGestureRecogniser: UIPanGestureRecognizer!

    var containerCenter: CGPoint {
        guard let animatingView = self.animatingView else {
            return .zero
        }
        return CGPoint(x: animatingView.frame.width / 2, y: animatingView.frame.height / 2)
    }

    init(
        swipeDirection: SwipeDirection, animatingView: UIView, contentView: UIView,
        params: SimulateForwardAnimationParameters = DefaultParameters
    ) {
        self.animatingView = animatingView
        self.contentView = contentView
        self.params = params
        self.swipeDirection = swipeDirection

        super.init()

        self.panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        animatingView.addGestureRecognizer(self.panGestureRecogniser)
    }

    func cancelExistingGestures() {
        self.panGestureRecogniser.isEnabled = false
        self.panGestureRecogniser.isEnabled = true
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
            * (swipeDirection == .back ? -1 : 1)
        let timeStep = TimeInterval(abs(translation) / speed)
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
            animatingView?.transform = transformForTranslation(translation.x)
            contentView?.transform = self.transformForTranslation(translation.x / 2)
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
