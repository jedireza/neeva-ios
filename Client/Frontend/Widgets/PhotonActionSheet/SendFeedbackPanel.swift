// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

public class SendFeedbackPanel: UIHostingController<AnyView> {
    init(requestId: String?, screenshot: UIImage?, url: URL?, query: String?, onOpenURL: @escaping (URL) -> ()) {
        super.init(rootView: AnyView(EmptyView()))
        rootView = AnyView(
            SendFeedbackView(screenshot: screenshot, url: url, onDismiss: { self.dismiss(animated: true, completion: nil) }, requestId: requestId, query: query)
                .environment(\.onOpenURL, onOpenURL)
        )

        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
