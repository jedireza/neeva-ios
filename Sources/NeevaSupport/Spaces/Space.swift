import Apollo
import SwiftUI
import Combine

public typealias Space = SpacesQuery.Data.ListSpace.Space

extension Space: Identifiable {
    public var id: String {
        pageMetadata!.pageId!
    }
}

public class SpaceListController: QueryController<SpacesQuery, [Space]> {
    public override init() {
        super.init()
        self.perform(query: SpacesQuery())
    }

    public override class func processData(_ data: SpacesQuery.Data) -> [Space] {
        data.listSpaces?.space ?? []
    }

    @discardableResult public static func getSpaces(
        completion: @escaping (Result<[Space], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: SpacesQuery(), completion: completion)
    }
}
