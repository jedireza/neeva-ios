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

    var body: some View {
        GeometryReader { outerGeom in
            HStack(spacing: 0) {
                GeometryReader { leadingGeom in
                    let trailingControlWidth = outerGeom.size.width - leadingGeom.size.width
                    HStack(spacing: 0) {
                        leadingActions()
                        GeometryReader { innerGeom in
                            let leadingControlWidth = leadingGeom.size.width - innerGeom.size.width
                            let filler: Color = debug ? .systemFill : .clear
                            HStack(spacing: 0) {
                                filler
                                    .frame(minWidth: 0, maxWidth: outerGeom.size.width / 2 - leadingControlWidth)
                                label()
                                    .background(GeometryReader { textGeom in
                                        Text("").preference(key: TitleWidthPreferenceKey.self, value: textGeom.size.width)
                                    })
                                    .layoutPriority(1)
                                    .onPreferenceChange(TitleWidthPreferenceKey.self) { self.titleWidth = $0 }
                                filler
                                    .frame(minWidth: 0, maxWidth: outerGeom.size.width / 2 - trailingControlWidth - titleWidth / 2)
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
