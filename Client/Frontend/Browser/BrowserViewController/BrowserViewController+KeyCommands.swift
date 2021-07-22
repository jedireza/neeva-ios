/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared

// Naming functions: use the suffix 'KeyCommand' for an additional level of namespacing (bug 1415830)
extension BrowserViewController {

    @objc func reloadTabKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "reload"])
        if let tab = tabManager.selectedTab, zeroQueryViewController == nil {
            tab.reload()
        }
    }

    @objc func goBackKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "go-back"])
        if let tab = tabManager.selectedTab, tab.canGoBack, zeroQueryViewController == nil {
            tab.goBack()
        }
    }

    @objc func goForwardKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "go-forward"])
        if let tab = tabManager.selectedTab, tab.canGoForward {
            tab.goForward()
        }
    }

    @objc func findInPageKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "find-in-page"])
        if let tab = tabManager.selectedTab, zeroQueryViewController == nil {
            self.tab(tab, didSelectFindInPageForSelection: "")
        }
    }

    @objc func selectLocationBarKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "select-location-bar"])
        scrollController.showToolbars(animated: true)
        legacyURLBar.model.setEditing(to: true)
    }

    @objc func newTabKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "new-tab"])
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        openBlankNewTab(focusLocationField: true, isPrivate: isPrivate)
    }

    @objc func newPrivateTabKeyCommand() {
        // NOTE: We cannot and should not distinguish between "new-tab" and "new-private-tab"
        // when recording telemetry for key commands.
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "new-tab"])
        openBlankNewTab(focusLocationField: true, isPrivate: true)
    }

    @objc func closeTabKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "close-tab"])

        guard let currentTab = tabManager.selectedTab else {
            return
        }

        tabManager.removeTabsWithToast([currentTab])
    }

    @objc func nextTabKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "next-tab"])
        guard let currentTab = tabManager.selectedTab else {
            return
        }

        let tabs = currentTab.isPrivate ? tabManager.privateTabs : tabManager.normalTabs
        if let index = tabs.firstIndex(of: currentTab), index + 1 < tabs.count {
            tabManager.selectTab(tabs[index + 1])
        } else if let firstTab = tabs.first {
            tabManager.selectTab(firstTab)
        }
    }

    @objc func previousTabKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "previous-tab"])
        guard let currentTab = tabManager.selectedTab else {
            return
        }

        let tabs = currentTab.isPrivate ? tabManager.privateTabs : tabManager.normalTabs
        if let index = tabs.firstIndex(of: currentTab), index - 1 < tabs.count && index != 0 {
            tabManager.selectTab(tabs[index - 1])
        } else if let lastTab = tabs.last {
            tabManager.selectTab(lastTab)
        }
    }

    @objc func restoreTabKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "restore-tabs"])
        _ = tabManager.restoreSavedTabs(tabManager.recentlyClosedTabs[0])
    }

    @objc func closeAllTabsCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "close-all-tabs"])

        if tabManager.selectedTab?.isPrivate ?? false {
            _ = tabManager.switchPrivacyMode()

            // wait for tabManager to switch to normal mode before closing private tabs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                tabManager.removeTabsAndAddNormalTab(tabManager.privateTabs, showToast: true)
                zeroQueryViewController?.model.isPrivate = false
            }
        } else {
            tabManager.removeTabsAndAddNormalTab(tabManager.normalTabs, showToast: true)
        }
    }

    @objc func showTabTrayKeyCommand() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .keyCommand, extras: ["action": "show-tab-tray"])
        showTabTray()
    }

    @objc func moveURLCompletionKeyCommand(sender: UIKeyCommand) {
        if let input = sender.input {
            legacyURLBar.neevaSuggestionModel.handleKeyboardShortcut(input: input)
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        let searchLocationCommands = [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(moveURLCompletionKeyCommand(sender:))),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(moveURLCompletionKeyCommand(sender:))),
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(moveURLCompletionKeyCommand(sender:))),
        ]
        let overidesTextEditing = [
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [.command, .shift], action: #selector(nextTabKeyCommand)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command, .shift], action: #selector(previousTabKeyCommand)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .command, action: #selector(goBackKeyCommand)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .command, action: #selector(goForwardKeyCommand)),
        ]
        let tabNavigation = [
            UIKeyCommand(title: Strings.ReloadPageTitle, action: #selector(reloadTabKeyCommand), input: "r", modifierFlags: .command),
            UIKeyCommand(title: Strings.BackTitle, action: #selector(goBackKeyCommand), input: "[", modifierFlags: .command),
            UIKeyCommand(title: Strings.ForwardTitle, action: #selector(goForwardKeyCommand), input: "]", modifierFlags: .command),

            UIKeyCommand(title: Strings.FindTitle, action: #selector(findInPageKeyCommand), input: "f", modifierFlags: .command),
            UIKeyCommand(title: Strings.SelectLocationBarTitle, action: #selector(selectLocationBarKeyCommand), input: "l", modifierFlags: .command),
            UIKeyCommand(title: Strings.NewTabTitle, action: #selector(newTabKeyCommand), input: "t", modifierFlags: .command),
            UIKeyCommand(title: Strings.NewIncognitoTabTitle, action: #selector(newPrivateTabKeyCommand), input: "p", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: Strings.CloseTabTitle, action: #selector(closeTabKeyCommand), input: "w", modifierFlags: .command),
            UIKeyCommand(title: Strings.ShowNextTabTitle, action: #selector(nextTabKeyCommand), input: "\t", modifierFlags: .control),
            UIKeyCommand(title: Strings.ShowPreviousTabTitle, action: #selector(previousTabKeyCommand), input: "\t", modifierFlags: [.control, .shift]),

            UIKeyCommand(title: Strings.RestoreLastClosedTabsTitle, action: #selector(restoreTabKeyCommand), input: "t", modifierFlags: [.shift, .command]),
            UIKeyCommand(title: Strings.CloseAllTabsTitle, action: #selector(closeAllTabsCommand), input: "w", modifierFlags: [.shift, .command]),

            // Switch tab to match Safari on iOS.
            UIKeyCommand(input: "]", modifierFlags: [.command, .shift], action: #selector(nextTabKeyCommand)),
            UIKeyCommand(input: "[", modifierFlags: [.command, .shift], action: #selector(previousTabKeyCommand)),

            UIKeyCommand(input: "\\", modifierFlags: [.command, .shift], action: #selector(showTabTrayKeyCommand)), // Safari on macOS
            UIKeyCommand(title: Strings.ShowTabTrayFromTabKeyCodeTitle, action: #selector(showTabTrayKeyCommand), input: "\t", modifierFlags: [.command, .alternate])
        ]

        let isEditingText = tabManager.selectedTab?.isEditing ?? false

        if legacyURLBar.inOverlayMode {
            return tabNavigation + searchLocationCommands
        } else if !isEditingText {
            return tabNavigation + overidesTextEditing
        }
        return tabNavigation
    }
}
