import SwiftUI
import Apollo

public struct AddToSpaceView: View {
    let space = TestSpaces.empty
    @State var isWaiting = false
    @State var cancellable: Apollo.Cancellable? = nil

    @ObservedObject var spaceList = SpaceListController()

    let title: String
    let description: String? // meta description
    let url: URL
    let onDismiss: (String?) -> ()

    public init(title: String, description: String?, url: URL, onDismiss: @escaping (String?) -> ()) {
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
                                self.cancellable = GraphQLAPI.perform(AddToSpaceMutation(
                                    input: AddSpaceResultByURLInput(
                                        spaceId: space.id,
                                        url: url.absoluteString,
                                        title: title,
                                        data: description,
                                        mediaType: "text/plain",
                                        isBase64: false,
                                        snapshotExpected: false
                                    )
                                )) { result in
                                    cancellable = nil
                                    switch result {
                                    case .failure(let err):
                                        print(err)
                                    case .success(let result):
                                        onDismiss(result.resultId)
                                    }
                                }
                            } label: {
                                SpaceView(space)
                            }
                        }
                    }
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
