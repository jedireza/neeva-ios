//
//  UserDetailView.swift
//  
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI
import RemoteImage

public struct ProfileFallbackView: View {
    public enum Size {
        case small
        case large
        public static let `default` = Size.large

        fileprivate var color: Color {
            switch self {
            case .small: return .letterAvatarBackground
            case .large: return .gray80
            }
        }
        fileprivate var titleLength: Int {
            switch self {
            case .small: return 1
            case .large: return 2
            }
        }
        fileprivate var titleSize: CGFloat {
            switch self {
            case .small: return 10
            case .large: return 15
            }
        }
    }

    let name: String
    let size: Size
    public var body: some View {
        ZStack {
            size.color
            Text(firstCharacters(size.titleLength, from: name))
                .font(.system(size: size.titleSize))
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

public struct UserAvatarView: View {
    let profile: UserProfile
    let size: ProfileFallbackView.Size
    public init(_ profile: UserProfile, size: ProfileFallbackView.Size = .default) {
        self.profile = profile
        self.size = size
    }

    public var body: some View {
        let fallbackText = profile.displayName.isEmpty ? profile.email : profile.displayName
        RemoteImage(
            type: .url(URL(string: profile.pictureUrl) ?? URL(string: "about:blank")!)
        ) { error in
            ProfileFallbackView(name: fallbackText, size: size)
        } imageView: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } loadingView: {
            ProfileFallbackView(name: fallbackText, size: size)
        }
        .clipShape(Circle())
    }
}

public struct UserDetailView: View {
    let profile: UserProfile
    public init(_ profile: UserProfile) {
        self.profile = profile
    }

    public var body: some View {
        HStack {
            UserAvatarView(profile).frame(width: 28, height: 28)

            VStack(alignment: .leading) {
                if !profile.displayName.isEmpty {
                    Text(profile.displayName)
                }
                Text(profile.email)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }.padding(.leading, 5)
        }
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserDetailView(testSpace.acl![0].profile)
            UserDetailView(testSpace.acl![1].profile)
            UserDetailView(ContactSuggestionController.Suggestion(
                            displayName: "",
                            email: "email@example.com",
                            pictureUrl: "https://i.pravatar.cc/150?img=3"))
            Group {
                UserAvatarView(testSpace.acl![0].profile, size: .small)
                UserAvatarView(testSpace.acl![1].profile, size: .small)
            }.frame(width: 20, height: 20)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
