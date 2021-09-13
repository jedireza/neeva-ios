// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct AddToNativeSpaceOverlaySheetContent: View {
    let space: Space
    let entityID: String?

    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    init(space: Space, entityID: String? = nil) {
        self.space = space
        self.entityID = entityID
    }

    var body: some View {
        AddToNativeSpaceView(space: space, entityID: entityID, dismiss: hideOverlaySheet)
            .overlaySheetIsFixedHeight(isFixedHeight: true)
            .overlaySheetTitle(title: entityID == nil ? "Add item" : "Update item")
    }
}

struct AddToNativeSpaceView: View {
    let space: Space
    let entityID: String?
    let dismiss: () -> Void

    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var titleText: String
    @State var urlText: String

    init(space: Space, entityID: String? = nil, dismiss: @escaping () -> Void) {
        self.space = space
        self.entityID = entityID
        self.dismiss = dismiss
        self.titleText = space.contentData?.first(where: { $0.id == entityID })?.title ?? ""
        self.urlText =
            space.contentData?.first(where: { $0.id == entityID })?.url?.absoluteString ?? ""
    }

    func inputField(title: String, bodytext: String, inputText: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).foregroundColor(.secondaryLabel).withFont(.labelMedium)
            TextField(bodytext, text: inputText)
                .withFont(unkerned: .bodyLarge)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }

    var body: some View {
        GroupedStack {
            inputField(title: "Title", bodytext: "Please provide a title", inputText: $titleText)
            inputField(
                title: "URL", bodytext: "Add a URL to your new item (optional)", inputText: $urlText
            )
            Button(
                action: {
                    if let entityID = entityID {
                        let oldData = (space.contentData?.first(where: { $0.id == entityID }))!
                        let index = (space.contentData?.firstIndex(where: { $0.id == entityID }))!
                        let newData = SpaceEntityData(
                            id: space.id.id,
                            url: oldData.url,
                            title: titleText,
                            snippet: oldData.snippet,
                            thumbnail: oldData.thumbnail)

                        spaceModel.detailedSpace?.space?.contentData?.replaceSubrange(
                            index..<(index + 1), with: [newData])
                        spaceModel.detailedSpace?.updateDetails()
                        spaceModel.updateSpaceEntity(
                            spaceID: space.id.id, entityID: entityID, title: titleText)
                    } else {
                        // construct a local spaceEntityData
                        let data = SpaceEntityData(
                            id: space.id.id,
                            url: URL(string: urlText),
                            title: titleText,
                            snippet: nil,
                            thumbnail: nil)

                        // modify target spaceCardDetail's Data and signal changes
                        spaceModel.detailedSpace?.space?.contentData?.insert(data, at: 0)
                        spaceModel.detailedSpace?.updateDetails()
                        spaceModel.add(spaceID: space.id.id, url: urlText, title: titleText)
                    }
                    dismiss()
                },
                label: {
                    Text(entityID == nil ? "Save" : "Update")
                        .withFont(.labelLarge)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                }
            )
            .buttonStyle(NeevaButtonStyle(.primary))
            .padding(.vertical, 16)
        }
    }
}
