// Copyright Neeva. All rights reserved.

import UIKit

extension UIMenu {
    convenience init(options: UIMenu.Options = [], sections: [[UIMenuElement]]) {
        self.init(
            options: options,
            children: sections.map { UIMenu(options: .displayInline, children: $0) }
        )
    }
}

/// This class manages dynamic display of and updates to a menu.
/// It needs to handle these two cases in particular:
/// 1. When the menu is not currently visible, it needs to save the closure to run when the menu is required
/// 2. If the menu is visible, it needs to be updated immediately without breaking the UX
class DynamicMenuButton: UIButton {
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        // create and add the context menu interaction.
        // done in willMove(toWindow:) because we can’t override
        // the initializer and specify buttonType = .system.
        if let contextMenuInteraction = contextMenuInteraction {
            addInteraction(contextMenuInteraction)
        }
    }

    /// The closure that produces the menu when requested
    private var dynamicMenu: () -> UIMenu? = { nil }

    ///
    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        let parent = super.contextMenuInteraction(
            interaction, configurationForMenuAtLocation: location)

        // provide the requested menu. This class only supports drop-down menus
        // (rather than context menus) because it does not pass a preview provider.
        return UIContextMenuConfiguration(
            identifier: parent?.identifier, previewProvider: nil,
            actionProvider: { _ in self.dynamicMenu() })
    }

    func setDynamicMenu(_ builder: @escaping () -> UIMenu?) {
        self.dynamicMenu = builder

        // no-op if no menu is visible
        // If the menu is currently visible, update it to include the latest items
        self.contextMenuInteraction?.updateVisibleMenu { currentMenu in
            builder() ?? currentMenu
        }
    }
}
