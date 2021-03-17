import Apollo
import SwiftUI
import Combine

/// Retrieves all spaces the user can view.
class SpaceListController: QueryController<ListSpacesQuery, [SpaceListController.Space]> {
    typealias Space = ListSpacesQuery.Data.ListSpace.Space

    override func reload() {
        self.perform(query: ListSpacesQuery(kind: .all))
    }

    override class func processData(_ data: ListSpacesQuery.Data) -> [Space] {
        data.listSpaces?.space ?? []
    }

    @discardableResult static func getSpaces(
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

/// Retrieves  full information for a single space.
class SpaceController: QueryController<FetchSpaceQuery, SpaceController.Space> {
    typealias Space = FetchSpaceQuery.Data.GetSpace.Space.Space
    typealias Entity = Space.Entity

    let id: String

    /// - Parameters:
    ///   - id: The ID of the space to fetch
    ///   - animation: The animation to perform when the space is fetched or updated.
    init(id: String, animation: Animation? = .default) {
        self.id = id
        super.init(animation: animation)
    }

    override func reload() {
        self.perform(query: FetchSpaceQuery(id: id))
    }

    override class func processData(_ data: FetchSpaceQuery.Data) -> Space {
        // safe to ! here because invalid space IDs will return an error
        data.getSpace!.space.first!.space!
    }

    @discardableResult static func getSpace(
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

// convenience functions that assume `nil` == “no access”
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

/// Updates a space’s metadata
class SpaceUpdater: MutationController<UpdateSpaceMutation, SpaceController.Space> {
    let spaceId: String

    /// - Parameters:
    ///   - spaceId: the ID of the space to update
    ///   - animation: the animation to apply when the entity is added. If `nil`, there will be no animation.
    ///   - onUpdate: see `SpaceLoaderView`
    init(spaceId: String, animation: Animation? = nil, onUpdate: @escaping Updater<SpaceController.Space>, onSuccess: @escaping () -> ()) {
        self.spaceId = spaceId
        super.init(animation: animation, onUpdate: onUpdate, onSuccess: onSuccess)
    }

    /// - Parameter title: the new title of the space
    /// - Parameter description: the new description of the space
    func execute(title: String, description: String) {
        super.execute(mutation: .init(input: .init(id: spaceId, name: title, description: description)))
    }

    override func update(_ newSpace: inout SpaceController.Space, from result: UpdateSpaceMutation.Data, after mutation: UpdateSpaceMutation) {
        if result.updateSpace {
            if let name = mutation.input.name ?? nil {
                newSpace.name = name
            }
            if let description = mutation.input.description ?? nil {
                newSpace.description = description
            }
        }
    }
}
