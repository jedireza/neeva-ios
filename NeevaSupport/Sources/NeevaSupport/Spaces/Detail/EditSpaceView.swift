//
//  EditSpaceView.swift
//  
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI
import Apollo

/// Edit the title/description of a space
struct EditSpaceView: View {
    let space: SpaceController.Space
    let onUpdate: Updater<SpaceController.Space>
    let onDismiss: () -> ()
    @State var title: String
    @State var description: String

    @State var isCancellingEdit = false

    @StateObject var updater: SpaceUpdater

    /// - Parameters:
    ///   - space: The space to edit
    ///   - spaceId: The ID of this space
    ///   - onDismiss: Called when the user cancels the edit
    ///   - onUpdate: See description in `SpaceLoaderView`
    init(for space: SpaceController.Space, with spaceId: String, onDismiss: @escaping () -> (), onUpdate: @escaping Updater<SpaceController.Space>) {
        self.space = space
        self.onUpdate = onUpdate
        self.onDismiss = onDismiss

        self._title = State(initialValue: space.name ?? "")
        self._description = State(initialValue: space.description ?? "")
        self._updater = .init(wrappedValue: .init(spaceId: spaceId, onUpdate: onUpdate, onSuccess: onDismiss))
    }

    var isDirty: Bool {
        title != (space.name ?? "")
            || description != (space.description ?? "")
            || updater.isRunning
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("\nSpace Title")) {
                    TextField("Please type a title for your Space", text: $title)
                        .padding(.horizontal, -5)
                }
                Section(header: Text("Description")) {
                    MultilineTextField("Please type a description for your Space", text: $description)
                }
            }
            .navigationTitle("Edit Space")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if updater.isRunning {
                        ActivityIndicator()
                    } else {
                        Button("Save") { updater.execute(title: title, description: description) }
                    }
                }
            }
            .disabled(updater.isRunning)
        }.navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $isCancellingEdit, content: {
            ActionSheet(
                title: Text("Discard changes?"),
                buttons: [
                    .destructive(Text("Discard Changes")) {
                        updater.cancellable?.cancel()
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

struct EditSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        EditSpaceView(for: testSpace, with: "some-id", onDismiss: {}, onUpdate: { _ in })
    }
}
