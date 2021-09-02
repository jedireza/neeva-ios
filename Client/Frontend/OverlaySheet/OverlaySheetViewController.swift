// Copyright Neeva. All rights reserved.

import SwiftUI

extension EnvironmentValues {
    private struct HideOverlaySheetKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }
    public var hideOverlaySheet: () -> Void {
        get { self[HideOverlaySheetKey] }
        set { self[HideOverlaySheetKey] = newValue }
    }
}

struct OverlaySheetRootView: View {
    var overlaySheetModel = OverlaySheetModel()

    let style: OverlaySheetStyle
    let content: () -> AnyView
    let onDismiss: () -> Void
    let onOpenURL: (URL) -> Void

    var body: some View {
        OverlaySheetView(model: overlaySheetModel, style: style, onDismiss: onDismiss) {
            content()
                .environment(\.hideOverlaySheet, { self.overlaySheetModel.hide() })
                .environment(\.onOpenURL, self.onOpenURL)
        }
        .onAppear {
            // It seems to be necessary to delay starting the animation until this point to
            // avoid a visual artifact.
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class OverlaySheetViewController: UIHostingController<OverlaySheetRootView> {
    init(
        style: OverlaySheetStyle, content: @escaping () -> AnyView,
        onDismiss: @escaping () -> Void, onOpenURL: @escaping (URL) -> Void
    ) {
        super.init(
            rootView: OverlaySheetRootView(
                style: style, content: content, onDismiss: onDismiss, onOpenURL: onOpenURL)
        )
        self.view.accessibilityViewIsModal = true
    }

    func hide() {
        rootView.overlaySheetModel.hide()
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
