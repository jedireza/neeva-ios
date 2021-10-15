// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI

class SpaceContentSheetModel: ObservableObject {
    @Published var selectedTab: Tab?
    @Published var currentSpaceDetail: SpaceCardDetails?
    @Published var currentSpaceEntityDetail: SpaceEntityThumbnail?
    @Published var comments: [SpaceCommentData]
    @Published var addedComments: [SpaceCommentData] = []
    @Published var commentAdded: String = ""
    @Published var addingComment: Bool = false {
        didSet {
            if !addingComment && !commentAdded.isEmpty {
                let originalDateFormatter = DateFormatter()
                originalDateFormatter.locale = Locale(
                    identifier: "en_US_POSIX")
                originalDateFormatter.dateFormat =
                    "yyyy-MM-dd'T'HH:mm:ssZ"
                let convertedDate = originalDateFormatter.string(
                    from: Date())
                addedComments.append(
                    SpaceCommentData(
                        id: UUID().uuidString,
                        profile: SpaceCommentData.Profile(
                            displayName: NeevaUserInfo.shared
                                .displayName!,
                            pictureUrl: NeevaUserInfo.shared.pictureUrl
                                ?? ""),
                        createdTs: convertedDate, comment: commentAdded)
                )
                AddSpaceCommentRequest(
                    spaceID: (selectedTab?.parentSpaceID)!, comment: commentAdded)
                commentAdded = ""
            }
        }
    }
    private var subscriptions = Set<AnyCancellable>()
    private var urlSubscription: AnyCancellable? = nil
    private var spaceModel: SpaceCardModel

    init(tabManager: TabManager, spaceModel: SpaceCardModel) {
        self.selectedTab = tabManager.selectedTab
        self.spaceModel = spaceModel

        if let spaceID = tabManager.selectedTab?.parentSpaceID, !spaceID.isEmpty,
            let space = SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID })
        {
            self.currentSpaceDetail = self.spaceModel.allDetails.first(where: {
                $0.id == tabManager.selectedTab?.parentSpaceID
            })
            self.currentSpaceEntityDetail = SpaceEntityThumbnail(
                data: (space.contentData?.first(where: { $0.url == tabManager.selectedTab?.url }))!,
                spaceID: spaceID)
            self.comments =
                SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID })?.comments ?? []
            self.addedComments = []
        } else {
            self.currentSpaceDetail = nil
            self.currentSpaceEntityDetail = nil
            self.comments = []
        }

        self.urlSubscription = tabManager.selectedTab?.$url.sink { [weak self] _ in
            self?.update()
        }

        tabManager.selectedTabPublisher.compactMap { $0 }.sink { tab in
            self.selectedTab = tab

            if !self.addedComments.isEmpty {
                if let spaceID = self.currentSpaceEntityDetail?.spaceID {
                    SpaceStore.shared.refreshSpace(spaceID: spaceID)
                }
                self.addedComments = []
            }

            self.update()

            self.urlSubscription = tab.$url.sink { _ in
                self.update()
            }
        }.store(in: &subscriptions)
    }

    func update() {
        var currentURL = self.selectedTab?.url
        if let internalURL = InternalURL(currentURL), internalURL.isSessionRestore {
            currentURL = URL(string: currentURL?.getQuery()["url"] ?? "")
        }

        if let spaceID = self.selectedTab?.parentSpaceID, !spaceID.isEmpty,
            let space = SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID }),
            let url = currentURL,
            let data = space.contentData?.first(where: { $0.url == url })
        {
            self.currentSpaceDetail = self.spaceModel.allDetails.first(where: {
                $0.id == spaceID
            })
            self.currentSpaceEntityDetail = SpaceEntityThumbnail(data: data, spaceID: spaceID)
            self.comments =
                SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID })?.comments
                ?? []
        } else {
            self.currentSpaceDetail = nil
            self.currentSpaceEntityDetail = nil
            self.comments = []
        }
    }
}
