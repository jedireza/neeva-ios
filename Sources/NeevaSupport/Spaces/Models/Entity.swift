import Apollo
import SwiftUI

public class EntityThumbnailController: QueryController<FetchSpaceResultThumbnailsQuery, [EntityThumbnailController.Image]> {
    public typealias Image = FetchSpaceResultThumbnailsQuery.Data.GetSpaceEntityImage.Image

    public let spaceId: String
    public let entityId: String

    public init(spaceId: String, entityId: String, animation: Animation? = .default) {
        self.spaceId = spaceId
        self.entityId = entityId
        super.init(animation: animation)
    }

    public override func reload() {
        self.perform(query: FetchSpaceResultThumbnailsQuery(input: .init(spaceId: spaceId, resultId: entityId)))
    }

    public override class func processData(_ data: FetchSpaceResultThumbnailsQuery.Data) -> [Image] {
        data.getSpaceEntityImages!.images!
    }

    @discardableResult public static func getThumbnails(
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

class SpaceResultCreator: MutationController<AddToSpaceMutation, SpaceController.Space> {
    let spaceId: String

    init(spaceId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>, onSuccess: @escaping () -> ()) {
        self.spaceId = spaceId
        super.init(animation: animation, onUpdate: onUpdate, onSuccess: onSuccess)
    }

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

class SpaceResultUpdater: MutationController<UpdateSpaceResultMutation, SpaceController.Space> {
    let spaceId: String
    let resultId: String

    init(spaceId: String, resultId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>, onSuccess: @escaping () -> ()) {
        self.spaceId = spaceId
        self.resultId = resultId
        super.init(animation: animation, onUpdate: onUpdate, onSuccess: onSuccess)
    }

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

class SpaceResultDeleter: MutationController<BatchDeleteSpaceResultMutation, SpaceController.Space> {
    let spaceId: String

    public init(spaceId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        super.init(animation: animation, onUpdate: onUpdate)
    }

    func execute(deleting entities: [SpaceController.Entity]) {
        execute(mutation: .init(space: spaceId, results: entities.map(\.id)))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: BatchDeleteSpaceResultMutation.Data, after mutation: BatchDeleteSpaceResultMutation) {
        if result.batchDeleteSpaceResult {
            newSpace.entities?.removeAll { mutation.results.contains($0.id) }
        }
    }
}
