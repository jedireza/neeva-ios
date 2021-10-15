// Copyright Neeva. All rights reserved.

import SwiftUI

struct GridScrollView<Content: View, Preference: PreferenceKey>: View
where Preference.Value == CGFloat {
    @Environment(\.columns) var columns
    let frameName: String = UUID().uuidString
    let onScrollOffsetChanged: (CGFloat) -> Void
    let preferenceKey: Preference.Type
    let content: (ScrollViewProxy) -> Content

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
        .coordinateSpace(name: frameName)
        .onPreferenceChange(preferenceKey.self) { scrollOffset in
            onScrollOffsetChanged(scrollOffset)
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
