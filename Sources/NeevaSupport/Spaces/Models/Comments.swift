//
//  Comments.swift
//  
//
//  Created by Jed Fox on 1/14/21.
//

import SwiftUI
import Apollo

/// Adds a comment to the provided space
class SpaceCommentCreator: MutationController<AddSpaceCommentMutation, SpaceController.Space> {
    let spaceId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space to add comments to
    ///   - animation: the animation to apply when the comment is added. If `nil`, there will be no animation.
    ///   - onUpdate: see `SpaceLoaderView`
    init(spaceId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        super.init(animation: animation, onUpdate: onUpdate)
    }

    /// - Parameter newText: The text to add as a comment
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

/// Deletes the given comment
class SpaceCommentDeleter: MutationController<DeleteSpaceCommentMutation, SpaceController.Space> {
    let spaceId: String
    let commentId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space to delete the comment from
    ///   - commentId: the ID of the comment to delete
    ///   - animation: the animation to apply when the comment is deleted. If `nil`, there will be no animation.
    ///   - onUpdate: see `SpaceLoaderView`
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

/// Edits the given comment
class SpaceCommentUpdater: MutationController<UpdateSpaceCommentMutation, SpaceController.Space> {
    let spaceId: String
    let commentId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space that contains the comment
    ///   - commentId: the ID of the comment to update
    ///   - animation: the animation to apply when the comment is updated. If `nil`, there will be no animation.
    ///   - onUpdate: see `SpaceLoaderView`
    init(spaceId: String, commentId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        self.commentId = commentId
        super.init(animation: animation, onUpdate: onUpdate)
    }

    /// - Parameter commentText: The updated text of the comment
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
