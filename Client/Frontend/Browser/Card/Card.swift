// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Shared

enum CardUX {
    static let DefaultCardSize : CGFloat = 160
    static let ShadowRadius : CGFloat = 2
    static let CornerRadius : CGFloat = 5
    static let ButtonSize : CGFloat = 28
    static let FaviconSize : CGFloat = 18
    static let HeaderSize : CGFloat = ButtonSize + 1
}

enum CardConfig {
    case carousel
    case grid
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
        static var defaultValue: (() -> ())? = nil
    }

    public var selectionCompletion: () -> () {
        get { self[SelectionCompletionKey] ?? { fatalError(".environment(\\.selectionCompletion) must be specified") } }
        set { self[SelectionCompletionKey] = newValue }
    }
}

struct FittedCard<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    let config: CardConfig

    @Environment(\.cardSize) private var cardSize

    var body: some View {
        Card(details: details, config: config)
            .frame(width: cardSize, height: cardSize + CardUX.HeaderSize)
    }
}

struct Card<Details>: View where Details: CardDetails {
    @ObservedObject var details: Details
    let config: CardConfig
    var showsSelection = true

    @Environment(\.selectionCompletion) private var selectionCompletion: () -> ()
    @State private var isPressed = false {
        didSet {
            print("**** \(oldValue) -> \(isPressed)")
        }
    }

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
                    if let title = details.title {
                        Text(title).withFont(.labelMedium)
                            .frame(maxWidth: .infinity,
                                   alignment: details.favicon != nil ? .leading : .center)
                            .padding(.trailing, 5).padding(.vertical, 4).lineLimit(1)
                    }
                    if let buttonImage = details.closeButtonImage {
                        Button(action: details.onClose) {
                            Image(uiImage: buttonImage).resizable().renderingMode(.template)
                                .foregroundColor(.secondaryLabel)
                                .padding(4)
                                .frame(width: CardUX.FaviconSize, height: CardUX.FaviconSize)
                                .padding(5)
                        }
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
                        .frame(width: geom.size.width, height: geom.size.height - CardUX.HeaderSize)
                        .clipped()
                }.buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
            }
        }
        .cornerRadius(CardUX.CornerRadius)
        .modifier(BorderTreatment(isSelected: showsSelection && details.isSelected))
        .onDrop(of: ["public.url", "public.text"], delegate: details)
        .scaleEffect(isPressed ? 0.95 : 1)
    }
}

