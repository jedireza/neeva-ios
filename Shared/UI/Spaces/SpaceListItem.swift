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
            iconColor = .Neeva.Brand.Blue
        } else {
            icon = .bookmark
            iconColor = .tertiaryLabel
        }
    }
    var body: some View {
        HStack {
            LargeSpaceIconView(space: space)
                .padding(.trailing, 8)
            Text(space.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.label)
                .lineLimit(1)
            if space.isPublic {
                Symbol(.link, size: 14)
                    .foregroundColor(.secondaryLabel)
            }
            if space.isShared {
                Symbol(.person2Fill, size: 14)
                    .foregroundColor(.secondaryLabel)
            }
            Spacer(minLength: 0)
            Symbol(icon, weight: .semibold)
                .frame(width: 44, height: 44)
                .foregroundColor(iconColor)
        }
        .padding(.vertical, 6)
        .padding(.leading, 16)
        .padding(.trailing, 5)
    }
}

struct LoadingSpaceListItem: View {
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.tertiarySystemFill)
                .frame(width: 36, height: 36)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.tertiarySystemFill)
                .frame(width: 150, height: 16)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.leading, 16)
    }
}

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVStack(spacing: 14) {
            LoadingSpaceListItem()
            SpaceListItem(.empty, currentURL: URL(string: "https://neeva.com")!)
            SpaceListItem(.savedForLaterEmpty, currentURL: URL(string: "https://neeva.com")!)
            SpaceListItem(.savedForLater, currentURL: URL(string: "https://neeva.com")!)
            SpaceListItem(.stackOverflow, currentURL: URL(string: "https://neeva.com")!)
            SpaceListItem(.sharedSpace, currentURL: URL(string: "https://neeva.com")!)
            SpaceListItem(.publicSpace, currentURL: URL(string: "https://neeva.com")!)
            SpaceListItem(.sharedPublicSpace, currentURL: URL(string: "https://neeva.com")!)
        }.padding(.vertical).previewLayout(.sizeThatFits)
    }
}
