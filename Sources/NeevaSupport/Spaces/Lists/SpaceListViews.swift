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
    let onOpenURL: (URL) -> ()

    public init(onDismiss: (() -> ())? = nil, onOpenURL: @escaping (URL) -> ()) {
        self.onDismiss = onDismiss
        self.onOpenURL = onOpenURL
    }

    public var body: some View {
        NavigationView {
            List(controller.data ?? []) { space in
                NavigationLink(
                    destination: SpaceLoaderView(id: space.id, initialTitle: space.space?.name ?? "", onOpenURL: onOpenURL)
                        .onDisappear(perform: controller.reload)
                ) {
                    SpaceListItem(space)
                }
            }
            .refreshControl(refreshing: controller)
            .navigationTitle("Spaces")
            .navigationBarTitleDisplayMode(onDismiss == nil ? .automatic : .inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if let onDismiss = onDismiss {
                        Button("Done", action: onDismiss)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        let alert = UIAlertController(title: "What would you like to name your space?", message: nil, preferredStyle: .alert)

                        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                        let confirmAction = UIAlertAction(title: "Add", style: .default) { _ in
                            guard let name = alert.textFields?.first?.text else { return }
                            CreateSpaceMutation(name: name).perform { result in
                                if case .success(let data) = result,
                                   let oldSpaces = controller.data {
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
                                } else {
                                    controller.reload()
                                    return
                                }
                            }
                        }
                        confirmAction.isEnabled = false
                        alert.addAction(confirmAction)

                        alert.addTextField { tf in
                            tf.placeholder = "Name your space"
                            tf.autocapitalizationType = .words
                            tf.enablesReturnKeyAutomatically = true
                            tf.returnKeyType = .done
                            tf.autocorrectionType = .default
                            tf.clearButtonMode = .always
                            tf.addAction(UIAction { _ in
                                confirmAction.isEnabled = tf.hasText
                            }, for: .editingChanged)
                        }

                        UIApplication.shared.frontViewController.present(alert, animated: true, completion: nil)
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SpaceLoaderView: View {
    @StateObject var controller: SpaceController
    let id: String
    let initialTitle: String
    let onOpenURL: (URL) -> ()

    init(id: String, initialTitle: String, onOpenURL: @escaping (URL) -> ()) {
        self._controller = .init(wrappedValue: SpaceController(id: id, animation: .default))
        self.id = id
        self.onOpenURL = onOpenURL
        self.initialTitle = initialTitle
    }
    var body: some View {
        if let space = controller.data {
            SpaceDetailView(space: space, with: id, onOpenURL: onOpenURL, onUpdate: { handler in
                if let handler = handler, var newSpace = controller.data {
                    handler(&newSpace)
                    controller.reload(optimisticResult: newSpace)
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
        SpaceListView(onOpenURL: { _ in })
        SpaceListView(onDismiss: { }, onOpenURL: { _ in })
        SpaceLoaderView(id: "", initialTitle: "Title", onOpenURL: { _ in })
    }
}
