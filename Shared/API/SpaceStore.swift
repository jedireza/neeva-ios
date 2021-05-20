// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

struct SpaceID: Hashable {
    let value: String
}

struct Space: Hashable {
    let id: SpaceID
    let name: String
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

        state = .refreshing
        spaces = []
        urlToSpacesMap = [:]

        SpaceListController.getSpaces() { result in
            switch result {
            case .success(let spaces):
                self.onUpdateSpaces(spaces)
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }

    private func onUpdateSpaces(_ spaces: [SpaceListController.Space]) {
        // Build the set of editable spaces:
        for space in spaces {
            if let pageId = space.pageMetadata?.pageId,
               let name = space.space?.name,
               space.space?.userAcl?.acl >= .edit {
                self.spaces.append(
                    Space(
                        id: SpaceID(value: pageId),
                        name: name,
                        thumbnail: space.space?.thumbnail,
                        resultCount: space.space?.resultCount ?? 0,
                        isDefaultSpace: space.space?.isDefaultSpace ?? false))
            }
        }

        // For each spaces, query the set of URLs contained in that space.
        // TODO(darin): This fan-out of network queries will be avoided
        // once we have support for making batch queries of spaces data.
        var pendingCount = 0
        for space in self.spaces {
            // No need to query empty spaces.
            if space.resultCount == 0 {
                continue
            }
            pendingCount += 1
            SpaceURLsQueryController.getURLs(spaceId: space.id.value) { result in
                switch result {
                case .success(let urls):
                    self.onUpdateSpaceURLs(spaceId: space.id, urls)
                case .failure(let error):
                    self.state = .failed(error)
                }
                pendingCount -= 1
                if pendingCount == 0 {
                    if case .refreshing = self.state {
                        self.state = .ready
                    }
                }
            }
        }
        // If we didn't generate any queries, then we are done.
        if pendingCount == 0 {
            self.state = .ready
        }
    }

    private func onUpdateSpaceURLs(spaceId: SpaceID, _ urls: [URL]) {
        for url in urls {
            var spaceIds = urlToSpacesMap[url] ?? []
            spaceIds.append(spaceId)
            urlToSpacesMap[url] = spaceIds
        }
    }
}
