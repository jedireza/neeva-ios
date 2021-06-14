// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

public struct SpaceID: Hashable, Identifiable {
    let value: String

    public var id: String { value }
}

public class Space: Hashable, Identifiable {
    public let id: SpaceID
    public let name: String
    public let lastModifiedTs: String
    public let thumbnail: String?
    public let resultCount: Int
    public let isDefaultSpace: Bool
    public let isShared: Bool
    public let isPublic: Bool
    public let userACL: SpaceACLLevel

    init(id: SpaceID, name: String, lastModifiedTs: String, thumbnail: String?, resultCount: Int, isDefaultSpace: Bool, isShared: Bool, isPublic: Bool, userACL: SpaceACLLevel) {
        self.id = id
        self.name = name
        self.lastModifiedTs = lastModifiedTs
        self.thumbnail = thumbnail
        self.resultCount = resultCount
        self.isDefaultSpace = isDefaultSpace
        self.isShared = isShared
        self.isPublic = isPublic
        self.userACL = userACL
    }

    public var url: URL {
        NeevaConstants.appSpacesURL / id.value
    }

    public var contentURLs: Set<URL>?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(lastModifiedTs)
    }
    public static func == (lhs: Space, rhs: Space) -> Bool {
        lhs.id == rhs.id && lhs.lastModifiedTs == rhs.lastModifiedTs
    }
}

// A store of all spaces data available to the client. Hides details of how the
// data is stored and fetched.
public class SpaceStore: ObservableObject {
    public static var shared = SpaceStore()

    public static func createMock(_ spaces: [Space]) -> SpaceStore {
        let mock = SpaceStore()
        mock.allSpaces = spaces
        mock.disableRefresh = true
        return mock
    }

    public enum State {
        case ready
        case refreshing
        case failed(Error)
    }

    /// The current state of the `SpaceStore`.
    @Published public private(set) var state: State = .ready

    /// The current set of spaces.
    @Published public private(set) var allSpaces: [Space] = []
    /// The current set of editable spaces.
    public var editableSpaces: [Space]  {
        allSpaces.filter { $0.userACL >= .edit }
    }

    private var disableRefresh = false

    private var urlToSpacesMap: [URL: [Space]] = [:]

    /// Use to query the set of spaces containing the given URL.
    func urlToSpaces(_ url: URL) -> [Space] {
        return urlToSpacesMap[url] ?? []
    }

    /// Use to query if `url` is part of the space specified by `spaceId`
    func urlInSpace(_ url: URL, spaceId: SpaceID) -> Bool {
        return urlToSpaces(url).contains { $0.id == spaceId }
    }

    /// Call to refresh the SpaceStore's copy of spaces data. Ignored if already refreshing.
    public func refresh() {
        if case .refreshing = state { return }
        if disableRefresh { return }

        state = .refreshing
        SpaceListController.getSpaces() { result in
            switch result {
            case .success(let spaces):
                self.onUpdateSpaces(spaces)
            case .failure(let error):
                self.allSpaces = []
                self.urlToSpacesMap = [:]
                self.state = .failed(error)
            }
        }
    }

    private func onUpdateSpaces(_ spaces: [SpaceListController.Space]) {
        let oldSpaceMap: [SpaceID: Space] = Dictionary(uniqueKeysWithValues: allSpaces.map { ($0.id, $0) })

        var spacesToFetch: [Space] = []

        var allSpaces = [Space]()
        // Build the set of spaces:
        for space in spaces {
            if let pageId = space.pageMetadata?.pageId,
               let space = space.space,
               let name = space.name,
               let lastModifiedTs = space.lastModifiedTs,
               let userAcl = space.userAcl?.acl {
                let spaceId = SpaceID(value: pageId)
                let newSpace = Space(
                    id: spaceId,
                    name: name,
                    lastModifiedTs: lastModifiedTs,
                    thumbnail: space.thumbnail ?? nil,
                    resultCount: space.resultCount ?? 0,
                    isDefaultSpace: space.isDefaultSpace ?? false,
                    isShared: !(space.acl?.map(\.userId).filter { $0 != NeevaUserInfo.shared.id }.isEmpty ?? true),
                    isPublic: space.hasPublicAcl ?? false,
                    userACL: userAcl
                )

                /// Note, we avoid parsing `lastModifiedTs` here and instead just use it as
                /// an opaque identifier. If the value we have stored from last fetch differs
                /// from the current value, then we'll just refetch the URLs for the space.
                /// Otherwise, we can use our cached data.
                if let oldSpace = oldSpaceMap[spaceId],
                   let contentURLs = oldSpace.contentURLs,
                   space.lastModifiedTs == oldSpace.lastModifiedTs {
                    self.onUpdateSpaceURLs(space: newSpace, contentURLs)
                } else {
                    spacesToFetch.append(newSpace)
                }

                allSpaces.append(newSpace)
            }
        }
        self.allSpaces = allSpaces

        if spacesToFetch.count > 0 {
            SpacesDataQueryController.getSpacesData(spaceIds: spacesToFetch.map(\.id.value)) { result in
                switch result {
                case .success(let spaces):
                    for space in spaces {
                        /// Note, we could update the `lastModifiedTs` field here but that's
                        /// likely an unnecessary optimization. The window between now and
                        /// when ListSpaces returned is short, and the downside of having a
                        /// stale `lastModifiedTs` stored in our cache is minor.
                        self.onUpdateSpaceURLs(space: spacesToFetch.first { $0.id.value == space.id }!, Set(space.urls))
                    }
                    self.state = .ready
                case .failure(let error):
                    self.state = .failed(error)
                }
            }
        } else {
            self.state = .ready
        }
    }

    private func onUpdateSpaceURLs(space: Space, _ urls: Set<URL>) {
        space.contentURLs = urls
        for url in urls {
            var spaces = urlToSpacesMap[url] ?? []
            spaces.append(space)
            urlToSpacesMap[url] = spaces
        }
    }
}
