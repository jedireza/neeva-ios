// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct SpaceHeaderView: View {
    let space: Space

    var owner: Space.Acl? {
        space.acls.first(where: { $0.acl == .owner })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(space.displayTitle)
                .withFont(.displayMedium)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            if let owner = owner?.profile {
                HStack(spacing: 12) {
                    Group {
                        if let pictureUrl = URL(string: owner.pictureUrl) {
                            WebImage(url: pictureUrl).resizable()
                        } else {
                            let name = (owner.displayName).prefix(2).uppercased()
                            Color.brand.blue
                                .overlay(
                                    Text(name)
                                        .accessibilityHidden(true)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    Text(owner.displayName)
                        .withFont(.bodyLarge)
                        .foregroundColor(.label)
                }
            }
            if let description = space.description, !description.isEmpty {
                Text(description)
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if space.isPublic {
                if let followers = space.followers {
                    HStack(spacing: 0) {
                        Symbol(decorative: .person2Fill, style: .bodyLarge)
                            .foregroundColor(.secondaryLabel)
                        Text(" \(followers) Following")
                            .withFont(.bodyLarge)
                            .foregroundColor(.secondaryLabel)
                    }
                }
            } else {
                HStack(spacing: 0) {
                    Symbol(decorative: .lock, style: .bodySmall)
                        .foregroundColor(.secondaryLabel)
                    Text("Only visible to you and people you shared with")
                        .withFont(.bodySmall)
                        .foregroundColor(.secondaryLabel)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.DefaultBackground)

    }
}
