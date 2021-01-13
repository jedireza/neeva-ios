//
//  SpaceListViews.swift
//  
//
//  Created by Jed Fox on 12/21/20.
//

import SwiftUI

public struct SpaceListView: View {
    @StateObject var controller = SpaceListController()
    let onDismiss: (() -> ())?

    public init(onDismiss: (() -> ())? = nil) {
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationView {
            Group {
                if let error = controller.error {
                    ErrorView(error, in: self, tryAgain: { controller.reload() })
                } else if let data = controller.data {
                    List(data) { space in
                        NavigationLink(
                            destination: SpaceLoaderView(id: space.id, initialTitle: space.space?.name ?? "")
                                .onDisappear(perform: controller.reload)
                        ) {
                            SpaceListItem(space)
                        }
                    }
                    .refreshControl(refreshing: controller)
                } else {
                    LoadingView("Loading Spaces")
                }
            }
            .navigationTitle("Spaces")
            .navigationBarTitleDisplayMode(onDismiss == nil ? .automatic : .inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if let onDismiss = onDismiss {
                        Button("Done", action: onDismiss)
                            .font(Font.body.bold())
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        openTextInputAlert(
                            title: "What would you like to name your space?",
                            confirmationButtonTitle: "Add",
                            placeholder: "Name your space",
                            configureTextField: { tf in
                                tf.autocapitalizationType = .words
                                tf.returnKeyType = .done
                                tf.autocorrectionType = .default
                                tf.clearButtonMode = .always
                            }
                        ) { name in
                            CreateSpaceMutation(name: name).perform { result in
                                if case .success(let data) = result,
                                   let oldSpaces = controller.data {
                                    withAnimation {
                                        controller.reload(optimisticResult: [
                                            .init(
                                                pageMetadata: .init(pageId: data.createSpace),
                                                space: .init(
                                                    name: name,
                                                    createdTs: dateParser.string(from: Date()),
                                                    lastModifiedTs: dateParser.string(from: Date())
                                                )
                                            )
                                        ] + oldSpaces)
                                    }
                                } else {
                                    controller.reload()
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("New Space")
                    }.disabled(controller.data == nil)
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SpaceLoaderView: View {
    @StateObject var controller: SpaceController
    let id: String
    let initialTitle: String

    init(id: String, initialTitle: String) {
        self._controller = .init(wrappedValue: SpaceController(id: id, animation: .default))
        self.id = id
        self.initialTitle = initialTitle
    }
    var body: some View {
        if let error = controller.error {
            ErrorView(error, in: self, tryAgain: { controller.reload() })
        } else if let space = controller.data {
            SpaceDetailView(space: space, with: id, onUpdate: { handler in
                if let handler = handler, var newSpace = controller.data {
                    handler(&newSpace)
                    withAnimation {
                        controller.reload(optimisticResult: newSpace)
                    }
                } else {
                    controller.reload(optimisticResult: nil)
                }
            }).refreshControl(refreshing: controller)
        } else {
            GeometryReader { _ in
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        LoadingView("Loading space…")
                        Spacer()
                    }
                    Spacer()
                }
            }
                .background(Color.groupedBackground.edgesIgnoringSafeArea(.all))
                .navigationTitle(initialTitle)
                .navigationBarTitleDisplayMode(.large)
        }
    }

}

struct SpacesListView_Previews: PreviewProvider {
    static var previews: some View {
        SpaceListView()
        SpaceListView(onDismiss: { })
        SpaceLoaderView(id: "", initialTitle: "Title")
    }
}
