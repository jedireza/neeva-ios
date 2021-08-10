// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

protocol OverflowMenuDelegate {
    func overflowMenuDidPressForward()
    func overflowMenuDidPressReloadStop(_ reloadButtonState: TabChromeModel.ReloadButtonState)
    func overflowMenuDidPressAddNewTab()
    func overflowMenuDidPressFindOnPage()
    func overflowMenuDidPressTextSize()
    func overflowMenuDidPressRequestDesktopSite()
}

struct OverflowMenuRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()
    let onDismiss: () -> Void
    var embeddedView: OverflowMenuView

    let chromeModel: TabChromeModel

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            self.embeddedView
                .environmentObject(chromeModel)
                .overlaySheetIsFixedHeight(isFixedHeight: true).padding(.top, 8)
        }
        .onAppear {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class OverflowMenuViewController: UIHostingController<OverflowMenuRootView> {
    var delegate: OverflowMenuDelegate?

    public init(
        delegate: OverflowMenuDelegate, onDismiss: @escaping () -> Void,
        isPrivate: Bool,
        feedbackImage: UIImage?,
        chromeModel: TabChromeModel,
        changedUserAgent: Bool?
    ) {
        super.init(
            rootView: OverflowMenuRootView(
                onDismiss: onDismiss,
                embeddedView: OverflowMenuView(
                    changedUserAgent: changedUserAgent ?? false,
                    menuAction: { action in
                        onDismiss()
                        switch action {
                        case .forward:
                            delegate.overflowMenuDidPressForward()
                        case .reload:
                            delegate.overflowMenuDidPressReloadStop(chromeModel.reloadButton)
                        case .newTab:
                            delegate.overflowMenuDidPressAddNewTab()
                        case .findOnPage:
                            delegate.overflowMenuDidPressFindOnPage()
                        case .textSize:
                            delegate.overflowMenuDidPressTextSize()
                        case .readingMode:
                            // not implemented yet
                            break
                        case .desktopSite:
                            delegate.overflowMenuDidPressRequestDesktopSite()
                        }
                    }
                ),
                chromeModel: chromeModel))
        self.delegate = delegate
        self.view.accessibilityViewIsModal = true
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
}
