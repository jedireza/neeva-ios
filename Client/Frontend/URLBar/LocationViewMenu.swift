// Copyright Neeva. All rights reserved.

import SwiftUI
import Combine

struct LocationViewMenu: UIViewRepresentable {
    /// Set this to `true` to present the menu from the area occupied by this view with the appropriate menu items.
    /// It will be set to `false` when the menu is dismissed by the user.
    @Binding var isVisible: Bool
    let copyAction: Action
    let pasteAction: Action
    let pasteAndGoAction: Action

    class MenuDisplayingView: UIView {
        init(isVisible: Binding<Bool>) {
            self._isVisible = isVisible
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @Binding var isVisible: Bool
        var oldItems: [UIMenuItem]?
        var menuVisible = false {
            didSet {
                if !menuVisible && isVisible {
                    isVisible = false
                    UIMenuController.shared.menuItems = oldItems
                    oldItems = nil
                }
            }
        }
        var subscriptions: Set<AnyCancellable> = []
        var actions: (copy: Action, paste: Action, pasteAndGo: Action)!

        override func copy(_: Any?) {
            UIMenuController.shared.hideMenu(from: self)
            actions.copy.handler()
        }
        override func paste(_: Any?) {
            UIMenuController.shared.hideMenu(from: self)
            actions.paste.handler()
        }
        @objc func pasteAndGo(_: Any) {
            UIMenuController.shared.hideMenu(from: self)
            actions.pasteAndGo.handler()
        }

        override func resignFirstResponder() -> Bool {
            UIMenuController.shared.hideMenu(from: self)
            return super.resignFirstResponder()
        }

        override var canBecomeFirstResponder: Bool { true }

        override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
            action == #selector(copy(_:)) || action == #selector(paste(_:)) || action == #selector(pasteAndGo(_:))
        }
    }

    func makeUIView(context: Context) -> MenuDisplayingView {
        let view = MenuDisplayingView(isVisible: $isVisible)
        NotificationCenter.default.publisher(for: UIMenuController.didHideMenuNotification)
            .sink { [weak view] _ in view?.menuVisible = false }
            .store(in: &view.subscriptions)
        return view
    }
    func updateUIView(_ view: MenuDisplayingView, context: Context) {
        view.actions = (copyAction, pasteAction, pasteAndGoAction)
        let menu = UIMenuController.shared
        if !menu.isMenuVisible && isVisible {
            view.oldItems = menu.menuItems
            menu.menuItems = [
                UIMenuItem(title: pasteAndGoAction.name, action: #selector(MenuDisplayingView.pasteAndGo(_:))),
            ]
            view.becomeFirstResponder()
            menu.showMenu(from: view, rect: view.frame)
        } else if menu.isMenuVisible && !isVisible {
            menu.hideMenu(from: view)
            view.menuVisible = false
        }
        if menu.isMenuVisible {
            menu.update()
        }
    }
}
