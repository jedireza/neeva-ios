import SwiftUI
import Apollo

public struct AddToSpaceView: View {
    let title: String
    let description: String? // meta description
    let url: URL
    let onDismiss: (AddToSpaceList.IDs?) -> ()

    public init(title: String, description: String?, url: URL, onDismiss: @escaping (AddToSpaceList.IDs?) -> ()) {
        self.title = title
        self.description = description
        self.url = url
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationView {
            AddToSpaceList(title: title, description: description, url: url, onDismiss: onDismiss)
                .navigationBarTitle(Text("Add to Space"), displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { onDismiss(nil) }
                    }
                }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

public struct AddToSpaceList: View {
    @State var isWaiting = false
    @State var cancellable: Apollo.Cancellable? = nil
    @State var searchTerm: String? = nil

    @StateObject var spaceList = SpaceListController()

    public struct IDs {
        public let space: String
        public let entity: String
    }

    let title: String
    let description: String? // meta description
    let url: URL
    let onDismiss: (AddToSpaceList.IDs?) -> ()

    public init(title: String, description: String?, url: URL, onDismiss: @escaping (IDs?) -> ()) {
        self.title = title
        self.description = description
        self.url = url
        self.onDismiss = onDismiss
    }

    var filteredSpaces: [SpaceListController.Space]? {
        guard let spaces = spaceList.data else { return nil }
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            return spaces.filter { $0.space?.name?.localizedCaseInsensitiveContains(searchTerm) ?? false }
        } else {
            return spaces
        }
    }

    public var body: some View {
        Group {
            if cancellable != nil {
                LoadingView("Adding to space…")
            } else if let error = spaceList.error {
                ErrorView(error, in: self, tryAgain: { spaceList.reload() })
            } else if let filteredSpaces = filteredSpaces {
                ZStack {
                    List {
                        ForEach(filteredSpaces) { space in
                            Button {
                                addToSpace(id: space.id)
                            } label: {
                                SpaceListItem(space).foregroundColor(.primary)
                            }
                        }
                    }
                    .refreshControl(refreshing: spaceList)
                    .searchBar("Search for space", text: $searchTerm)
                    .listStyle(DefaultListStyle())

                    if !(searchTerm ?? "").isEmpty && filteredSpaces.isEmpty {
                        VStack {
                            Spacer()
                            Text("No Results Found")
                                .font(.title)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        SpaceListView.newSpaceButton { name, result in
                            if case .success(let data) = result {
                                addToSpace(id: data.createSpace)
                            } else {
                                spaceList.reload()
                            }
                        }.disabled(spaceList.data == nil)
                    }
                }
           } else {
                LoadingView("Loading spaces…")
            }
        }
        .onDisappear {
            if let cancellable = self.cancellable {
                cancellable.cancel()
            }
        }
        .navigationBarItems(
            leading: Button("Cancel", action: { onDismiss(nil) })
        )
    }

    func addToSpace(id: String) {
        let cancellable = AddToSpaceMutation(
            input: AddSpaceResultByURLInput(
                spaceId: id,
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
                onDismiss(IDs(space: id, entity: data.entityId))
            }
        }
        withAnimation {
            self.cancellable = cancellable
        }
    }
}

struct AddToSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddToSpaceView(title: "Hello, world!", description: "<h1>Testing!</h1>", url: URL(string: "https://google.com")!, onDismiss: { print($0 ?? "Cancelled") })
    }
}
