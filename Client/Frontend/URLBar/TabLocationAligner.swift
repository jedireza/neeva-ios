// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

fileprivate struct TitleWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// NOTE: this view has not been tested with layouts where `Leading` is wider than `Trailing`.
/// If that is possible with the parameters you pass, make sure to check that it works properly.
struct TabLocationAligner<Leading: View, Label: View, Trailing: View>: View {
    let debug: Bool
    let leadingActions: () -> Leading
    let label: () -> Label
    let trailingActions: () -> Trailing

    init(
        debug: Bool = FeatureFlag[.newURLBarDebug],
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.debug = debug
        self.label = label
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
                            LocationLabelAligner(
                                debug: debug,
                                label: label,
                                leadingPadding: leadingGeom.size.width - innerGeom.size.width,
                                trailingPadding: outerGeom.size.width - leadingGeom.size.width,
                                centerX: outerGeom.size.width / 2,
                                centerY: innerGeom.size.height / 2
                            )
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
            Text("\(label): \(Measurement(value: Double(value), unit: Unit(symbol: "px")).description)")
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
        let labelOffset = centerX - leadingPadding - max(-trailingGap, 0)

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
            .position(x: labelOffset, y: centerY)
            .overlay(formatPX("x", labelOffset).padding(.leading, 5), alignment: .topLeading)
            .background(Group {
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
        TabLocationAligner(debug: true) {
            Text(title)
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
        }.previewStyle()

        TabLocationAligner(debug: true) {
            Text(title)
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(debug: true) {
            Text(title)
        } leading: { } trailing: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}
        }.previewStyle()

        TabLocationAligner(debug: true) {
            Text(title)
        } leading: {
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
