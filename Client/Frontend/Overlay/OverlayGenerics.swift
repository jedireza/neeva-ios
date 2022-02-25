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

    private struct OverlayMinHeightToFillScrollViewKey: EnvironmentKey {
        static let defaultValue: CGFloat = .zero
    }

    public var overlayMinHeightToFillScrollView: CGFloat {
        get { self[OverlayMinHeightToFillScrollViewKey.self] }
        set { self[OverlayMinHeightToFillScrollViewKey.self] = newValue }
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
    static let defaultOverlayPosition: OverlaySheetPosition = .middle

    let overlayModel = OverlaySheetModel()
    var overlayPosition: OverlaySheetPosition

    let style: OverlayStyle
    let content: () -> AnyView
    let onDismiss: () -> Void
    let onOpenURL: (URL) -> Void
    let headerButton: OverlayHeaderButton?
    let headerContent: () -> AnyView

    init(
        overlayPosition: OverlaySheetPosition = Self.defaultOverlayPosition,
        style: OverlayStyle,
        content: @escaping () -> AnyView,
        onDismiss: @escaping () -> Void,
        onOpenURL: @escaping (URL) -> Void,
        headerButton: OverlayHeaderButton?,
        headerContent: @escaping () -> AnyView = { AnyView(erasing: EmptyView()) }
    ) {
        self.overlayPosition = overlayPosition
        self.style = style
        self.content = content
        self.onDismiss = onDismiss
        self.onOpenURL = onOpenURL
        self.headerButton = headerButton
        self.headerContent = headerContent
    }

    @ViewBuilder
    var overlay: some View {
        OverlaySheetView(
            model: overlayModel,
            style: style,
            onDismiss: {
                onDismiss()
                overlayModel.hide()
            },
            headerButton: headerButton,
            headerContent: headerContent
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
