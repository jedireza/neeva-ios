// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct AddToNativeSpaceOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let space: Space
    let entityID: String?

    init(space: Space, entityID: String? = nil) {
        self.space = space
        self.entityID = entityID
    }

    var body: some View {
        AddToNativeSpaceView(space: space, entityID: entityID, dismiss: hideOverlay)
            .overlayIsFixedHeight(isFixedHeight: true)
            .overlayTitle(title: entityID == nil ? "Add item" : "Update item")
    }
}

struct AddToNativeSpaceView: View {
    let space: Space
    let entityID: String?
    let dismiss: () -> Void

    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var descriptionText: String
    @State var titleText: String
    @State var urlText: String

    @available(iOS 15.0, *)
    @FocusState private var isFocused: FieldType?

    private func textEditAccentColor(type: FieldType) -> Color {
        if #available(iOS 15.0, *) {
            if type == isFocused {
                return .ui.adaptive.blue
            } else {
                return .quaternaryLabel
            }
        } else {
            return .quaternaryLabel
        }
    }

    init(space: Space, entityID: String? = nil, dismiss: @escaping () -> Void) {
        self.space = space
        self.entityID = entityID
        self.dismiss = dismiss
        let data = space.contentData?.first(where: { $0.id == entityID })
        self.titleText = data?.title ?? ""
        self.urlText = data?.url?.absoluteString ?? ""
        self.descriptionText = data?.snippet ?? ""
    }

    private func inputField(title: FieldType, bodytext: String, inputText: Binding<String>)
        -> some View
    {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.rawValue)
                .withFont(.headingXSmall)
                .foregroundColor(.secondaryLabel)
            if #available(iOS 15.0, *) {
                TextField(bodytext, text: inputText)
                    .withFont(unkerned: .bodyLarge)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isFocused, equals: title)
                    .accentColor(textEditAccentColor(type: title))
            } else {
                TextField(bodytext, text: inputText)
                    .withFont(unkerned: .bodyLarge)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .roundedOuterBorder(cornerRadius: 12, color: textEditAccentColor(type: title), lineWidth: 1)
    }

    var body: some View {
        GroupedStack {
            if entityID != nil {
                inputField(
                    title: .descriptionField,
                    bodytext: "Please provide a description",
                    inputText: $descriptionText)
            }
            inputField(
                title: .titleField, bodytext: "Please provide a title", inputText: $titleText)
            inputField(
                title: .urlField, bodytext: "Add a URL to your new item (optional)",
                inputText: $urlText
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
                            snippet: descriptionText,
                            thumbnail: oldData.thumbnail)

                        spaceModel.detailedSpace?.space?.contentData?.replaceSubrange(
                            index..<(index + 1), with: [newData])
                        spaceModel.detailedSpace?.updateDetails()
                        spaceModel.updateSpaceEntity(
                            spaceID: space.id.id, entityID: entityID,
                            title: titleText, snippet: descriptionText)
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

    private enum FieldType: String, Hashable {
        case urlField = "URL"
        case titleField = "TITLE"
        case descriptionField = "DESCRIPTION"
    }
}
