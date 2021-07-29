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

struct BorderTreatment: ViewModifier {
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

struct FittedCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details

    @Environment(\.cardSize) private var cardSize

    var body: some View {
        Card(details: details)
            .frame(width: cardSize, height: CardUX.CardHeight)
    }
}

struct Card<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
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
                            width: geom.size.width, height: geom.size.height - CardUX.HeaderSize,
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
        .scaleEffect(isPressed ? 0.95 : 1)
        .overlay(
            Group {
                if let buttonImage = details.closeButtonImage {
                    Button(action: details.onClose) {
                        Image(uiImage: buttonImage).resizable().renderingMode(.template)
                            .foregroundColor(.secondaryLabel)
                            .padding(4)
                            .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                            .padding(5)
                            .accessibilityLabel("Close \(details.title)")
                    }
                }
            }, alignment: .topTrailing)
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
