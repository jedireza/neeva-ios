// Copyright Neeva. All rights reserved.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI

struct SpaceDetailList: View {
    @Default(.showDescriptions) var showDescriptions
    @Default(.seenBlackFridayNotifyPromo) var seenBlackFridayNotifyPromo
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace
    @Environment(\.shareURL) var shareURL

    @ObservedObject var primitive: SpaceCardDetails
    let spaceCommentsModel = SpaceCommentsModel()
    @Binding var headerVisible: Bool

    var space: Space? {
        primitive.manager.get(for: primitive.id)
    }

    var promoCardType: PromoCardType? {
        guard
            primitive.id == SpaceStore.promotionalSpaceId
                && !seenBlackFridayNotifyPromo
                && NotificationPermissionHelper.shared.permissionStatus == .undecided
        else {
            return nil
        }

        return spacesModel.promoCard()
    }

    var canEdit: Bool {
        primitive.ACL >= .edit
    }

    var ownerName: String? {
        space?.acls.first(where: { $0.acl == .owner })?.profile.displayName
    }

    func descriptionForNote(_ details: SpaceEntityThumbnail) -> String? {
        if let snippet = details.data.snippet, snippet.contains("](@") {
            let index = snippet.firstIndex(of: "@")
            var substring = snippet.suffix(from: index!)
            if let endIndex = substring.firstIndex(of: ")") {
                substring = substring[..<endIndex]
                return snippet.replacingOccurrences(
                    of: substring,
                    with: neevaSearchEngine.searchURLForQuery(String(substring))!.absoluteString)
            }
        }
        return details.data.snippet
    }

    var body: some View {
        if gridModel.refreshDetailedSpaceSubscription != nil {
            ProgressView().padding(12)
        }
        NavigationView {
            List {
                if let promoCardType = promoCardType {
                    PromoCard(type: promoCardType, viewWidth: 390)
                        .buttonStyle(PlainButtonStyle())
                        .modifier(ListSeparatorModifier())
                }
                SpaceHeaderView(space: space!)
                    .modifier(ListSeparatorModifier())
                    .iPadOnlyID()
                    .onAppear {
                        headerVisible = UIDevice.current.userInterfaceIdiom != .pad
                    }
                    .onDisappear {
                        headerVisible = false
                    }
                ForEach(primitive.allDetails, id: \.id) { details in
                    let editSpaceItem = {
                        guard let space = space else {
                            return
                        }

                        SceneDelegate.getBVC(with: tabModel.manager.scene)
                            .showModal(
                                style: .withTitle
                            ) {
                                AddOrUpdateSpaceContent(
                                    space: space,
                                    config: .updateSpaceItem(details.id)
                                )
                                .environmentObject(spacesModel)
                            }
                    }
                    if let url = details.data.url {
                        SpaceEntityDetailView(
                            details: details,
                            onSelected: {
                                let bvc = SceneDelegate.getBVC(with: tabModel.manager.scene)
                                if let navPath = NavigationPath.navigationPath(
                                    from: url, with: bvc)
                                {
                                    gridModel.hideWithNoAnimation()
                                    spacesModel.detailedSpace = nil

                                    NavigationPath.handle(nav: navPath, with: bvc)
                                    return
                                }
                                onOpenURLForSpace(url, primitive.id)
                                gridModel.hideWithNoAnimation()
                                spacesModel.detailedSpace = nil
                            },
                            onDelete: { index in
                                onDelete(offsets: IndexSet([index]))
                            },
                            addToAnotherSpace: { url, title, description in
                                spacesModel.detailedSpace = nil
                                SceneDelegate.getBVC(with: tabModel.manager.scene)
                                    .showAddToSpacesSheet(
                                        url: url, title: title, description: description)
                            },
                            editSpaceItem: editSpaceItem,
                            index: primitive.allDetails.firstIndex { $0.id == details.id } ?? 0
                        )
                        .modifier(ListSeparatorModifier())
                        .listRowBackground(Color.DefaultBackground)
                        .onDrag {
                            NSItemProvider(id: details.id)
                        }
                        .iPadOnlyID()
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(details.title)
                                .withFont(.headingMedium)
                                .foregroundColor(.label)
                            if let description = descriptionForNote(details), !description.isEmpty {
                                if #available(iOS 15.0, *),
                                    let attributedSnippet = try? AttributedString(
                                        markdown: description)
                                {
                                    Text(attributedSnippet)
                                        .withFont(.bodyLarge)
                                        .lineLimit(3)
                                        .modifier(DescriptionTextModifier())
                                } else {
                                    Text(description)
                                        .withFont(.bodyLarge)
                                        .lineLimit(3)
                                        .modifier(DescriptionTextModifier())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .modifier(
                            EditSpaceActionModifier(
                                details: details,
                                onDelete: { index in
                                    onDelete(offsets: IndexSet([index]))
                                }, editSpaceItem: editSpaceItem,
                                index: primitive.allDetails.firstIndex { $0.id == details.id } ?? 0)
                        )
                        .modifier(ListSeparatorModifier())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondaryBackground)
                        .onDrag {
                            NSItemProvider(id: details.id)
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
                if let space = space {
                    SpaceCommentsView(space: space, model: spaceCommentsModel)
                        .modifier(ListSeparatorModifier())
                }
            }
            .modifier(ListStyleModifier())
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea([.top, .bottom])
        }.modifier(iPadOnlyStackNavigation())
    }

    private func onDelete(offsets: IndexSet) {
        let entitiesToBeDeleted = offsets.map { index in
            primitive.allDetails[index]
        }

        primitive.allDetails.remove(atOffsets: offsets)
        spacesModel.delete(
            space: primitive.id, entities: entitiesToBeDeleted, from: tabModel.manager.scene
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

struct CompactSpaceDetailList: View {
    let primitive: SpaceCardDetails
    @Environment(\.onOpenURLForSpace) var onOpenURLForSpace

    var body: some View {
        VStack {
            ForEach(primitive.allDetails, id: \.id) { details in
                if let url = details.data.url {
                    Button(
                        action: {
                            onOpenURLForSpace(url, primitive.id)
                        },
                        label: {
                            HStack(alignment: .center, spacing: 12) {
                                details.thumbnail.frame(width: 36, height: 36).cornerRadius(8)
                                Text(details.title).withFont(.labelMedium).foregroundColor(.label)
                                Spacer()
                            }.padding(.horizontal, 16)
                        })
                }
            }
        }
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

struct CompactSeparatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listSectionSeparator(Visibility.hidden)
                .listRowSeparator(Visibility.hidden)
        } else {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
                .padding(.horizontal, 16)
        }
    }
}

struct ListStyleModifier: ViewModifier {
    @Environment(\.onOpenURLForSpace) var openURLForSpace
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var spaceModel: SpaceCardModel

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listStyle(.plain)
                .background(Color.TrayBackground)
                .environment(
                    \.openURL,
                    OpenURLAction(handler: {
                        gridModel.hideWithNoAnimation()
                        openURLForSpace($0, spaceModel.detailedSpace!.id)
                        spaceModel.detailedSpace = nil
                        return .handled
                    })
                )
                .refreshable {
                    gridModel.refreshDetailedSpace()
                }
        } else {
            content
        }
    }
}

struct iPadOnlyStackNavigation: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.useTabletInterface {
            content
                .navigationViewStyle(.stack)
        } else {
            content
                .navigationViewStyle(.automatic)
        }
    }
}

extension View {
    @ViewBuilder func iPadOnlyID() -> some View {
        if UIDevice.current.useTabletInterface {
            self.id(UUID())
        } else {
            self
        }
    }
}
