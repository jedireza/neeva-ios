// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI

class SpaceContentSheetModel: ObservableObject {
    @Published var selectedTab: Tab?
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

    init(tabManager: TabManager) {
        self.selectedTab = tabManager.selectedTab

        if let spaceID = tabManager.selectedTab?.parentSpaceID {
            self.currentSpaceEntityDetail = SpaceEntityThumbnail(
                data: (SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID })!
                    .contentData?.first(where: { $0.url == tabManager.selectedTab?.url }))!,
                spaceID: spaceID)
            self.comments =
                SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID })?.comments ?? []
            self.addedComments = []
        } else {
            self.currentSpaceEntityDetail = nil
            self.comments = []
        }
        tabManager.selectedTabPublisher.compactMap { $0 }.sink { tab in
            self.selectedTab = tab

            if !self.addedComments.isEmpty {
                SpaceStore.shared.refresh()
                self.addedComments = []
            }

            if let spaceID = tab.parentSpaceID,
                let data =
                    SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID })!
                    .contentData?.first(where: { $0.url == self.selectedTab?.url })
            {
                self.currentSpaceEntityDetail = SpaceEntityThumbnail(data: data, spaceID: spaceID)
                self.comments =
                    SpaceStore.shared.allSpaces.first(where: { $0.id.id == spaceID })?.comments
                    ?? []
            } else {
                self.currentSpaceEntityDetail = nil
                self.comments = []
            }
        }.store(in: &subscriptions)
    }
}
