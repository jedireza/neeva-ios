//
//  CreateEntityView.swift
//
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI
import Apollo

struct CreateEntityView: View {
    let spaceId: String
    let onUpdate: Updater<SpaceController.Space>
    let onDismiss: () -> ()

    @State var title = ""
    @State var url = ""

    @State var isCancellingEdit = false

    @State var cancellable: Apollo.Cancellable?

    @StateObject var updater: SpaceResultCreator

    init(inSpace id: String, onDismiss: @escaping () -> (), onUpdate: @escaping Updater<SpaceController.Space>) {
        spaceId = id

        self.onUpdate = onUpdate
        self.onDismiss = onDismiss

        self._updater = .init(wrappedValue: .init(spaceId: id, onUpdate: onUpdate, onSuccess: onDismiss))
    }

    var isDirty: Bool {
        title != "" || url != ""
    }

    var body: some View {
        let isSaving = updater.isRunning

        NavigationView {
            Form {
                Section(header: Text("\nItem Title")) {
                    TextField("Please type a title for your Space item", text: $title)
                        .padding(.horizontal, -5)
                        .foregroundColor(.primary)
                }
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
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ActivityIndicator()
                    } else {
                        Button("Save") {
                            updater.execute(title: title, url: url)
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
                        onDismiss()
                    },
                    .cancel()
                ])
        })
        .presentation(isModal: isDirty || isSaving, onDismissalAttempt: {
            if !isSaving { isCancellingEdit = true }
        })
    }
}

struct CreateEntityView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEntityView(inSpace: "some-id", onDismiss: {}, onUpdate: { _ in })
    }
}
