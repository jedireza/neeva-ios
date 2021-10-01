// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

public struct SpaceID: Hashable, Identifiable {
    let value: String

    public var id: String { value }
}

public struct SpaceCommentData {
    public typealias Profile = GetSpacesDataQuery.Data.GetSpace.Space.Space.Comment.Profile
    public let id: String
    public let profile: Profile
    public let createdTs: String
    public let comment: String

    public init(id: String, profile: Profile, createdTs: String, comment: String) {
        self.id = id
        self.profile = profile
        self.createdTs = createdTs
        self.comment = comment
    }

    public var formattedRelativeTime: String {
        let originalDateFormatter = DateFormatter()
        originalDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        originalDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let convertedDate = originalDateFormatter.date(from: createdTs)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeDate = formatter.localizedString(for: convertedDate!, relativeTo: Date())
        return relativeDate
    }
}

public struct SpaceEntityData {
    public let id: String
    public let url: URL?
    public let title: String?
    public let snippet: String?
    public let thumbnail: String?

    public init(id: String, url: URL?, title: String?, snippet: String?, thumbnail: String?) {
        self.id = id
        self.url = url
        self.title = title
        self.snippet = snippet
        self.thumbnail = thumbnail
    }
}

public class Space: Hashable, Identifiable {
    public typealias Acl = ListSpacesQuery.Data.ListSpace.Space.Space.Acl
    public let id: SpaceID
    public var name: String
    public let lastModifiedTs: String
    public let thumbnail: String?
    public let resultCount: Int
    public let isDefaultSpace: Bool
    public var isShared: Bool
    public var isPublic: Bool
    public let userACL: SpaceACLLevel
    public let acls: [Acl]

    init(
        id: SpaceID, name: String, lastModifiedTs: String, thumbnail: String?, resultCount: Int,
        isDefaultSpace: Bool, isShared: Bool, isPublic: Bool, userACL: SpaceACLLevel,
        acls: [Acl] = []
    ) {
        self.id = id
        self.name = name
        self.lastModifiedTs = lastModifiedTs
        self.thumbnail = thumbnail
        self.resultCount = resultCount
        self.isDefaultSpace = isDefaultSpace
        self.isShared = isShared
        self.isPublic = isPublic
        self.userACL = userACL
        self.acls = acls
    }

    public var url: URL {
        NeevaConstants.appSpacesURL / id.value
    }

    public var urlWithAddedItem: URL {
        url.withQueryParam("hid", value: contentData?.first?.id ?? "")
    }

    public var contentURLs: Set<URL>?
    public var contentData: [SpaceEntityData]?
    public var comments: [SpaceCommentData]?

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
    public static var suggested = SpaceStore(
        suggestedIDs: FeatureFlag[.recommendedSpaces]
            ? [
                // From neeva.com/community
                "AvTLrA0-XxVpTsesZx_gRcDBxl4SE9tY6pgF9eNh",
                "XYJHMw5ptIlAot-1yln1MdLgSOoRsGzn1-b2C3GE",
                "F5saVvevP299zjEbkh3ZsmzL8SsMERGPtHU7JWkI",
                "Ok-XsoNeDNzu0uV6ziFFJ-XxH0oGAquIyxPhaweF",
                "WiF8e6LomHAnUNTudwzpCZ0i3dHsTtiaP14F6FcA",
                "v8JNVLpV2V_tRshYe87ZXoF2NfkVaMyDKaQImveS",
                "bG6jT2pnzrmdINzh9vY77wacBjawGfnUlc_V6D1P",
                "VSg5lqugMVgpyXiCDoQsuEBXbqrwYydDJkOMVSy9",
                "MwC3dgk3bbVSmB_AGPL0RHMkt-_Ejn5yjOV3sLTF",
                "Zt0o4Sj_7va3Uakw2V-n6MZ5YY6sVdLSRNcQkNSq",
                "wb6aqCBubAs9GHAZuq6ycBdzK38DdxpU5PAP9wWC",
                "brt5oi5afuen3lbh1ij0",
                "qyAaEMBS-1AZE_3RI-jnlAao6OvbbtT4e294zDM5",
                "zxrsTxErt66ZvoTG5FBEKG8yHiqiCpfpA4XWybrn",
                "P18WZHuqEJDnf7llLgmyOIhiLpwF-gLl3OlhT6sh",
                "brogg3ipmtasecqj230g",
            ] : [])

    private var suggestedSpaceIDs: [String]? = nil

