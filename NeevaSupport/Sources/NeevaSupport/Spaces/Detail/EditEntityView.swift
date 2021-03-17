//
//  EditEntityView.swift
//
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI
import Apollo

/// Edit the title/snippet/thumbnail of a space entity/result
struct EditEntityView: View {
    let spaceId: String
    let entity: SpaceController.Entity
    let onDismiss: () -> ()

    @State var title: String
    @State var snippet: String
    @State var thumbnail: String

    @State var isCancellingEdit = false

    @State var cancellable: Apollo.Cancellable?

    @StateObject var updater: SpaceResultUpdater

    /// - Parameters:
    ///   - entity: The entity to edit
    ///   - spaceId: The ID of the space that contains this entity/result
    ///   - onDismiss: Called when the user cancels the edit
    ///   - onUpdate: See description in `SpaceLoaderView`
    init(for entity: SpaceController.Entity, inSpace spaceId: String, onDismiss: @escaping () -> (), onUpdate: @escaping Updater<SpaceController.Space>) {
        self.spaceId = spaceId
        self.entity = entity
        self._title = .init(initialValue: entity.spaceEntity?.title ?? "")
        self._snippet = .init(initialValue: entity.spaceEntity?.snippet ?? "")
        self._thumbnail = .init(initialValue: entity.spaceEntity?.thumbnail ?? "")

        self.onDismiss = onDismiss

        self._updater = .init(wrappedValue: .init(spaceId: spaceId, resultId: entity.id, onUpdate: onUpdate, onSuccess: onDismiss))
    }

    var isDirty: Bool {
        title != (entity.spaceEntity?.title ?? "")
            || snippet != (entity.spaceEntity?.snippet ?? "")
            || thumbnail != (entity.spaceEntity?.thumbnail ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("\nItem Title")) {
                    TextField("Please type a title for your Space item", text: $title)
                        .padding(.horizontal, -5)
                        .foregroundColor(.primary)
                }
                Section(header: Text("Description")) {
                    MultilineTextField("Please type a description for your Space item", text: $snippet)
                }
                Section(header: Text("Thumbnail")) {
                    EditThumbnailView(spaceId: spaceId, entityId: entity.id, selectedThumbnail: $thumbnail)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if updater.isRunning {
                        ActivityIndicator()
                    } else {
                        Button("Save") {
                            updater.execute(title: title, snippet: snippet, thumbnail: thumbnail)
                        }.disabled(title.isEmpty)
                    }
                }
            }
            .disabled(updater.isRunning)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $isCancellingEdit, content: {
            ActionSheet(
                title: Text("Discard changes?"),
                buttons: [
                    .destructive(Text("Discard Changes")) {
                        cancellable?.cancel()
                        onDismiss()
                    },
                    .cancel()
                ])
        })
        .presentation(isModal: isDirty || updater.isRunning, onDismissalAttempt: {
            if !updater.isRunning { isCancellingEdit = true }
        })
    }
}

struct EditEntityView_Previews: PreviewProvider {
    static var previews: some View {
        EditEntityView(for: testSpace.entities![0], inSpace: "some-id", onDismiss: {}, onUpdate: { _ in })
    }
}
