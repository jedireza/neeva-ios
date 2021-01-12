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
        let canEdit = userAcl >= .comment && profile.userId == comment.userid
        let canRemove = userAcl == .owner || canEdit

        let actions: [Action?] = [
            .edit(condition: canEdit, handler: onEdit),
            .delete(condition: canRemove) { promptingDelete = true }
        ]

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
            if isSaving {
                ActivityIndicator()
            } else if canRemove {
                actions.menu
                    .padding(.trailing, -2)
                    .padding(.top, -3)
                    .actionSheet(isPresented: $promptingDelete) {
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
                    }
            }
        }
        .padding(.top, 2)
        .disabled(isSaving)
        .opacity(isSaving ? 0.5 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(comment.comment ?? "") by \(comment.profile?.displayName ?? "") \(format(comment.createdTs, as: .full) ?? "")")
        .accessibilityActions(actions)
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

func composeComment(in spaceId: String, onUpdate: @escaping Updater<SpaceController.Space>) {
    openTextInputAlert(title: "Add a Comment", confirmationButtonTitle: "Save") { tf in
        tf.placeholder = placeholders.randomElement()!
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .default
        tf.returnKeyType = .done
    } onConfirm: { commentText in
        AddSpaceCommentMutation(space: spaceId, commentText: commentText).perform { result in
            if case .success(let data) = result,
               let commentId = data.addSpaceComment {
                onUpdate { newSpace in
                    let ts = dateParser.string(from: Date())
                    newSpace.comments?.append(
                        .init(id: commentId, userid: nil, profile: nil, createdTs: ts, lastModifiedTs: ts, comment: commentText)
                    )
                }
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
            Button("Add Comment") {
                composeComment(in: "", onUpdate: { _ in })
            }
        }.listStyle(GroupedListStyle())
    }
}
