//
//  EditSpaceView.swift
//  
//
//  Created by Jed Fox on 12/22/20.
//

import SwiftUI
import Apollo

struct EditSpaceView: View {
    let spaceId: String
    let space: SpaceController.Space
    let onUpdate: Updater<SpaceController.Space>
    @State var title: String
    @State var description: String
    @State var isSaving = false
    @Binding var isPresented: Bool

    @State var cancellable: Apollo.Cancellable?
    @State var isCancellingEdit = false

    @Environment(\.presentationMode) var presentationMode

    init(for space: SpaceController.Space, with id: String, isPresented: Binding<Bool>, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.space = space
        spaceId = id
        self._isPresented = isPresented
        self.onUpdate = onUpdate

        self._title = State(initialValue: space.name ?? "")
        self._description = State(initialValue: space.description ?? "")
    }

    var isDirty: Bool {
        title != (space.name ?? "")
            || description != (space.description ?? "")
            || isSaving
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
                        .padding(.horizontal, -10)
                }
            }
            .navigationBarTitle(Text("Edit Space"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }.font(.body),
                trailing: Group {
                    if isSaving {
                        ActivityIndicator()
                    } else {
                        Button("Save") {
                            cancellable = UpdateSpaceMutation(
                                input: .init(
                                    id: spaceId,
                                    name: title,
                                    description: description
                                )
                            ).perform { result in
                                isSaving = false
                                guard case .success(let data) = result, data.updateSpace else { return }
                                onUpdate { newSpace in
                                    newSpace.name = title
                                    newSpace.description = description
                                }
                                isPresented = false
                            }
                        }
                    }
                }
            )
            .disabled(isSaving)
        }.navigationViewStyle(StackNavigationViewStyle())
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

struct EditSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        EditSpaceView(for: testSpace, with: "some-id", isPresented: .constant(true), onUpdate: { _ in })
    }
}
