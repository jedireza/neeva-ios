// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    @EnvironmentObject var browserModel: BrowserModel
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
                .animation(nil)

            if tabGroupCardModel.detailedTabGroup != nil {
                Color.secondaryBackground.frame(height: 2).edgesIgnoringSafeArea(.top)
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
                    .buttonStyle(.neeva(.primary))
                    .padding(16)
                }
            } else if spacesModel.detailedSpace != nil && primitive.allDetails.isEmpty
                && !(space?.isDigest ?? false)
            {
                EmptySpaceView()
            } else if showingAsList {
                spaceList
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
                            AddOrUpdateSpaceContent(space: space, config: .addSpaceItem) {
                                helpURL in
                                SceneDelegate.getBVC(with: tabModel.manager.scene).openURLInNewTab(
                                    helpURL)
                            }.environmentObject(spacesModel)
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
        if let space = space, !space.isDefaultSpace && !space.isDigest {
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
                                    browserModel.hideWithNoAnimation()
                                    spacesModel.detailedSpace = nil
                                    onOpenURL(url)
                                }
                                .environment(\.shareURL, shareURL)
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
        if showingAsList && canEdit, let space = space {
            Button(
                action: {
                    SceneDelegate.getBVC(with: tabModel.manager.scene)
                        .showModal(
                            style: .withTitle
                        ) {
                            AddOrUpdateSpaceContent(space: space, config: .updateSpace)
                                .environmentObject(spacesModel)
                        }
                    ClientLogger.shared.logCounter(
                        .SpacesDetailEditButtonClicked,
                        attributes: EnvironmentHelper.shared.getAttributes())
                },
                label: {
                    if !headerVisible {
                        Label(
                            title: {
                                Text("Edit Space")
                                    .withFont(.labelMedium)
                                    .foregroundColor(Color.label)
                            },
                            icon: { Image(systemName: "square.and.pencil") }
                        )
                    } else {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.label)
                            .tapTargetFrame()
                    }
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
                        ? .arrowDownRightAndArrowUpLeft : .arrowUpLeftAndArrowDownRight
                )
                .foregroundColor(Color.label)
                .tapTargetFrame()
            })
    }

    @ViewBuilder var menuButton: some View {
        Menu(
            content: {
                if let space = space, !space.isDefaultSpace {
                    deleteButton
                }

                if !headerVisible {
                    addButton
                    editButton
                    descriptionToggle
                }
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
                    Symbol(decorative: .arrowBackward)
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                })
            if case .active = editMode, tabGroupDetail != nil {
                VStack(spacing: 2) {
                    TextField(
                        "Enter a name for your tab group",
                        text: $newTitle,
                        onCommit: {
                            if newTitle != primitive.title {
                                tabGroupDict[tabGroupDetail!.id] = newTitle
                                tabGroupCardModel.manager.cleanUpTabGroupNames()
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
                    .animation(.easeInOut, value: headerVisible)
                } else {
                    Text(primitive.title)
                        .withFont(.headingMedium)
                        .foregroundColor(Color.label)
                        .opacity(headerVisible && tabGroupDetail == nil ? 0 : 1)
                        .animation(.easeInOut, value: headerVisible)
                }
            }
            Spacer()
            if let space = space {
                if headerVisible {
                    addButton
                    editButton
                    layoutButton
                }
                shareButton

                if !space.isDigest {
                    menuButton
                }
            } else {
                tabGroupEditButton
            }
        }.frame(height: gridModel.pickerHeight)
            .frame(maxWidth: .infinity)
            .background(Color.DefaultBackground.ignoresSafeArea())
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

    @ViewBuilder var spaceList: some View {
        if let spaceDetails = primitive as? SpaceCardDetails {
            SpaceDetailList(primitive: spaceDetails, headerVisible: $headerVisible)
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
                                .contextMenu {
                                    FeatureFlag[.tabGroupsPinning]
                                        ? TabGroupContextMenu(details: details) : nil
                                }
                                .modifier(
                                    CardTransitionModifier(
                                        details: details, containerGeometry: scrollGeometry,
                                        extraBottomPadding: topToolbar
                                            ? 0 : UIConstants.ToolbarHeight)
                                )
                                .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
                                .environment(\.selectionCompletion) {
                                    ClientLogger.shared.logCounter(.tabInTabGroupClicked)
                                    browserModel.hideWithAnimation()
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
