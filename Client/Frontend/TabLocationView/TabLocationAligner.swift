// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

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
        debug: Bool = FeatureFlag[.debugURLBar],
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
                            ZStack {
                                LocationLabelAligner(
                                    transitionToEditing: transitionToEditing,
                                    debug: debug,
                                    label: label,
                                    leadingPadding: leadingPadding,
                                    trailingPadding: trailingPadding,
                                    centerX: outerGeom.size.width / 2,
                                    centerY: innerGeom.size.height / 2
                                )
                                labelOverlay(
                                    EdgeInsets(
                                        top: 0, leading: leadingPadding, bottom: 0,
                                        trailing: trailingPadding))
                            }
                        }  // GeometryReader
                    }  // HStack
                }  // GeometryReader
                trailingActions()
            }  // HStack
        }  // GeometryReader
        .overlay(
            Group {
                if debug {
                    Color.purple.frame(width: 1, height: 10)
                }
            }, alignment: .bottom)
    }
}

private struct LocationLabelAligner<Label: View>: View {
    let transitionToEditing: Bool
    let debug: Bool
    let label: () -> Label
    let leadingPadding: CGFloat
    let trailingPadding: CGFloat
    let centerX: CGFloat
    let centerY: CGFloat

    @State private var titleWidth: CGFloat = 0

    @ViewBuilder
    func formatPX(_ label: String, _ value: CGFloat) -> some View {
        if debug {
            Text(
                "\(label): \(Measurement(value: Double(value), unit: Unit(symbol: "px")).description)"
            )
            .font(.caption2)
            .allowsHitTesting(false)
        }
    }

    var body: some View {
        /// The space between the end of the title and the trailing controls, if the title was centered inside the location view.
        ///
        /// Can be negative if the title is wide enough to collide with the trailing controls.
        let trailingGap = centerX - trailingPadding - titleWidth / 2

        /// The offset necessary (from the trailing edge of the leading controls) to center the label in the aligner.
        ///
        /// If the label would extend over the trailing controls if centered, this offset will align its trailing edge with
        /// the leading edge of the trailing controls.
        let labelOffset =
            transitionToEditing
            // left-align when editing
            ? titleWidth / 2
            : centerX - leadingPadding - max(-trailingGap, 0)

        label()
            .background(
                GeometryReader { textGeom in
                    (debug ? Color.yellow.opacity(0.25) : Color.clear)
                        .useEffect(deps: textGeom.size.width) { self.titleWidth = $0 }
                        .overlay(
                            Group {
                                if debug {
                                    Color.orange.frame(width: 1, height: 10)
                                }
                            }, alignment: .top
                        )
                        .overlay(formatPX("width", titleWidth), alignment: .bottomTrailing)
                        .allowsHitTesting(false)
                }
            )
            .position(x: labelOffset, y: centerY)
            .overlay(formatPX("x", labelOffset).padding(.leading, 5), alignment: .topLeading)
            .background(
                Group {
                    if debug {
                        Color.green
                            .opacity(0.2)
                            .allowsHitTesting(false)
                    }
                })

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
        } labelOverlay: { _ in
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: true, debug: true) {
            Text("editing")
        } labelOverlay: { _ in
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
        } labelOverlay: { _ in
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(decorative: .squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
        } labelOverlay: { _ in
        } leading: {
        } trailing: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
            TabLocationBarButton(label: Symbol(decorative: .arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(decorative: .squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(transitionToEditing: false, debug: true) {
            Text(title)
        } labelOverlay: { _ in
        } leading: {
            Text("")
        } trailing: {
            Text("")
        }
        .previewStyle()

    }
    static var previews: some View {
        ForEach(
            ["title", "a very very very very very long title", "a", "a long title"], id: \.self
        ) { title in
            VStack {
                contents(for: title)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
