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
        return HStack(spacing: 16) {
            LargeSpaceIconView(space: space)
            Text(space.space!.name ?? "")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Image("menu-spaces")
                .frame(width: 44, height: 44)
                .foregroundColor(Color .gray)
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
