// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

fileprivate enum UX {
    static let height: CGFloat = 42
}

fileprivate struct LocationBarButton<Label: View>: View {
    let label: Label
    let action: () -> ()

    var body: some View {
        Button(action: action) {
            label
                .frame(width: UX.height, height: UX.height)
        }.foregroundColor(.label)
    }
}

fileprivate struct TitleWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TabLocationView: View {
    init(url: URL?, debug: Bool = false) {
        self.url = url
        self.debug = debug
    }
    let url: URL?
    let debug: Bool

    @State private var titleWidth: CGFloat = 0

    var body: some View {
        Capsule()
            .fill(Color.systemFill)
            .overlay(GeometryReader { outerGeom in
                HStack(spacing: 0) {
                    GeometryReader { leadingGeom in
                        let trailingControlWidth = outerGeom.size.width - leadingGeom.size.width
                        HStack(spacing: 0) {
                            LocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
                            GeometryReader { innerGeom in
                                let leadingControlWidth = leadingGeom.size.width - innerGeom.size.width
                                let filler: Color = debug ? .red : .clear
                                HStack(spacing: 0) {
                                    filler
                                        .frame(minWidth: 0, maxWidth: outerGeom.size.width / 2 - leadingControlWidth)
                                    Text(url?.host ?? "")
                                        .background(GeometryReader { textGeom in
                                            Text("").preference(key: TitleWidthPreferenceKey.self, value: textGeom.size.width)
                                        })
                                        .frame(height: UX.height)
                                        .layoutPriority(1)
                                        .onPreferenceChange(TitleWidthPreferenceKey.self) { self.titleWidth = $0 }
                                    filler
                                        .frame(minWidth: 0, maxWidth: outerGeom.size.width / 2 - trailingControlWidth - titleWidth / 2)
                                }
                            }
                        }
                    }
//                    LocationBarButton(label: Symbol(.arrowClockwise)) {}
                    LocationBarButton(label: Symbol(.arrowClockwise)) {}
                    LocationBarButton(label: Symbol(.squareAndArrowUp)) {}
                }
            })
            .overlay(Group {
                if debug {
                    Color.green.frame(width: 1)
                }
            })
            .frame(height: UX.height)
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(url: URL(string: "https://a/about"))
            TabLocationView(url: URL(string: "https://neeva.com/about"))
            TabLocationView(url: URL(string: "https://long.domain.domain.long/about"))
            TabLocationView(url: URL(string: "https://viii.verylong.subdomain.neeva.com/about"))
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
