// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

/// see also `LocationViewShareButton`
struct TopBarShareButton: View {
    let url: URL?
    let onTap: (UIView) -> Void

    @State private var shareTargetView: UIView!
    @EnvironmentObject private var chromeModel: TabChromeModel

    var body: some View {
        TabToolbarButton(label: Symbol(.squareAndArrowUp, size: 20, label: "Share")) {
            onTap(shareTargetView)
        }
        .uiViewRef($shareTargetView)
        .disabled(url == nil || !chromeModel.isPage)
    }
}

struct TopBarShareButton_Previews: PreviewProvider {
    static var previews: some View {
        TopBarShareButton(url: nil, onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))
        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: false))

        TopBarShareButton(url: "https://neeva.com", onTap: { _ in })
            .environmentObject(TabChromeModel(isPage: true))
    }
}
