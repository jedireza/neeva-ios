//
//  EditEntityView.swift
//
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI
import Apollo

struct EditEntityView: View {
    let spaceId: String
    let entity: SpaceController.Entity? // nil if creating a new item
    let onUpdate: Updater<SpaceController.Space>

    @State var title: String
    @State var snippet: String
    @State var url: String
    @State var thumbnail: String
    @Binding var isPresented: Bool

    @State var isSaving = false
    @State var isCancellingEdit = false

    @State var cancellable: Apollo.Cancellable?

    init(for entity: SpaceController.Entity?, inSpace id: String, isPresented: Binding<Bool>, onUpdate: @escaping Updater<SpaceController.Space>) {
        spaceId = id
        self.entity = entity
        self._title = State(initialValue: entity?.spaceEntity?.title ?? "")
        self._snippet = State(initialValue: entity?.spaceEntity?.snippet ?? "")
        self._url = .init(initialValue: "") // only used when creating
        self._thumbnail = .init(initialValue: entity?.spaceEntity?.thumbnail ?? "")

        self._isPresented = isPresented
        self.onUpdate = onUpdate
    }

    var isDirty: Bool {
        title != (entity?.spaceEntity?.title ?? "")
            || snippet != (entity?.spaceEntity?.snippet ?? "")
            || url != ""
            || thumbnail != (entity?.spaceEntity?.thumbnail ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("\nItem Title")) {
                    TextField("Please type a title for your Space item", text: $title)
                        .padding(.horizontal, -5)
                        .foregroundColor(.primary)
                }
                if let entity = entity {
                    Section(header: Text("Description")) {
                        MultilineTextField("Please type a description for your Space item", text: $snippet)
                    }
                    Section(header: Text("Thumbnail")) {
                        EditThumbnailView(spaceId: spaceId, entityId: entity.id, selectedThumbnail: $thumbnail)
                    }
                } else {
                    Section(header: Text("URL")) {
                        TextField("Add a URL to your new item (optional)", text: $url)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal, -5)
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle(entity == nil ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if isSaving {
                        ActivityIndicator()
                    } else {
                        Button("Save") {
                            if let entity = entity {
                                cancellable = UpdateSpaceResultMutation(
                                    input: .init(
                                        spaceId: spaceId,
                                        resultId: entity.id,
                                        title: title,
                                        snippet: snippet,
                                        thumbnail: thumbnail
                                    )
                                ).perform { result in
                                    isSaving = false
                                    guard case .success(let data) = result, data.updateSpaceEntityDisplayData == true else { return }
                                    onUpdate { newSpace in
                                        if let idx = newSpace.entities?.firstIndex(where: { $0.id == entity.id }) {
                                            var newEntity = newSpace.entities![idx]
                                            newEntity.spaceEntity?.title = self.title
                                            newEntity.spaceEntity?.snippet = self.snippet
                                            newEntity.spaceEntity?.thumbnail = self.thumbnail
                                            newSpace.entities!.replaceSubrange(idx...idx, with: [newEntity])
                                        }
                                    }
                                    isPresented = false
                                }
                            } else {
                                cancellable = AddToSpaceMutation(
                                    input: .init(
                                        spaceId: spaceId,
                                        url: url,
                                        title: title
                                    )
                                ).perform { result in
                                    isSaving = false
                                    guard case .success(let data) = result else { return }
                                    onUpdate { newSpace in
                                        newSpace.entities?.append(
                                            .init(
                                                metadata: .init(docId: data.entityId),
                                                spaceEntity: .init(url: url, title: title)
                                            )
                                        )
                                    }
                                    isPresented = false
                                }
                            }
                        }.disabled(title.isEmpty)
                    }
                }
            }
            .disabled(isSaving)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $isCancellingEdit, content: {
            ActionSheet(
                title: Text("Discard changes?"),
                buttons: [
                    .destructive(Text("Discard Changes")) {
                        cancellable?.cancel()
                        isPresented = false
                    },
                    .cancel()
                ])
        })
        .presentation(isModal: isDirty || isSaving, onDismissalAttempt: {
            if !isSaving { isCancellingEdit = true }
        })
    }
}

struct EditEntityView_Previews: PreviewProvider {
    static var previews: some View {
        EditEntityView(for: testSpace.entities![0], inSpace: "some-id", isPresented: .constant(true), onUpdate: { _ in })
    }
}
