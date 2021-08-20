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

    let primitive: Details

    let listColumns = Array(
        repeating:
            GridItem(
                .flexible(),
                spacing: DetailsViewUX.Padding),
        count: 1)

    var body: some View {
        VStack(spacing: 0) {
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
                .background(Color.background)
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(
                    columns: gridModel.showingDetailsAsList ? listColumns : gridColumns,
                    spacing: DetailsViewUX.Padding
                ) {
                    ForEach(primitive.allDetails, id: \.id) { details in
                        if gridModel.showingDetailsAsList {
                            SingleDetailView(details: details) {
                                openURL((details.manager.get(for: details.id)?.primitiveUrl)!)
                                gridModel.hideWithNoAnimation()
                                spacesModel.detailedSpace = nil
                            }
                        } else {
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
                    }
                    Spacer()
                }
                .padding(.vertical, DetailsViewUX.Padding)
            }
        }
    }
}

struct SingleDetailView<Details: CardDetails>: View {
    let details: Details
    let onSelected: () -> Void
    @State private var isPressed = false
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
            .padding(DetailsViewUX.ItemPadding)
            .background(Color.background)
            .scaleEffect(isPressed ? 0.95 : 1)
        }.buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            primitive: SpaceCardDetails(space: .stackOverflow, bvc: SceneDelegate.getBVC(for: nil)))
    }
}
