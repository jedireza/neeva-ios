// Copyright Neeva. All rights reserved.

import SwiftUI
import Apollo

public class AddToSpaceRequest: ObservableObject {
    var cancellable: Apollo.Cancellable? = nil

    public let title: String
    public let description: String? // meta description
    public let url: URL

    public enum Mode {
        case saveToExistingSpace
        case saveToNewSpace

        public var title: String {
            switch self {
            case .saveToNewSpace:
                return "Create Space"
            case .saveToExistingSpace:
                return "Save to Spaces"
            }
        }
    }
    @Published public var mode: Mode = .saveToExistingSpace

    public enum State {
        case initial
        case creatingSpace
        case savingToSpace
        case savedToSpace
        case deletingFromSpace
        case deletedFromSpace
        case failed
    }
    @Published public var state: State = .initial

    // The results from a request. |targetSpaceName| is set on both
    // success and failure. |targetSpaceID| is only set on success.
    @Published public var targetSpaceName: String?
    @Published public var targetSpaceID: String?
    @Published public var error: Error?

    /// - Parameters:
    ///   - title: The title of the newly created entity
    ///   - description: The description/snippet of the newly created entity
    ///   - url: The URL of the newly created entity
    public init(title: String, description: String?, url: URL) {
        self.title = title
        self.description = description
        self.url = url
        SpaceStore.shared.refresh()
    }

    func addToNewSpace(spaceName: String) {
        guard spaceName.count > 0 else { return }

        self.targetSpaceName = spaceName

        // Note: This creates a reference cycle between self and the mutation.
        // This means even if all other references are dropped to self, then
        // the mutation will attempt to run to completion.
        self.cancellable = CreateSpaceMutation(
            name: spaceName
        ).perform { result in
            self.cancellable = nil
            switch result {
            case .success(let data):
                self.addToExistingSpace(id: data.createSpace, name: spaceName)
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
            }
        }
        withAnimation {
            self.state = .creatingSpace
        }
    }

    public func addToExistingSpace(id: String, name: String) {
        self.targetSpaceName = name

        // Note: This creates a reference cycle between self and the mutation.
        // This means even if all other references are dropped to self, then
        // the mutation will attempt to run to completion.
        self.cancellable = AddToSpaceMutation(
            input: AddSpaceResultByURLInput(
                spaceId: id,
                url: self.url.absoluteString,
                title: self.title,
                data: self.description,
                mediaType: "text/plain",
                isBase64: false,
                snapshotExpected: false
            )
        ).perform { result in
            self.cancellable = nil
            switch result {
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
                break
            case .success(_):
                self.targetSpaceID = id
                withAnimation {
                    self.state = .savedToSpace
                }
            }
        }
        withAnimation {
            self.state = .savingToSpace
        }
    }

    func deleteFromExistingSpace(id: String, name: String) {
        self.targetSpaceName = name

        // Note: This creates a reference cycle between self and the mutation.
        // This means even if all other references are dropped to self, then
        // the mutation will attempt to run to completion.
        self.cancellable = DeleteSpaceResultByUrlMutation(
            input: DeleteSpaceResultByURLInput(spaceId: id, url: self.url.absoluteString)
        ).perform { result in
            self.cancellable = nil
            switch result {
            case .failure(let error):
                self.error = error
                withAnimation {
                    self.state = .failed
                }
                break
            case .success(_):
                self.targetSpaceID = id
                withAnimation {
                    self.state = .deletedFromSpace
                }
                break
            }
        }
        withAnimation {
            self.state = .deletingFromSpace
        }
    }
}

public struct AddToSpaceView: View {
    @ObservedObject var request: AddToSpaceRequest
    @ObservedObject var spaceStore = SpaceStore.shared

    @State private var searchTerm = ""
    @State private var backgroundColor: Color? = nil

    let onDismiss: () -> ()

    public init(request: AddToSpaceRequest, onDismiss: @escaping () -> () = {}) {
        self.request = request
        self.onDismiss = onDismiss
    }

    func filter(_ spaces: [Space]) -> [Space] {
        if !searchTerm.isEmpty {
            return spaces.filter {
                $0.name.localizedCaseInsensitiveContains(searchTerm)
            }
        }
        return spaces
    }

    var searchHeader: some View {
        SpacesSearchHeaderView(
            searchText: $searchTerm,
            createAction: { request.mode = .saveToNewSpace }
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    @ViewBuilder var filteredListView: some View {
        let filteredSpaces = filter(spaceStore.editableSpaces)
        if !searchTerm.isEmpty && filteredSpaces.isEmpty {
            Text("No Results Found")
                .font(.title)
                .foregroundColor(.secondaryLabel)
                .padding(.top, 16)
        } else {
            LazyVStack(spacing: 14) {
                ForEach(filteredSpaces, id: \.self) { space in
                    Button {
                        if SpaceStore.shared.urlInSpace(request.url, spaceId: space.id) {
                            request.deleteFromExistingSpace(id: space.id.value, name: space.name)
                        } else {
                            request.addToExistingSpace(id: space.id.value, name: space.name)
                        }
                        onDismiss()
                    } label: {
                        SpaceListItem(space, currentURL: request.url)
                    }
                }
            }
            .padding(.bottom, 16)
        }
    }

    public var body: some View {
        Group {
            if request.mode == .saveToNewSpace {
                CreateSpaceView() {
                    request.addToNewSpace(spaceName: $0)
                    onDismiss()
                }
            } else {
                GeometryReader { geom in
                    let sv = ScrollView {
                        VStack(spacing: 0) {
                            if case .failed(_) = spaceStore.state {} else {
                                searchHeader
                            }
                            switch spaceStore.state {
                            case .refreshing:
                                VStack(spacing: 14) {
                                    ForEach(0..<20) { _ in
                                        LoadingSpaceListItem()
                                            .padding(.vertical, 10)
                                            .padding(.leading, 16)
                                    }
                                }
                            case .failed(let error):
                                ErrorView(error, in: self, tryAgain: { spaceStore.refresh() })
                                    .frame(height: geom.size.height)
                            case .ready:
                                filteredListView
                            }
                        }
                    }
                    .onPreferenceChange(ErrorViewBackgroundPreferenceKey.self) { self.backgroundColor = $0 }
                    if let bg = backgroundColor {
                        sv.background(bg.ignoresSafeArea())
                    } else {
                        sv
                    }
                }
            }
        }
    }
}

struct AddToSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddToSpaceView(request: AddToSpaceRequest(title: "Hello, world!", description: "<h1>Testing!</h1>", url: "https://google.com"), onDismiss: { print("Done") })
    }
}
