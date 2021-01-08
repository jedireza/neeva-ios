//
//  SpaceDetailView.swift
//  
//
//  Created by Jed Fox on 12/21/20.
//

import SwiftUI

public struct Wrapper<Content: View>: UIViewControllerRepresentable {
    var content: () -> Content
    public func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        vc.view.isOpaque = false
        return vc
    }
    public func updateUIViewController(_ vc: UIHostingController<Content>, context: Context) {
        vc.rootView = content()
    }
}

struct BigHeader: View {
    let title: String
    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Wrapper {
            HStack {
                Text(title).font(.title3).bold()
                Spacer(minLength: 0)
            }
        }
    }
}

public struct SpaceDetailView: View {
    let space: SpaceController.Space
    let spaceId: String
    let onOpenURL: (URL) -> ()
    let onUpdate: Updater<SpaceController.Space>

    public init(space: SpaceController.Space, with id: String, onOpenURL: @escaping (URL) -> (), onUpdate: @escaping Updater<SpaceController.Space>) {
        self.space = space
        self.spaceId = id
        self.onOpenURL = onOpenURL
        self.onUpdate = onUpdate
    }

    @State var isDeleting = false
    @State var isCancellingEdit = false
    @State var isEditing = false
    @State var isSharing = false
    @State var isAdding = false

    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        Group {
            if let entities = space.entities,
               !entities.isEmpty {
                List {
                    let entityViews = ForEach(entities) { entity in
                        if let urlString = entity.spaceEntity?.url,
                           let url = URL(string: urlString) {
                            Section {
                                Button(action: { onOpenURL(url) }) {
                                    SpaceEntityView(entity: entity, spaceId: spaceId, spaceAcl: space.userAcl?.acl, onUpdate: onUpdate)
                                        .padding(.vertical)
                                        .buttonStyle(BorderlessButtonStyle())
                                        .accentColor(.primary)
                                }
                            }
                        } else {
                            Section(header: Wrapper {
                                SpaceEntityView(entity: entity, spaceId: spaceId, spaceAcl: space.userAcl?.acl, onUpdate: onUpdate)
                            }) {}
                        }
                    }
                    if space.userAcl?.acl >= .edit {
                        entityViews.onDelete { indexSet in
                            BatchDeleteSpaceResultMutation(space: spaceId, results: indexSet.map { entities[$0].id }).perform { result in
                                guard case .success(let data) = result, data.batchDeleteSpaceResult else { return }
                                onUpdate { newSpace in
                                    // this could potentially remove incorrect entities if the user performs several deletes in a row
                                    // however, this is client-only and will be remedied once the query comes back
                                    newSpace.entities?.remove(atOffsets: indexSet)
                                }
                            }
                        }
                    } else {
                        entityViews
                    }
                    if let desc = space.description, !desc.isEmpty {
                        Section(header: BigHeader("About this Space")) {
                            Text(desc)
                        }
                    }
                    Section(header: BigHeader("Discussion")) {
                        if let comments = space.comments, !comments.isEmpty {
                            ForEach(comments) { comment in
                                CommentView(comment: comment, userAcl: space.userAcl?.acl)
                            }
                        }
                    }
                    if space.comments?.isEmpty ?? true {
                        Section(header: Wrapper {
                            Text("No comments have been added to this space.")
                                .foregroundColor(.secondary)
                        }) {}
                    }
                    if space.userAcl?.acl >= .comment {
                        ComposeCommentView(spaceId: spaceId, onUpdate: onUpdate)
                    }
                }
                .listStyle(GroupedListStyle())
            } else {
                VStack {
                    Spacer()
                    HStack { Spacer() }
                    Text("No items")
                        .font(.title).fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text("Add to your space by clicking the bookmark icon on a search result")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(20)
                        .padding(.horizontal, 20)
                    Button("[TODO] Search for “\(space.name ?? "")”") /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/.disabled(true)
                    Spacer()
                }.background(Color.groupedBackground.edgesIgnoringSafeArea(.all))
            }
        }
        .navigationBarTitle(Text(space.name!), displayMode: .large)
        .navigationBarItems(trailing: navBarItems)
    }

    var navBarItems: some View {
        HStack(alignment: .firstTextBaseline, spacing: 25) {
            Button(action: { isSharing = true }, label: {
                Image(systemName: space.userAcl?.acl == .owner ? "person.crop.circle.badge.plus" : "person.2.fill")
            }).sheet(isPresented: $isSharing) {
                ShareSpaceView(space: space, id: spaceId, onUpdate: onUpdate)
            }
            if space.userAcl?.acl >= .edit {
                Button(action: { isAdding = true }, label: {
                    Image(systemName: "plus")
                }).sheet(isPresented: $isAdding) {
                    EditEntityView(for: nil, inSpace: spaceId, isPresented: $isAdding, onUpdate: onUpdate)
                }
            }

            Menu {
                // TODO: implement
                Button("Open All Links") /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/.hidden()
                if space.userAcl?.acl >= .edit {
                    // TODO: implement
                    Button("Reorder items") /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/.hidden()
                    Button(action: { isEditing = true }) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                }
                if space.userAcl?.acl == .owner {
                    Button(action: { isDeleting = true }) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }.actionSheet(isPresented: $isDeleting, content: {
                ActionSheet(
                    title: Text("Delete “\(space.name!)” permanently?"),
                    buttons: [
                        .destructive(Text("Delete")) {
                            DeleteSpaceMutation(input: .init(id: spaceId)).perform { _ in
                                presentationMode.wrappedValue.dismiss()
                            }
                        },
                        .cancel()
                    ])
            }).sheet(isPresented: $isEditing, content: {
                EditSpaceView(for: space, with: spaceId, isPresented: $isEditing, onUpdate: onUpdate)
            })
        }.imageScale(.large).font(.body)
    }
}

