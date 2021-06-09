// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

enum TabLocationViewUX {
    static let height: CGFloat = 42
}

struct TabLocationView: View {
    init(url: URL?) {
        self.url = url
    }
    let url: URL?

    var body: some View {
        Capsule()
            .fill(Color.systemFill)
            .overlay(TabLocationAligner {
                Text(url?.host ?? "")
                    .frame(height: TabLocationViewUX.height)
            } leading: {
                TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
            } trailing: {
//                TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
                TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
                TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}

            })
            .frame(height: TabLocationViewUX.height)
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(url: URL(string: "https://a/about"))
            TabLocationView(url: URL(string: "https://neeva.com/about"))
            TabLocationView(url: URL(string: "https://long.domain.domain.long/about"))
            TabLocationView(url: URL(string: "https://vviii.verylong.subdomain.neeva.com/about"))
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
