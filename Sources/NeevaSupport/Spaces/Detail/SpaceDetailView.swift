//
//  SpaceDetailView.swift
//  
//
//  Created by Jed Fox on 12/21/20.
//

import SwiftUI
import Introspect

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

struct BigHeader<Accessory: View>: View {
    let title: String
    let accessory: () -> Accessory
    init(_ title: String, @ViewBuilder accessory: @escaping () -> Accessory) {
        self.title = title
        self.accessory = accessory
    }

    var body: some View {
        Wrapper {
            HStack {
                Text(title)
                    .font(.title3).bold()
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                accessory()
                    .accessibilityRemoveTraits(.isHeader)
            }
        }
    }
}

extension BigHeader where Accessory == EmptyView {
    init(_ title: String) {
        self.title = title
        self.accessory = EmptyView.init
    }
}

extension Array: Identifiable where Element == SpaceController.Entity {
    public var id: String {
        map(\.id).joined(separator: "\n")
    }
}

struct DiscussionSection: View {
    let space: SpaceController.Space
    let spaceId: String
    let onUpdate: Updater<SpaceController.Space>

    @StateObject var creator: SpaceCommentCreator

    init(space: SpaceController.Space, spaceId: String, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.space = space
        self.spaceId = spaceId
        self.onUpdate = onUpdate
        self._creator = .init(wrappedValue: .init(spaceId: spaceId, onUpdate: onUpdate))
    }

    private static let placeholders = ["Add a comment...", "What's on your mind?", "Write it down so you won't forget!"]

    var body: some View {
        Section(header: BigHeader("Discussion") {
            if space.userAcl?.acl >= .comment {
                Button {
                    openTextInputAlert(
                        title: "Add a Comment",
                        confirmationButtonTitle: "Save",
                        configureTextField: { tf in
                            tf.placeholder = Self.placeholders.randomElement()!
                            tf.autocapitalizationType = .sentences
                            tf.autocorrectionType = .default
                            tf.returnKeyType = .done
                        },
                        onConfirm: creator.execute
                    )
                } label: {
                    Label("New Comment", systemImage: "plus.bubble.fill")
                }
            }
        }) {
            if let comments = space.comments, !comments.isEmpty {
                ForEach(comments) { comment in
                    CommentView(spaceId: spaceId, comment: comment, userAcl: space.userAcl?.acl, onUpdate: onUpdate)
                }
            }
        }
        if space.comments?.isEmpty ?? true {
            Section(header: Wrapper {
                Text("No comments have been added to this space.")
                    .foregroundColor(.secondary)
            }) {}
        }
    }
}

public struct SpaceDetailView: View {
    let space: SpaceController.Space
    let spaceId: String
    let onUpdate: Updater<SpaceController.Space>

    public init(space: SpaceController.Space, with id: String, onUpdate: @escaping Updater<SpaceController.Space>) {
        self.space = space
        self.spaceId = id
        self.onUpdate = onUpdate

        self._entityDeleter = .init(wrappedValue: .init(spaceId: id, onUpdate: onUpdate))
    }

