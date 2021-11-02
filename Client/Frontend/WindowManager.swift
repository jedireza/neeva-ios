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

class WindowManager: KeyboardReadable {
    private let parentWindow: UIWindow

    private let inOutAnimationDuration = 0.3
    private var openWindow: UIWindow?

    let keyboardHelper = KeyboardHelper.defaultHelper
    private var keyboardHeightListener: AnyCancellable?
    private var keyboardVisibleListener: AnyCancellable?

    public func createWindow(
        with rootViewController: UIViewController, height: CGFloat, addShadow: Bool = false,
        checkKeyboard: Bool = true, alignToBottom: Bool,
        completionHandler: @escaping () -> Void = {}
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
                [unowned self] keyboardVisible in
                // Calls window to load after keyboard is dismissed
                // Small delay to allow keyboard to hide before showing window
                if !keyboardVisible {
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + KeyboardHelper.keyboardAnimationTime
                    ) {
                        createWindow(
                            with: rootViewController, height: height, addShadow: addShadow,
                            checkKeyboard: false, alignToBottom: alignToBottom,
                            completionHandler: completionHandler)
                    }
                }
            }

            return
        }

        keyboardVisibleListener = nil

        // add extra height to extend the window under the view
        // prevents taps from going to the view underneath the window
        openWindow?.frame = CGRect(
            x: 0, y: calculateY(viewHeight: height, alignToBottom: alignToBottom),
            width: parentWindow.bounds.width, height: height + 30)
        openWindow?.rootViewController = UIViewController()
        openWindow?.windowLevel = .alert
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

        // Tells caller that the window was displayed
        completionHandler()
    }

    private func setWindowRootViewController(
        _ rootViewController: UIViewController, height: CGFloat
    ) {
        UIView.animate(withDuration: inOutAnimationDuration) {
            self.openWindow?.alpha = 1
            self.openWindow?.center.y -= height
        }

        rootViewController.modalPresentationStyle = .overFullScreen
        openWindow?.rootViewController?.present(
            rootViewController, animated: false, completion: nil)

        SceneDelegate.getBVC(for: rootViewController.view).becomeFirstResponder()
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

    private func calculateY(viewHeight: CGFloat, alignToBottom: Bool) -> CGFloat {
        let height =
            alignToBottom
            ? UIScreen.main.bounds.height - viewHeight + 25
            : UIScreen.main.bounds.height - viewHeight
        let bottomConstraint = alignToBottom ? 0 : bottomConstraint()
        let safeAreaPadding: CGFloat = 24

        keyboardHeightListener = keyboardPublisher.sink(receiveValue: { keyboardHeight in
            UIView.animate(withDuration: 0.3) {
                if keyboardHeight > 0 {
                    self.openWindow?.center.y = height - (bottomConstraint / 2) - keyboardHeight
                } else {
                    self.openWindow?.center.y = height - bottomConstraint
                }

                // have to add back half of the viewHeight as this is from the center not the top
                if !alignToBottom {
                    self.openWindow?.center.y += (viewHeight / 2)
                } else if keyboardHeight <= 0 {
                    self.openWindow?.center.y -= safeAreaPadding
                }

                self.openWindow?.layoutIfNeeded()
            }
        })

        return height - bottomConstraint - safeAreaPadding
    }

    private func bottomConstraint() -> CGFloat {
        let safeArea = openWindow?.safeAreaInsets.bottom ?? 0
        return safeArea + UIConstants.BottomToolbarHeight
    }

    init(parentWindow: UIWindow) {
        self.parentWindow = parentWindow
    }
}
