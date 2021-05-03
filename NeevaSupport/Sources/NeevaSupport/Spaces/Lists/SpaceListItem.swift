// Copyright Neeva. All rights reserved.

import SwiftUI

/// An entry in a space list
struct SpaceListItem: View {
    let space: SpaceListController.Space
    let currentURL: String?
    /// - Parameter space: the space to render
    init(_ space: SpaceListController.Space, currentURL: String? = "") {
        self.space = space
        self.currentURL = currentURL
    }
    var body: some View {
        HStack(spacing: 16) {
            LargeSpaceIconView(space: space)
            Text(space.space!.name ?? "")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            Symbol.neeva(.bookmark, size: 16, weight: .semibold)
                .frame(width: 44, height: 44)
                .foregroundColor(.tertiaryLabel)
        }
        .padding([.top, .bottom], 6)
        .padding(.leading, 16)
        .padding(.trailing, 5)
    }
}

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SpaceListItem(.savedForLater)
            SpaceListItem(.stackOverflow)
        }
    }
}
