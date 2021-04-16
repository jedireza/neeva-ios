import SwiftUI
import Apollo


/// Prompts the user to add a given URL to a space
public struct AddToSpaceView: View {
    let title: String
    let description: String? // meta description
    let url: URL
    let showNewSpaceButton: Bool
    let onDismiss: (AddToSpaceList.IDs?) -> ()

    /// - Parameters:
    ///   - title: The title of the newly created entity
    ///   - description: The description/snippet of the newly created entity
    ///   - url: The URL of the newly created entity
    ///   - showNewSpaceButton: Flag to decide if we show the add new space button
    ///   - onDismiss: Called to close the sheet. `nil` is passed if the user cancels; otherwise, the ID of the selected space and newly created entity are passed.
    public init(title: String, description: String?, url: URL, showNewSpaceButton: Bool = true, onDismiss: @escaping (AddToSpaceList.IDs?) -> ()) {
        self.title = title
        self.description = description
        self.url = url
        self.showNewSpaceButton = showNewSpaceButton
        self.onDismiss = onDismiss
    }

    public var body: some View {
        AddToSpaceList(title: title, description: description, url: url, showNewSpaceButton: showNewSpaceButton, onDismiss: onDismiss)
    }
}

public struct AddToSpaceList: View {
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
    let showNewSpaceButton: Bool
    let onDismiss: (AddToSpaceList.IDs?) -> ()

    public init(title: String, description: String?, url: URL, showNewSpaceButton: Bool = true, onDismiss: @escaping (IDs?) -> ()) {
        self.title = title
        self.description = description
        self.url = url
        self.showNewSpaceButton = showNewSpaceButton
        self.onDismiss = onDismiss
    }

    func filter(_ spaces: [SpaceListController.Space]) -> [SpaceListController.Space] {
        let filtered = spaces.filter { $0.space?.userAcl?.acl >= .edit }
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            return filtered.filter { $0.space?.name?.localizedCaseInsensitiveContains(searchTerm) ?? false }
        } else {
            return filtered
        }
    }

    public var body: some View {
        Group {
            if cancellable != nil {
                LoadingView("Adding to space…")
                    .onDisappear {
                        // Take care to cancel the request if it's still pending.
                        if let cancellable = self.cancellable {
                            cancellable.cancel()
                        }
                    }
            } else {
                ScrollView {
                    VStack {
                        switch spaceList.state {
                        case .running:
                            LoadingView("Loading spaces…")
                        case .failure(let error):
                            ErrorView(error, in: self, tryAgain: { spaceList.reload() })
                        case .success(let spaces):
                            let filteredSpaces = filter(spaces)
                            SpacesSearchHeaderView(filterAction: filterListByString, onCreateSpace: { result, name in
                                addToSpace(id: result.createSpace, name: name)
                            }).padding(.horizontal, 4)
                            if !(searchTerm ?? "").isEmpty && filteredSpaces.isEmpty {
                                Text("No Results Found")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 16)
                            } else {
                                LazyVStack(spacing: 20) {
                                    ForEach(filteredSpaces) { space in
                                        Button {
                                            addToSpace(id: space.id, name: space.space?.name ?? "Unknown")
                                        } label: {
                                            SpaceListItem(space).foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(DefaultListStyle())
                .padding(.bottom, 16)
            }
        }
    }

    func filterListByString( searchValue: String ){
        self.searchTerm = searchValue
    }

    func addToSpace(id: String, name: String) {
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
                onDismiss(IDs(space: name, entity: ""))
                print(err)
                break
            case .success(let data):
                onDismiss(IDs(space: name, entity: data.entityId))
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
