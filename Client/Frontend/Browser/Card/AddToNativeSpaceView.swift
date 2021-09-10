// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct AddToNativeSpaceOverlaySheetContent: View {
    let space: Space
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    var body: some View {
        AddToNativeSpaceView(space: space, dismiss: hideOverlaySheet)
            .overlaySheetIsFixedHeight(isFixedHeight: true)
    }
}

struct AddToNativeSpaceView: View {
    let space: Space
    let dismiss: () -> Void

    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var titleText: String = ""
    @State var urlText: String = ""

    init(space: Space, dismiss: @escaping () -> Void) {
        self.space = space
        self.dismiss = dismiss
        // Do we need to know if this space is public?
    }

    var header: some View {
        HStack {
            Text("Add item").withFont(.headingMedium)
            Spacer()
            Button(
                action: {
                    dismiss()
                },
                label: {
                    Image(systemName: "xmark").foregroundColor(.secondaryLabel)
                })
        }
    }

    func inputField(title: String, bodytext: String, inputText: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).foregroundColor(.secondaryLabel).withFont(.labelMedium)
            TextField(bodytext, text: inputText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }

    var body: some View {
        GroupedStack {
            header
            inputField(title: "Title", bodytext: "Please provide a title", inputText: $titleText)
            inputField(
                title: "URL", bodytext: "Add a URL to your new item (optional)", inputText: $urlText
            )
            HStack {
                Spacer()
                Button(
                    action: {
                        spaceModel.add(spaceID: space.id.id, url: urlText, title: titleText)
                        dismiss()
                    },
                    label: {
                        Text("Save").frame(width: 50).foregroundColor(.white)
                    }
                )
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Capsule().fill(Color.brand.blue))
            }
            .padding(.top, 10)
        }
    }
}
