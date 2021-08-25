// Copyright Neeva. All rights reserved.

import SwiftUI

struct CompactCardContent<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    @State var inHoverMode = true

    var body: some View {
        CompactCard(details: details, inHoverMode: false)
            .onHover { isHover in
                withAnimation {
                    inHoverMode = isHover
                }
            }
            .padding()
    }
}

/// A card that only shows title/favicon unless hovered
struct CompactCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    @State private var isPressed = false

    /// Whether — if this card is selected — the blue border should be drawn
    var showsSelection = true
    var inHoverMode = true

    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void

    var body: some View {
        Button {
            details.onSelect()
            selectionCompletion()
        } label: {
            VStack {
                if inHoverMode {
                    GeometryReader { geom in
                        details.thumbnail
                            .frame(
                                width: max(0, geom.size.width),
                                height: max(
                                    0,
                                    geom.size.height
                                        - (details.thumbnailDrawsHeader ? 0 : CardUX.HeaderSize)),
                                alignment: .top
                            )
                            .clipped()
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
            	.background(Color.background)
            }
        }
        .accessibilityLabel(details.accessibilityLabel)
        .modifier(ActionsModifier(close: details.closeButtonImage == nil ? nil : details.onClose))
        .accessibilityAddTraits(.isButton)
        .cornerRadius(CardUX.CornerRadius)
        .modifier(
            BorderTreatment(
                isSelected: showsSelection && details.isSelected,
                thumbnailDrawsHeader: details.thumbnailDrawsHeader)
        )
        .onDrop(of: ["public.url", "public.text"], delegate: details)
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
                    },
                    alignment: .topTrailing
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1)
        .padding(.bottom)
    }
}
