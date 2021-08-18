// Copyright Neeva. All rights reserved.

import Combine
import Shared
import UIKit
import SwiftUI

class WindowManager: KeyboardReadable {
    private var rootViewController: UIViewController?
    private var alignToBottom: Bool
    private let inOutAnimationDuration = 0.3
    private var openWindow: UIWindow?
    private var keyboardHeightListener: AnyCancellable?

    public func createWindow(with rootViewController: UIViewController, height: CGFloat, addShadow: Bool = false) {
        self.rootViewController = rootViewController

        let window = SceneDelegate.getKeyWindow(for: rootViewController.view)

        guard let scene = window.windowScene else {
            return
        }
        
        openWindow = .init(windowScene: scene)

        // add extra height to extend the window under the view
        // prevents taps from going to the view underneath the window
        openWindow?.frame = CGRect(x: 0, y: calculateY(viewHeight: height), width: window.bounds.width, height: height + 30)
        openWindow?.rootViewController = UIViewController()
        openWindow?.windowLevel = .alert + 1
        openWindow?.alpha = 0
        openWindow?.center.y += height
        openWindow?.makeKeyAndVisible()

        if addShadow {
            openWindow?.layer.shadowColor = UIColor.black.cgColor
            openWindow?.layer.shadowRadius = 48
            openWindow?.layer.shadowOpacity = 0.16
            openWindow?.layer.shadowOffset = CGSize(width: 0, height: -8)
        } else {
            openWindow?.layer.shadowOpacity = 0
        }

        setWindowRootViewController(rootViewController, height: height)
    }

    private func setWindowRootViewController(_ rootViewController: UIViewController, height: CGFloat) {
        UIView.animate(withDuration: inOutAnimationDuration) {
            self.openWindow?.alpha = 1
            self.openWindow?.center.y -= height
        }

        rootViewController.modalPresentationStyle = .overFullScreen
        openWindow?.rootViewController?.present(rootViewController, animated: false, completion: nil)
    }

    public func removeCurrentWindow() {
        UIView.animate(withDuration: inOutAnimationDuration) {
            self.openWindow?.alpha = 0
        }

        openWindow?.rootViewController?.dismiss(
            animated: true,
            completion: { [self] in
                openWindow?.isHidden = true

                // setting to nil removes UIWindow from stack
                // (removes all references, ARC takes care of the rest)
                openWindow = nil
            })
    }

    private func calculateY(viewHeight: CGFloat) -> CGFloat {
        let height = alignToBottom ? UIScreen.main.bounds.height - viewHeight + 25 : UIScreen.main.bounds.height - viewHeight
        let bottomConstraint = alignToBottom ? 0 : bottomConstraint()

        // not the safe area, just adds a bit extra padding
        let safeAreaPadding: CGFloat = 12

        keyboardHeightListener = keyboardPublisher.sink(receiveValue: { keyboardHeight in
            UIView.animate(withDuration: 0.3) {
                if keyboardHeight > 0 {
                    self.openWindow?.center.y = height - (bottomConstraint / 2) - keyboardHeight
                } else {
                    self.openWindow?.center.y = height - bottomConstraint - safeAreaPadding
                }

                self.openWindow?.layoutIfNeeded()
            }
        })

        return height - bottomConstraint
    }

    private func bottomConstraint() -> CGFloat {
        let safeArea = SceneDelegate.getKeyWindow(for: rootViewController?.view).safeAreaInsets.bottom
        return safeArea + UIConstants.BottomToolbarHeight
    }

    init(alignToBottom: Bool = false) {
        self.alignToBottom = alignToBottom
    }
}
