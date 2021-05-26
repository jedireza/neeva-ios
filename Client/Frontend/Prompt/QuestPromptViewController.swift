//
//  QuestPromptViewController.swift
//  Client
//
//  Created by Macy Ngan on 5/25/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Shared

struct PromptContent {
    let title: String
    let description: String
    let buttonMessage: String? = nil
}

class QuestPromptViewController: UIHostingController<TourPromptView> {

    var delegate: BrowserViewController?

    // still need to provide callback method
    public init(delegate:BrowserViewController, source: UIView, content: PromptContent) {
        super.init(rootView: TourPromptView(title: content.title, description: content.description, buttonMessage: content.buttonMessage ?? ""))
        self.delegate = delegate
        self.modalPresentationStyle = .popover
        self.rootView.onConfirm = self.onDismiss

        let popoverViewController = self.popoverPresentationController
        popoverViewController?.passthroughViews = [source]
        popoverViewController?.permittedArrowDirections = .any
        popoverViewController?.delegate = delegate
        popoverViewController?.sourceView = source
    }

    func onDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

