// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

public class SendFeedbackPanel: UIHostingController<AnyView> {
    init(
        requestId: String?, screenshot: UIImage?, url: URL?, query: String?,
        onOpenURL: @escaping (URL) -> Void
    ) {
        super.init(rootView: AnyView(EmptyView()))
        rootView = AnyView(
            SendFeedbackView(
                screenshot: screenshot, url: url,
                onDismiss: { self.dismiss(animated: true, completion: nil) }, requestId: requestId,
                query: query) { feedbackRequest in
                // Wait for feedback UI to dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ToastDefaults().showToastForFeedback(request: feedbackRequest, toastViewManager: SceneDelegate.getCurrentSceneDelegate(for: self.view).toastViewManager)
                }
            }
            .environment(\.onOpenURL, onOpenURL)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