    @State var isDeleting = false
    @State var deletingEntities: [SpaceController.Entity]? = nil
    @State var isCancellingEdit = false
    @State var isEditing = false
    @State var isSharing = false
    @State var isAdding = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onOpenURL) var onOpenURL

    @StateObject var entityDeleter: SpaceResultDeleter

    public var body: some View {
        let name = space.name ?? ""
        Group {
            if let entities = space.entities,
               !entities.isEmpty {
                List {
                    let entityViews = ForEach(entities) { entity in
                        if let urlString = entity.spaceEntity?.url,
                           let url = URL(string: urlString) {
                            Section(header: EmptyView().accessibilityHidden(true)) {
                                Button(action: { onOpenURL(url) }) {
                                    SpaceEntityView(entity: entity, spaceId: spaceId, spaceAcl: space.userAcl?.acl, onUpdate: onUpdate, onDelete: { deletingEntities = [entity] })
                                        .padding(.vertical)
                                        .buttonStyle(BorderlessButtonStyle())
                                        .accentColor(.primary)
                                }
                            }
                        } else {
                            Section(header: Wrapper {
                                SpaceEntityView(entity: entity, spaceId: spaceId, spaceAcl: space.userAcl?.acl, onUpdate: onUpdate, onDelete: { deletingEntities = [entity] })
                            }) {}
                        }
                    }
                    if space.userAcl?.acl >= .edit {
                        entityViews.onDelete { indexSet in
                            deletingEntities = indexSet.map { entities[$0] }
                        }
                    } else {
                        entityViews
                    }
                    if let desc = space.description, !desc.isEmpty {
                        Section(header: BigHeader("About this Space")) {
                            Text(desc)
                        }
                    }
                    DiscussionSection(space: space, spaceId: spaceId, onUpdate: onUpdate)
                }
                .listStyle(GroupedListStyle())
            } else {
                ZStack {
                    Color.groupedBackground.edgesIgnoringSafeArea(.all)
                    ScrollView {}
                    GeometryReader { geom in
                        BlankSlateView(name: name)
                            .padding(.top, geom.size.width > geom.size.height ? 44 : 92)
                            .edgesIgnoringSafeArea(.top)
                    }
                }
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: navMenu)
        .sheet(isPresented: $isAdding) {
            CreateEntityView(inSpace: spaceId, onDismiss: { isAdding = false }, onUpdate: onUpdate)
        }
        .additionalSheet(isPresented: $isEditing) {
            EditSpaceView(for: space, with: spaceId, onDismiss: { isEditing = false }, onUpdate: onUpdate)
        }
        .additionalSheet(isPresented: $isSharing) {
            ShareSpaceView(space: space, id: spaceId, onUpdate: onUpdate)
        }
        .actionSheet(item: $deletingEntities, content: deleteEntitiesActionSheet)
        .additionalActionSheet(isPresented: $isDeleting, content: deleteActionSheet)
    }

    func deleteEntitiesActionSheet(_ entities: [SpaceController.Entity]) -> ActionSheet {
        let title: String
        if entities.count == 1 {
            title = "Are you sure that you want to remove “\(entities[0].spaceEntity?.title ?? "")” from your space?"
        } else {
            title = "Are you sure that you want to remove \(entities.count) items from your space?"
        }
        return ActionSheet(title: Text(title), buttons: [
            .cancel(),
            .destructive(Text(entities.count == 1 ? "Delete" : "Delete \(entities.count) Items")) {
                entityDeleter.execute(deleting: entities)
            }
        ])
    }

    func deleteActionSheet() -> ActionSheet {
        let name = space.name ?? ""
        return ActionSheet(
            title: Text("Delete “\(name)” permanently?"),
            buttons: [
                .destructive(Text("Delete “\(name)”")) {
                    DeleteSpaceMutation(input: .init(id: spaceId)).perform { _ in
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                .cancel()
            ]
        )
    }

    var navMenu: some View {
        Menu {
            // TODO: implement
            // Button("Open All Links") /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/
            if space.userAcl?.acl >= .edit {
                Button(action: { isAdding = true }) {
                    Label("Add Item", systemImage: "plus")
                }

                // TODO: implement
                // Button("Reorder items") /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/
                if !space.isDefault {
                    Button(action: { isEditing = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            if !space.isDefault {
                if space.userAcl?.acl == .owner {
                    Button(action: { isSharing = true }) {
                        Label("Share", systemImage: "person.crop.circle.badge.plus")
                    }
                    Button(action: { isDeleting = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } else {
                    Button(action: { isSharing = true }) {
                        Label("Shared with", systemImage: "person.2.fill")
                    }
                }
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
                .font(.system(size: 17))
                .imageScale(.large)
                .labelStyle(IconOnlyLabelStyle())
        }

    }
}

struct BlankSlateView: View {
    let name: String?
    
    @Environment(\.onOpenURL) var onOpenURL
    var body: some View {
        VStack {
            Spacer()
            HStack { Spacer() }
            Text("No items")
                .font(.title).fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text("Add to your space by clicking the bookmark icon on a search result.")
                .multilineTextAlignment(.center)
                .font(.title3)
                .padding(20)
                .padding(.horizontal, 20)
            if let name = name, !name.isEmpty,
               let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                Button("Search for “\(name)”") {
                    onOpenURL(URL(string: "/search?q=\(encoded)&c=All&src=InternalSearchLink", relativeTo: NeevaConstants.appURL)!)
                }
                .font(.title3)
                .buttonStyle(BigBlueButtonStyle())
            }
            Spacer()
        }
    }
}

struct BigBlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 7)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .fill(Color.accentColor)
                    .opacity(configuration.isPressed ? 0.5 : 1)
                    .frame(minWidth: 230)
            )
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
            SpaceDetailView(space: testSpace, with: "", onUpdate: { _ in })
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
