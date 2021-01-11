import Apollo
import SwiftUI
import Combine

public class SpaceListController: QueryController<ListSpacesQuery, [SpaceListController.Space]> {
    public typealias Space = ListSpacesQuery.Data.ListSpace.Space

    public override func reload() {
        self.perform(query: ListSpacesQuery(kind: .all))
    }

    public override class func processData(_ data: ListSpacesQuery.Data) -> [Space] {
        data.listSpaces?.space ?? []
    }

    @discardableResult public static func getSpaces(
        completion: @escaping (Result<[Space], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: ListSpacesQuery(kind: .all), completion: completion)
    }
}

extension SpaceListController.Space: Identifiable {
    public var id: String {
        pageMetadata!.pageId!
    }
}

public class SpaceController: QueryController<FetchSpaceQuery, SpaceController.Space> {
    public typealias Space = FetchSpaceQuery.Data.GetSpace.Space.Space
    public typealias Entity = Space.Entity

    public let id: String

    public init(id: String, animation: Animation? = .default) {
        self.id = id
        super.init(animation: animation)
    }

    public override func reload() {
        self.perform(query: FetchSpaceQuery(id: id))
    }

    public override class func processData(_ data: FetchSpaceQuery.Data) -> Space {
        // safe to ! here because invalid space IDs will return an error
        data.getSpace!.space.first!.space!
    }

    @discardableResult public static func getSpace(
        id: String,
        completion: @escaping (Result<Space, Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: FetchSpaceQuery(id: id), completion: completion)
    }
}

extension SpaceController.Space.Entity: Identifiable {
    public var id: String { metadata!.docId! }
}
extension SpaceController.Space.Acl: Identifiable {
    public var id: String { userId }
}
extension SpaceController.Space.Comment: Identifiable {}

extension SpaceController.Space {
    public var isDefault: Bool { isDefaultSpace ?? false }
}

extension SpaceACLLevel: Comparable {
    public static func < (_ lhs: SpaceACLLevel, _ rhs: SpaceACLLevel) -> Bool {
        switch lhs {
        case .owner:
            return false
        case .edit:
            return rhs == .owner
        case .comment:
            return rhs == .owner || rhs == .edit
        case .view, .publicView:
            return rhs == .owner || rhs == .edit || rhs == .comment
        case .__unknown(let rawValue):
            fatalError("Cannot compare unknown ACL level \(rawValue)")
        }
    }
}

public func >= (_ lhs: SpaceACLLevel?, _ rhs: SpaceACLLevel) -> Bool {
    if let lhs = lhs {
        return lhs >= rhs
    } else {
        return false
    }
}
public func < (_ lhs: SpaceACLLevel?, _ rhs: SpaceACLLevel) -> Bool {
    !(lhs >= rhs)
}
