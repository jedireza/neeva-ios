// Copyright Neeva. All rights reserved.

import SwiftUI

struct CompactCardContent<Details>: View where Details: CardDetails {
    @EnvironmentObject var cardStripModel: CardStripModel
    @ObservedObject var details: Details

    var isHover = false
    var alwaysShowThumbnail: Bool

    var body: some View {
        CompactCard(details: details, showThumbnail: isHover || alwaysShowThumbnail)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { gesture in
                        print(gesture.translation.width)
                        cardStripModel.selectTabForDrag(distance: gesture.translation.width)
                    }
            )
            .padding()
    }
}

/// A card that only shows title/favicon unless hovered
struct CompactCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    @State private var isPressed = false

    /// Whether — if this card is selected — the blue border should be drawn
    var showsSelection = true
    var showThumbnail = true

    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    var body: some View {
        Button {
            details.onSelect()
            selectionCompletion()
        } label: {
            VStack {
                if showThumbnail {
                    GeometryReader { geom in
                        details.thumbnail
                            .frame(
                                width: max(0, geom.size.width),
                                height: CardUX.CompactCardThumbnailHeight
                            )
                            .clipped()
                            .cornerRadius(CardUX.CornerRadius)
                            .modifier(
                                BorderTreatment(
                                    isSelected: showsSelection && details.isSelected,
                                    thumbnailDrawsHeader: details.thumbnailDrawsHeader)
                            )
                    }
                }

            	HStack(spacing: 0) {
            	    if let favicon = details.favicon {
            	        favicon
            	            .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
            	            .cornerRadius(CardUX.CornerRadius)
            	            .padding(5)
            	    }
            	    Text(details.title).withFont(.labelMedium)
            	        .frame(maxWidth: .infinity, alignment: .leading)
            	        .padding(.trailing, 5).padding(.vertical, 4).lineLimit(1)
            	    if details.closeButtonImage != nil {
            	        Color.clear
            	            .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
            	            .padding(5)
            	    }
            	}
            	.padding()
                .frame(height: CardUX.CompactCardHeight)
                .background(Color.background.cornerRadius(CardUX.CornerRadius))
                .modifier(
                    BorderTreatment(
                        isSelected: showsSelection && details.isSelected,
                        thumbnailDrawsHeader: details.thumbnailDrawsHeader)
                )
                .if(let: details.closeButtonImage) { buttonImage, view in
                    view
                        .overlay(
                            Button(action: details.onClose) {
                                Image(uiImage: buttonImage).resizable().renderingMode(.template)
                                    .foregroundColor(.secondaryLabel)
                                    .padding(4)
                                    .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                                    .padding(5)
                                    .accessibilityLabel("Close \(details.title)")
                                    .padding(.trailing, 4)
                            },
                            alignment: .trailing
                        )
                }
            }
        }
        .accessibilityLabel(details.accessibilityLabel)
        .modifier(ActionsModifier(close: details.closeButtonImage == nil ? nil : details.onClose))
        .accessibilityAddTraits(.isButton)
        .onDrop(of: ["public.url", "public.text"], delegate: details)
        .scaleEffect(isPressed ? 0.95 : 1)
        .padding(.bottom)
        .frame(minWidth: showThumbnail ? 200 : 0, maxWidth: 350)
        .transition(.fade)
    }
}
