// Copyright Neeva. All rights reserved.

import SwiftUI

extension EnvironmentValues {
    private struct HideOverlayKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }

    public var hideOverlay: () -> Void {
        get { self[HideOverlayKey] }
        set { self[HideOverlayKey] = newValue }
    }
}

struct OverlayRootView: View {
    let isPopover: Bool
    let style: OverlayStyle
    let content: () -> AnyView
    let onDismiss: () -> Void
    let onOpenURL: (URL) -> Void

    var body: some View {
        if isPopover {
            PopoverRootView(style: style, content: content, onDismiss: onDismiss, onOpenURL: onOpenURL)
        } else {
            OverlaySheetRootView(style: style, content: content, onDismiss: onDismiss, onOpenURL: onOpenURL)
        }
    }
}

private struct PopoverRootView: View {
    var style: OverlayStyle
    var content: () -> AnyView
    var onDismiss: () -> Void
    var onOpenURL: (URL) -> Void

    var body: some View {
        PopoverView(style: style, onDismiss: onDismiss) {
            content()
                .environment(\.onOpenURL, self.onOpenURL)
                .environment(\.hideOverlay, onDismiss)
        }
    }
}

private struct OverlaySheetRootView: View {
    let overlayModel = OverlaySheetModel()

    let style: OverlayStyle
    let content: () -> AnyView
    let onDismiss: () -> Void
    let onOpenURL: (URL) -> Void

    @ViewBuilder
    var overlay: some View {
        OverlaySheetView(model: overlayModel, style: style, onDismiss: onDismiss) {
            content()
                .environment(\.onOpenURL, self.onOpenURL)
                .environment(\.hideOverlay, { self.overlayModel.hide() })
        }
    }

    var body: some View {
        overlay
            .onAppear {
                // It seems to be necessary to delay starting the animation until this point to
                // avoid a visual artifact.
                DispatchQueue.main.async {
                    self.overlayModel.show()
                }
            }
    }
}

class OverlayViewController: UIHostingController<OverlayRootView> {
    init(
        isPopover: Bool, style: OverlayStyle, content: @escaping () -> AnyView,
        onDismiss: @escaping () -> Void, onOpenURL: @escaping (URL) -> Void
    ) {
        super.init(
            rootView: OverlayRootView(
                isPopover: isPopover, style: style, content: content, onDismiss: onDismiss,
                onOpenURL: onOpenURL)
        )

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
