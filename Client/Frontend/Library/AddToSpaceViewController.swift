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
    var overlaySheetModel = OverlaySheetModel()
    var spaceIDs: AddToSpaceList.IDs?

    init(title: String, description: String?, url: URL, onDismiss: @escaping (AddToSpaceList.IDs?) -> (), onOpenURL: @escaping (URL) -> ()) {
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            OverlaySheetView(model: self.overlaySheetModel, title: "Save to Spaces", onDismiss: { onDismiss(self.spaceIDs) }) {
                AddToSpaceView(
                    title: title, description: description, url: url,
                    onDismiss: { spaceIDs in
                        // The user made a selection. Store that and run the animation to hide the
                        // sheet. When that completes, we'll run the provided onDismiss callback.
                        self.overlaySheetModel.hide()
                        self.spaceIDs = spaceIDs
                    })
            }
            .onTapGesture {
                // Added to enable dismissing the virtual keyboard by tapping on whitespace.
                // (The AddToSpaceView supports typing in a filter string.)
                self.rootView.hideKeyboard()
            }
        )

        // Make sure the theme is propagated properly, even if it changes while the sheet
        // is visible. This is needed for UI that does not just take its colors from the
        // current Theme object.
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // By default, a UIHostingController opens as an opaque layer, so we override
        // that behavior here.
        view.backgroundColor = .clear
    }

    @objc override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Wait to show the sheet (i.e., run our animation) until the view controller
        // is visible.

        self.overlaySheetModel.show()
    }
}
