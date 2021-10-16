// Copyright Neeva. All rights reserved.

import SwiftUI

struct GridScrollView<Content: View, Preference: PreferenceKey>: View
where Preference.Value == CGFloat {
    @Environment(\.columns) var columns
    let frameName: String = UUID().uuidString
    let onScrollOffsetChanged: (CGFloat) -> Void
    let preferenceKey: Preference.Type
    let content: (ScrollViewProxy) -> Content
    @State var orientation = UIDevice.current.orientation
    @State var token = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { scrollReaderProxy in
                LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                    content(scrollReaderProxy)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: preferenceKey.self,
                            value: proxy.frame(in: .named(frameName)).minY)
                    }
                )
                .padding(.vertical, CardGridUX.GridSpacing)
            }
        }
        .id(token)
        .coordinateSpace(name: frameName)
        .onPreferenceChange(preferenceKey.self) { scrollOffset in
            onScrollOffsetChanged(scrollOffset)
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        ) { _ in
            let newOrientation = UIDevice.current.orientation
            // Re-create the ScrollView since scrollOffset calculation is not reliable after device rotation.
            // This appears to be a bug in UIKit as even UIScrollView.contentOffset shows the same bug.
            if orientation.isLandscape != newOrientation.isLandscape {
                token += 1
            }
            orientation = newOrientation
        }
    }
}

//struct GridScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        GridScrollView(onScrollOffsetChanged: { _ in }) {
//            scrollReaderProxy in
//            ForEach(0..<30) { index in
//                Color.black.frame(width: 50, height: 50)
//                    .id(index)
//            }
//            .onAppear { scrollReaderProxy.scrollTo(29) }
//        }
//    }
//}
