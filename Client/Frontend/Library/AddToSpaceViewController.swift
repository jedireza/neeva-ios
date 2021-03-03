//
//  AddToSpaceViewController.swift
//  Client
//
//  Created by Jed Fox on 12/21/20.
//  Copyright © 2020 Neeva. All rights reserved.
//

import SwiftUI
import NeevaSupport

class AddToSpaceViewController: UIHostingController<AnyView> {
    struct Content: View {
        let title: String
        let description: String?
        let url: URL
        let onDismiss: (AddToSpaceList.IDs?) -> ()
        let onOpenURL: (URL) -> ()
        var body: some View {
            AddToSpaceView(title: title, description: description, url: url, onDismiss: onDismiss)
                .environment(\.onOpenURL, onOpenURL)
        }
    }
    init(title: String, description: String?, url: URL, onDismiss: @escaping (AddToSpaceList.IDs?) -> (), onOpenURL: @escaping (URL) -> ()) {
        super.init(rootView: AnyView(EmptyView()))
        self.rootView = AnyView(
            Content(title: title, description: description, url: url, onDismiss: onDismiss, onOpenURL: onOpenURL)
        )

        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
