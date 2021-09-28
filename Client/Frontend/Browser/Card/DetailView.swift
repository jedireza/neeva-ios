// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

enum DetailsViewUX {
    static let Padding: CGFloat = 2
    static let ThumbnailCornerRadius: CGFloat = 6
    static let ThumbnailSize: CGFloat = 54
    static let ItemPadding: CGFloat = 14
    static let EditingRowInset: CGFloat = 8
}

struct DetailView<Details: ThumbnailModel>: View
where
    Details: AccessingManagerProvider,
    Details.Thumbnail: CardDetails, Details: CardDetails,
    Details.Thumbnail: AccessingManagerProvider
{
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupCardModel: TabGroupCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    @Environment(\.onOpenURL) var onOpenURL
    @Environment(\.shareURL) var shareURL
    @Environment(\.columns) var gridColumns
    @State private var editMode = EditMode.inactive
    @State private var shareMenuPresented = false
    @State private var newTitle: String = ""
    @State private var shareTargetView: UIView!

    @ObservedObject var primitive: Details

    var space: Space? {
        primitive.manager.get(for: primitive.id) as? Space
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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                topBar
                if tabGroupCardModel.detailedTabGroup != nil {
                    tabGroupGrid
                } else if spacesModel.detailedSpace != nil && primitive.allDetails.isEmpty {
                    EmptySpaceView()
                } else if showingAsList {
                    spaceList
                } else {
                    spaceGrid
                }
            }.accessibilityHidden(shareMenuPresented)
            if let space = space, shareMenuPresented {
                ShareSpaceView(
                    space: space,
                    shareTarget: shareTargetView,
                    isPresented: $shareMenuPresented
                )
                .environmentObject(spacesModel)
                .transition(.flipFromRight)
                .animation(.easeInOut)
            }
        }
    }

    @ViewBuilder var addButton: some View {
        if let space = space, canEdit {
            Button(
                action: {
                    SceneDelegate.getBVC(with: tabModel.manager.scene).showModal(
                        style: .withTitle
                    ) {
                        AddToNativeSpaceOverlayContent(space: space)
                            .environmentObject(spacesModel)
                    }
                },
                label: {
                    Label(
                        title: {
                            Text("Add Item")
                                .withFont(.labelMedium)
                                .foregroundColor(Color.label)
                        },
                        icon: { Image(systemName: "plus.square") }
                    )
                }
            )
        }
    }

    @ViewBuilder var shareButton: some View {
        if let space = space {
            Button(
                action: {
                    if case .owner = space.userACL {
                        shareMenuPresented = true
                    } else {
                        shareURL(space.url, shareTargetView)
                        ClientLogger.shared.logCounter(
                            .FollowerSharedSpace,
                            attributes: getLogCounterAttributesForSpaces(
                                details: primitive as! SpaceCardDetails))
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
                        editMode = .active
                    case .active:
                        editMode = .inactive
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
            if let space = space {
                guard
                    let index = spacesModel.allDetails.firstIndex(where: {
                        primitive.id == $0.id
                    })
                else {
                    return
                }
                spacesModel.allDetails.remove(at: index)
                spacesModel.removeSpace(spaceID: space.id.id, isOwner: space.ACL == .owner)
            }
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

    @ViewBuilder var menuButton: some View {
        Menu(
            content: {
                deleteButton
                editButton
                addButton
                webUIButton
            },
            label: {
                Symbol(decorative: .ellipsis, style: .labelMedium)
                    .foregroundColor(Color.label)
                    .tapTargetFrame()
            })
    }

    var topBar: some View {
        HStack {
            Button(
                action: {
                    if space != nil {
                        withAnimation {
                            spacesModel.detailedSpace = nil
                        }
                    } else {
                        withAnimation {
                            tabGroupCardModel.detailedTabGroup = nil
                        }
                    }
                },
                label: {
                    Symbol(decorative: .arrowLeft)
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                })
            if case .active = editMode {
                VStack(spacing: 2) {
                    TextField(
                        "Enter a name for your Space", text: $newTitle,
                        onCommit: {
                            if let space = space, newTitle != primitive.title {
                                spacesModel.updateSpaceName(space: space, newTitle: newTitle)
                            }
                        }
                    )
                    .lineLimit(1)
                    .foregroundColor(Color.label)
                    Color.ui.adaptive.separator
                        .frame(height: 1)
                }
            } else {
                Text(primitive.title)
                    .withFont(.labelLarge)
                    .foregroundColor(Color.label)
            }
            if primitive.isSharedPublic {
                Symbol(decorative: .link, style: .labelMedium)
                    .foregroundColor(.secondaryLabel)
            }
            if primitive.isSharedWithGroup {
                Symbol(decorative: .person2Fill, style: .labelMedium)
                    .foregroundColor(.secondaryLabel)
            }
            Spacer()
            if space != nil {
                shareButton
                menuButton
            }
        }.frame(height: gridModel.pickerHeight)
            .frame(maxWidth: .infinity)
            .background(Color.DefaultBackground.edgesIgnoringSafeArea(.horizontal))
    }

    var spaceList: some View {
        List {
            ForEach(primitive.allDetails, id: \.id) { details in
                if let entity = details.manager.get(for: details.id) {
                    if let url = entity.primitiveUrl {
                        SingleDetailView(
                            details: details,
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
                            }
                        )
                        .listRowInsets(
                            EdgeInsets.init(
                                top: 0,
                                leading: editMode == .active ? DetailsViewUX.EditingRowInset : 0,
                                bottom: 0,
                                trailing: editMode == .active ? DetailsViewUX.EditingRowInset : 0)
                        )
                        .listRowBackground(Color.TrayBackground)
                    } else {
                        Section(
                            header: Text(entity.displayTitle)
                                .withFont(.headingSmall)
                                .textCase(.none)
                                .padding(.horizontal)
                                .padding(.top, 14)
                                .padding(.bottom, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.TrayBackground)
                        ) {}
                        .listRowInsets(
                            EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                    }
                }
            }.onDelete(perform: canEdit ? onDelete : nil)
                .onMove(perform: canEdit ? onMove : nil)
        }
        .environment(\.editMode, canEdit ? $editMode : nil)
        .background(Color.groupedBackground)
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

    var tabGroupGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: gridColumns,
                spacing: CardGridUX.GridSpacing
            ) {
                ForEach(primitive.allDetails, id: \.id) { details in
                    FittedCard(details: details)
                        .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
                        .environment(\.selectionCompletion) {
                            gridModel.hideWithNoAnimation()
                            tabGroupCardModel.detailedTabGroup = nil
                        }
                }
                Spacer()
            }
            .padding(.vertical, CardGridUX.GridSpacing)
            .background(Color.clear)
        }
    }

    private func onDelete(offsets: IndexSet) {
        let deletedEntities: [String] = offsets.map { index in
            primitive.allDetails[index].id
        }
        primitive.allDetails.remove(atOffsets: offsets)
        spacesModel.delete(space: primitive.id, entities: deletedEntities)
    }

    private func onMove(source: IndexSet, destination: Int) {
        primitive.allDetails.move(fromOffsets: source, toOffset: destination)
        spacesModel.reorder(space: primitive.id, entities: primitive.allDetails.map { $0.id })
    }
}

struct SingleDetailView<Details: CardDetails>: View where Details: AccessingManagerProvider {
    let details: Details
    let onSelected: () -> Void
    let addToAnotherSpace: (URL, String?, String?) -> Void
    let editSpaceItem: () -> Void

    var hostAndPath: String? {
        details.manager.get(for: details.id)?.primitiveUrl?.normalizedHostAndPath
    }

    var isImage: Bool {
        guard let hostAndPath = hostAndPath else {
            return false
        }

        return hostAndPath.hasSuffix(".jpeg")
            || hostAndPath.hasSuffix(".jpg")
            || hostAndPath.hasSuffix(".png")
    }

    @State private var isPressed: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Color.TrayBackground.frame(height: 2)
            Button {
                onSelected()
                ClientLogger.shared.logCounter(
                    .SpacesDetailEntityClicked,
                    attributes: EnvironmentHelper.shared.getAttributes())
            } label: {
                if isImage, let url = details.manager.get(for: details.id)?.primitiveUrl {
                    VStack(spacing: 0) {
                        WebImage(url: url).resizable()
                            .transition(.fade(duration: 0.5))
                            .background(Color.white)
                            .scaledToFit().frame(maxHeight: 120)
                            .padding(16)
                        if !details.title.isEmpty {
                            Text(details.title)
                                .withFont(.bodyMedium)
                                .lineLimit(1)
                                .foregroundColor(Color.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else {
                    HStack(spacing: DetailsViewUX.ItemPadding) {
                        details.thumbnail.frame(
                            width: DetailsViewUX.ThumbnailSize, height: DetailsViewUX.ThumbnailSize
                        )
                        .cornerRadius(DetailsViewUX.ThumbnailCornerRadius)
                        VStack(spacing: DetailsViewUX.Padding) {
                            Text(details.title)
                                .withFont(.bodyMedium)
                                .lineLimit(2)
                                .foregroundColor(Color.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let snippet = details.description {
                                Text(snippet)
                                    .withFont(.bodySmall)
                                    .lineLimit(2)
                                    .foregroundColor(Color.secondaryLabel)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }.buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
                .padding()
                .background(Color.DefaultBackground)
        }.scaleEffect(isPressed ? 0.95 : 1)
            .contextMenu(
                ContextMenu(menuItems: {
                    if details.ACL >= .edit {
                        Button(
                            action: {
                                editSpaceItem()
                            },
                            label: {
                                Label("Edit item", systemSymbol: .squareAndPencil)
                            })
                    }
                    Button(
                        action: {
                            addToAnotherSpace(
                                (details.manager.get(for: details.id)?.primitiveUrl)!,
                                details.title, details.description)
                        },
                        label: {
                            Label("Add to another Space", systemSymbol: .docOnDoc)
                        })
                })
            )
            .accessibilityLabel(details.title).accessibilityHint("Space Item")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            primitive: SpaceCardDetails(
                space: .stackOverflow,
                manager: SpaceStore.shared))
    }
}
