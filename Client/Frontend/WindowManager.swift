// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI
import UIKit

// Creates a seperate class to respond to Keyboard Input while displaying a popover window.
// Though the functions are not directly called in the class, the keyboard shortcuts do not work without them.
class PopoverWindow: UIWindow {
    let bvc: BrowserViewController

    @objc func reloadTabKeyCommand() {
        bvc.reloadTabKeyCommand()
    }

    @objc func goBackKeyCommand() {
        bvc.goBackKeyCommand()
    }

    @objc func goForwardKeyCommand() {
        bvc.goForwardKeyCommand()
    }

    @objc func findInPageKeyCommand() {
        bvc.findInPageKeyCommand()
    }

    @objc func selectLocationBarKeyCommand() {
        bvc.selectLocationBarKeyCommand()
    }

    @objc func newTabKeyCommand() {
        bvc.newTabKeyCommand()
    }

    @objc func newPrivateTabKeyCommand() {
        bvc.newPrivateTabKeyCommand()
    }

    @objc func closeTabKeyCommand() {
        bvc.closeTabKeyCommand()
    }

    @objc func nextTabKeyCommand() {
        bvc.nextTabKeyCommand()
    }

    @objc func previousTabKeyCommand() {
        bvc.previousTabKeyCommand()
    }

    @objc func restoreTabKeyCommand() {
        bvc.restoreTabKeyCommand()
    }

    @objc func closeAllTabsCommand() {
        bvc.closeTabKeyCommand()
    }

    @objc func showTabTrayKeyCommand() {
        bvc.showTabTrayKeyCommand()
    }

    @objc func moveURLCompletionKeyCommand(sender: UIKeyCommand) {
        bvc.moveURLCompletionKeyCommand(sender: sender)
    }

    override var keyCommands: [UIKeyCommand]? {
        return bvc.keyboardShortcuts
    }

    init(bvc: BrowserViewController, scene: UIWindowScene) {
        self.bvc = bvc
        super.init(windowScene: scene)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum WindowPlacement {
    case top
    case bottomToolbarPadding
    case findInPage
}

class WindowManager: KeyboardReadable {
    private let parentWindow: UIWindow

    private let inOutAnimationDuration = 0.3
    private var openWindow: UIWindow?
    private var placement: WindowPlacement = .bottomToolbarPadding
    private var viewHeight: CGFloat = 0

    let keyboardHelper = KeyboardHelper.defaultHelper
    private var keyboardHeightListener: AnyCancellable?
    private var keyboardVisibleListener: AnyCancellable?

    public func createWindow(
        with rootViewController: UIViewController, placement: WindowPlacement, height: CGFloat,
        addShadow: Bool = false, checkKeyboard: Bool = true, completionHandler: @escaping () -> Void = {}
    ) {
        guard let scene = parentWindow.windowScene else {
            return
        }

        openWindow = PopoverWindow(
            bvc: SceneDelegate.getBVC(for: rootViewController.view), scene: scene)

        // If keyboard is showing, opening window will close it
        // Does not interfere with find in page, but might prevent a Toast
        if checkKeyboard && keyboardHelper.keyboardVisible {
            keyboardVisibleListener = keyboardHelper.$keyboardVisible.sink {
                [weak self] keyboardVisible in
                guard let self = self else { return }

                // Calls window to load after keyboard is dismissed
                // Small delay to allow keyboard to hide before showing window
                if !keyboardVisible {
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + KeyboardHelper.keyboardAnimationTime
                    ) {
                        self.createWindow(
                            with: rootViewController, placement: placement, height: height, addShadow: addShadow,
                            checkKeyboard: false, completionHandler: completionHandler)
                    }
                }
            }

            return
        }

        keyboardVisibleListener = nil

        // add extra height to extend the window under the view
        // prevents taps from going to the view underneath the window
        openWindow?.frame = CGRect(
            x: 0, y: calculateY(viewHeight: height, placement: placement),
            width: parentWindow.bounds.width, height: height + 30)
        openWindow?.rootViewController = UIViewController()
        openWindow?.windowLevel = .alert
        openWindow?.alpha = 0
        openWindow?.center.y += placement == .top ? -height : height
        openWindow?.makeKeyAndVisible()

        if addShadow {
            openWindow?.layer.shadowColor = UIColor.black.cgColor
            openWindow?.layer.shadowRadius = 48
            openWindow?.layer.shadowOpacity = 0.16
            openWindow?.layer.shadowOffset = CGSize(width: 0, height: -8)
        } else {
            openWindow?.layer.shadowOpacity = 0
        }

        setWindowRootViewController(rootViewController, placement: placement, height: height)

        // Tells caller that the window was displayed
        completionHandler()
    }

    private func setWindowRootViewController(
        _ rootViewController: UIViewController, placement: WindowPlacement, height: CGFloat
    ) {
        UIView.animate(withDuration: inOutAnimationDuration) {
            self.openWindow?.alpha = 1
            self.openWindow?.center.y += placement == .top ? height : -height

            self.openWindow?.layoutIfNeeded()
        }

        rootViewController.modalPresentationStyle = .overFullScreen
        openWindow?.rootViewController?.present(
            rootViewController, animated: false, completion: nil)
        viewHeight = height
        self.placement = placement

        SceneDelegate.getBVC(for: rootViewController.view).becomeFirstResponder()
    }

    public func removeCurrentWindow() {
        UIView.animate(withDuration: inOutAnimationDuration) { [self] in
            openWindow?.alpha = 0
            openWindow?.center.y += placement == .top ? -viewHeight : viewHeight

            openWindow?.layoutIfNeeded()
        } completion: { [self] _ in
            openWindow?.rootViewController?.dismiss(
                animated: false,
                completion: {
                    openWindow?.isHidden = true

                    // setting to nil removes UIWindow from stack
                    // (removes all references, ARC takes care of the rest)
                    openWindow = nil
                })
        }
    }

    private func calculateY(viewHeight: CGFloat, placement: WindowPlacement) -> CGFloat {
        let safeAreaInsets = parentWindow.safeAreaInsets
        let height = UIScreen.main.bounds.height
        let padding: CGFloat = 12
        var y: CGFloat = 0

        switch placement {
        case .top:
            y = safeAreaInsets.top + padding
        case .bottomToolbarPadding:
            y = height - safeAreaInsets.bottom - viewHeight - bottomConstraint()
        case .findInPage:
            y = height - viewHeight + 28
        }

        if placement != .top {
            keyboardHeightListener = keyboardPublisher.sink(receiveValue: { keyboardHeight in
                UIView.animate(withDuration: 0.3) {
                    if keyboardHeight > 0 {
                        self.openWindow?.center.y = y - keyboardHeight + 28
                    } else {
                        // Push find in page down a bit more when keyboard hidden
                        self.openWindow?.center.y = y + (placement == .findInPage ? 12 : 0)
                    }

                    self.openWindow?.layoutIfNeeded()
                }
            })
        }

        return y
    }

    private func bottomConstraint() -> CGFloat {
        let safeArea = parentWindow.safeAreaInsets.bottom
        return safeArea + UIConstants.BottomToolbarHeight
    }

    init(parentWindow: UIWindow) {
        self.parentWindow = parentWindow
    }
}
