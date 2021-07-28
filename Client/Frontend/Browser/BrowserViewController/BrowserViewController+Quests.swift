//
//  BrowserViewController+Quests.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import Defaults
import Shared
import SwiftUI

extension BrowserViewController {
    func showSearchBarTourPrompt() {
        // show tour prompt for search bar
        if Defaults[.searchInputPromptDismissed] || !NeevaUserInfo.shared.hasLoginCookie() {
            return
        }

        let prompt = SearchBarTourPromptViewController(delegate: self, source: self.urlBar.view)
        prompt.view.backgroundColor = UIColor.Tour.Background
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
        if self.urlBar.shared.model.showToolbarItems {
            self.dismiss(animated: true)
            // TODO: update for modern url bar
            self.urlBar.legacy?.didClickNeevaMenu()
        } else {
            BrowserViewController.foregroundBVC().showNeevaMenuSheet()
        }
    }

    func showQuestNeevaMenuPrompt() {
        guard TourManager.shared.hasActiveStep() else { return }
        var target: UIView

        scrollController.showToolbars(animated: true)

        if !self.urlBar.shared.model.showToolbarItems, let toolbar = toolbar {
            // TODO(jed): open this prompt from SwiftUI once we have a full-height SwiftUI hierarchy
            target = toolbar.view
        } else {
            // TODO: update for modern url bar
            target = self.urlBar!.legacy!.neevaMenuButton
        }

        let content = TourPromptContent(
            title: "Get the most out of Neeva!",
            description: "Access your Neeva Home, Spaces, Settings, and more",
            buttonMessage: "Let's take a Look!", onButtonClick: onStartQuestButtonClickHandler,
            onClose: onCloseQuestHandler)

        let prompt = TourPromptViewController(delegate: self, source: target, content: content)

        prompt.view.backgroundColor = UIColor.Tour.Background.lightVariant
        prompt.preferredContentSize = prompt.sizeThatFits(in: CGSize(width: 300, height: 190))

        guard let currentViewController = navigationController?.topViewController else {
            return
        }

        if currentViewController is BrowserViewController {
            present(prompt, animated: true, completion: nil)
        }
    }
}
