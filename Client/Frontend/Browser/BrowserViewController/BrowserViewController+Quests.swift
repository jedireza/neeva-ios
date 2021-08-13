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
    func showSearchBarTourPromptIfNeeded(for url: URL) {
        guard NeevaConstants.isNeevaHome(url: url), !Defaults[.searchInputPromptDismissed],
            NeevaUserInfo.shared.hasLoginCookie()
        else {
            return
        }

        let prompt = SearchBarTourPromptViewController(delegate: self, source: urlBar.view)
        prompt.view.backgroundColor = UIColor.Tour.Background
        prompt.preferredContentSize = prompt.sizeThatFits(in: CGSize(width: 260, height: 165))

        if self.presentedViewController == nil {
            present(prompt, animated: true, completion: nil)
        }
    }

    // Only called by portrait mode / legacy URL bar
    // Duplicated in TopBarNeevaMenuButton
    func onCloseQuestHandler() {
        self.dismiss(animated: true, completion: nil)
        TourManager.shared.responseMessage(for: TourManager.shared.getActiveStepName(), exit: true)
    }

    // Only called by portrait mode / legacy URL bar
    func onStartQuestButtonClickHandler() {
        if self.chromeModel.inlineToolbar {
            self.dismiss(animated: true)
            self.urlBar.legacy?.didClickNeevaMenu()
        } else {
            SceneDelegate.getBVC().showNeevaMenuSheet()
        }
    }

    func showQuestNeevaMenuPrompt() {
        guard TourManager.shared.hasActiveStep() else { return }
        var target: UIView

        scrollController.showToolbars(animated: true)

        if !self.chromeModel.inlineToolbar, let toolbar = toolbar {
            // TODO(jed): open this prompt from SwiftUI once we have a full-height SwiftUI hierarchy
            target = toolbar.view
        } else {
            switch urlBar {
            case .legacy(let urlBar):
                target = urlBar.neevaMenuButton
            case .modern:
                chromeModel.showNeevaMenuTourPrompt = true
                return
            case .none: fatalError()
            }
        }

        // Duplicated in TopBarNeevaMenuButton
        let content = TourPromptContent(
            title: "Get the most out of Neeva!",
            description: "Access your Neeva Home, Spaces, Settings, and more",
            buttonMessage: "Let's take a Look!", onButtonClick: onStartQuestButtonClickHandler,
            onClose: onCloseQuestHandler)

        let prompt = TourPromptViewController(delegate: self, source: target, content: content)

        prompt.view.backgroundColor = UIColor.Tour.Background.lightVariant
        prompt.preferredContentSize = prompt.sizeThatFits(in: CGSize(width: 300, height: 190))

        if self.presentedViewController == nil {
            present(prompt, animated: true, completion: nil)
        }
    }
}
