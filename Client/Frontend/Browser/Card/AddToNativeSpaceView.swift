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
            .overlayTitle(title: entityID == nil ? "Add item" : "Edit item")
    }
}

private enum FieldType: String, Hashable {
    case urlField = "URL"
    case titleField = "TITLE"
    case descriptionField = "DESCRIPTION"
}

@available(iOS 15.0, *)
private struct iOS15InputField: View {
    @FocusState private var isFocused: FieldType?

    let title: FieldType
    let bodyText: String
    @Binding var inputText: String

    private func textEditAccentColor(type: FieldType) -> Color {
        if type == isFocused {
            return .ui.adaptive.blue
        } else {
            return .quaternaryLabel
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.rawValue)
                .withFont(.headingXSmall)
                .foregroundColor(.secondaryLabel)

            if case .descriptionField = title {
                TextEditor(text: $inputText)
                    .withFont(unkerned: .bodyLarge)
                    .frame(minHeight: 80)
                    .focused($isFocused, equals: title)
                    .accentColor(textEditAccentColor(type: title))
            } else {
                TextField(bodyText, text: $inputText)
                    .withFont(unkerned: .bodyLarge)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isFocused, equals: title)
                    .accentColor(textEditAccentColor(type: title))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .roundedOuterBorder(cornerRadius: 12, color: textEditAccentColor(type: title), lineWidth: 1)
    }
}

private struct LegacyInputField: View {
    let title: FieldType
    let bodyText: String
    @Binding var inputText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.rawValue)
                .withFont(.headingXSmall)
                .foregroundColor(.secondaryLabel)

            TextField(bodyText, text: $inputText)
                .withFont(unkerned: .bodyLarge)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .roundedOuterBorder(cornerRadius: 12, color: .quaternaryLabel, lineWidth: 1)
    }
}

struct AddToNativeSpaceView: View {
    let space: Space
    let entityID: String?
    let dismiss: () -> Void
    let thumbnailModel = CustomThumbnailModel()

    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var descriptionText: String
    @State var titleText: String
    @State var urlText: String

    init(space: Space, entityID: String? = nil, dismiss: @escaping () -> Void) {
        self.space = space
        self.entityID = entityID
        self.dismiss = dismiss
        let data = space.contentData?.first(where: { $0.id == entityID })
        self.titleText = data?.title ?? ""
        self.urlText = data?.url?.absoluteString ?? ""
        self.descriptionText = data?.snippet ?? ""
    }

    private func inputField(title: FieldType, bodyText: String, inputText: Binding<String>)
        -> some View
    {
        Group {
            if #available(iOS 15.0, *) {
                iOS15InputField(title: title, bodyText: bodyText, inputText: inputText)
            } else {
                LegacyInputField(title: title, bodyText: bodyText, inputText: inputText)
            }
        }
    }

    var body: some View {
        GroupedStack {
            inputField(
                title: .titleField, bodyText: "Please provide a title", inputText: $titleText)
            if entityID != nil {
                inputField(
                    title: .descriptionField,
                    bodyText: "Please provide a description",
                    inputText: $descriptionText)
                if let url = URL(string: urlText),
                    let thumbnails = spaceModel.thumbnailURLCandidates[url],
                    thumbnailModel.showing
                {
                    CustomThumbnailPicker(thumbnails: thumbnails, model: thumbnailModel)
                }
            }
            if entityID == nil {
                inputField(
                    title: .urlField, bodyText: "Add a URL to your new item (optional)",
                    inputText: $urlText
                )
            }
            Button(
                action: {
                    if let entityID = entityID {
                        let oldData = (space.contentData?.first(where: { $0.id == entityID }))!
                        let index = (space.contentData?.firstIndex(where: { $0.id == entityID }))!
                        let newData = SpaceEntityData(
                            id: oldData.id,
                            url: oldData.url,
                            title: titleText,
                            snippet: descriptionText,
                            thumbnail: thumbnailModel.selectedData ?? oldData.thumbnail)
                        spaceModel.detailedSpace?.space?.contentData?.replaceSubrange(
                            index..<(index + 1), with: [newData])
                        spaceModel.detailedSpace?.allDetails.replaceSubrange(
                            index..<(index + 1),
                            with: [SpaceEntityThumbnail(data: newData, spaceID: space.id.id)])
                        spaceModel.updateSpaceEntity(
                            spaceID: space.id.id, entityID: entityID,
                            title: titleText, snippet: descriptionText,
                            thumbnail: thumbnailModel.selectedData)
                        thumbnailModel.selectedData = nil
                        thumbnailModel.thumbnailData = [URL: String]()
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
                    Text("Save")
                        .withFont(.labelLarge)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                }
            )
            .buttonStyle(NeevaButtonStyle(.primary))
            .padding(.vertical, 16)
        }.onAppear {
            thumbnailModel.showing = true
        }.onDisappear {
            thumbnailModel.showing = false
        }
    }
}
