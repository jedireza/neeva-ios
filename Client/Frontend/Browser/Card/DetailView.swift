// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

enum DetailsViewUX {
    static let Padding: CGFloat = 2
    static let ThumbnailCornerRadius: CGFloat = 6
    static let ThumbnailSize: CGFloat = 54
    static let ItemPadding: CGFloat = 14
}

struct DetailView<Details: ThumbnailModel>: View
where
    Details.Thumbnail: CardDetails, Details: CardDetails,
    Details.Thumbnail: AccessingManagerProvider
{
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @Environment(\.onOpenURL) var openURL
    @Environment(\.columns) var gridColumns
    @State private var editMode = EditMode.inactive

    let primitive: Details

    let listColumns = Array(
        repeating:
            GridItem(
                .flexible(),
                spacing: DetailsViewUX.Padding),
        count: 1)

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
            Spacer()
            if gridModel.showingDetailsAsList {
                Button(
                    action: {
                        editMode = .active
                    },
                    label: {
                        Image(
                            systemName: "square.and.pencil"
                        )
                        .foregroundColor(Color.label)
                        .tapTargetFrame()
                    })
            }
            Button(
                action: {
                    withAnimation {
                        gridModel.showingDetailsAsList.toggle()
                    }
                },
                label: {
                    Image(
                        systemName: gridModel.showingDetailsAsList
                            ? "square.grid.2x2.fill" : "rectangle.grid.1x2.fill"
                    )
                    .foregroundColor(Color.label)
                    .tapTargetFrame()
                })
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
                        }.background(Color.background)
                    } else {
                        Section(
                            header: Text(entity.displayTitle)
                                .withFont(.headingSmall)
                                .textCase(.none)
                                .padding(.horizontal)
                                .padding(.top, 14)
                                .padding(.bottom, 10)
                        ) {}
                    }
                }
            }
            .onDelete(perform: onDelete)
            .onMove(perform: onMove)
        }
        .environment(\.editMode, $editMode)
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
        primitive.allDetails.remove(atOffsets: offsets)
    }

    private func onMove(source: IndexSet, destination: Int) {
        primitive.allDetails.move(fromOffsets: source, toOffset: destination)
    }
}

struct SingleDetailView<Details: CardDetails>: View {
    let details: Details
    let onSelected: () -> Void
    var description: String {
        details.id
    }

    var body: some View {
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
        }
        .padding()
    }

}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            primitive: SpaceCardDetails(space: .stackOverflow, bvc: SceneDelegate.getBVC(for: nil)))
    }
}
