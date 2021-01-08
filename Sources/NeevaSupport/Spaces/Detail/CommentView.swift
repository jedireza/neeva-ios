//
//  CommentView.swift
//  
//
//  Created by Jed Fox on 1/6/21.
//

import SwiftUI

struct CommentView: View {
    let spaceId: String
    let comment: SpaceController.Space.Comment
    let userAcl: SpaceACLLevel?
    let onUpdate: Updater<SpaceController.Space>

    @State var isSaving = false
    @State var promptingDelete = false
    @StateObject var profile = UserProfileController.shared

    var body: some View {
        HStack(alignment: .top) {
            Group {
                if let profile = comment.profile {
                    UserAvatarView(profile, size: .small)
                } else {
                    Color.clear
                }
            }.frame(width: 20, height: 20).offset(y: -2)
            if let text = comment.comment {
                Text(text)
            }
            Spacer()
            if let date = format(comment.createdTs, as: .compact) {
                Text(date)
            }
            let canEdit = userAcl >= .comment && profile.userId == comment.userid
            let canRemove = userAcl == .owner || canEdit
            if isSaving {
                ActivityIndicator()
            } else if canRemove {
                Menu {
                    if canEdit {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                    Button(action: {
                        promptingDelete = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .contentShape(Rectangle())
                }.actionSheet(isPresented: $promptingDelete) {
                    ActionSheet(
                        title: Text("Delete comment ”\(comment.comment ?? "")” by \(comment.profile?.displayName ?? "")?"),
                        buttons: [
                            .destructive(Text("Delete")) {
                                isSaving = true
                                DeleteSpaceCommentMutation(space: spaceId, comment: comment.id!).perform { result in
                                    isSaving = false
                                    guard
                                        case .success(let data) = result,
                                        data.deleteSpaceComment ?? false
                                    else {
                                        onUpdate(nil)
                                        return
                                    }
                                    onUpdate { newSpace in
                                        newSpace.comments?.removeAll(where: { $0.id == comment.id })
                                    }
                                }
                            },
                            .cancel()
                        ]
                    )
                }.padding(.trailing, -2)
            }
        }
        .padding(.top, 2)
        .disabled(isSaving)
        .opacity(isSaving ? 0.5 : 1)
    }

    func onEdit() {
        openTextInputAlert(
            title: "Edit comment",
            confirmationButtonTitle: "Save",
            inputRequired: true,
            initialText: comment.comment!,
            configureTextField: { tf in
                tf.autocapitalizationType = .sentences
                tf.returnKeyType = .done
                tf.autocorrectionType = .default
            }
        ) { commentText in
            isSaving = true
            UpdateSpaceCommentMutation(space: spaceId, comment: comment.id!, commentText: commentText).perform { result in
                isSaving = false
                guard
                    case .success(let data) = result,
                    data.updateSpaceComment ?? false
                else {
                    onUpdate(nil)
                    return
                }
                onUpdate { newSpace in
                    if let idx = newSpace.comments?.firstIndex(where: { $0.id == comment.id }) {
                        newSpace.comments![idx].comment = commentText
                    }
                }
            }
        }
    }
}

fileprivate let placeholders = ["Add a comment...", "What's on your mind?", "Write it down so you won't forget!"]

struct ComposeCommentView: View {
    let spaceId: String
    let onUpdate: Updater<SpaceController.Space>

    @State var placeholder = placeholders.randomElement()!
    @State var comment = ""
    @State var saving = false
    var body: some View {
        HStack {
            if saving {
                Text("One moment…").foregroundColor(.secondary)
            } else {
                // TODO: submit on return, make return key say “Save” or similar
                TextField(placeholder, text: $comment)
                Button("Save") {
                    saving = true
                    AddSpaceCommentMutation(space: spaceId, commentText: comment).perform { result in
                        saving = false
                        guard case .success(let data) = result,
                              let commentId = data.addSpaceComment
                        else { return }
                        let commentText = comment
                        comment = ""
                        onUpdate { newSpace in
                            let ts = dateParser.string(from: Date())
                            newSpace.comments?.append(
                                .init(id: commentId, userid: nil, profile: nil, createdTs: ts, lastModifiedTs: ts, comment: commentText)
                            )
                        }
                    }
                }
                .opacity(comment.isEmpty ? 0 : 1)
                .transition(.opacity)
                .animation(.default)
                .font(Font.body.bold())
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section(header: Text("Sample Comments")) {
                CommentView(spaceId: "", comment: .init(id: "hello", userid: "sapoigj", profile: profile, createdTs: "2020-12-18T15:42:19Z", lastModifiedTs: "2020-12-18T15:42:19Z", comment: "A comment"), userAcl: .comment, onUpdate: { _ in })
                CommentView(spaceId: "", comment: .init(id: "hello", userid: "sapoigj", profile: nil, createdTs: "2020-12-18T15:42:19Z", lastModifiedTs: "2020-12-18T15:42:19Z", comment: "A comment"), userAcl: .owner, onUpdate: { _ in })
                CommentView(spaceId: "", comment: .init(id: "hello", userid: "sapoigj", profile: profile, createdTs: "2021-01-06T18:46:16Z", lastModifiedTs: "2021-01-06T18:56:24Z", comment: "A very very very very very very very very very very very very long comment"), userAcl: nil, onUpdate: { _ in })
            }
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in })
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in }, comment: "Comment text")
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in }, comment: "Comment text", saving: true)
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in }, saving: true)
        }.listStyle(GroupedListStyle())
    }
}