    public init(suggestedIDs: [String]? = nil) {
        self.suggestedSpaceIDs = suggestedIDs
    }

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
    public var editableSpaces: [Space] {
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
        if let _ = suggestedSpaceIDs {
            fetchSuggestedSpaces()
            return
        }
        SpaceListController.getSpaces { result in
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

    private func fetchSuggestedSpaces() {
        guard let ids = suggestedSpaceIDs else {
            return
        }

        GraphQLAPI.shared.isAnonymous = true
        SpacesDataQueryController.getSpacesData(spaceIds: ids) { result in
            switch result {
            case .success(let spaces):
                for space in spaces {
                    let fetchedSpace = Space(
                        id: SpaceID(value: space.id), name: space.name, lastModifiedTs: "",
                        thumbnail: nil, resultCount: space.entities.count, isDefaultSpace: false,
                        isShared: false, isPublic: true, userACL: .publicView)
                    self.allSpaces.append(fetchedSpace)
                    self.onUpdateSpaceURLs(
                        space: fetchedSpace,
                        urls: Set(
                            space.entities.filter { $0.url != nil }.reduce(into: [URL]()) {
                                $0.append($1.url!)
                            }),
                        data: space.entities,
                        comments: space.comments)
                }
                self.state = .ready
            case .failure(let error):
                self.state = .failed(error)
            }
        }
        GraphQLAPI.shared.isAnonymous = false
    }

    public static func onRecommendedSpaceSelected(space: Space) {
        shared.allSpaces.append(space)
        SpacesDataQueryController.getSpacesData(spaceIds: [space.id.id]) { result in
            switch result {
            case .success:
                Logger.browser.info("Space followed")
            case .failure(let error):
                Logger.browser.error(error.localizedDescription)
            }
        }
    }

    private func onUpdateSpaces(_ spaces: [SpaceListController.Space]) {
        let oldSpaceMap: [SpaceID: Space] = Dictionary(
            uniqueKeysWithValues: allSpaces.map { ($0.id, $0) })

        // Clear to avoid holding stale data. Will be rebuilt below.
        urlToSpacesMap = [:]

        var spacesToFetch: [Space] = []

        var allSpaces = [Space]()
        // Build the set of spaces:
        for space in spaces {
            if let pageId = space.pageMetadata?.pageId,
                let space = space.space,
                let name = space.name,
                let lastModifiedTs = space.lastModifiedTs,
                let userAcl = space.userAcl?.acl
            {
                let spaceId = SpaceID(value: pageId)
                let newSpace = Space(
                    id: spaceId,
                    name: name,
                    lastModifiedTs: lastModifiedTs,
                    thumbnail: space.thumbnail ?? nil,
                    resultCount: space.resultCount ?? 0,
                    isDefaultSpace: space.isDefaultSpace ?? false,
                    isShared:
                        !(space.acl?.map(\.userId).filter { $0 != NeevaUserInfo.shared.id }.isEmpty
                        ?? true),
                    isPublic: space.hasPublicAcl ?? false,
                    userACL: userAcl,
                    acls: space.acl ?? []
                )

                /// Note, we avoid parsing `lastModifiedTs` here and instead just use it as
                /// an opaque identifier. If the value we have stored from last fetch differs
                /// from the current value, then we'll just refetch the URLs for the space.
                /// Otherwise, we can use our cached data.
                if let oldSpace = oldSpaceMap[spaceId],
                    let contentURLs = oldSpace.contentURLs,
                    let contentData = oldSpace.contentData,
                    let comments = oldSpace.comments,
                    space.lastModifiedTs == oldSpace.lastModifiedTs
                {
                    self.onUpdateSpaceURLs(
                        space: newSpace,
                        urls: contentURLs,
                        data: contentData,
                        comments: comments)
                } else {
                    spacesToFetch.append(newSpace)
                }

                allSpaces.append(newSpace)
            }
        }
        self.allSpaces = allSpaces

        if spacesToFetch.count > 0 {
            SpacesDataQueryController.getSpacesData(spaceIds: spacesToFetch.map(\.id.value)) {
                result in
                switch result {
                case .success(let spaces):
                    for space in spaces {
                        /// Note, we could update the `lastModifiedTs` field here but that's
                        /// likely an unnecessary optimization. The window between now and
                        /// when ListSpaces returned is short, and the downside of having a
                        /// stale `lastModifiedTs` stored in our cache is minor.

                        self.onUpdateSpaceURLs(
                            space: spacesToFetch.first { $0.id.value == space.id }!,
                            urls: Set(
                                space.entities.filter { $0.url != nil }.reduce(into: [URL]()) {
                                    $0.append($1.url!)
                                }),
                            data: space.entities,
                            comments: space.comments)
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

    private func onUpdateSpaceURLs(
        space: Space, urls: Set<URL>, data: [SpaceEntityData], comments: [SpaceCommentData]
    ) {
        space.contentURLs = urls
        space.contentData = data
        space.comments = comments
        for url in urls {
            var spaces = urlToSpacesMap[url] ?? []
            spaces.append(space)
            urlToSpacesMap[url] = spaces
        }
    }
}
