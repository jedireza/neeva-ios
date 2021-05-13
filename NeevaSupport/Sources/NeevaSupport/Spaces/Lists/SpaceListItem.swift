// Copyright Neeva. All rights reserved.

import SwiftUI

/// An entry in a space list
struct SpaceListItem: View {
    let space: Space
    let icon: Nicon
    let iconColor: Color

    /// - Parameter space: the space to render
    init(_ space: Space, currentURL: URL) {
        self.space = space
        if SpaceStore.shared.urlInSpace(currentURL, spaceId: space.id) {
            icon = .bookmarkFill
            iconColor = Color.Neeva.Brand.Blue
        } else {
            icon = .bookmark
            iconColor = .tertiaryLabel
        }
    }
    var body: some View {
        HStack(spacing: 16) {
            LargeSpaceIconView(space: space)
            Text(space.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            Symbol.neeva(icon, size: 16, weight: .semibold)
                .frame(width: 44, height: 44)
                .foregroundColor(iconColor)
        }
        .padding([.top, .bottom], 6)
        .padding(.leading, 16)
        .padding(.trailing, 5)
    }
}

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SpaceListItem(.savedForLater, currentURL: URL(string: "https://neeva.com")!)
            SpaceListItem(.stackOverflow, currentURL: URL(string: "https://neeva.com")!)
        }
    }
}
