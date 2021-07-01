// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Storage

@objc(InitialViewController)
class InitialViewController: UIHostingController<ShareToView> {

    @objc init() {
        super.init(rootView: ShareToView(item: nil, onDismiss: { _ in }))
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        ExtensionUtils.extractSharedItem(fromExtensionContext: extensionContext) { item, error in
            if let item = item, error == nil {
                self.rootView = ShareToView(item: item, onDismiss: { [weak self] didComplete in
                    if didComplete {
                        self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    } else {
                        self?.extensionContext?.cancelRequest(withError: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil))
                    }
                })
            } else {
                let alert = UIAlertController(title: Strings.SendToErrorTitle, message: Strings.SendToErrorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Strings.SendToErrorOKButton, style: .default) { _ in
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                })
                self.present(alert, animated: true, completion: nil)

                self.extensionContext?.cancelRequest(withError: CocoaError(.keyValueValidation))
            }
        }
    }
}
