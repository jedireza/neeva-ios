//
//  ShareSpaceView.swift
//  
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI
import Apollo

/// Represents an invitation the user is composing
struct InviteState {
    /// The access level invited users will be given
    var shareType = SpaceACLLevel.comment
    /// The users to invite
    var selected = [ContactSuggestionController.Suggestion]()
    /// A message to send along with the invitation
    var note = ""
}

/// Represents the results of sending an invitation
struct InvitationSentState {
    /// The number of invitations successfully sent
    let invitationsSent: Int
    /// A list of emails of people who are not Neeva users.
    /// To share with these emails, the user can enable public sharing and email them the link.
    let nonNeevanEmails: [String]

    /// For VoiceOver users, speak an announcement that describes what happened.
    func notify() {
        UIAccessibility.post(notification: .screenChanged, argument: "Sent \(invitationsSent) invitation\(invitationsSent == 1 ? "" : "s")." + (nonNeevanEmails.isEmpty ? "" : " Could not send \(nonNeevanEmails.count) invitation\(nonNeevanEmails.count == 1 ? "" : "s")."))
    }
}

/// A view that provides read and (if permitted) write access to space sharing details.
struct ShareSpaceView: View {
    @StateObject var publicityController: SpacePublicACLController
    @StateObject var suggestionsController = ContactSuggestionController()

    @Environment(\.presentationMode) var presentationMode

    @State var invite = InviteState()
    @State var sendingInvites: Apollo.Cancellable? = nil
    @State var sentInvites: InvitationSentState? = nil

    let space: SpaceController.Space
    let spaceId: String
    let onUpdate: Updater<SpaceController.Space>

    /// - Parameters:
    ///   - space: the space whose details will be updated
    ///   - id: the ID of the space
    ///   - onUpdate: see `SpaceLoaderView`
    init(
        space: SpaceController.Space,
        id: String,
        onUpdate: @escaping Updater<SpaceController.Space>
    ) {
        self.space = space
        self.spaceId = id
        self.onUpdate = onUpdate

        self._publicityController = .init(wrappedValue: SpacePublicACLController(id: id, hasPublicACL: space.hasPublicAcl ?? false))
    }

    /// special initializer for previews
    fileprivate init(
        space: SpaceController.Space,
        id: String,
        onUpdate: @escaping Updater<SpaceController.Space>,
        sendingInvites: Apollo.Cancellable?,
        sentInvites: InvitationSentState?
    ) {
        self.space = space
        self.spaceId = id
        self.onUpdate = onUpdate
        self._sendingInvites = .init(initialValue: sendingInvites)
        self._sentInvites = .init(initialValue: sentInvites)

        self._publicityController = .init(wrappedValue: SpacePublicACLController(id: id, hasPublicACL: space.hasPublicAcl ?? false))
    }

