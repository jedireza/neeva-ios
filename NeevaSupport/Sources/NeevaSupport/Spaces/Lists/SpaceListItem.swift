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
                .font(.system(size: 16))
                .fontWeight(.regular)
                Spacer()
            Image("menu-spaces")
                .foregroundColor(Color .gray)
        }.padding(.horizontal, 16)
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
