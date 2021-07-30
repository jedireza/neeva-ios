/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit

extension TabTrayControllerV1 {
    override var keyCommands: [UIKeyCommand]? {
        let toggleText =
            tabDisplayManager.isPrivate
            ? Strings.SwitchToNonPBMKeyCodeTitle : Strings.SwitchToIBMKeyCodeTitle
        let commands = [
            UIKeyCommand(
                title: toggleText, action: #selector(didTogglePrivateModeKeyCommand), input: "`",
                modifierFlags: .command),
            UIKeyCommand(
                input: "w", modifierFlags: .command, action: #selector(didCloseTabKeyCommand)),
            UIKeyCommand(
                title: Strings.CloseAllTabsFromTabTrayKeyCodeTitle,
                action: #selector(didCloseAllTabsKeyCommand), input: "w",
                modifierFlags: [.command, .shift]),
            UIKeyCommand(
                input: "\\", modifierFlags: [.command, .shift],
                action: #selector(didEnterTabKeyCommand)),
            UIKeyCommand(
                input: "\t", modifierFlags: [.command, .alternate],
                action: #selector(didEnterTabKeyCommand)),
            UIKeyCommand(
                title: Strings.OpenNewTabFromTabTrayKeyCodeTitle,
                action: #selector(didOpenNewTabKeyCommand), input: "t", modifierFlags: .command),
            UIKeyCommand(
                input: UIKeyCommand.inputDownArrow, modifierFlags: [],
                action: #selector(didChangeSelectedTabKeyCommand(sender:))),
            UIKeyCommand(
                input: UIKeyCommand.inputUpArrow, modifierFlags: [],
                action: #selector(didChangeSelectedTabKeyCommand(sender:))),
            UIKeyCommand(
                title: Strings.CloseTabFromTabTrayKeyCodeTitle,
                action: #selector(didCloseTabKeyCommand), input: "\u{8}", modifierFlags: []),
            UIKeyCommand(
                input: UIKeyCommand.inputLeftArrow, modifierFlags: [],
                action: #selector(didChangeSelectedTabKeyCommand(sender:))),
            UIKeyCommand(
                title: Strings.OpenSelectedTabFromTabTrayKeyCodeTitle,
                action: #selector(didEnterTabKeyCommand), input: "\r", modifierFlags: []),
            UIKeyCommand(
                input: UIKeyCommand.inputRightArrow, modifierFlags: [],
                action: #selector(didChangeSelectedTabKeyCommand(sender:))),
        ]
        return commands
    }

    @objc func didTogglePrivateModeKeyCommand() {
        // NOTE: We cannot and should not capture telemetry here.
        didToggleToolbarIncognitoButton()
    }

    @objc func didCloseTabKeyCommand() {
        if let tab = tabManager.selectedTab {
            tabManager.removeTabAndUpdateSelectedTab(tab, allowToast: true)
        }
    }

    @objc func didCloseAllTabsKeyCommand() {
        closeTabsForCurrentTray()
    }

    @objc func didEnterTabKeyCommand() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @objc func didOpenNewTabKeyCommand() {
        openNewTab()
    }

    @objc func didChangeSelectedTabKeyCommand(sender: UIKeyCommand) {
        let step: Int
        guard let input = sender.input else { return }
        switch input {
        case UIKeyCommand.inputLeftArrow:
            step = -1
        case UIKeyCommand.inputRightArrow:
            step = 1
        case UIKeyCommand.inputUpArrow:
            step = -numberOfColumns
        case UIKeyCommand.inputDownArrow:
            step = numberOfColumns
        default:
            step = 0
        }

        let tabs = tabDisplayManager.dataStore
        let currentIndex: Int
        if let selected = tabManager.selectedTab {
            currentIndex = tabs.index(of: selected) ?? 0
        } else {
            currentIndex = 0
        }

        let nextIndex = max(0, min(currentIndex + step, tabs.count - 1))
        if let nextTab = tabs.at(nextIndex) {
            tabManager.selectTab(nextTab)
        }
    }
}
