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

    @State var promptingDelete = false
    @ObservedObject var profile = UserProfileController.shared

    @StateObject var deleter: SpaceCommentDeleter
    @StateObject var updater: SpaceCommentUpdater

    init(
        spaceId: String,
        comment: SpaceController.Space.Comment,
        userAcl: SpaceACLLevel?,
        onUpdate: @escaping Updater<SpaceController.Space>
    ) {
        self.spaceId = spaceId
        self.comment = comment
        self.userAcl = userAcl
        self._deleter = .init(wrappedValue: .init(spaceId: spaceId, commentId: comment.id!, onUpdate: onUpdate))
        self._updater = .init(wrappedValue: .init(spaceId: spaceId, commentId: comment.id!, onUpdate: onUpdate))
    }

    var body: some View {
        let canEdit = userAcl >= .comment && profile.userId == comment.userid
        let canRemove = userAcl == .owner || canEdit
        let isSaving = deleter.isRunning

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
                                .destructive(Text("Delete")) { deleter.execute() },
                                .cancel()
                            ]
                        )
                    }
            }
        }
        .padding(.top, 2)
        .disabled(isSaving)
        .opacity(isSaving  ? 0.5 : 1)
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
            },
            onConfirm: updater.execute
        )
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
        }.listStyle(GroupedListStyle())
    }
}
