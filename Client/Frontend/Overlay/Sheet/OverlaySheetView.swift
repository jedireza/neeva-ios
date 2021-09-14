// Copyright Neeva. All rights reserved.

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

// This view provides an overlay bottom sheet implementation that starts in a
// half-height (or middle) position. The user can drag it to a fullscreen (or
// top) position or can drag down to dismiss.
// Intended to present content that is flexible in height (e.g., a ScrollView).
struct OverlaySheetView<Content: View>: View, KeyboardReadable {
    @StateObject var model: OverlaySheetModel

    @State private var keyboardHeight: CGFloat = 0
    @State private var topBarHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var title: String = ""
    @State private var isFixedHeight: Bool = false

    let style: OverlayStyle
    let onDismiss: () -> Void
    let content: () -> Content

    private var keyboardIsVisible: Bool {
        return keyboardHeight > 0
    }

    // The height of the spacer is a function of the outer geometry (i.e.,
    // that of our container) and the current delta height.
    private func getSpacerHeight(_ outerGeometry: GeometryProxy) -> CGFloat {
        var size: CGFloat
        if isFixedHeight {
            switch self.model.position {
            case .top, .middle:
                size = outerGeometry.size.height - contentHeight - topBarHeight
            case .dismissed:
                size = outerGeometry.size.height
            }
        } else {
            let defaultSize: CGFloat
            switch self.model.position {
            case .top:
                defaultSize = 0
            case .middle:
                if isPortraitMode(outerGeometry) {
                    defaultSize = outerGeometry.size.height / 2
                } else {
                    defaultSize = 0  // Landscape mode does not support half-height
                }
            case .dismissed:
                defaultSize = outerGeometry.size.height
            }
            size = defaultSize + self.model.deltaHeight
        }
        if size < 0 {
            size = 0
        }
        return size
    }

    // Applied to the top bar.
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

    var topBar: some View {
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
                if style.showTitle {
                    Text(title)
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                        .padding(.leading, 16)
                    Spacer()
                    Button {
                        self.model.hide()
                    } label: {
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
        }
    }

    var sheet: some View {
        GeometryReader { outerGeometry in
            VStack(spacing: 0) {
                // The height of this spacer is what controls the apparent height of
                // the sheet. By sizing this spacer instead of the sheet directly
                // we avoid encroaching on the safe area. That's because the spacer
                // cannot be made to have negative height.
                Spacer()
                    .frame(height: getSpacerHeight(outerGeometry))

                VStack(spacing: 0) {
                    self.topBar
                        .modifier(ViewHeightKey())
                        .onPreferenceChange(ViewHeightKey.self) { self.topBarHeight = $0 }
                    self.content()
                        .modifier(ViewHeightKey())
                        .onPreferenceChange(ViewHeightKey.self) { self.contentHeight = $0 }
                        .onPreferenceChange(OverlayTitlePreferenceKey.self) { self.title = $0 }
                        .onPreferenceChange(OverlayIsFixedHeightPreferenceKey.self) {
                            self.isFixedHeight = $0
                        }
                    if isFixedHeight {
                        Spacer()
                    }
                }
                .background(
                    Color(style.backgroundColor)
                        .cornerRadius(16, corners: [.topLeft, .topRight])
                        .ignoresSafeArea(edges: .bottom)
                        .gesture(topDrag)
                )

            }
        }
        .onReceive(keyboardPublisher) { height in
            // When opening the keyboard, we want our animation to slightly lag behind the keyboard.
            // When closing the keyboard, we want our animation to slightly lead ahead of the keyboard.
            let durationScalar: Double
            if height > 0 {
                durationScalar = 1.6
            } else {
                durationScalar = 0.6
            }
            withAnimation(.easeInOut(duration: OverlaySheetUX.animationDuration * durationScalar)) {
                keyboardHeight = height
                if height > 0 && model.position != .dismissed {
                    model.position = .top
                }
            }
        }
    }

    var body: some View {
        GeometryReader { outerGeometry in
            ZStack {
                // The semi-transparent backdrop used to shade the content that lies below
                // the sheet.
                Button(action: self.model.hide) {
                    Color.black
                        .opacity(self.model.backdropOpacity)
                        .ignoresSafeArea()
                        .modifier(
                            DismissalObserverModifier(
                                backdropOpacity: self.model.backdropOpacity,
                                position: self.model.position, onDismiss: self.onDismiss))
                }
                .buttonStyle(HighlightlessButtonStyle())
                .accessibilityHint("Dismiss pop-up window")
                // make this the last option. This will bring the user’s focus first to the
                // useful content inside of the overlay sheet rather than the close button.
                .accessibilitySortPriority(-1)

                // Used to center the sheet within the container view.
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    self.sheet
                        // Constrain to full width in portrait mode.
                        .frame(
                            minWidth: isPortraitMode(outerGeometry)
                                ? outerGeometry.size.width : OverlaySheetUX.landscapeModeWidth,
                            maxWidth: isPortraitMode(outerGeometry)
                                ? outerGeometry.size.width : OverlaySheetUX.landscapeModeWidth)
                    Spacer(minLength: 0)
                }
            }
        }
        .accessibilityAction(.escape, model.hide)
    }

    private func isPortraitMode(_ outerGeometry: GeometryProxy) -> Bool {
        return outerGeometry.size.width < outerGeometry.size.height
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

private struct DismissalObserverModifier: AnimatableModifier {
    var backdropOpacity: Double
    let position: OverlaySheetPosition
    let onDismiss: () -> Void

    var animatableData: Double {
        get { backdropOpacity }
        set {
            backdropOpacity = newValue
            if position == .dismissed && backdropOpacity == 0.0 {
                // Run after the call stack has unwound as |onDismiss| may tear down
                // the overlay sheet, which could cause issues for SwiftUI processing.
                // See issue #401.
                let onDismiss = self.onDismiss
                
                DispatchQueue.main.async {
                    onDismiss()
                }
            }
        }
    }

    func body(content: Content) -> some View {
        return content
    }
}
