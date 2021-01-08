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
