// Copyright © Neeva. All rights reserved.
import SwiftUI
import Shared

struct TourPromptContent {
    let title: String
    let description: String
    let buttonMessage: String?
    let onButtonClick: (()-> Void)?
    let onClose: (()-> Void)?

    init(title: String, description: String, buttonMessage: String? = nil, onButtonClick: (()->Void)? = nil, onClose: (()->Void)? = nil) {
        self.title = title
        self.description = description
        self.buttonMessage = buttonMessage
        self.onButtonClick = onButtonClick
        self.onClose = onClose
    }
}

class TourPromptViewController: UIHostingController<TourPromptView> {

    var delegate: BrowserViewController?

    public init(delegate:BrowserViewController, source: UIView, content: TourPromptContent) {
        super.init(rootView: TourPromptView(title: content.title, description: content.description, buttonMessage: content.buttonMessage ?? "", onConfirm: content.onButtonClick ?? nil, onClose: content.onClose ?? nil, staticColorMode: true))
        self.delegate = delegate
        self.modalPresentationStyle = .popover
        if content.onButtonClick == nil {
            self.rootView.onConfirm = self.onDismiss
        } else {
            self.rootView.onConfirm = content.onButtonClick
        }

        if let popoverViewController = self.popoverPresentationController {
            popoverViewController.passthroughViews = [source]
            popoverViewController.permittedArrowDirections = .any
            popoverViewController.delegate = delegate
            popoverViewController.sourceView = source
        }
    }

    func onDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidDisappear(_ animated: Bool) {
        TourManager.shared.notifyCurrentViewClose()
        super.viewDidDisappear(animated)
    }
}
