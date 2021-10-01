// Copyright Neeva. All rights reserved.

import Defaults
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

struct ShareSpaceView: View {
    typealias ACL = ListSpacesQuery.Data.ListSpace.Space.Space.Acl
    let space: Space
    let shareTargetView: UIView
    let fromAddToSpace: Bool
    @Binding var isPresented: Bool

    @Default(.seenSpacesShareIntro) var seenSpacesShareIntro: Bool
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var suggestedContacts: [ContactsProvider.Profile] = []
    @State var selectedProfiles: [ContactsProvider.Profile] = []
    @State var isPublic: Bool
    @State var soloACLSharePresented: Bool = false
    @State var emailText: String = ""
    @State var noteText: String
    @State var selectedACL = SpaceACLLevel.view

    init(
        space: Space, shareTarget: UIView, isPresented: Binding<Bool>, compact: Bool = false,
        noteText: String
    ) {
        self.space = space
        self.shareTargetView = shareTarget
        self.isPublic = space.isPublic
        self._isPresented = isPresented
        self.fromAddToSpace = compact
        self.noteText = noteText
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
            .padding(.horizontal, 16)
            .background(Color.DefaultBackground)
    }

    var soloShareButtonUI: some View {
        Group {
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
                        .stroke(Color.tertiaryLabel, lineWidth: 1)
                )
                .padding(.bottom, 16)
            Button(
                action: {
                    var sharedUsers = 0
                    if !selectedProfiles.isEmpty {
                        sharedUsers = selectedProfiles.count
                        spaceModel.addSoloACLs(
                            space: space, emails: selectedProfiles.map { $0.email },
                            acl: selectedACL, note: noteText)
                    } else if emailText.contains("@") {
                        sharedUsers = 1
                        spaceModel.addSoloACLs(
                            space: space, emails: [emailText],
                            acl: selectedACL, note: noteText)
                    }

                    if sharedUsers > 0,
                        let toastManager = SceneDelegate.getCurrentSceneDelegate(
                            with: tabModel.manager.scene)?.toastViewManager
                    {
                        toastManager.makeToast(
                            text:
                                "Success! Space shared with \(sharedUsers) \(sharedUsers == 1 ? "person" : "people")"
                        )
                        .enqueue(manager: toastManager)
                    }

                    isPresented = false
                },
                label: {
                    Text("Invite")
                        .withFont(.labelLarge)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                }
            )
            .buttonStyle(NeevaButtonStyle(.primary))
            .padding(.bottom, 16)
        }
    }

    var soloACLShareView: some View {
        VStack(spacing: 0) {
            Button(
                action: { soloACLSharePresented.toggle() },
                label: {
                    HStack(spacing: 0) {
                        Text("Invite someone")
                            .withFont(.headingMedium)
                            .foregroundColor(.label)
                        Spacer()
                        Symbol(decorative: soloACLSharePresented ? .chevronUp : .chevronDown)
                            .foregroundColor(.label)
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 19)
                }
            ).buttonStyle(TableCellButtonStyle())
            if soloACLSharePresented {
                emailEntry.padding(.horizontal, 16)
                if suggestedContacts.isEmpty {
                    soloShareButtonUI.padding(.horizontal, 16)
                } else {
                    suggestedContactsCell.padding(.horizontal, 16)
                }
            }
        }.background(Color.DefaultBackground)
    }

    var publicACLShareView: some View {
        VStack(spacing: 0) {
            if space.ACL == .owner {
                Toggle(
                    isOn: $isPublic,
                    label: {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Enable shareable link")
                                .withFont(.headingMedium)
                                .foregroundColor(.label)
                            Text("Anyone with the link can view")
                                .withFont(.bodyMedium)
                                .foregroundColor(.secondaryLabel)
                        }
                    }
                ).padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            if space.ACL == .owner || isPublic {
                ShareToSocialView(
                    url: fromAddToSpace ? space.urlWithAddedItem : space.url, noteText: noteText,
                    shareTarget: shareTargetView
                ) { onShared in
                    guard !isPublic else {
                        isPresented = false
                        onShared()
                        return
                    }
                    if seenSpacesShareIntro {
                        self.isPublic = true
                        isPresented = false
                        onShared()
                    } else {
                        SceneDelegate.getBVC(with: tabModel.manager.scene).showModal(
                            style: .spaces,
                            content: {
                                SpacesShareIntroOverlayContent(onShare: {
                                    seenSpacesShareIntro = true
                                    self.isPublic = true
                                    onShared()
                                })
                            })
                    }
                }
            }
        }.background(Color.DefaultBackground)
    }

    var header: some View {
        HStack(spacing: 0) {
            Text("Done").withFont(.headingMedium).hidden()
            Spacer()
            Text("Share Space")
                .withFont(.headingMedium)
                .foregroundColor(.label)
            Spacer()
            Button(
                action: { isPresented = false },
                label: {
                    Text("Done")
                        .withFont(.headingMedium)
                        .foregroundColor(.ui.adaptive.blue)
                })
        }.padding(.horizontal, 7)
            .padding(.vertical, 15)
            .background(Color.DefaultBackground)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if !fromAddToSpace {
                header
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 2) {
                    if space.ACL == .owner {
                        soloACLShareView
                    }
                    publicACLShareView
                    if !fromAddToSpace {
                        Text("Who has access")
                            .withFont(.headingSmall)
                            .foregroundColor(.label)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        currentACLList
                    }
                }
            }
            Spacer()
        }
        .background(Color.TrayBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .bottom)
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
                        ContactsProvider.Profile(
                            displayName: email, email: email, pictureUrl: ""))
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
