//
//  CommentView.swift
//  
//
//  Created by Jed Fox on 1/6/21.
//

import SwiftUI

struct CommentView: View {
    let comment: SpaceController.Space.Comment
    let userAcl: SpaceACLLevel?

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
            let canEdit = userAcl >= .comment && UserProfileController.shared.userId == comment.userid
            let canRemove = userAcl == .owner || canEdit
            if canRemove {
                Menu {
                    if canEdit {
                        Button(action: {}) {
                            Label("Edit", systemImage: "pencil")
                        }.disabled(true)
                    }
                    Button(action: {}) {
                        Label("Delete", systemImage: "trash")
                    }.disabled(true)
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .contentShape(Rectangle())
                }
            }
        }.padding(.top, 2)
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
                    AddSpaceCommentMutation(space: spaceId, comment: comment).perform { result in
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
                CommentView(comment: .init(id: "hello", userid: "sapoigj", profile: profile, createdTs: "2020-12-18T15:42:19Z", lastModifiedTs: "2020-12-18T15:42:19Z", comment: "A comment"), userAcl: .comment)
                CommentView(comment: .init(id: "hello", userid: "sapoigj", profile: nil, createdTs: "2020-12-18T15:42:19Z", lastModifiedTs: "2020-12-18T15:42:19Z", comment: "A comment"), userAcl: .owner)
                CommentView(comment: .init(id: "hello", userid: "sapoigj", profile: profile, createdTs: "2021-01-06T18:46:16Z", lastModifiedTs: "2021-01-06T18:56:24Z", comment: "A very very very very very very very very very very very very long comment"), userAcl: nil)
            }
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in })
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in }, comment: "Comment text")
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in }, comment: "Comment text", saving: true)
            ComposeCommentView(spaceId: "asdf", onUpdate: { _ in }, saving: true)
        }.listStyle(GroupedListStyle())
    }
}
