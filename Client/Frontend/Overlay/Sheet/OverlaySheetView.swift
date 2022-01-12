// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI

enum OverlaySheetUX {
    /// Number of points you have to drag the top bar to tigger an animation
    /// of the overlay sheet to a new position.
    static let slideThreshold: CGFloat = 100

    /// Duration of slide animations.
    static let animationDuration: Double = 0.2

    /// Opacity of the backdrop when the overlay sheet is done animating open.
    static let backdropMaxOpacity: Double = 0.2

    /// Width of the sheet when in landscape mode.
    static let landscapeModeWidth: CGFloat = 500
}

public struct OverlayHeaderButton {
    public let text: LocalizedStringKey
    public let icon: Nicon
    public let action: () -> Void
}

// This view provides an overlay bottom sheet implementation that starts in a
// half-height (or middle) position. The user can drag it to a fullscreen (or
// top) position or can drag down to dismiss.
// Intended to present content that is flexible in height (e.g., a ScrollView).
struct OverlaySheetView<Content: View>: View, KeyboardReadable {
    // MARK: - Properties
    @StateObject var model: OverlaySheetModel

    @State private var keyboardHeight: CGFloat = 0
    @State private var titleHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var title: LocalizedStringKey? = nil
    @State private var isFixedHeight: Bool = false
    @State private var bottomSafeArea: CGFloat = 0

    let style: OverlayStyle
    let onDismiss: () -> Void
    let headerButton: OverlayHeaderButton?
    let content: () -> Content

    private var keyboardIsVisible: Bool {
        return keyboardHeight > 0
    }

    // MARK: - View Functions
    private func isPortraitMode(_ outerGeometry: GeometryProxy) -> Bool {
        return outerGeometry.size.width < outerGeometry.size.height
    }

    private func getSpacerHeight(_ outerGeometry: GeometryProxy) -> CGFloat {
        let viewHeight = outerGeometry.size.height
        var size: CGFloat

        if isFixedHeight {
            switch self.model.position {
            case .top, .middle:
                size =
                    viewHeight - contentHeight
                    - (bottomSafeArea > 0 ? 0 : NeevaMenuUX.bottomPadding)
            case .dismissed:
                size = viewHeight
            }
        } else {
            switch model.position {
            case .top:
                size = 0

                if style.showTitle {
                    size += titleHeight
                }
            case .middle:
                if isPortraitMode(outerGeometry) {
                    size = viewHeight / 2
                } else {
                    size = 0
                }
            case .dismissed:
                return viewHeight
            }

            size = size + model.deltaHeight
        }

        size -= keyboardHeight

        let min: CGFloat = UIConstants.TopToolbarHeightWithToolbarButtonsShowing
        if size < min {
            size = min
        }

        return size
    }

