// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension EnvironmentValues {
    private struct HideOverlayKey: EnvironmentKey {
        static let defaultValue: () -> Void = {}
    }

    public var hideOverlay: () -> Void {
        get { self[HideOverlayKey.self] }
        set { self[HideOverlayKey.self] = newValue }
    }

    private struct OverlayModelKey: EnvironmentKey {
        static let defaultValue = OverlaySheetModel()
    }

    public var overlayModel: OverlaySheetModel {
        get { self[OverlayModelKey.self] }
        set { self[OverlayModelKey.self] = newValue }
    }
}

struct OverlayRootView: View {
    let isPopover: Bool
    let style: OverlayStyle
    let content: () -> AnyView
    let onDismiss: () -> Void
    let onOpenURL: (URL) -> Void
    let headerButton: OverlayHeaderButton?

    var body: some View {
        if isPopover {
            PopoverRootView(
                style: style, content: content, onDismiss: onDismiss,
                onOpenURL: onOpenURL, headerButton: headerButton)
        } else {
            OverlaySheetRootView(
                style: style, content: content, onDismiss: onDismiss,
                onOpenURL: onOpenURL, headerButton: headerButton)
        }
    }
}

struct PopoverRootView: View {
    var style: OverlayStyle
    var content: () -> AnyView
    var onDismiss: () -> Void
    var onOpenURL: (URL) -> Void
    let headerButton: OverlayHeaderButton?

    var body: some View {
        PopoverView(style: style, onDismiss: onDismiss, headerButton: headerButton) {
            content()
                .environment(\.onOpenURL, self.onOpenURL)
                .environment(\.hideOverlay, onDismiss)
        }
    }
}

struct OverlaySheetRootView: View {
    let overlayModel = OverlaySheetModel()
    var overlayPosition: OverlaySheetPosition = .middle

    let style: OverlayStyle
    let content: () -> AnyView
    let onDismiss: () -> Void
    let onOpenURL: (URL) -> Void
    let headerButton: OverlayHeaderButton?

    @ViewBuilder
    var overlay: some View {
        OverlaySheetView(
            model: overlayModel, style: style,
            onDismiss: {
                onDismiss()
                overlayModel.hide()
            }, headerButton: headerButton
        ) {
            content()
                .environment(\.onOpenURL, self.onOpenURL)
                .environment(\.hideOverlay, { self.overlayModel.hide() })
                .environment(\.overlayModel, overlayModel)
        }
    }

    var body: some View {
        overlay
            .onAppear {
                // It seems to be necessary to delay starting the animation until this point to
                // avoid a visual artifact.
                DispatchQueue.main.async {
                    self.overlayModel.show(defaultPosition: overlayPosition)
                }
            }
    }
}

class OverlayViewController: UIHostingController<OverlayRootView> {
    let isPopover: Bool
    let style: OverlayStyle

    init(
        isPopover: Bool, style: OverlayStyle, content: @escaping () -> AnyView,
        onDismiss: @escaping () -> Void, onOpenURL: @escaping (URL) -> Void,
        headerButton: OverlayHeaderButton?
    ) {
        self.isPopover = isPopover
        self.style = style
        super.init(
            rootView: OverlayRootView(
                isPopover: isPopover, style: style, content: content, onDismiss: onDismiss,
                onOpenURL: onOpenURL, headerButton: headerButton)
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
