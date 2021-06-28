// Copyright Neeva. All rights reserved.

import UIKit

class ToastWindowManager {
    private let inOutAnimationDuration = 0.3
    private var openWindow: UIWindow?

    /// Creates an overlayed window to display Toast in
    // Allows UI interaction without hiding Toast
    public func createWindow(with rootViewController: UIViewController) {
        openWindow = UIWindow(frame: CGRect(x: 0, y: getY(), width: UIScreen.main.bounds.width, height: 70))
        openWindow?.rootViewController = UIViewController()
        openWindow?.windowLevel = .alert + 1
        openWindow?.alpha = 0
        openWindow?.makeKeyAndVisible()

        setWindowRootViewController(rootViewController)
    }

    private func setWindowRootViewController(_ rootViewController: UIViewController) {
        rootViewController.modalPresentationStyle = .overCurrentContext
        rootViewController.modalTransitionStyle = .coverVertical

        UIView.animate(withDuration: inOutAnimationDuration) {
            self.openWindow?.alpha = 1
        }

        openWindow?.rootViewController?.present(rootViewController, animated: true, completion: nil)
    }

    /// Removes Toast window from view
    public func removeCurrentWindow() {
        UIView.animate(withDuration: inOutAnimationDuration) {
            self.openWindow?.alpha = 0
        }

        openWindow?.rootViewController?.dismiss(animated: true, completion: { [self] in
            openWindow?.isHidden = true

            // setting to nil removes UIWindow from stack
            // (removes all references, ARC takes care of the rest)
            openWindow = nil
        })
    }

    private func getY() -> CGFloat {
        let height = UIScreen.main.bounds.height
        let safeArea = UIApplication.shared.windows.first?.safeAreaInsets
        let padding: CGFloat = 45
        let toastHeight: CGFloat = 52

        return height - (safeArea?.top ?? 0) - UIConstants.BottomToolbarHeight - toastHeight - padding
    }
}
