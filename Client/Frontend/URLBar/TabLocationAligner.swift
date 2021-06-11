// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

fileprivate struct TitleWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TabLocationAligner<Leading: View, Label: View, Trailing: View>: View {
    let debug: Bool
    let leadingActions: () -> Leading
    let label: () -> Label
    let trailingActions: () -> Trailing

    init(
        debug: Bool = false,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.debug = debug
        self.label = label
        self.leadingActions = leading
        self.trailingActions = trailing
    }

    @State private var titleWidth: CGFloat = 0

    @ViewBuilder
    func formatPX(_ value: CGFloat) -> some View {
        if debug {
            Text("\(Measurement(value: Double(value), unit: Unit(symbol: "px")).description)")
                .font(.caption2)
                .allowsHitTesting(false)
        }
    }

    var body: some View {
        GeometryReader { outerGeom in
            HStack(spacing: 0) {
                GeometryReader { leadingGeom in
                    let trailingControlWidth = outerGeom.size.width - leadingGeom.size.width
                    HStack(spacing: 0) {
                        leadingActions()
                        GeometryReader { innerGeom in
                            let leadingControlWidth = leadingGeom.size.width - innerGeom.size.width
                            let filler: Color = debug ? .systemFill.opacity(0.5) : .clear
                            HStack(spacing: 0) {
                                let leadingSpace = outerGeom.size.width / 2 - leadingControlWidth
                                filler
                                    .frame(minWidth: 0, maxWidth: leadingSpace)
                                    .overlay(formatPX(leadingSpace))
                                    .allowsHitTesting(false)

                                label()
                                    .background(GeometryReader { textGeom in
                                        let color: Color = debug ? .yellow.opacity(0.25) : .clear
                                        color
                                            .onChange(of: textGeom.size.width) {
                                                self.titleWidth = $0
                                            }
                                            .allowsHitTesting(false)
                                    })
                                    .layoutPriority(1)
                                    .overlay(formatPX(titleWidth), alignment: .bottomTrailing)
                                let trailingSpace = outerGeom.size.width / 2 - trailingControlWidth - titleWidth / 2
                                filler
                                    .frame(minWidth: 0, maxWidth: trailingSpace)
                                    .overlay(formatPX(trailingSpace))
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
                trailingActions()
            }
        }.overlay(Group {
            if debug {
                Color.green.frame(width: 1)
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
