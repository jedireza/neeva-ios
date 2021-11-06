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

        let prompt = SearchBarTourPromptViewController(delegate: self, source: topBar.view)
        prompt.view.backgroundColor = UIColor.Tour.Background
        prompt.preferredContentSize = prompt.sizeThatFits(in: CGSize(width: 260, height: 165))

        if self.presentedViewController == nil {
            present(prompt, animated: true, completion: nil)
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
            chromeModel.showNeevaMenuTourPrompt = true
            return
        }

        // Duplicated in TopBarNeevaMenuButton
        let content = TourPromptContent(
            title: "Get the most out of Neeva!",
            description: "Access your Neeva Home, Spaces, Settings, and more",
            buttonMessage: "Let's take a Look!",
            onButtonClick: {
                SceneDelegate.getBVC(for: self.view).showNeevaMenuSheet()

            },
            onClose: { [self] in
                // Duplicated in TopBarNeevaMenuButton
                self.dismiss(animated: true, completion: nil)
                TourManager.shared.responseMessage(
                    for: TourManager.shared.getActiveStepName(), exit: true)
            })

        let prompt = TourPromptViewController(delegate: self, source: target, content: content)

        prompt.view.backgroundColor = UIColor.Tour.Background.lightVariant
        prompt.preferredContentSize = prompt.sizeThatFits(in: CGSize(width: 300, height: 190))

        if self.presentedViewController == nil {
            present(prompt, animated: true, completion: nil)
        }
    }
}