struct SpaceDetailView_Previews: PreviewProvider {
//    struct Wrapper: View {
//        @StateObject var space = SpaceController(id: "SkksIM_iAclak16nHYfcqAY8IwxsasTD1pU1XqUe")
//        var body: some View {
//            if let space = space.data {
//                SpaceDetailView(space: space)
//            } else {
//                LoadingView("Loading space…")
//            }
//        }
//    }
    static var previews: some View {
        NavigationView {
            SpaceDetailView(space: testSpace, with: "", onOpenURL: { _ in }, onUpdate: { _ in })
        }.navigationViewStyle(StackNavigationViewStyle())
        NavigationView {
            SpaceDetailView(
                space: .init(
                    name: "Empty Space",
                    description: "",
                    createdTs: "2020-12-18T15:43:30Z",
                    lastModifiedTs: "2020-12-18T15:43:30Z",
                    acl: [
                        .init(
                            userId: "bvd2vpedu5mmd2tm0dug",
                            profile: .init(
                                displayName: "Jed Fox",
                                email: "jed@neeva.co",
                                pictureUrl: "https://lh3.googleusercontent.com/a-/AOh14GhpAsV1_QUrGqFzTXFAo3JrIoMASM-6KDQJhN8t=s96-c"
                            ),
                            acl: .owner
                        )
                    ],
                    userAcl: .init(
                        acl: .owner,
                        userId: "bvd2vpedu5mmd2tm0dug"
                    ),
                    hasPublicAcl: false,
                    comments: [],
                    thumbnailSize: .init(
                        height: 0,
                        width: 0
                    ),
                    isDefaultSpace: false,
                    entities: []
                ),
                with: "",
                onOpenURL: { _ in },
                onUpdate: { _ in }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

let userId = "bvd2vpedu5mmd2tm0dug"
let profile = FetchSpaceQuery.Data.GetSpace.Space.Space.Comment.Profile(
    displayName: "Jed Fox",
    email: "jed@neeva.co",
    pictureUrl: "https://lh3.googleusercontent.com/a-/AOh14GhpAsV1_QUrGqFzTXFAo3JrIoMASM-6KDQJhN8t=s96-c"
)
let profile2 = FetchSpaceQuery.Data.GetSpace.Space.Space.Entity.SpaceEntity.CreatedBy(
    displayName: "Jed Fox",
    email: "jed@neeva.co",
    pictureUrl: "https://lh3.googleusercontent.com/a-/AOh14GhpAsV1_QUrGqFzTXFAo3JrIoMASM-6KDQJhN8t=s96-c"
)
let testSpace = SpaceController.Space(
    name: "name",
    description: "description",
    createdTs: "2020-12-18T16:12:38Z",
    lastModifiedTs: "2020-12-21T18:42:37Z",
    acl: [
        .init(
            userId: userId,
            profile: .init(
                displayName: "Jed Fox",
                email: "jed@neeva.co",
                pictureUrl: "https://lh3.googleusercontent.com/a-/AOh14GhpAsV1_QUrGqFzTXFAo3JrIoMASM-6KDQJhN8t=s96-c"
            ),
            acl: .owner
        ),
        .init(
            userId: userId + "2",
            profile: .init(
                displayName: "jed2",
                email: "jed2@neeva.co",
                pictureUrl: ""
            ),
            acl: .edit
        )
    ],
    userAcl: .init(acl: .owner, userId: userId),
    hasPublicAcl: false,
    comments: [
        .init(
            id: "bvgep50do08in1m7gfdg",
            userid: userId,
            profile: profile,
            createdTs: "2020-12-21T18:42:28Z",
            lastModifiedTs: "2020-12-21T18:42:37Z",
            comment: "Hello, world."
        ),
        .init(
            id: "bvgep5odo08in1m7gff0",
            userid: userId,
            profile: profile,
            createdTs: "2020-12-21T18:42:31Z",
            lastModifiedTs: "2020-12-21T18:42:31Z",
            comment: "Hello, world!"
        ),
    ],
    thumbnail: SpaceThumbnails.stackOverflowThumbnail,
    resultCount: 4,
    isDefaultSpace: false,
    entities: [
        .init(metadata: .init(docId: "1"), spaceEntity: .init(
            url: "https://example.com",
            title: "Example website",
            snippet: "Hello, world!",
            resultType: "web",
            contentType: "",
            contentUrl: "",
            contentHeight: 0,
            contentWidth: 0,
            thumbnail: "",
            createdBy: profile2
        )),
        .init(metadata: .init(docId: "2"), spaceEntity: .init(
            url: "https://google.com",
            title: "No Snippet",
            snippet: "",
            resultType: "web",
            contentType: "",
            contentUrl: "",
            contentHeight: 0,
            contentWidth: 0,
            thumbnail: "",
            createdBy: profile2
        )),
        .init(metadata: .init(docId: "2"), spaceEntity: .init(
            url: "",
            title: "Title Only",
            snippet: "",
            resultType: "web",
            contentType: "",
            contentUrl: "",
            contentHeight: 0,
            contentWidth: 0,
            thumbnail: "",
            createdBy: profile2
        )),
        .init(metadata: .init(docId: "3"), spaceEntity: .init(
            url: "https://github.com/neevaco/neeva-ios/blob/6223606e39e70f1224101a81ac0974d909298234/Client/Frontend/Browser/BrowserViewController/BrowserViewController%2BUIDropInteractionDelegate.swift",
            title: "GitHub: Where the world builds software · GitHub",
            snippet: "GitHub is where over 56 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and features, power your CI/CD and DevOps workflows, and secure code before you commit it.",
            resultType: "web",
            contentType: "",
            contentUrl: "",
            contentHeight: 0,
            contentWidth: 0,
            thumbnail: SpaceThumbnails.githubThumbnail,
            createdBy: profile2
        )),
        .init(metadata: .init(docId: "4"), spaceEntity: .init(
            url: "https://stackoverflow.com",
            title: "Title",
            snippet: "",
            resultType: "web",
            contentType: "",
            contentUrl: "",
            contentHeight: 0,
            contentWidth: 0,
            thumbnail: SpaceThumbnails.stackOverflowThumbnail,
            createdBy: profile2
        ))
    ]
)
var testSpace2: SpaceController.Space = {
    var sp = testSpace
    sp.hasPublicAcl = true
    return sp
}()
