//
//  BrowserViewController+Quests.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Defaults
import Shared

extension BrowserViewController {
    func showSearchBarTourPrompt() {
        // show tour prompt for search bar
        if Defaults[.searchInputPromptDismissed] || !NeevaUserInfo.shared.hasLoginCookie() {
            return
        }

        let prompt = SearchBarTourPromptViewController(delegate: self, source: self.legacyURLBar.legacyLocationView.urlLabel)
        prompt.view.backgroundColor = UIColor.neeva.Tour.Background
        prompt.preferredContentSize = prompt.sizeThatFits(in: CGSize(width: 260, height: 165))

        guard let currentViewController = navigationController?.topViewController else {
            return
        }

        if currentViewController is BrowserViewController {
            present(prompt, animated: true, completion: nil)
        }
    }
    
    func onCloseQuestHandler() {
        self.dismiss(animated: true, completion: nil)
        TourManager.shared.responseMessage(for: TourManager.shared.getActiveStepName(), exit: true)
    }

    func onStartQuestButtonClickHandler() {
        if self.legacyURLBar.toolbarIsShowing {
            self.dismiss(animated: true)
            self.legacyURLBar.didClickNeevaMenu()
        } else {
            BrowserViewController.foregroundBVC().showNeevaMenuSheet()
        }
    }

    func showQuestNeevaMenuPrompt() {
        if !TourManager.shared.hasActiveStep() {
            return
        }
        var target: UIView
        
        scrollController.showToolbars(animated: true)

        if !self.legacyURLBar.toolbarIsShowing {
            guard let neevaMenu = self.toolbar?.toolbarNeevaMenuButton else { return }
            target = neevaMenu
        } else {
            target = self.legacyURLBar.neevaMenuButton
        }

        let content = TourPromptContent(title: "Get the most out of Neeva!", description: "Access your Neeva Home, Spaces, Settings, and more", buttonMessage: "Let's take a Look!", onButtonClick: onStartQuestButtonClickHandler, onClose: onCloseQuestHandler)

        let prompt = TourPromptViewController(delegate: self, source: target, content: content)

        prompt.view.backgroundColor = UIColor.neeva.Tour.Background.lightVariant
        prompt.preferredContentSize = prompt.sizeThatFits(in: CGSize(width: 300, height: 190))

        guard let currentViewController = navigationController?.topViewController else {
            return
        }

        if currentViewController is BrowserViewController {
            present(prompt, animated: true, completion: nil)
        }
    }
}
