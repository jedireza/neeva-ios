// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

enum ShareSpaceViewUX {
    static let Padding: CGFloat = 8
}

struct ShareSpaceView: View {
    typealias ACL = ListSpacesQuery.Data.ListSpace.Space.Space.Acl
    let space: Space
    let dismiss: () -> Void
    @Binding var presentShareOnDismiss: Bool

    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var suggestedContacts: [ContactsProvider.Profile] = []
    @State var selectedProfiles: [ContactsProvider.Profile] = []
    @State var isPublic: Bool
    @State var emailText: String = ""
    @State var selectedACL = SpaceACLLevel.view

    init(space: Space, presentShareOnDismiss: Binding<Bool>, dismiss: @escaping () -> Void) {
        self.space = space
        self.isPublic = space.isPublic
        self._presentShareOnDismiss = presentShareOnDismiss
        self.dismiss = dismiss
    }

    var header: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Share This Space")
                    .withFont(.labelLarge)
                    .lineLimit(1)
                    .foregroundColor(Color.label)
                Text("Invite others to collaborate.")
                    .withFont(.labelMedium)
                    .lineLimit(1)
                    .foregroundColor(Color.secondaryLabel)
            }.padding(ShareSpaceViewUX.Padding)
        }
    }

    var shareButtonsUI: some View {
        VStack {
            Spacer()
            ACLView(selectedACL: $selectedACL).padding(10)
            Button {
                spaceModel.addSoloACLs(
                    space: space, emails: selectedProfiles.map { $0.email }, acl: selectedACL)
                dismiss()
            } label: {
                Text("Share")
                    .withFont(.labelMedium)
                    .lineLimit(1)
                    .foregroundColor(.brand.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.brand.blue)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

    var selectedProfilesUI: some View {
        VStack(alignment: .leading) {
            ForEach(selectedProfiles, id: \.email) { profile in
                HStack {
                    Text(profile.displayName)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(.brand.white)
                    Button {
                        let index = selectedProfiles.firstIndex {
                            $0.email == profile.email
                        }
                        selectedProfiles.remove(at: index!)
                    } label: {
                        Symbol(decorative: .xmark, style: .labelMedium)
                            .foregroundColor(.brand.white)
                    }
                }.padding(.vertical, 6).padding(.horizontal, 10)
                    .background(Color.brand.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }

    var emailEntry: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                if !selectedProfiles.isEmpty {
                    HStack(alignment: .center) {
                        selectedProfilesUI
                        Spacer()
                        shareButtonsUI
                    }
                }
                TextField(
                    "Enter email address", text: $emailText,
                    onCommit: {
                        if emailText.contains("@") {
                            selectedProfiles.append(
                                ContactsProvider.Profile(
                                    displayName: emailText, email: emailText, pictureUrl: ""))
                            emailText = ""
                        }
                    }
                )
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .lineLimit(1)
                .foregroundColor(Color.label)
                .padding(.vertical, 10)
            }.padding(10)
        }
    }

    var suggestedContactsCell: some View {
        GroupedCell(alignment: .leading) {
            LazyVStack(alignment: .leading) {
                ForEach(
                    suggestedContacts.filter { suggested in
                        !selectedProfiles.contains(where: { $0.email == suggested.email })
                    }, id: \.email
                ) { profile in
                    Button(action: {
                        selectedProfiles.append(profile)
                        emailText = ""
                        suggestedContacts = []
                    }) {
                        HStack {
                            ProfileView(
                                pictureURL: profile.pictureUrl, displayName: profile.displayName,
                                email: profile.email)
                            Spacer()
                        }
                    }
                }.buttonStyle(TableCellButtonStyle())
            }.padding(.vertical, ShareSpaceViewUX.Padding)
        }
    }

    var currentACLList: some View {
        GroupedCell(alignment: .leading) {
            LazyVStack(alignment: .leading) {
                ForEach(space.acls, id: \.userId) { acl in
                    HStack {
                        ProfileView(
                            pictureURL: acl.profile.pictureUrl,
                            displayName: acl.profile.displayName, email: acl.profile.email)
                        Spacer(minLength: 0)
                        Text(acl.acl.rawValue)
                            .withFont(.labelMedium)
                            .lineLimit(1)
                            .foregroundColor(Color.label)
                    }
                }
            }.padding(.vertical, ShareSpaceViewUX.Padding)
        }
    }

    var sharePubliclyToggle: some View {
        GroupedCell(alignment: .leading) {
            VStack {
                Toggle(isOn: $isPublic) {
                    VStack(alignment: .leading) {
                        Text("Share Publicly")
                            .withFont(.labelLarge)
                            .lineLimit(1)
                            .foregroundColor(Color.label)
                        Text("Anyone with the link can view.")
                            .withFont(.labelMedium)
                            .lineLimit(1)
                            .foregroundColor(Color.secondaryLabel)
                    }
                }
                if isPublic {
                    Button {
                        presentShareOnDismiss = true
                        dismiss()
                    } label: {
                        Text("Share Link")
                            .withFont(.labelMedium)
                            .lineLimit(1)
                            .foregroundColor(.brand.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.brand.blue)
                            .clipShape(Capsule())
                    }
                }
            }.padding(ShareSpaceViewUX.Padding)
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            GroupedStack {
                header
                emailEntry
                ZStack {
                    currentACLList
                    if !suggestedContacts.isEmpty {
                        suggestedContactsCell
                    }
                }
                sharePubliclyToggle
            }
            .onChange(
                of: emailText,
                perform: { value in
                    guard !emailText.isEmpty else {
                        suggestedContacts = []
                        return
                    }

                    ContactsProvider.getContacts(for: emailText.lowercased()) { result in
                        switch result {
                        case .success(let profiles):
                            self.suggestedContacts = profiles.compactMap { $0 }
                        case .failure(let error):
                            Logger.browser.info(error.localizedDescription)
                        }
                    }
                }
            )
            .onChange(of: isPublic) { value in
                spaceModel.changePublicACL(space: space, add: value)
            }

        }

    }
}

struct ACLView: View {
    @Binding var selectedACL: SpaceACLLevel

    var body: some View {
        Menu(
            content: {
                Button {
                    selectedACL = .edit
                } label: {
                    Text("Can edit")
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
                Button {
                    selectedACL = .comment
                } label: {
                    Text("Can comment")
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
                Button {
                    selectedACL = .view
                } label: {
                    Text("Can view")
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
            },
            label: {
                HStack {
                    Text(selectedACL.rawValue)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.label)
                    Symbol(decorative: .chevronDown, style: .labelMedium)
                        .foregroundColor(.label)
                }
            })
    }
}

struct ProfileView: View {
    let pictureURL: String
    let displayName: String
    let email: String

    var body: some View {
        Group {
            if let pictureUrl = URL(string: pictureURL) {
                WebImage(url: pictureUrl).resizable()
            } else {
                let name = (displayName).prefix(2).uppercased()
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
        .frame(width: 20, height: 20)
        VStack(alignment: .leading, spacing: 0) {
            Text(displayName)
                .withFont(.labelMedium)
                .lineLimit(1)
                .foregroundColor(Color.label)
            Text(email)
                .withFont(.labelMedium)
                .lineLimit(1)
                .foregroundColor(Color.secondaryLabel)
        }
    }
}
