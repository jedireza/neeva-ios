// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

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

/// Retrieves all URLs for a space
class SpaceURLsQueryController: QueryController<GetSpaceUrLsQuery, [URL]> {
    private var spaceId: String

    public init(spaceId: String) {
        self.spaceId = spaceId
        super.init()
    }

    override func reload() {
        self.perform(query: GetSpaceUrLsQuery(id: spaceId))
    }

    override class func processData(_ data: GetSpaceUrLsQuery.Data) -> [URL] {
        var urls: [URL] = []
        if let spaces = data.getSpace?.space, spaces.count == 1, let entities = spaces[0].space?.entities {
            for entity in entities {
                if let urlString = entity.spaceEntity?.url {
                    if let url = URL(string: urlString) {
                        urls.append(url)
                    }
                }
            }
        }
        return urls
    }

    @discardableResult static func getURLs(
        spaceId: String,
        completion: @escaping (Result<[URL], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: GetSpaceUrLsQuery(id: spaceId), completion: completion)
    }
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
