import Apollo
import SwiftUI

/// Retrieves the thumbnails attached to a given entity
class EntityThumbnailController: QueryController<FetchSpaceResultThumbnailsQuery, [EntityThumbnailController.Image]> {
    typealias Image = FetchSpaceResultThumbnailsQuery.Data.GetSpaceEntityImage.Image

    let spaceId: String
    let entityId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space that contains the entity
    ///   - entityId: the ID of the entity to retrieve thumbnails for
    ///   - animation: the animation to apply when the thumbnails are updated. If `nil`, there will be no animation.
    init(spaceId: String, entityId: String, animation: Animation? = nil) {
        self.spaceId = spaceId
        self.entityId = entityId
        super.init(animation: animation)
    }

    override func reload() {
        self.perform(query: FetchSpaceResultThumbnailsQuery(input: .init(spaceId: spaceId, resultId: entityId)))
    }

    override class func processData(_ data: FetchSpaceResultThumbnailsQuery.Data) -> [Image] {
        data.getSpaceEntityImages!.images!
    }

    @discardableResult static func getThumbnails(
        spaceId: String,
        entityId: String,
        completion: @escaping (Result<[Image], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: FetchSpaceResultThumbnailsQuery(input: .init(spaceId: spaceId, resultId: entityId)), completion: completion)
    }
}
extension EntityThumbnailController.Image: Identifiable {
    public var id: String { imageUrl! }
}

/// Adds a space result/entity to the given space
class SpaceResultCreator: MutationController<AddToSpaceMutation, SpaceController.Space> {
    let spaceId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space to add entities to
    ///   - animation: the animation to apply when the entity is added. If `nil`, there will be no animation.
    ///   - onUpdate: see `SpaceLoaderView`
    init(spaceId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>, onSuccess: @escaping () -> ()) {
        self.spaceId = spaceId
        super.init(animation: animation, onUpdate: onUpdate, onSuccess: onSuccess)
    }

    /// - Parameters:
    ///   - title: the title of the entity to add
    ///   - url: the URL of the entity to add
    func execute(title: String, url: String) {
        super.execute(mutation: .init(input: .init(spaceId: spaceId, url: url, title: title)))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: AddToSpaceMutation.Data, after mutation: AddToSpaceMutation) {
        newSpace.entities?.insert(.init(
            metadata: .init(docId: result.entityId),
            spaceEntity: .init(url: mutation.input.url, title: mutation.input.title)
        ), at: 0)
    }
}

/// Updates a space result/entity
class SpaceResultUpdater: MutationController<UpdateSpaceResultMutation, SpaceController.Space> {
    let spaceId: String
    let resultId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space that contains the entity
    ///   - entityId: the ID of the entity to edit
    ///   - animation: the animation to apply when the entity is updated. If `nil`, there will be no animation.
    ///   - onUpdate: see `SpaceLoaderView`
    init(spaceId: String, resultId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>, onSuccess: @escaping () -> ()) {
        self.spaceId = spaceId
        self.resultId = resultId
        super.init(animation: animation, onUpdate: onUpdate, onSuccess: onSuccess)
    }

    /// - Parameters:
    ///   - title: the updated title of the entity
    ///   - snippet: the updated snippet/description of the entity
    ///   - thumbnail: the updated thumbnail URI of the entity
    func execute(title: String, snippet: String, thumbnail: String) {
        super.execute(mutation: .init(input: .init(spaceId: spaceId, resultId: resultId, title: title, snippet: snippet, thumbnail: thumbnail)))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: UpdateSpaceResultMutation.Data, after mutation: UpdateSpaceResultMutation) {
        if result.updateSpaceEntityDisplayData ?? false {
            if let idx = newSpace.entities?.firstIndex(where: { $0.id == resultId }) {
                var newEntity = newSpace.entities![idx]
                if let title = mutation.input.title ?? nil {
                    newEntity.spaceEntity?.title = title
                }
                if let snippet = mutation.input.snippet ?? nil {
                    newEntity.spaceEntity?.snippet = snippet
                }
                if let thumbnail = mutation.input.thumbnail ?? nil {
                    newEntity.spaceEntity?.thumbnail = thumbnail
                }
                newSpace.entities!.replaceSubrange(idx...idx, with: [newEntity])
            }
        }
    }
}

/// Deletes a space result/entity
class SpaceResultDeleter: MutationController<BatchDeleteSpaceResultMutation, SpaceController.Space> {
    let spaceId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space that contains the entities to delete
    ///   - animation: the animation to apply when the entity is deleted. If `nil`, there will be no animation.
    ///   - onUpdate: see `SpaceLoaderView`
    init(spaceId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        super.init(animation: animation, onUpdate: onUpdate)
    }

    /// - Parameter entities: The entities to delete.
    func execute(deleting entities: [SpaceController.Entity]) {
        execute(mutation: .init(space: spaceId, results: entities.map(\.id)))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: BatchDeleteSpaceResultMutation.Data, after mutation: BatchDeleteSpaceResultMutation) {
        if result.batchDeleteSpaceResult {
            newSpace.entities?.removeAll { mutation.results.contains($0.id) }
        }
    }
}
