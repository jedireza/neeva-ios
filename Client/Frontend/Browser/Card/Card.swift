// Copyright Neeva. All rights reserved.

import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum CardUX {
    static let DefaultCardSize: CGFloat = 160
    static let ShadowRadius: CGFloat = 2
    static let CornerRadius: CGFloat = 5
    static let ButtonSize: CGFloat = 28
    static let FaviconSize: CGFloat = 18
    static let HeaderSize: CGFloat = ButtonSize + 1
    static let CardHeight: CGFloat = 174
}

private struct BorderTreatment: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .shadow(radius: CardUX.ShadowRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CardUX.CornerRadius)
                    .stroke(isSelected ? Color.ui.adaptive.blue : Color.clear, lineWidth: 3)
            )
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct DragToCloseInteraction: ViewModifier {
    let action: () -> Void

    private let threshold: CGFloat = 80

    @State private var offset = CGFloat.zero

    private var progress: CGFloat {
        abs(offset) / (threshold * 1.5)
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
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        let target = value.predictedEndTranslation.width
                        withAnimation(.interactiveSpring()) {
                            if abs(target) > threshold {
                                offset = target
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
        static var defaultValue: (() -> Void)? = nil
    }
    public var selectionCompletion: () -> Void {
        get {
            self[SelectionCompletionKey] ?? {
                fatalError(".environment(\\.selectionCompletion) must be specified")
            }
        }
        set { self[SelectionCompletionKey] = newValue }
    }
}

/// A card that constrains itself to the default height and provided width.
struct FittedCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details

    @Environment(\.cardSize) private var cardSize

    var body: some View {
        Card(details: details)
            .frame(width: cardSize, height: CardUX.CardHeight)
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
                HStack(spacing: 0) {
                    if let favicon = details.favicon {
                        favicon.resizable()
                            .transition(.fade(duration: 0.5)).background(Color.white)
                            .scaledToFit()
                            .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                            .cornerRadius(CardUX.CornerRadius)
                            .padding(5)
                    }
                    Text(details.title).withFont(.labelMedium)
                        .frame(
                            maxWidth: .infinity,
                            alignment: details.favicon != nil ? .leading : .center
                        )
                        .padding(.trailing, 5).padding(.vertical, 4).lineLimit(1)
                    if details.closeButtonImage != nil {
                        Color.clear
                            .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                            .padding(5)
                    }
                }
                .frame(height: CardUX.ButtonSize)
                .background(Color.DefaultBackground)

                Color(UIColor.Browser.urlBarDivider).frame(height: 1)

                Button(action: {
                    details.onSelect()
                    selectionCompletion()
                }) {
                    details.thumbnail
                        .frame(
                            width: max(0, geom.size.width),
                            height: max(0, geom.size.height - CardUX.HeaderSize),
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
        .modifier(BorderTreatment(isSelected: showsSelection && details.isSelected))
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
