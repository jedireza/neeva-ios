// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

/// NOTE: this view has not been tested with layouts where `Leading` is wider than `Trailing`.
/// If that is possible with the parameters you pass, make sure to check that it works properly.
struct TabLocationAligner<Leading: View, Label: View, LabelOverlay: View, Trailing: View>: View {
    let transitionToEditing: Bool
    let debug: Bool
    let leadingActions: () -> Leading
    let label: () -> Label
    let labelOverlay: (EdgeInsets) -> LabelOverlay
    let trailingActions: () -> Trailing

    init(
        transitionToEditing: Bool,
        debug: Bool = FeatureFlag[.newURLBarDebug],
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder labelOverlay: @escaping (EdgeInsets) -> LabelOverlay,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.transitionToEditing = transitionToEditing
        self.debug = debug
        self.label = label
        self.labelOverlay = labelOverlay
        self.leadingActions = leading
        self.trailingActions = trailing
    }

    var body: some View {
        GeometryReader { outerGeom in
            HStack(spacing: 0) {
                GeometryReader { leadingGeom in
                    HStack(spacing: 0) {
                        leadingActions()
                        GeometryReader { innerGeom in
                            let leadingPadding = leadingGeom.size.width - innerGeom.size.width
                            let trailingPadding = outerGeom.size.width - leadingGeom.size.width
                            VStack(alignment: transitionToEditing ? .leading : .center, spacing: 0) {
                                HStack { Spacer() }
                                ZStack {
                                    LocationLabelAligner(
                                        transitionToEditing: transitionToEditing,
                                        debug: debug,
                                        label: label,
                                        leadingPadding: leadingPadding,
                                        trailingPadding: trailingPadding,
                                        availableWidth: innerGeom.size.width
                                    )
                                    labelOverlay(EdgeInsets(top: 0, leading: leadingPadding, bottom: 0, trailing: trailingPadding))
                                }
                            }
                        } // GeometryReader
                    } // HStack
                } // GeometryReader
                trailingActions()
            } // HStack
        } // GeometryReader
        .overlay(Group {
            if debug {
                Color.purple.frame(width: 1, height: 10)
            }
        }, alignment: .bottom)
    }
}

fileprivate struct LocationLabelAligner<Label: View>: View {
    let transitionToEditing: Bool
    let debug: Bool
    let label: () -> Label
    let leadingPadding: CGFloat
    let trailingPadding: CGFloat
    let availableWidth: CGFloat

    @State private var titleWidth: CGFloat = 0

    @ViewBuilder
    func formatPX(_ label: String, _ value: CGFloat) -> some View {
        if debug {
            Text("\(label): \(Measurement(value: Double(value), unit: Unit(symbol: "px")).description)")
                .font(.caption2)
                .allowsHitTesting(false)
        }
    }

    var body: some View {
        label()
            .background(GeometryReader { textGeom in
                (debug ? Color.yellow.opacity(0.25) : Color.clear)
                    .onAppear { self.titleWidth = textGeom.size.width }
                    .onChange(of: textGeom.size.width) { self.titleWidth = $0 }
                    .overlay(Group {
                        if debug {
                            Color.orange.frame(width: 1, height: 10)
                        }
                    }, alignment: .top)
                    .overlay(formatPX("width", titleWidth), alignment: .bottomTrailing)
                    .allowsHitTesting(false)
            })
            // if the edge of the title would extend past the trailing edge of the available space…
            .offset(x: (titleWidth / 2) > (availableWidth / 2 - trailingPadding)
                        // right-align
                        ? (availableWidth - titleWidth) / 2
                        // otherwise center-align in the superview
                        : -(trailingPadding - leadingPadding) / 2)
            .background(Group {
                if debug {
                    Color.green
                        .opacity(0.2)
                        .allowsHitTesting(false)
                }
            })
            .animation(nil)
    }
}


extension TabLocationAligner {
    fileprivate func previewStyle() -> some View {
        self
            .border(Color.orange)
            .frame(height: TabLocationViewUX.height)
    }
}

struct TabLocationAligner_Previews: PreviewProvider {
    @ViewBuilder
    static func contents(for title: String) -> some View {
        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
                .frame(height: TabLocationViewUX.height)
        } labelOverlay: { _ in } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: true, debug: true) {
            Text("editing")
                .frame(height: TabLocationViewUX.height)
        } labelOverlay: { _ in } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
                .frame(height: TabLocationViewUX.height)
        } labelOverlay: { _ in } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
                .frame(height: TabLocationViewUX.height)
        } labelOverlay: { _ in } leading: { } trailing: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
                .frame(height: TabLocationViewUX.height)
        } labelOverlay: { _ in } leading: {
            Text("")
        } trailing: {
            Text("")
        }
        .previewStyle()

    }
    static var previews: some View {
        ForEach(["title", "a very very very very very long title", "a", "a long title"], id: \.self) { title in
            VStack {
                contents(for: title)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
