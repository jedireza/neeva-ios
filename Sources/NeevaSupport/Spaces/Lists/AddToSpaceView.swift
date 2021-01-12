import SwiftUI
import Apollo

public struct AddToSpaceView: View {
    @State var isWaiting = false
    @State var cancellable: Apollo.Cancellable? = nil

    @StateObject var spaceList = SpaceListController()

    public struct IDs {
        public let space: String
        public let entity: String
    }

    let title: String
    let description: String? // meta description
    let url: URL
    let onDismiss: (IDs?) -> ()

    public init(title: String, description: String?, url: URL, onDismiss: @escaping (IDs?) -> ()) {
        self.title = title
        self.description = description
        self.url = url
        self.onDismiss = onDismiss
    }

    public var body: some View {
        return NavigationView {
            Group {
                if cancellable != nil {
                    LoadingView("Adding to space…")
                } else if let spaces = spaceList.data {
                    List {
                        ForEach(spaces) { space in
                            Button {
                                let cancellable = AddToSpaceMutation(
                                    input: AddSpaceResultByURLInput(
                                        spaceId: space.id,
                                        url: url.absoluteString,
                                        title: title,
                                        data: description,
                                        mediaType: "text/plain",
                                        isBase64: false,
                                        snapshotExpected: false
                                    )
                                ).perform { result in
                                    self.cancellable = nil
                                    switch result {
                                    case .failure(let err):
                                        print(err)
                                    case .success(let data):
                                        onDismiss(IDs(space: space.id, entity: data.entityId))
                                    }
                                }
                                withAnimation {
                                    self.cancellable = cancellable
                                }
                            } label: {
                                SpaceListItem(space).foregroundColor(.primary)
                            }
                        }
                    }
                    .refreshControl(refreshing: spaceList)
                    .listStyle(DefaultListStyle())
                } else if let error = spaceList.error {
                    if let error = error as? GraphQLAPI.Error {
                        Text(error.errors.description)
                    } else {
                        Text(error.localizedDescription)
                    }
                } else {
                    LoadingView("Loading spaces…")
                }
            }
            .navigationBarTitle(Text("Add to Space"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel", action: { onDismiss(nil) })
            )
        }.navigationViewStyle(StackNavigationViewStyle())
        .onDisappear {
            if let cancellable = self.cancellable {
                cancellable.cancel()
            }
        }
    }
}

struct AddToSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddToSpaceView(title: "Hello, world!", description: "<h1>Testing!</h1>", url: URL(string: "https://google.com")!, onDismiss: { print($0 ?? "Cancelled") })
    }
}
