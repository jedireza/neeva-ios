// Copyright Neeva. All rights reserved.

import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum CardUX {
    static let DefaultCardSize: CGFloat = 160
    static let ShadowRadius: CGFloat = 2
    static let CornerRadius: CGFloat = 12
    static let ButtonSize: CGFloat = 28
    static let FaviconSize: CGFloat = 18
    static let HeaderSize: CGFloat = ButtonSize + 1
    static let CardHeight: CGFloat = 174
}

private struct BorderTreatment: ViewModifier {
    let isSelected: Bool
    let thumbnailDrawsHeader: Bool

    func body(content: Content) -> some View {
        content
            .shadow(radius: thumbnailDrawsHeader ? 0 : CardUX.ShadowRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CardUX.CornerRadius)
                    .stroke(isSelected ? Color.ui.adaptive.blue : Color.clear, lineWidth: 3)
            )
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct DragToCloseInteraction: ViewModifier {
    let action: () -> Void
    @State private var hasExceededThreshold = false

    @Environment(\.cardSize) private var cardSize
    @State private var offset = CGFloat.zero

    private var dragToCloseThreshold: CGFloat {
        // Using `cardSize` here helps this scale properly with different card sizes,
        // across portrait and landscape modes.
        cardSize * 0.6
    }

    private var progress: CGFloat {
        abs(offset) / (dragToCloseThreshold * 1.5)
    }
    private var angle: Angle {
        .radians(Double(progress * (.pi / 10)).withSign(offset.sign))
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(1 - (progress / 5))
            .rotation3DEffect(angle, axis: (x: 0.0, y: 1.0, z: 0.0))
            .offset(x: offset)
            .opacity(Double(1 - progress))
            .highPriorityGesture(
                DragGesture()
                    .onChanged { value in
                        // Workaround for SwiftUI gestures and UIScrollView not playing well
                        // together. See issue #1378 for details. Only apply an offset if the
                        // translation is mostly in the horizontal direction to avoid translating
                        // the card when the UIScrollView is scrolling.
                        if offset != 0
                            || abs(value.translation.width) > abs(value.translation.height)
                        {
                            offset = value.translation.width
                            if abs(offset) > dragToCloseThreshold {
                                if !hasExceededThreshold {
                                    hasExceededThreshold = true
                                    Haptics.swipeGesture()
                                }
                            } else {
                                hasExceededThreshold = false
                            }
                        }
                    }
                    .onEnded { value in
                        let finalOffset = value.translation.width
                        withAnimation(.interactiveSpring()) {
                            if abs(finalOffset) > dragToCloseThreshold {
                                offset = finalOffset
                                action()

                                // work around reopening tabs causing the state to not be reset
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500))
                                {
                                    offset = 0
                                }
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
    }
}

extension EnvironmentValues {
    private struct CardSizeKey: EnvironmentKey {
        static var defaultValue: CGFloat = CardUX.DefaultCardSize
    }

    public var cardSize: CGFloat {
        get { self[CardSizeKey] }
        set { self[CardSizeKey] = newValue }
    }

    private struct SelectionCompletionKey: EnvironmentKey {
        static var defaultValue: () -> Void = {}
    }
    public var selectionCompletion: () -> Void {
        get { self[SelectionCompletionKey] }
        set { self[SelectionCompletionKey] = newValue }
    }
}

/// A card that constrains itself to the default height and provided width.
struct FittedCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details

    @Environment(\.cardSize) private var cardSize

    var body: some View {
        Card(details: details)
            .frame(width: cardSize, height: cardSize + CardUX.HeaderSize)
    }
}

/// A flexible card that takes up as much space as it is allotted.
struct Card<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    /// Whether — if this card is selected — the blue border should be drawn
    var showsSelection = true

    @Environment(\.selectionCompletion) private var selectionCompletion: () -> Void
    @State private var isPressed = false

    var body: some View {
        GeometryReader { geom in
            VStack(alignment: .center, spacing: 0) {
                if !details.thumbnailDrawsHeader {
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
                    .frame(height: CardUX.ButtonSize)
                    .background(Color.DefaultBackground)

                    Color.ui.adaptive.separator.frame(height: 1)
                }
                Button(action: {
                    details.onSelect()
                    selectionCompletion()
                }) {
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
                }.buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
            }
        }
        .accessibilityElement(children: .ignore)
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
                .modifier(DragToCloseInteraction(action: details.onClose))
        }
        .scaleEffect(isPressed ? 0.95 : 1)
    }

    private struct ActionsModifier: ViewModifier {
        let close: (() -> Void)?

        func body(content: Content) -> some View {
            if let close = close {
                content.accessibilityAction(named: "Close", close)
            } else {
                content
            }
        }
    }
}