    // MARK: - Views
    /// Controls height of the OverlaySheet
    private var topSpacer: some View {
        VStack(spacing: 0) {
            Spacer()

            // Without this, the smooth drag animation does not work
            Color.clear
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            if !isFixedHeight {
                Capsule()
                    .fill(Color.tertiaryLabel)
                    .frame(width: 32, height: 4)
                    .padding(15).background(Color.clear)  // make the selectable area larger
                    .accessibilityElement()
                    .accessibilityLabel("Pop-up controller")
                    .accessibilityValue(model.position.rawValue)
                    .accessibilityHint("Adjust the size of this pop-up window")
                    // TODO: make this action become disabled instead of doing nothing
                    .accessibilityAction(named: "Expand") {
                        withAnimation(.easeOut(duration: OverlaySheetUX.animationDuration)) {
                            self.model.position = .top
                        }
                    }
                    .accessibilityAction(named: model.position == .top ? "Collapse" : "Dismiss") {
                        if model.position == .top {
                            withAnimation(.easeOut(duration: OverlaySheetUX.animationDuration)) {
                                self.model.position = .middle
                            }
                        } else {
                            model.hide()
                        }
                    }
                    .padding(-15)
                    .padding(.top, 8)
            }

            HStack(spacing: 0) {
                if style.showTitle, let title = title {
                    Text(title)
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                        .padding(.leading, 16)
                    Spacer()
                    Button(action: onDismiss) {
                        Symbol(.xmark, style: .headingMedium, label: "Close")
                            .foregroundColor(.tertiaryLabel)
                            .tapTargetFrame()
                            .padding(.trailing, 4.5)
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.top, 8)
            .onHeightOfViewChanged { height in
                self.titleHeight = height
            }
        }
    }

    private var sheetContent: some View {
        self.content()
            .modifier(ViewHeightKey())
            .onPreferenceChange(OverlayTitlePreferenceKey.self) { self.title = $0 }
            .onPreferenceChange(OverlayIsFixedHeightPreferenceKey.self) {
                self.isFixedHeight = $0
            }
    }

    private var sheet: some View {
        VStack {
            VStack(spacing: 0) {
                self.topBar
                    .modifier(ViewHeightKey())
                    .onPreferenceChange(ViewHeightKey.self) { self.model.topBarHeight = $0 }

                if isFixedHeight {
                    sheetContent
                } else {
                    ScrollView(model.position == .top ? [.vertical] : [], showsIndicators: false) {
                        sheetContent
                            .padding(.bottom, 18)
                    }
                }
            }.padding(.bottom, bottomSafeArea).background(
                Color(style.backgroundColor)
                    .cornerRadius(16, corners: [.topLeading, .topTrailing])
                    .ignoresSafeArea(edges: .bottom)
            )
            .onHeightOfViewChanged { height in
                self.contentHeight = height
            }
            .gesture(topDrag)
        }
    }

    var body: some View {
        GeometryReader { outerGeometry in
            DismissBackgroundView(
                opacity: model.backdropOpacity, position: model.position,
                onDismiss: style.nonDismissible ? {} : onDismiss)

            VStack {
                // The height of this spacer is what controls the apparent height of
                // the sheet. By sizing this spacer instead of the sheet directly
                // we avoid encroaching on the safe area. That's because the spacer
                // cannot be made to have negative height.
                topSpacer
                    .frame(height: getSpacerHeight(outerGeometry))
                    .animation(.interactiveSpring(), value: model.deltaHeight)

                // Used to center the sheet within the container view.
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    sheet
                        // Constrain to full width in portrait mode.
                        .frame(
                            minWidth: isPortraitMode(outerGeometry)
                                ? outerGeometry.size.width : OverlaySheetUX.landscapeModeWidth,
                            maxWidth: isPortraitMode(outerGeometry)
                                ? outerGeometry.size.width : OverlaySheetUX.landscapeModeWidth
                        )
                    Spacer(minLength: 0)
                }
            }
            .padding(.top, 16)
            .keyboardListener { height in
                keyboardHeight = height
            }
            .background(
                HStack(spacing: 0) {
                    Spacer().layoutPriority(0.5)

                    if let headerButton = headerButton, case .middle = model.position {
                        Button(
                            action: {
                                headerButton.action()
                                model.hide()
                            },
                            label: {
                                HStack(spacing: 10) {
                                    Text(headerButton.text)
                                        .withFont(.labelLarge)
                                    Symbol(decorative: headerButton.icon)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        )
                        .buttonStyle(NeevaButtonStyle(.primary))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .layoutPriority(0.5)
                    }
                }.offset(y: -20 + model.deltaHeight)
            )
        }
        .ignoresSafeArea()
        .safeAreaChanged { insets in
            self.bottomSafeArea = insets.bottom
        }
    }

    // MARK: - Drag
    private var topDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isFixedHeight {
                    self.onDragChanged(value)
                }
            }
            .onEnded { value in
                if !isFixedHeight {
                    self.onDragEnded(value)
                }
            }
    }

    private func onDragChanged(_ value: DragGesture.Value) {
        self.model.deltaHeight += value.translation.height
    }

    // Update position based on how much delta height has been accumulated.
    // Set those values using withAnimation so the resulting UI changes are
    // applied smoothly.
    private func onDragEnded(_ value: DragGesture.Value) {
        self.model.deltaHeight += value.translation.height

        var newPosition = self.model.position
        if self.model.deltaHeight > OverlaySheetUX.slideThreshold {
            // Middle position only makes sense when the keyboard is hidden, and if
            // the delta is too large, then we just want to dismiss the sheet.
            if self.model.position == .top && !keyboardIsVisible
                && self.model.deltaHeight < 4 * OverlaySheetUX.slideThreshold
            {
                newPosition = .middle
            } else {
                self.model.hide()
                return
            }
        } else if self.model.deltaHeight < -OverlaySheetUX.slideThreshold {
            newPosition = .top
        }

        withAnimation(.easeOut(duration: OverlaySheetUX.animationDuration)) {
            self.model.position = newPosition
            self.model.deltaHeight = 0
        }
    }
}
