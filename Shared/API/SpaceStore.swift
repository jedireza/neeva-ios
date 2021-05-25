// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

struct SpaceID: Hashable {
    let value: String
}

struct Space: Hashable {
    let id: SpaceID
    let name: String
    let lastModifiedTs: String
    let thumbnail: String?
    let resultCount: Int
    let isDefaultSpace: Bool
}

// A store of all spaces data available to the client. Hides details of how the
// data is stored and fetched.
class SpaceStore: ObservableObject {
    static var shared = SpaceStore()

    enum State {
        case ready
        case refreshing
        case failed(Error)
    }

    // The current state of the SpaceStore.
    @Published private(set) var state: State = .ready

    // The current set of spaces.
    private(set) var spaces: [Space] = []

    private var spaceToURLsMap: [SpaceID: [URL]] = [:]
    private var urlToSpacesMap: [URL: [SpaceID]] = [:]

    // Use to query the set of spaces containing the given URL.
    func urlToSpaces(_ url: URL) -> [SpaceID] {
        return urlToSpacesMap[url] ?? []
    }

    // Use to query if |url| is part of the space specified by |spaceId|.
    func urlInSpace(_ url: URL, spaceId: SpaceID) -> Bool {
        return urlToSpaces(url).contains(spaceId)
    }

    // Call to refresh the SpaceStore's copy of spaces data. Ignored if already
    // refreshing.
    func refresh() {
        if case .refreshing = state { return }

        // Grab the map of spaceID to lastModifiedTs before we discard |spaces|.
        // We will use this to validate our cache of URLs once we get the current
        // space list back.
        let lastModifiedTsMap = getLastModifiedTsMap()

        state = .refreshing
        spaces = []
        urlToSpacesMap = [:]

        SpaceListController.getSpaces() { result in
            switch result {
            case .success(let spaces):
                self.onUpdateSpaces(lastModifiedTsMap, spaces)
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }

    private func onUpdateSpaces(_ lastModifiedTsMap: [SpaceID: String], _ spaces: [SpaceListController.Space]) {
        // Build the set of editable spaces:
        for space in spaces {
            if let pageId = space.pageMetadata?.pageId,
               let name = space.space?.name,
               let lastModifiedTs = space.space?.lastModifiedTs,
               space.space?.userAcl?.acl >= .edit {
                self.spaces.append(
                    Space(
                        id: SpaceID(value: pageId),
                        name: name,
                        lastModifiedTs: lastModifiedTs,
                        thumbnail: space.space?.thumbnail,
                        resultCount: space.space?.resultCount ?? 0,
                        isDefaultSpace: space.space?.isDefaultSpace ?? false))
            }
        }

        // Update |spaceToURLsMap| based on |lastModifiedTs|. Note, we avoid parsing
        // |lastModifiedTs| here and instead just use it as an opaque identifier. If
        // the value we have stored from last fetch differs from the current value,
        // then we'll just refetch the URLs for the space. Otherwise, we can use our
        // cached data.
        let existingSpaceToURLsMap = spaceToURLsMap
        spaceToURLsMap = [:]
        var spacesToFetch: [SpaceID] = []
        for space in self.spaces {
            if space.lastModifiedTs == lastModifiedTsMap[space.id] {
                self.onUpdateSpaceURLs(spaceId: space.id, existingSpaceToURLsMap[space.id] ?? [])
            } else {
                spacesToFetch.append(space.id)
            }
        }

        if spacesToFetch.count > 0 {
            let ids: [String] = spacesToFetch.map({ $0.value })
            SpacesDataQueryController.getSpacesData(spaceIds: ids) { result in
                switch result {
                case .success(let spaces):
                    for space in spaces {
                        // Note, we could update the |lastModifiedTs| field here but that's
                        // likely an unnecessary optimization. The window between now and
                        // when ListSpaces returned is short, and the downside of having a
                        // stale |lastModifiedTs| stored in our cache is minor.
                        self.onUpdateSpaceURLs(spaceId: SpaceID(value: space.id), space.urls)
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

    private func onUpdateSpaceURLs(spaceId: SpaceID, _ urls: [URL]) {
        spaceToURLsMap[spaceId] = urls
        for url in urls {
            var spaceIds = urlToSpacesMap[url] ?? []
            spaceIds.append(spaceId)
            urlToSpacesMap[url] = spaceIds
        }
    }

    private func getLastModifiedTsMap() -> [SpaceID: String] {
        var result: [SpaceID: String] = [:]
        for space in spaces {
            result[space.id] = space.lastModifiedTs
        }
        return result
    }
}
