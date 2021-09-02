// Copyright Neeva. All rights reserved.

import SwiftUI

struct SpacesSearchHeaderView: View {
    @Environment(\.onOpenURL) private var onOpenURL

    @Binding var searchText: String

    let createAction: () -> Void
    let onDismiss: () -> Void
    let importData: SpaceImportHandler?

    public init(
        searchText: Binding<String>,
        createAction: @escaping () -> Void,
        onDismiss: @escaping () -> Void,
        importData: SpaceImportHandler? = nil
    ) {
        self._searchText = searchText
        self.createAction = createAction
        self.onDismiss = onDismiss
        self.importData = importData
    }

    var body: some View {
        HStack(spacing: 24) {
            CapsuleTextField(icon: Symbol(decorative: .magnifyingglass, style: .labelLarge),
                              placeholder: "Search Spaces", text: $searchText)
            Button {
                self.createAction()
            } label: {
                HStack(spacing: 5) {
                    Symbol(decorative: .plus, style: .labelLarge)
                    Text("Create")
                        .withFont(.labelLarge)
                }
            }
            .frame(height: 40)
            .foregroundColor(.ui.adaptive.blue)
            .padding(.trailing, 3)
            if let data = importData {
                Button {
                    // TODO: Show a toast as importing could take a while or fail.
                    data.importToNewSpace {
                        SpaceStore.shared.refresh()
                        onOpenURL(NeevaConstants.appSpacesURL)
                    }
                    onDismiss()
                } label: {
                    HStack(spacing: 5) {
                        Symbol(decorative: .plus, style: .labelLarge)
                        Text("Spacify")
                            .withFont(.labelLarge)
                    }
                }
                .frame(height: 40)
                .foregroundColor(.ui.adaptive.blue)
                .padding(.trailing, 3)
            }
        }
    }
}

struct SpacesSearchHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SpacesSearchHeaderView(searchText: .constant(""), createAction: {}, onDismiss: {})
        SpacesSearchHeaderView(searchText: .constant("Hello, world"), createAction: {}, onDismiss: {})
    }
}
