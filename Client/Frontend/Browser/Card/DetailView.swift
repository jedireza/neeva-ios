// Copyright Neeva. All rights reserved.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum DetailsViewUX {
    static let Padding: CGFloat = 4
    static let ThumbnailCornerRadius: CGFloat = 6
    static let ThumbnailSize: CGFloat = 54
    static let DetailThumbnailSize: CGFloat = 72
    static let ItemPadding: CGFloat = 14
    static let EditingRowInset: CGFloat = 8
}

struct DetailView<Details: ThumbnailModel>: View
where
    Details: AccessingManagerProvider,
    Details.Thumbnail: CardDetails, Details: CardDetails,
    Details.Thumbnail: AccessingManagerProvider
{
    @Default(.tabGroupNames) var tabGroupDict: [String: String]
    @Default(.showDescriptions) var showDescriptions
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    @Environment(\.onOpenURL) var onOpenURL
    @Environment(\.shareURL) var shareURL
    @Environment(\.columns) var gridColumns
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var editMode = EditMode.inactive
    @State private var shareMenuPresented = false
    @State private var newTitle: String = ""
    @State private var shareTargetView: UIView? = nil
    @State private var showConfirmDeleteAlert = false
    @State private var headerVisible = true

    @ObservedObject var primitive: Details
    var dismissWithAnimation: () -> Void
    @State var selectedTabIDs: [String] = []

    var topToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var space: Space? {
        primitive.manager.get(for: primitive.id) as? Space
    }

    var tabGroupDetail: TabGroupCardDetails? {
        primitive as? TabGroupCardDetails
    }

    let listColumns = Array(
        repeating:
            GridItem(
                .flexible(),
                spacing: DetailsViewUX.Padding),
        count: 1)

    var canEdit: Bool {
        primitive.ACL >= .edit
    }

    var showingAsList: Bool {
        spacesModel.detailedSpace != nil ? true : false
    }

    var ownerName: String? {
        space?.acls.first(where: { $0.acl == .owner })?.profile.displayName
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Color.secondaryBackground.frame(height: 2).edgesIgnoringSafeArea(.top)
            if tabGroupCardModel.detailedTabGroup != nil {
                tabGroupGrid

                if editMode == .active {
                    Button(
                        action: {
                            selectedTabIDs.forEach {
                                tabModel.manager.get(for: $0)?.rootUUID =
                                    UUID().uuidString
                            }
                            tabModel.manager.objectWillChange.send()
                            editMode = .inactive

                            var attributes = EnvironmentHelper.shared.getAttributes()

                            attributes.append(
                                ClientLogCounterAttribute(
                                    key: LogConfig.TabGroupAttribute.numTabsRemoved,
                                    value: String(selectedTabIDs.count)
                                )
                            )

                            ClientLogger.shared.logCounter(
                                .tabRemovedFromGroup, attributes: attributes)
                        },
                        label: {
                            Text("Remove from group")
                                .withFont(.labelLarge)
                                .frame(maxWidth: .infinity)
                                .clipShape(Capsule())
                        }
                    )
                    .environment(\.isEnabled, selectedTabIDs.count > 0)
                    .buttonStyle(NeevaButtonStyle(.primary))
                    .padding(16)
                }
            } else if spacesModel.detailedSpace != nil && primitive.allDetails.isEmpty {
                EmptySpaceView()
            } else if showingAsList {
                spaceList
            } else {
                spaceGrid
            }
        }
        .accessibilityHidden(shareMenuPresented)
        .onDisappear {
            gridModel.animateDetailTransitions = true
        }
    }

    @ViewBuilder var addButton: some View {
        if let space = space, canEdit {
            Button(
                action: {
                    DispatchQueue.main.async {
                        SceneDelegate.getBVC(with: tabModel.manager.scene).showModal(
                            style: .withTitle
                        ) {
                            AddToNativeSpaceOverlayContent(space: space)
                                .environmentObject(spacesModel)
                        }
                    }
                },
                label: {
                    if !headerVisible {
                        Label(
                            title: {
                                Text("Add Item")
                                    .withFont(.labelMedium)
                                    .foregroundColor(Color.label)
                            },
                            icon: { Image(systemName: "plus.square") }
                        )
                    } else {
                        Image(systemName: "plus")
                            .foregroundColor(.label)
                            .tapTargetFrame()
                    }
                }
            )
        }
    }

    @ViewBuilder var shareButton: some View {
        if let space = space {
            Button(
                action: {
                    if case .owner = space.userACL {
                        SceneDelegate.getBVC(with: tabModel.manager.scene)
                            .showModal(
                                style: .withTitle
                            ) {
                                ShareSpaceContent(
                                    space: space,
                                    shareTargetView: shareTargetView ?? UIView(),
                                    fromAddToSpace: false,
                                    noteText: "Check out my Neeva Space!"
                                )
                                .environmentObject(spacesModel)
                                .environmentObject(tabModel)
                                .environment(\.onOpenURL) { url in
                                    gridModel.hideWithNoAnimation()
                                    spacesModel.detailedSpace = nil
                                    onOpenURL(url)
                                }
                            }
                    } else {
                        shareURL(space.url, shareTargetView ?? UIView())
                        ClientLogger.shared.logCounter(
                            .FollowerSharedSpace,
                            attributes: getLogCounterAttributesForSpaces(
                                details: primitive as? SpaceCardDetails))
                    }
                    ClientLogger.shared.logCounter(
                        .SpacesDetailShareButtonClicked,
                        attributes: EnvironmentHelper.shared.getAttributes())
                },
                label: {
                    Image(
                        systemName: "square.and.arrow.up"
                    )
                    .foregroundColor(Color.label)
                    .tapTargetFrame()
                }
            ).uiViewRef($shareTargetView)
        }
    }

    @ViewBuilder var editButton: some View {
        if showingAsList && canEdit {
            Button(
                action: {
                    switch editMode {
                    case .inactive:
                        newTitle = primitive.title

                        withAnimation {
                            editMode = .active
                        }
                    case .active:
                        withAnimation {
                            editMode = .inactive
                        }

                        if let space = space, newTitle != primitive.title {
                            spacesModel.updateSpaceName(space: space, newTitle: newTitle)
                        }
                    default:
                        Logger.browser.info("Pressed button again during transition. Ignoring...")
                    }
                    ClientLogger.shared.logCounter(
                        .SpacesDetailEditButtonClicked,
                        attributes: EnvironmentHelper.shared.getAttributes())
                },
                label: {
                    Label(
                        title: {
                            Text(editMode == .inactive ? "Edit Space" : "Done Editing")
                                .withFont(.labelMedium)
                                .foregroundColor(Color.label)
                        },
                        icon: { Image(systemName: "square.and.pencil") }
                    )
                })
        }
    }

    @ViewBuilder var deleteButton: some View {
        Button {
            showConfirmDeleteAlert = true
        } label: {
            Label(
                title: {
                    Text(space?.ACL == .owner ? "Delete Space" : "Unfollow")
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                },
                icon: { Image(systemName: "trash") }
            )
        }
    }

    @ViewBuilder var webUIButton: some View {
        Button {
            if let space = space {
                gridModel.hideWithNoAnimation()
                spacesModel.detailedSpace = nil
                onOpenURLForSpace(space.url, space.id.id)
            }
        } label: {
            Label(
                title: {
                    Text("Open as Website")
                        .withFont(.labelMedium)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                },
                icon: { Image(systemName: "doc.richtext") }
            )
        }
    }

    var descriptionToggle: some View {
        Toggle(isOn: $showDescriptions) {
            Text("Show Descriptions")
                .withFont(.labelMedium)
                .foregroundColor(.secondaryLabel)
        }
    }

    var layoutButton: some View {
        Button(
            action: { showDescriptions.toggle() },
            label: {
                Symbol(
                    decorative: showDescriptions
                        ? .rectangleArrowtriangle2Inward : .rectangleArrowtriangle2Outward
                )
                .foregroundColor(Color.label)
                .tapTargetFrame()
            })
    }

    @ViewBuilder var menuButton: some View {
        Menu(
            content: {
                deleteButton
                editButton
                if !headerVisible {
                    addButton
                    descriptionToggle
                }
                webUIButton
            },
            label: {
                Symbol(decorative: .ellipsis, style: .labelMedium)
                    .foregroundColor(Color.label)
                    .tapTargetFrame()
            }
        ).actionSheet(isPresented: $showConfirmDeleteAlert) {
            ActionSheet(
                title: Text(
                    "Are you sure you want to " + (space?.ACL == .owner ? "delete" : "unfollow")
                        + " this space?"),
                buttons: [
                    .destructive(
                        Text(space?.ACL == .owner ? "Delete Space" : "Unfollow Space"),
                        action: {
                            if let space = space {
                                guard
                                    let index = spacesModel.allDetails.firstIndex(where: {
                                        primitive.id == $0.id
                                    })
                                else {
                                    return
                                }

                                spacesModel.allDetails.remove(at: index)
                                spacesModel.removeSpace(
                                    spaceID: space.id.id, isOwner: space.ACL == .owner)
                            }
                        })
                ])
        }
    }

    var topBar: some View {
        HStack {
            Button(
                action: dismissWithAnimation,
                label: {
                    Symbol(decorative: .arrowLeft)
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                })
            if case .active = editMode {
                VStack(spacing: 2) {
                    TextField(
                        space != nil
                            ? "Enter a name for your Space" : "Enter a name for your tab group",
                        text: $newTitle,
                        onCommit: {
                            if newTitle != primitive.title {
                                if let space = space {
                                    spacesModel.updateSpaceName(space: space, newTitle: newTitle)
                                } else {
                                    tabGroupDict[tabGroupDetail!.id] = newTitle
                                    tabGroupCardModel.manager.cleanUpTabGroupNames()
                                }
                            }
                            editMode = .inactive
                        }
                    )
                    .lineLimit(1)
                    .foregroundColor(Color.label)
                    Color.label
                        .frame(height: 1)
                }
            } else {
                if let ownerName = ownerName {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(primitive.title)
                            .withFont(.headingSmall)
                            .foregroundColor(Color.label)
                        Text(ownerName)
                            .withFont(.bodyXSmall)
                            .foregroundColor(Color.secondaryLabel)
                    }
                    .opacity(headerVisible ? 0 : 1)
                    .animation(.easeInOut)
                } else {
                    Text(primitive.title)
                        .withFont(.headingMedium)
                        .foregroundColor(Color.label)
                        .opacity(headerVisible ? 0 : 1)
                        .animation(.easeInOut)
                }

            }
            Spacer()
            if space != nil {
                if headerVisible && editMode != .active {
                    addButton
                    layoutButton
                }
                shareButton
                menuButton
            } else {
                tabGroupEditButton
            }
        }.frame(height: gridModel.pickerHeight)
            .frame(maxWidth: .infinity)
            .background(Color.DefaultBackground.edgesIgnoringSafeArea(.horizontal))
    }

    var tabGroupEditButton: some View {
        Button(
            action: {
                switch editMode {
                case .inactive:
                    newTitle = primitive.title
                    editMode = .active
                case .active:
                    editMode = .inactive
                    if newTitle != primitive.title {
                        tabGroupDict[tabGroupDetail!.id] = newTitle
                        tabGroupCardModel.manager.cleanUpTabGroupNames()
                    }
                default: break
                }
            }) {
                if case .inactive = editMode {
                    Text("Edit")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                        .padding(.horizontal, 15)
                } else if case .active = editMode {
                    Text("Done")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                        .padding(.horizontal, 15)
                }
            }
    }

    var spaceList: some View {
        NavigationView {
            List {
                SpaceHeaderView(space: space!)
                    .modifier(ListSeparatorModifier())
                    .onAppear {
                        headerVisible = true
                    }
                    .onDisappear {
                        headerVisible = false
                    }
                ForEach(primitive.allDetails, id: \.id) { details in
                    if let entity = details.manager.get(for: details.id) {
                        if let url = entity.primitiveUrl,
                            let spaceEntityDetails = details as? SpaceEntityThumbnail
                        {
                            SpaceEntityDetailView(
                                details: spaceEntityDetails,
                                onSelected: {
                                    onOpenURLForSpace(url, primitive.id)
                                    gridModel.hideWithNoAnimation()
                                    spacesModel.detailedSpace = nil
                                },
                                addToAnotherSpace: { url, title, description in
                                    spacesModel.detailedSpace = nil
                                    SceneDelegate.getBVC(with: tabModel.manager.scene)
                                        .showAddToSpacesSheet(
                                            url: url, title: title, description: description)
                                },
                                editSpaceItem: {
                                    guard let space = space else {
                                        return
                                    }

                                    SceneDelegate.getBVC(with: tabModel.manager.scene)
                                        .showModal(
                                            style: .withTitle
                                        ) {
                                            AddToNativeSpaceOverlayContent(
                                                space: space, entityID: details.id
                                            )
                                            .environmentObject(spacesModel)
                                        }
                                },
                                index: primitive.allDetails.firstIndex { $0.id == details.id } ?? 0
                            )
                            .modifier(ListSeparatorModifier())
                            .listRowBackground(Color.DefaultBackground)
                            .onDrag {
                                NSItemProvider(id: details.id)
                            }
                        } else {
                            Text(entity.displayTitle)
                                .withFont(.headingMedium)
                                .foregroundColor(.label)
                                .textCase(.none)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondaryBackground)
                                .modifier(ListSeparatorModifier())
                                .onDrag {
                                    NSItemProvider(id: details.id)
                                }
                        }
                    }
                }
                .onDelete(perform: canEdit ? onDelete : nil)
                .onMove(perform: canEdit ? onMove : nil)
                if let generators = space?.generators, !generators.isEmpty {
                    SpaceGeneratorHeader(generators: generators)
                        .modifier(ListSeparatorModifier())
                    ForEach(generators, id: \.id) { generator in
                        SpaceGeneratorView(generator: generator)
                            .modifier(ListSeparatorModifier())
                    }
                }
            }
            .background(Color.groupedBackground)
            .modifier(ListStyleModifier())
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea([.top, .bottom])
        }
    }

    var spaceGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: gridColumns,
                spacing: DetailsViewUX.Padding
            ) {
                ForEach(primitive.allDetails, id: \.id) { details in
                    VStack(spacing: 0) {
                        FittedCard(details: details).environment(\.selectionCompletion) {
                            onOpenURLForSpace(
                                (details.manager.get(for: details.id)?.primitiveUrl)!, primitive.id)
                            gridModel.hideWithNoAnimation()
                            spacesModel.detailedSpace = nil
                        }
                        HStack {
                            Spacer(minLength: DetailsViewUX.ItemPadding)
                            Text(details.title)
                                .withFont(.labelMedium)
                                .lineLimit(1)
                                .foregroundColor(Color.label)
                                .frame(height: CardUX.HeaderSize)
                            Spacer(minLength: DetailsViewUX.ItemPadding)
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, DetailsViewUX.Padding)
        }
    }

    func tabSelectButtonOverlay(details: TabCardDetails) -> some View {
        Group {
            if editMode == .active {
                Button(action: {
                    if let index = selectedTabIDs.firstIndex(where: { $0 == details.id }) {
                        selectedTabIDs.remove(at: index)
                    } else {
                        selectedTabIDs.append(details.id)
                    }
                }) {
                    Image(
                        systemSymbol: selectedTabIDs.contains(details.id)
                            ? .checkmarkCircleFill : .circle
                    )
                    .resizable().renderingMode(.template)
                    .foregroundColor(
                        selectedTabIDs.contains(details.id) ? .ui.adaptive.blue : .tertiaryLabel
                    )
                    .padding(2)
                    .frame(width: 24, height: 24)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
                    .padding(6)
                }
            }
        }
    }

    var tabGroupGrid: some View {
        GeometryReader { scrollGeometry in
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollProxy in
                    LazyVGrid(columns: gridColumns, spacing: CardGridUX.GridSpacing) {
                        ForEach(tabGroupDetail!.allDetails, id: \.id) { details in
                            FittedCard(details: details)
                                .modifier(
                                    CardTransitionModifier(
                                        details: details, containerGeometry: scrollGeometry,
                                        extraBottomPadding: topToolbar
                                            ? 0 : UIConstants.ToolbarHeight)
                                )
                                .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
                                .environment(\.selectionCompletion) {
                                    ClientLogger.shared.logCounter(.tabInTabGroupClicked)
                                    gridModel.hideWithAnimation()
                                }
                                .overlay(
                                    tabSelectButtonOverlay(details: details),
                                    alignment: .topTrailing)
                        }
                    }
                    .padding(.vertical, CardGridUX.GridSpacing)
                    .onAppear {
                        if let selectedItem = primitive.allDetails.first(where: \.isSelected) {
                            scrollProxy.scrollTo(selectedItem.id)
                        }
                    }
                }
            }
            .environment(\.columns, gridColumns)
        }
        .ignoresSafeArea(edges: topToolbar ? [.bottom] : [])
    }

    private func onDelete(offsets: IndexSet) {
        let entitiesToBeDeleted = offsets.map { index in
            primitive.allDetails[index]
        }

        let deletedEntities: [SpaceEntityThumbnail] = entitiesToBeDeleted.compactMap { entity in
            entity as? SpaceEntityThumbnail
        }

        primitive.allDetails.remove(atOffsets: offsets)
        spacesModel.delete(
            space: primitive.id, entities: deletedEntities, from: tabModel.manager.scene
        ) {
            for index in 0..<entitiesToBeDeleted.count {
                primitive.allDetails.insert(entitiesToBeDeleted[index], at: 0)
            }
        }
    }

    private func onMove(source: IndexSet, destination: Int) {
        primitive.allDetails.move(fromOffsets: source, toOffset: destination)
        spacesModel.reorder(space: primitive.id, entities: primitive.allDetails.map { $0.id })
    }
}

struct ListSeparatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
                .listSectionSeparator(Visibility.hidden)
                .listRowSeparator(Visibility.hidden)
                .listSectionSeparatorTint(Color.TrayBackground)
        } else {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
        }
    }
}

struct ListStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listStyle(.plain)
                .background(Color.TrayBackground)
        } else {
            content
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            primitive: SpaceCardDetails(
                space: .stackOverflow,
                manager: SpaceStore.shared)
        ) {}
    }
}