    var body: some View {
        let canEditSettings = space.userAcl?.acl == .owner
        NavigationView {
            if let sendingInvites = sendingInvites {
                VStack {
                    Spacer()
                    HStack { Spacer() }
                    LoadingView("Sharing…")
                    Spacer()
                }
                .navigationBarItems(
                    leading: Button("Cancel") {
                        sendingInvites.cancel()
                        self.sendingInvites = nil
                    }.font(.body)
                )
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.groupedBackground.edgesIgnoringSafeArea(.all))
            } else if let sentInvites = sentInvites {
                VStack {
                    Spacer()
                    HStack { Spacer() }
                    Group {
                        if sentInvites.nonNeevanEmails.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .font(.largeTitle)
                    .imageScale(.large)
                    .padding(.bottom)
                    .accessibilityHidden(true)

                    Text("Sent \(sentInvites.invitationsSent) invitation\(sentInvites.invitationsSent == 1 ? "" : "s").")
                        .font(.title).bold()
                        .accessibilitySortPriority(1)
                        .accessibilityAddTraits(.isHeader)
                    if !sentInvites.nonNeevanEmails.isEmpty {
                        let count = sentInvites.nonNeevanEmails.count
                        VStack(spacing: 30) {
                            Text("We couldn't find Neeva users for \(count) of the addresses you entered.")
                            if publicityController.hasPublicACL {
                                Text("Would you like to send them the public link?")
                                Button(action: {
                                    sendingInvites = ShareSpacePublicLinkMutation(
                                        space: spaceId,
                                        emails: sentInvites.nonNeevanEmails,
                                        note: invite.note
                                    ).perform { result in
                                        sendingInvites = nil
                                        if case .success(let data) = result,
                                           let result = data.shareSpacePublicLink,
                                           let numShared = result.numShared,
                                           let failures = result.failures {
                                            let sent = InvitationSentState(invitationsSent: numShared, nonNeevanEmails: failures)
                                            self.sentInvites = sent
                                            sent.notify()
                                        }
                                    }
                                }) {
                                    Text("Send")
                                    Image(systemName: "arrow.right")
                                }
                            } else {
                                Text("Enable link sharing and send?")
                                if publicityController.isUpdating {
                                    LoadingView("Enabling…", mini: true)
                                        .padding(.vertical, -5)
                                } else {
                                    Button(action: {
                                        publicityController.hasPublicACL = true
                                    }) {
                                        Text("Enable Public Link")
                                    }
                                }
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding()
                    }
                    Spacer()
                }
                .navigationBarItems(
                    trailing: Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.groupedBackground.edgesIgnoringSafeArea(.all))
            } else {
                Form {
                    if canEditSettings {
                        SpaceInviteView(invite: $invite, suggestions: suggestionsController)
                        if suggestionsController.query.isEmpty {
                            if invite.selected.isEmpty {
                                SharedWithView(users: space.acl!, canEdit: canEditSettings, spaceId: spaceId, onUpdate: onUpdate)
                                PublicToggleView(
                                    isPublic: $publicityController.hasPublicACL,
                                    isUpdating: publicityController.isUpdating,
                                    spaceId: spaceId
                                )
                            } else {
                                DecorativeSection {
                                    MultilineTextField("Optional message…", text: $invite.note)
                                }
                            }
                        } else {
                            Section(header: Text("Suggestions")) {
                                switch suggestionsController.state {
                                case .failure(let error):
                                    ErrorView(error, in: self, tryAgain: { suggestionsController.reload() })
                                        .buttonStyle(BorderlessButtonStyle())
                                case .success(let users):
                                    ForEach(users.isEmpty ? [.init(displayName: "", email: suggestionsController.query, pictureUrl: "")] : users) { user in
                                        Button {
                                            invite.selected.append(user)
                                            suggestionsController.query = ""
                                        } label: {
                                            UserDetailView(user).accentColor(.primary)
                                        }.accessibilityHint("Double-tap to add to pending invitation list")
                                    }
                                case .running:
                                    EmptyView()
                                }
                            }
                        }
                    } else {
                        SharedWithView(users: space.acl!, canEdit: canEditSettings, spaceId: spaceId, onUpdate: onUpdate)
                    }
                }
                .navigationTitle(canEditSettings ? "Share This Space" : "Shared with")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Group {
                        if !invite.selected.isEmpty {
                            Button("Cancel") { invite.selected = [] }
                                .font(.body)
                        }
                    },
                    trailing: Group {
                        if invite.selected.isEmpty {
                            Button("Done") { presentationMode.wrappedValue.dismiss() }
                        } else {
                            Button("Share") {
                                guard !invite.selected.isEmpty else { return }

                                sendingInvites = AddSpaceSoloAcLsMutation(
                                    space: spaceId,
                                    shareWith: invite.selected.map { .init(email: $0.email, acl: invite.shareType) },
                                    note: invite.note
                                ).perform { result in
                                    sendingInvites = nil
                                    guard case .success(let data) = result,
                                          let result = data.addSpaceSoloAcLs else {
                                        onUpdate(nil)
                                        return
                                    }
                                    // TODO: handle when changedACLCount + nonNeevanEmails.count < invite.selected.count
                                    sentInvites = .init(
                                        invitationsSent: result.changedAclCount ?? 0,
                                        nonNeevanEmails: result.nonNeevanEmails!
                                    )
                                    sentInvites!.notify()
                                    onUpdate(nil)
                                }
                            }
                        }
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear { onUpdate(nil) }
        .presentation(isModal: sendingInvites != nil || (!invite.selected.isEmpty && sentInvites == nil))
    }
}

struct ShareSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSpaceView(space: testSpace, id: String(repeating: "space123", count: 10), onUpdate: { _ in })
        ShareSpaceView(space: testSpace, id: String(repeating: "space123", count: 10), onUpdate: { _ in }, sendingInvites: Apollo.EmptyCancellable(), sentInvites: .init(invitationsSent: 0, nonNeevanEmails: ["jed@neeva.co"]))
        ShareSpaceView(space: testSpace2, id: String(repeating: "space123", count: 10), onUpdate: { _ in }, sendingInvites: nil, sentInvites: .init(invitationsSent: 1, nonNeevanEmails: ["jed@neeva.co"]))
        ShareSpaceView(space: testSpace, id: String(repeating: "space123", count: 10), onUpdate: { _ in }, sendingInvites: nil, sentInvites: .init(invitationsSent: 0, nonNeevanEmails: ["jed@neeva.co"]))
        ShareSpaceView(space: testSpace, id: String(repeating: "space123", count: 10), onUpdate: { _ in }, sendingInvites: nil, sentInvites: .init(invitationsSent: 4, nonNeevanEmails: []))
    }
}
