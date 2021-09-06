// Copyright Neeva. All rights reserved.

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
    @EnvironmentObject var spacesModel: SpaceCardModel
    @Environment(\.onOpenURL) var openURL
    @Environment(\.shareURL) var shareURL
    @Environment(\.columns) var gridColumns
    @State private var editMode = EditMode.inactive
    @State private var shareMenuPresented = false
    @State private var presentShareOnDismiss = false

    let primitive: Details

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

    var body: some View {
        VStack(spacing: 0) {
            topBar
            if gridModel.showingDetailsAsList {
                spaceList
            } else {
                spaceGrid
            }
        }
    }

    var topBar: some View {
        HStack {
            Button(
                action: {
                    withAnimation {
                        spacesModel.detailedSpace = nil
                    }
                },
                label: {
                    Symbol(decorative: .arrowLeft)
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                })
            Text(primitive.title)
                .withFont(.labelLarge)
                .foregroundColor(Color.label)
            if primitive.isSharedPublic {
                Symbol(decorative: .link, style: .labelMedium)
                    .foregroundColor(.secondaryLabel)
            }
            if primitive.isSharedWithGroup {
                Symbol(decorative: .person2Fill, style: .labelMedium)
                    .foregroundColor(.secondaryLabel)
            }
            Spacer()
            if let space = space {
                Button(
                    action: {
                        if case .owner = space.userACL {
                            shareMenuPresented = true
                        } else {
                            shareURL(space.url)
                        }
                    },
                    label: {
                        Image(
                            systemName: "square.and.arrow.up"
                        )
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                    }
                ).presentAsPopover(
                    isPresented: $shareMenuPresented,
                    onDismiss: {
                        guard presentShareOnDismiss else {
                            return
                        }
                        shareURL(space.url)
                        presentShareOnDismiss = false
                    }
                ) {
                    ShareSpaceView(space: space, presentShareOnDismiss: $presentShareOnDismiss) {
                        self.shareMenuPresented = false
                    }
                    .environmentObject(spacesModel)
                }
            }
            if gridModel.showingDetailsAsList && canEdit {
                Button(
                    action: {
                        switch editMode {
                        case .inactive:
                            editMode = .active
                        case .active:
                            editMode = .inactive
                        default:
                            print("Pressed button again during transition. Ignoring...")
                        }
                    },
                    label: {
                        Image(
                            systemName: "square.and.pencil"
                        )
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                    })
            }
        }.frame(height: gridModel.pickerHeight)
            .frame(maxWidth: .infinity)
            .background(Color.background.edgesIgnoringSafeArea(.horizontal))
    }

    var spaceList: some View {
        List {
            ForEach(primitive.allDetails, id: \.id) { details in
                if let entity = details.manager.get(for: details.id) {
                    if let url = entity.primitiveUrl {
                        SingleDetailView(details: details) {
                            openURL(url)
                            gridModel.hideWithNoAnimation()
                            spacesModel.detailedSpace = nil
                        }
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
            }.onDelete(perform: onDelete)
                .onMove(perform: onMove)
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
                            openURL(
                                (details.manager.get(for: details.id)?.primitiveUrl)!)
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

struct SingleDetailView<Details: CardDetails>: View {
    let details: Details
    let onSelected: () -> Void
    var description: String {
        details.id
    }
    @State private var isPressed: Bool = false

    var body: some View {
        VStack {
            Button {
                onSelected()
            } label: {
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
            }.buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
                .padding()
                .background(Color.DefaultBackground)
            Color.TrayBackground.frame(height: 1)
        }.scaleEffect(isPressed ? 0.95 : 1)

    }

}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            primitive: SpaceCardDetails(
                space: .stackOverflow, bvc: SceneDelegate.getBVC(for: nil),
                manager: SpaceStore.shared))
    }
}
