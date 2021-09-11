// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

enum ShareSpaceViewUX {
    static let Padding: CGFloat = 8
}

extension SpaceACLLevel {
    var editText: String {
        switch self {
        case .comment:
            return "Can comment"
        case .edit:
            return "Can edit"
        case .view:
            return "Can view"
        default:
            return ""
        }
    }
}

struct ShareSpaceOverlaySheetContent: View {
    let space: Space
    @Binding var presentShareOnDismiss: Bool
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    var body: some View {
        ShareSpaceView(
            space: space,
            presentShareOnDismiss: $presentShareOnDismiss,
            dismiss: hideOverlaySheet
        ).overlaySheetIsFixedHeight(isFixedHeight: true)
    }
}

struct ShareSpaceView: View {
    typealias ACL = ListSpacesQuery.Data.ListSpace.Space.Space.Acl
    let space: Space
    @Binding var presentShareOnDismiss: Bool
    let dismiss: () -> Void

    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var suggestedContacts: [ContactsProvider.Profile] = []
    @State var selectedProfiles: [ContactsProvider.Profile] = []
    @State var isPublic: Bool
    @State var emailText: String = ""
    @State var noteText: String = "Check out my new Neeva Space!"
    @State var selectedACL = SpaceACLLevel.view

    init(space: Space, presentShareOnDismiss: Binding<Bool>, dismiss: @escaping () -> Void) {
        self.space = space
        self.isPublic = space.isPublic
        self._presentShareOnDismiss = presentShareOnDismiss
        self.dismiss = dismiss
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Share \"\(space.displayTitle)\"")
                .withFont(.headingMedium)
                .lineLimit(1)
                .foregroundColor(Color.label)
            Text("Invite others to collaborate.")
                .withFont(.labelMedium)
                .lineLimit(1)
                .foregroundColor(Color.secondaryLabel)
        }.padding(ShareSpaceViewUX.Padding)
    }

    var shareButtonUI: some View {
        VStack(spacing: 0) {
            TextField("Add a note!", text: $noteText)
                .withFont(unkerned: .bodyLarge)
                .lineLimit(3)
                .foregroundColor(Color.label)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(height: 112, alignment: .topLeading)
                .background(Color.DefaultBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondaryLabel, lineWidth: 1)
                )
                .padding(.bottom, 16)
            Button(
                action: {
                    if !selectedProfiles.isEmpty {
                        spaceModel.addSoloACLs(
                            space: space, emails: selectedProfiles.map { $0.email },
                            acl: selectedACL, note: noteText)
                    } else if emailText.contains("@") {
                        spaceModel.addSoloACLs(
                            space: space, emails: [emailText],
                            acl: selectedACL, note: noteText)
                    }

                    dismiss()
                },
                label: {
                    Text("Share")
                        .withFont(.labelLarge)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                }
            )
            .buttonStyle(NeevaButtonStyle(.primary))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    var selectedProfilesUI: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(minimum: 75, maximum: 200)), count: 2)
        ) {
            ForEach(selectedProfiles, id: \.email) { profile in
                HStack {
                    Text(profile.displayName)
                        .withFont(.bodyLarge)
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
                            .padding(.vertical, 8)
                    }
                }.padding(.horizontal, 10)
                    .background(Color.brand.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }.padding(.vertical, 10)
    }

    var emailEntry: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !selectedProfiles.isEmpty {
                selectedProfilesUI
            }
            HStack {
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
                .withFont(unkerned: .bodyLarge)
                .lineLimit(1)
                .foregroundColor(Color.label)
                .padding(.vertical, 10)
                ACLView(selectedACL: $selectedACL).padding(10)
            }.frame(height: 22)
        }.padding(20)
            .background(Color.DefaultBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tertiaryLabel, lineWidth: 1)
            )
            .padding(.vertical, 12)
    }

    var suggestedContactsCell: some View {
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

    var currentACLList: some View {
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

    var sharePubliclyToggle: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $isPublic) {
                VStack(alignment: .leading) {
                    Text("Get Link & Share Publicly")
                        .withFont(.headingSmall)
                        .lineLimit(1)
                        .foregroundColor(Color.label)
                    Text("Anyone with the link can view.")
                        .withFont(.bodyMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
            }
            if isPublic {
                Button(
                    action: {
                        presentShareOnDismiss = true
                        dismiss()
                    },
                    label: {
                        Text("Share Link")
                            .withFont(.labelLarge)
                            .frame(maxWidth: .infinity)
                            .clipShape(Capsule())
                    }
                )
                .buttonStyle(NeevaButtonStyle(.primary))
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }.padding(ShareSpaceViewUX.Padding)
    }

    var body: some View {
        GroupedStack {
            header
            emailEntry
            if !suggestedContacts.isEmpty {
                suggestedContactsCell
            } else if !selectedProfiles.isEmpty || !emailText.isEmpty {
                shareButtonUI
            } else {
                currentACLList
                sharePubliclyToggle
            }
        }
        .onChange(
            of: emailText,
            perform: { value in
                guard !emailText.isEmpty else {
                    suggestedContacts = []
                    return
                }

                if emailText.last == " " && emailText.contains("@") {
                    let email = String(emailText.dropLast())
                    selectedProfiles.append(
                        ContactsProvider.Profile(displayName: email, email: email, pictureUrl: ""))
                    emailText = ""
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

struct ACLView: View {
    @Binding var selectedACL: SpaceACLLevel

    var body: some View {
        Menu(
            content: {
                Button {
                    selectedACL = .edit
                } label: {
                    Text(SpaceACLLevel.edit.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
                Button {
                    selectedACL = .comment
                } label: {
                    Text(SpaceACLLevel.comment.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
                Button {
                    selectedACL = .view
                } label: {
                    Text(SpaceACLLevel.view.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                }
            },
            label: {
                HStack {
                    Text(selectedACL.editText)
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.ui.adaptive.blue)
                    Symbol(decorative: .chevronDown, style: .labelMedium)
                        .foregroundColor(Color.ui.adaptive.blue)
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
                .withFont(.bodyMedium)
                .lineLimit(1)
                .foregroundColor(Color.label)
            Text(email)
                .withFont(.bodySmall)
                .lineLimit(1)
                .foregroundColor(Color.secondaryLabel)
        }
    }
}
