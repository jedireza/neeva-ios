// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

enum DetailsViewUX {
    static let Padding: CGFloat = 10
    static let DetailsCornerRadius: CGFloat = 12
    static let ThumbnailCornerRadius: CGFloat = 8
    static let ThumbnailSize: CGFloat = 54
    static let ItemPadding: CGFloat = 12
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
                    action: { spacesModel.detailedSpace = nil },
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
                    action: { gridModel.showingDetailsAsList.toggle() },
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
                LazyVGrid(columns: gridModel.showingDetailsAsList ? listColumns : gridColumns) {
                    ForEach(primitive.allDetails, id: \.id) { details in
                        if gridModel.showingDetailsAsList {
                            SingleDetailView(details: details)
                                .onTapGesture {
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
                .padding(DetailsViewUX.Padding)
            }
        }
    }
}

struct SingleDetailView<Details: CardDetails>: View {
    let details: Details
    var body: some View {
        HStack(spacing: DetailsViewUX.ItemPadding) {
            details.thumbnail.frame(
                width: DetailsViewUX.ThumbnailSize, height: DetailsViewUX.ThumbnailSize
            )
            .cornerRadius(DetailsViewUX.ThumbnailCornerRadius)
            Text(details.title)
                .withFont(.bodyMedium)
                .lineLimit(2)
                .foregroundColor(Color.label)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DetailsViewUX.ItemPadding)
        .background(Color.background)
        .cornerRadius(DetailsViewUX.DetailsCornerRadius)
    }

}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(primitive: SpaceCardDetails(space: .stackOverflow))
    }
}
