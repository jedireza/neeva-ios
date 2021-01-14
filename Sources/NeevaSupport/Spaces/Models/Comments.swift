//
//  Comments.swift
//  
//
//  Created by Jed Fox on 1/14/21.
//

import SwiftUI
import Apollo

class SpaceCommentCreator: MutationController<AddSpaceCommentMutation, SpaceController.Space> {
    let spaceId: String

    init(spaceId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        super.init(animation: animation, onUpdate: onUpdate)
    }

    func execute(_ newText: String) {
        super.execute(mutation: .init(space: spaceId, commentText: newText))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: AddSpaceCommentMutation.Data, after mutation: AddSpaceCommentMutation) {
        if let commentId = result.addSpaceComment {
            let ts = dateParser.string(from: Date())
            newSpace.comments?.append(
                .init(id: commentId, userid: nil, profile: nil, createdTs: ts, lastModifiedTs: ts, comment: mutation.commentText)
            )
        }
    }
}

class SpaceCommentDeleter: MutationController<DeleteSpaceCommentMutation, SpaceController.Space> {
    let spaceId: String
    let commentId: String

    init(spaceId: String, commentId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        self.commentId = commentId
        super.init(animation: animation, onUpdate: onUpdate)
    }

    func execute() {
        super.execute(mutation: .init(space: spaceId, comment: commentId))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: DeleteSpaceCommentMutation.Data, after mutation: DeleteSpaceCommentMutation) {
        if result.deleteSpaceComment ?? false {
            newSpace.comments?.removeAll(where: { $0.id == commentId })
        }
    }
}

class SpaceCommentUpdater: MutationController<UpdateSpaceCommentMutation, SpaceController.Space> {
    let spaceId: String
    let commentId: String

    init(spaceId: String, commentId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        self.commentId = commentId
        super.init(animation: animation, onUpdate: onUpdate)
    }

    func execute(_ commentText: String) {
        super.execute(mutation: .init(space: spaceId, comment: commentId, commentText: commentText))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: UpdateSpaceCommentMutation.Data, after mutation: UpdateSpaceCommentMutation) {
        if result.updateSpaceComment ?? false {
            if let idx = newSpace.comments?.firstIndex(where: { $0.id == commentId }) {
                newSpace.comments![idx].comment = mutation.commentText
            }
        }
    }
}
